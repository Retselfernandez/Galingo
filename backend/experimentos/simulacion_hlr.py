#!/usr/bin/env python3
"""
Validación metodológica de HLR frente a SM-2 mediante SIMULACIÓN con verdad
conocida y secuencias POR ÍTEM (para un baseline SM-2 justo).

Diferencias clave frente a los logs reales de Anki/FSRS:
  - Intervalos asignados de forma ALEATORIA (elimina o sesgo de programación
    adaptativa, que invalida a comparación sobre planificadores óptimos).
  - Cada ítem ten unha secuencia de repasos -> SM-2 mantén estado real.

Métricas apropiadas para recuerdo binario: AUC-ROC, Brier score e calibración
(a MAE sobre saídas binarias está dominada pola taxa base).

Uso:  python3 backend/experimentos/simulacion_hlr.py
"""
import json, os, math
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from scipy.optimize import minimize
from sklearn.metrics import roc_auc_score, roc_curve

HERE = os.path.dirname(os.path.abspath(__file__))
FIGS = os.path.join(HERE, 'figuras'); os.makedirs(FIGS, exist_ok=True)
LN2 = math.log(2)
RNG = np.random.default_rng(7)
THETA_TRUE = np.array([0.5, 0.35, -0.45, -0.25])

def feats(s, f, d):
    return np.column_stack([np.ones_like(s), np.sqrt(1.0+s), np.sqrt(1.0+f), d])

def hl(th, X): return np.power(2.0, np.clip(X@th, -10, 15))
def rc(h, t):  return np.power(2.0, np.clip(-t/(h+1e-9), -20, 0))

def simulate(n_users=400, items_per_user=40, max_reviews=25):
    """Xera secuencias por ítem con intervalos aleatorios."""
    S, F, D, T, P, U, I = [], [], [], [], [], [], []
    for u in range(n_users):
        for it in range(items_per_user):
            s = f = 0; item_id = u*items_per_user + it
            d = RNG.uniform(0.1, 1.0)
            for _ in range(RNG.integers(3, max_reviews)):
                t = float(RNG.uniform(0.3, 40.0))          # intervalo ALEATORIO
                h = float(hl(THETA_TRUE, np.array([[1.0, math.sqrt(1+s), math.sqrt(1+f), d]]))[0])
                p_true = float(rc(np.array([h]), np.array([t]))[0])
                p = 1.0 if RNG.uniform() < p_true else 0.0
                S.append(s); F.append(f); D.append(d); T.append(t); P.append(p)
                U.append(u); I.append(item_id)
                if p == 1.0: s += 1
                else: f += 1
    return (np.array(S), np.array(F), np.array(D), np.array(T), np.array(P),
            np.array(U), np.array(I))

def train_hlr(X, t, p):
    def loss(th):
        h = hl(th, X); ph = rc(h, t)
        po = np.where(p == 1, 0.95, 0.05); ho = np.clip(-t/(np.log(po)/LN2), 0.1, 10.0)
        return np.mean((p-ph)**2) + 0.05*np.mean((ho-h)**2) + 0.01*np.sum(th**2)
    r = minimize(loss, np.zeros(4), method='Nelder-Mead',
                 options={'maxiter': 6000, 'xatol': 1e-4, 'fatol': 1e-7})
    return r.x

def sm2_predict(t_arr, p_arr, item_arr):
    """SM-2 con estado por ítem; devolve p̂ antes de cada actualización."""
    ph = np.zeros(len(p_arr))
    state = {}
    for k in range(len(p_arr)):
        iid = item_arr[k]; t = t_arr[k]
        rep, ef, interval = state.get(iid, (0, 2.5, 1.0))
        ph[k] = 2.0 ** (-t / max(interval, 1e-9))
        q = 4 if p_arr[k] == 1.0 else 1
        if q >= 3:
            interval = 1.0 if rep == 0 else (6.0 if rep == 1 else round(interval*ef))
            rep += 1
        else:
            rep, interval = 0, 1.0
        ef = max(1.3, ef + (0.1 - (5-q)*(0.08 + (5-q)*0.02)))
        state[iid] = (rep, ef, interval)
    return ph

def brier(p, ph): return float(np.mean((p-ph)**2))
def calib(p, ph, bins=10):
    e = np.linspace(0, 1, bins+1); xs=[]; ys=[]
    for lo, hi in zip(e[:-1], e[1:]):
        m = (ph>=lo)&(ph<hi) if hi < 1 else (ph>=lo)&(ph<=hi)
        if m.sum() > 0: xs.append(float(ph[m].mean())); ys.append(float(p[m].mean()))
    return xs, ys

def main():
    S,F,D,T,P,U,I = simulate()
    print(f'Eventos: {len(P):,} | usuarios: {U.max()+1} | ítems: {I.max()+1}')
    users = np.unique(U); cut = int(0.8*len(users))
    tr = np.isin(U, users[:cut]); te = ~tr

    X = feats(S,F,D)
    theta = train_hlr(X[tr], T[tr], P[tr])
    print('theta real :', np.round(THETA_TRUE,3).tolist())
    print('theta est. :', np.round(theta,3).tolist())

    p_hlr = rc(hl(theta, X[te]), T[te])
    p_sm2 = sm2_predict(T[te], P[te], I[te])

    res = {
        'n_eventos': int(len(P)), 'n_usuarios': int(U.max()+1),
        'theta_true': THETA_TRUE.tolist(), 'theta_est': [float(x) for x in theta],
        'HLR': {'AUC': float(roc_auc_score(P[te], p_hlr)), 'Brier': brier(P[te], p_hlr),
                'MAE': float(np.mean(np.abs(P[te]-p_hlr)))},
        'SM2': {'AUC': float(roc_auc_score(P[te], p_sm2)), 'Brier': brier(P[te], p_sm2),
                'MAE': float(np.mean(np.abs(P[te]-p_sm2)))},
    }
    res['mejora_Brier_%'] = 100*(res['SM2']['Brier']-res['HLR']['Brier'])/res['SM2']['Brier']
    print(json.dumps(res, indent=2, ensure_ascii=False))
    json.dump(res, open(os.path.join(HERE,'resultados_simulacion.json'),'w'), indent=2, ensure_ascii=False)

    # Figuras
    fig,ax=plt.subplots(figsize=(6,4)); x=np.arange(2); w=0.35
    ax.bar(x-w/2,[res['HLR']['Brier'],res['HLR']['MAE']],w,label='HLR',color='#2b6cb0')
    ax.bar(x+w/2,[res['SM2']['Brier'],res['SM2']['MAE']],w,label='SM-2',color='#dd6b20')
    ax.set_xticks(x); ax.set_xticklabels(['Brier','MAE']); ax.set_ylabel('Error')
    ax.set_title('Simulación: erro de predición (menor = mellor)'); ax.legend()
    fig.tight_layout(); fig.savefig(os.path.join(FIGS,'sim_error.png'),dpi=150); plt.close(fig)

    fig,ax=plt.subplots(figsize=(5,5))
    for ph,nm,c in [(p_hlr,f"HLR (AUC={res['HLR']['AUC']:.3f})",'#2b6cb0'),
                    (p_sm2,f"SM-2 (AUC={res['SM2']['AUC']:.3f})",'#dd6b20')]:
        fpr,tpr,_=roc_curve(P[te],ph); ax.plot(fpr,tpr,label=nm,color=c)
    ax.plot([0,1],[0,1],'--',color='grey',lw=1); ax.set_xlabel('Falsos positivos')
    ax.set_ylabel('Verdadeiros positivos'); ax.set_title('Simulación: curva ROC'); ax.legend()
    fig.tight_layout(); fig.savefig(os.path.join(FIGS,'sim_roc.png'),dpi=150); plt.close(fig)

    fig,ax=plt.subplots(figsize=(5,5))
    for ph,nm,c in [(p_hlr,'HLR','#2b6cb0'),(p_sm2,'SM-2','#dd6b20')]:
        xs,ys=calib(P[te],ph); ax.plot(xs,ys,'o-',label=nm,color=c)
    ax.plot([0,1],[0,1],'--',color='grey',lw=1); ax.set_xlabel('Probabilidade predita')
    ax.set_ylabel('Frecuencia observada'); ax.set_title('Simulación: calibración'); ax.legend()
    fig.tight_layout(); fig.savefig(os.path.join(FIGS,'sim_calibracion.png'),dpi=150); plt.close(fig)
    print('Figuras en', FIGS)

if __name__ == '__main__':
    main()

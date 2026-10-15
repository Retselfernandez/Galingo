#!/usr/bin/env python3
"""
Validación experimental de HLR frente a SM-2 sobre datos REALES de repetición
espaciada (dataset FSRS / Anki revlogs, licencia MIT, sin relación con ninguna
plataforma comercial de idiomas).

Construye eventos (s, f, t, p) por tarjeta y evalúa:
  - HLR  (implementación equivalente a la del cliente Dart / backend)
  - SM-2 (línea base determinista, idéntica a lib/core/ml/sm2_engine.dart)

Métricas: MAE, RMSE, AUC-ROC y curva de calibración. Genera figuras para la
memoria (§9 Evaluación experimental).

Uso:
  python3 backend/experimentos/hlr_vs_sm2_fsrs.py
"""
import glob, json, os, math
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from sklearn.metrics import roc_auc_score, roc_curve

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, 'fsrs', '*.tsv')
FIGS = os.path.join(HERE, 'figuras')
os.makedirs(FIGS, exist_ok=True)

LN2 = math.log(2)

# ── 1. Carga y construcción de eventos ───────────────────────────────────────
def load_events():
    files = sorted(glob.glob(DATA))
    if not files:
        raise SystemExit('Non hai ficheiros .tsv en ' + DATA)
    rows = []
    for fi, path in enumerate(files):
        df = pd.read_csv(path, sep='\t')
        df = df.dropna(subset=['delta_t', 'y', 'card_id'])
        df['card_id'] = df['card_id'].astype(str)
        df['delta_t'] = df['delta_t'].astype(float)
        df['y'] = df['y'].astype(int)
        df = df.sort_values(['card_id', 'i'])
        # s = aciertos previos, f = fallos previos (acumulados por tarxeta)
        s_prev = df.groupby('card_id')['y'].cumsum() - df['y']
        tot_prev = df.groupby('card_id').cumcount()
        f_prev = tot_prev - s_prev
        df['s'] = s_prev.astype(int)
        df['f'] = f_prev.astype(int)
        df['user'] = fi
        rows.append(df[['user', 'card_id', 's', 'f', 'delta_t', 'y']])
    ev = pd.concat(rows, ignore_index=True)
    ev = ev[ev['delta_t'] >= 0].copy()
    ev['t'] = ev['delta_t'].clip(lower=0.001)
    ev['d'] = 0.5  # dificultade constante (o dataset non a fornece)
    ev['p'] = ev['y'].astype(float)
    return ev

# ── 2. HLR (idéntico á formulación do cliente) ───────────────────────────────
def hlr_features(s, f, d):
    return np.column_stack([np.ones_like(s), np.sqrt(1.0 + s), np.sqrt(1.0 + f), d])

def hlr_half_life(theta, X):
    power = np.clip(X @ theta, -10.0, 15.0)
    return np.power(2.0, power)

def hlr_recall(h, t):
    return np.power(2.0, np.clip(-t / (h + 1e-9), -20.0, 0.0))

def train_hlr(X, t, p, epochs=40, lr=0.01, lam=0.01, alpha=0.05):
    theta = np.array([0.5, 0.35, -0.45, -0.25])
    n = len(p)
    for _ in range(epochs):
        h = hlr_half_life(theta, X)
        ph = hlr_recall(h, t)
        p_obs = np.where(p == 1.0, 0.95, 0.05)
        h_obs = np.clip(-t / (np.log(p_obs) / LN2), 0.1, 10.0)
        dp = ph * (LN2 ** 2) * (t / (h + 1e-3))
        dh = h * LN2
        g = np.zeros(4)
        for j in range(4):
            gp = -2.0 * (p - ph) * dp * X[:, j]
            gh = -2.0 * alpha * (h_obs - h) * dh * X[:, j]
            g[j] = np.mean(np.clip(gp + gh, -5.0, 5.0))
        g = np.clip(g, -1.5, 1.5) + lam * theta
        theta -= lr * g
        theta = np.clip(theta, -5.0, 5.0)
    return theta

# ── 3. SM-2 (idéntico a sm2_engine.dart) ─────────────────────────────────────
def sm2_predict(df):
    """Devolve p̂ de SM-2 por fila (antes de actualizar), procesando por tarxeta."""
    ph = np.zeros(len(df))
    idx = np.zeros(len(df), dtype=int)
    for card, sub in df.groupby('card_id', sort=False):
        rep, ef, interval = 0, 2.5, 1
        for pos, (i, r) in enumerate(zip(sub.index, sub['p'])):
            t = sub.loc[i, 't']
            ph[i] = 2.0 ** (-t / max(interval, 1e-9))
            q = 4 if r == 1.0 else 1
            if q >= 3:
                interval = 1 if rep == 0 else (6 if rep == 1 else round(interval * ef))
                rep += 1
            else:
                rep, interval = 0, 1
            ef = max(1.3, ef + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)))
    return ph

# ── 4. Métricas ──────────────────────────────────────────────────────────────
def metrics(p, ph):
    mae = float(np.mean(np.abs(p - ph)))
    rmse = float(np.sqrt(np.mean((p - ph) ** 2)))
    try:
        auc = float(roc_auc_score(p, ph)) if len(set(p)) > 1 else float('nan')
    except Exception:
        auc = float('nan')
    return mae, rmse, auc

def calibration(p, ph, bins=10):
    edges = np.linspace(0, 1, bins + 1)
    xs, ys = [], []
    for lo, hi in zip(edges[:-1], edges[1:]):
        m = (ph >= lo) & (ph < hi) if hi < 1 else (ph >= lo) & (ph <= hi)
        if m.sum() > 0:
            xs.append(float(ph[m].mean()))
            ys.append(float(p[m].mean()))
    return xs, ys

# ── 5. Experimento ───────────────────────────────────────────────────────────
def main():
    ev = load_events()
    print(f'Eventos totais: {len(ev):,} | usuarios: {ev.user.nunique()} | tarxetas: {ev.card_id.nunique():,}')

    # Partición por usuario (evita filtración): 80/20
    users = sorted(ev.user.unique())
    cut = max(1, int(0.8 * len(users)))
    tr = ev[ev.user.isin(users[:cut])].reset_index(drop=True)
    te = ev[ev.user.isin(users[cut:])].reset_index(drop=True)
    if len(te) == 0:  # fallback: partición por tarxeta
        cards = ev.card_id.unique(); cutc = int(0.8 * len(cards))
        tr = ev[ev.card_id.isin(cards[:cutc])].reset_index(drop=True)
        te = ev[ev.card_id.isin(cards[cutc:])].reset_index(drop=True)
    print(f'Treino: {len(tr):,} | Teste: {len(te):,}')

    Xtr = hlr_features(tr.s.values, tr.f.values, tr.d.values)
    theta = train_hlr(Xtr, tr.t.values, tr.p.values)
    print('theta HLR =', np.round(theta, 4).tolist())

    Xte = hlr_features(te.s.values, te.f.values, te.d.values)
    h_hlr = hlr_half_life(theta, Xte)
    p_hlr = hlr_recall(h_hlr, te.t.values)
    p_sm2 = sm2_predict(te)

    mae_h, rmse_h, auc_h = metrics(te.p.values, p_hlr)
    mae_s, rmse_s, auc_s = metrics(te.p.values, p_sm2)
    mejora = 100 * (mae_s - mae_h) / mae_s if mae_s > 0 else 0

    res = {
        'eventos': int(len(ev)), 'usuarios': int(ev.user.nunique()),
        'theta': [float(x) for x in theta],
        'HLR': {'MAE': mae_h, 'RMSE': rmse_h, 'AUC': auc_h},
        'SM2': {'MAE': mae_s, 'RMSE': rmse_s, 'AUC': auc_s},
        'mejora_MAE_%': mejora,
    }
    print(json.dumps(res, indent=2, ensure_ascii=False))
    json.dump(res, open(os.path.join(HERE, 'resultados.json'), 'w'), indent=2, ensure_ascii=False)

    # ── Figuras ──
    # 1) MAE / RMSE
    fig, ax = plt.subplots(figsize=(6, 4))
    x = np.arange(2); w = 0.35
    ax.bar(x - w/2, [mae_h, rmse_h], w, label='HLR', color='#2b6cb0')
    ax.bar(x + w/2, [mae_s, rmse_s], w, label='SM-2', color='#dd6b20')
    ax.set_xticks(x); ax.set_xticklabels(['MAE', 'RMSE'])
    ax.set_ylabel('Error'); ax.set_title('Error de predicción (menor = mellor)')
    ax.legend(); fig.tight_layout(); fig.savefig(os.path.join(FIGS, 'fig_mae_rmse.png'), dpi=150); plt.close(fig)

    # 2) ROC
    fig, ax = plt.subplots(figsize=(5, 5))
    for ph, name, c in [(p_hlr, f'HLR (AUC={auc_h:.3f})', '#2b6cb0'), (p_sm2, f'SM-2 (AUC={auc_s:.3f})', '#dd6b20')]:
        fpr, tpr, _ = roc_curve(te.p.values, ph)
        ax.plot(fpr, tpr, label=name, color=c)
    ax.plot([0, 1], [0, 1], '--', color='grey', lw=1)
    ax.set_xlabel('Falsos positivos'); ax.set_ylabel('Verdadeiros positivos')
    ax.set_title('Curva ROC'); ax.legend(); fig.tight_layout()
    fig.savefig(os.path.join(FIGS, 'fig_roc.png'), dpi=150); plt.close(fig)

    # 3) Calibración
    fig, ax = plt.subplots(figsize=(5, 5))
    for ph, name, c in [(p_hlr, 'HLR', '#2b6cb0'), (p_sm2, 'SM-2', '#dd6b20')]:
        xs, ys = calibration(te.p.values, ph)
        ax.plot(xs, ys, 'o-', label=name, color=c)
    ax.plot([0, 1], [0, 1], '--', color='grey', lw=1)
    ax.set_xlabel('Probabilidade predita'); ax.set_ylabel('Frecuencia observada')
    ax.set_title('Curva de calibración'); ax.legend(); fig.tight_layout()
    fig.savefig(os.path.join(FIGS, 'fig_calibracion.png'), dpi=150); plt.close(fig)

    # 4) Curva de retención observada vs predita
    fig, ax = plt.subplots(figsize=(6, 4))
    te2 = te.copy(); te2['ph'] = p_hlr
    te2['bin'] = pd.cut(te2.t, bins=[0, 1, 3, 7, 14, 30, 90, 1e9])
    g = te2.groupby('bin', observed=True).agg(obs=('p', 'mean'), pred=('ph', 'mean'), n=('p', 'size'))
    xlab = [f'{int(b.left)}-{int(min(b.right, 999))}d' for b in g.index]
    ax.plot(xlab, g.obs, 'o-', label='Observado', color='#2f855a')
    ax.plot(xlab, g.pred, 's--', label='HLR predito', color='#2b6cb0')
    ax.set_xlabel('Intervalo desde o último repaso (días)'); ax.set_ylabel('Probabilidade de recordo')
    ax.set_title('Curva de olvido'); ax.legend(); fig.tight_layout()
    fig.savefig(os.path.join(FIGS, 'fig_retencion.png'), dpi=150); plt.close(fig)

    print('Figuras en', FIGS)

if __name__ == '__main__':
    main()

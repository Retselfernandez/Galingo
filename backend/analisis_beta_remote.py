"""Análisis de la beta desde el backend desplegado.

Uso:
    python analisis_beta_remote.py [URL_BACKEND]

Descarga /api/v1/export y calcula:
  - usuarios, retención D1/D7, sesiones, eventos y feedback
  - HLR (si >= 20 eventos): MAE y AUC-ROC con regresión logística
"""
import datetime
import json
import os
import sys
import urllib.request
from collections import defaultdict

URL = sys.argv[1] if len(sys.argv) > 1 else "https://galingo-backend.onrender.com"
TOKEN = os.environ.get("EXPORT_TOKEN", "")


def fetch(url):
    req = urllib.request.Request(
        f"{url}/api/v1/export", headers={"X-Admin-Token": TOKEN})
    with urllib.request.urlopen(req, timeout=180) as r:
        return json.load(r)


def main():
    data = fetch(URL)
    eventos = data.get("eventos", [])
    sesiones = data.get("sesiones", [])
    feedback = data.get("feedback", [])

    por_usuario = defaultdict(set)
    for s in sesiones:
        por_usuario[s["user_id"]].add(s["fecha"])
    usuarios = len(por_usuario)
    # Retención honesta: volveu o día seguinte / á semana seguinte
    # do seu primeiro día de uso (non "ten máis dun día").
    d1 = 0
    d7 = 0
    for fechas in por_usuario.values():
        dias = {datetime.date.fromisoformat(f) for f in fechas}
        primeiro = min(dias)
        if primeiro + datetime.timedelta(days=1) in dias:
            d1 += 1
        if primeiro + datetime.timedelta(days=7) in dias:
            d7 += 1

    print(json.dumps({
        "usuarios_beta": usuarios,
        "retencion_dia1_pct": round(d1 / usuarios * 100, 1) if usuarios else 0,
        "retencion_dia7_pct": round(d7 / usuarios * 100, 1) if usuarios else 0,
        "sesiones_totales": len(sesiones),
        "eventos_totales": len(eventos),
        "reportes_totales": len(feedback),
    }, indent=2, ensure_ascii=False))

    if len(eventos) >= 20:
        try:
            import numpy as np
            from sklearn.linear_model import LogisticRegression
            from sklearn.metrics import mean_absolute_error, roc_auc_score
            from sklearn.model_selection import train_test_split

            X = np.array([
                [np.sqrt(1 + e["aciertos"]), np.sqrt(1 + e["fallos"]),
                 e["dificultad"], -np.log(max(e["intervalo_dias"] or 1.0, 0.01))]
                for e in eventos
            ])
            y = np.array([1 if (e["resultado"] or 0) >= 0.5 else 0 for e in eventos])
            Xtr, Xte, ytr, yte = train_test_split(
                X, y, test_size=0.2, stratify=y, random_state=42)
            clf = LogisticRegression(C=1.0, max_iter=1000).fit(Xtr, ytr)
            p = clf.predict_proba(Xte)[:, 1]
            print(json.dumps({
                "hlr_n": len(eventos),
                "hlr_mae": round(mean_absolute_error(yte, p), 4),
                "hlr_auc_roc": round(roc_auc_score(yte, p), 4),
                "hlr_coef": clf.coef_.tolist(),
                "hlr_intercept": clf.intercept_.tolist(),
            }, indent=2))
        except Exception as ex:  # noqa: BLE001
            print(json.dumps({"hlr_error": str(ex)}))
    else:
        print(json.dumps({"hlr": "datos insuficientes", "n": len(eventos)}))


if __name__ == "__main__":
    main()

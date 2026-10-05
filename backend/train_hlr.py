"""Reentrenamiento HLR semanal con scikit-learn.
Uso: python train_hlr.py  (lee DATABASE_URL del entorno)
"""
import json, os
import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import mean_absolute_error, roc_auc_score
from sklearn.model_selection import train_test_split
from models import SessionLocal, TrazaInteraccion

def main():
    db = SessionLocal()
    rows = db.query(TrazaInteraccion).all()
    if len(rows) < 20:
        print(json.dumps({"error": "datos insuficientes", "n": len(rows)}))
        return
    X = np.array([[np.sqrt(1+r.aciertos), np.sqrt(1+r.fallos), r.dificultad,
                   -np.log(max(r.intervalo_dias or 1.0, 0.01))] for r in rows])
    y = np.array([1 if r.resultado >= 0.5 else 0 for r in rows])
    users = np.array([r.user_id for r in rows])
    Xtr, Xte, ytr, yte = train_test_split(X, y, test_size=0.2, stratify=y)
    clf = LogisticRegression(C=1.0, max_iter=1000).fit(Xtr, ytr)
    p = clf.predict_proba(Xte)[:, 1]
    print(json.dumps({
        "n": len(rows),
        "mae": mean_absolute_error(yte, p),
        "auc_roc": roc_auc_score(yte, p),
        "coef": clf.coef_.tolist(), "intercept": clf.intercept_.tolist(),
    }, indent=2))

if __name__ == "__main__":
    main()

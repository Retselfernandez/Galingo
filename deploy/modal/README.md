# Despliegue del backend de Galingo en Modal (serverless, gratis)

Plan **Starter de Modal**: **$30/mes de cómputo gratis** (recurrente), sin tarjeta,
HTTPS y escala a cero. El modelo ASR se descarga una sola vez a un volumen.

## 1. Cuenta
- Crea la cuenta en https://modal.com (login con GitHub/Google, **sin tarjeta**).

## 2. Autenticar aquí
```bash
pip install -U modal
modal setup          # abre el navegador para autenticar (o: modal token new)
```

## 3. Desplegar (desde la raíz del repo)
```bash
cd ~/Desktop/TFM/Galingo
modal deploy deploy/modal/modal_app.py
```
Modal imprimirá la URL, tipo:
`https://<usuario>--galingo-backend-web.modal.run`

## 4. Probar
```bash
curl https://<usuario>--galingo-backend-web.modal.run/api/v1/metricas
curl -F "audio=@test.mp3" -F "target=Ola, bos días!" \
  https://<usuario>--galingo-backend-web.modal.run/api/v1/voz/avaliar
```

## Notas
- **Escala a cero**: si no hay tráfico, no gasta; la primera petición tras un rato
  tarda unos segundos (carga del modelo).
- **Persistencia**: modelo en volumen `galingo-models`, BD SQLite en `galingo-data`.
  Para telemetría más sólida, usa un Postgres (Neon) y define `DATABASE_URL`.
- **Coste**: si el uso supera los $30/mes, Modal factura; para una beta con testers
  ocasionales debería sobrar. Puedes fijar un presupuesto en el panel.

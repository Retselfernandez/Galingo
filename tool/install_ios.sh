#!/usr/bin/env bash
# Reinstala/actualiza Galingo nun iPhone conectado, renovando a firma de
# 7 días do sideload SEN borrar os datos da app (progreso, XP, repaso).
#
# Uso:
#   bash tool/install_ios.sh                    # backend de produción (Render)
#   API_BASE_URL=http://192.168.1.10:8000 bash tool/install_ios.sh
#   bash tool/install_ios.sh <udid>             # se hai varios iPhone conectados
#
# Require: Mac con Xcode, iPhone conectado por USB e desbloqueado
#          («Confiar neste ordenador»).
set -euo pipefail
cd "$(dirname "$0")/.."

API="${API_BASE_URL:-https://galingo-backend.onrender.com}"

# ─── 1) Detectar o iPhone (UDID) ────────────────────────────────────────────
UDID="${1:-}"
if [ -z "$UDID" ]; then
  UDID=$(flutter devices --machine 2>/dev/null | python3 -c '
import json, sys
try:
    for d in json.load(sys.stdin):
        if d.get("targetPlatform") == "ios" and not d.get("emulator"):
            print(d["id"])
            break
except Exception:
    pass
')
fi

if [ -z "$UDID" ]; then
  echo "❌ Non hai ningún iPhone conectado (ou está bloqueado)."
  echo "   Conecta o iPhone por USB, desbloquéao e pulsa «Confiar neste ordenador»."
  exit 1
fi

# ─── 2) Mapear UDID -> identificador de devicectl ───────────────────────────
TMP=$(mktemp)
xcrun devicectl list devices --json-output "$TMP" >/dev/null 2>&1 || true
DEVICE=$(python3 - "$TMP" "$UDID" <<'PY'
import json, sys
path, udid = sys.argv[1], sys.argv[2]
try:
    data = json.load(open(path))
    for d in data.get("result", {}).get("devices", []):
        if (d.get("hardwareProperties") or {}).get("udid") == udid:
            print(d.get("identifier", ""))
            break
except Exception:
    pass
PY
)
rm -f "$TMP"

if [ -z "$DEVICE" ]; then
  echo "❌ Non atopei o iPhone ($UDID) en devicectl. Desbloquéao e reintenta."
  exit 1
fi

echo "→ iPhone:  $UDID"
echo "→ Backend: $API"
echo "→ Compilando (release; renova a firma de 7 días)…"
flutter build ios --release --dart-define=API_BASE_URL="$API"

# ─── 3) Instalar como ACTUALIZACIÓN (conserva os datos) ─────────────────────
echo "→ Instalando (actualización, sen borrar datos)…"
xcrun devicectl device install app --device "$DEVICE" build/ios/iphoneos/Runner.app \
  | grep -iE "App installed|error" | head -3

echo
echo "✅ Galingo actualizada. Válida 7 días."
echo "   Se a app non abre: Ajustes → General → VPN e xestión de dispositivos → Confiar."

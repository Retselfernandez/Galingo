#!/usr/bin/env bash
# Script para compilar el paquete Beta para iOS
set -e

echo "🚀 Compilando paquete Beta para iOS..."
cd "$(dirname "$0")/.."

flutter build ios --release --no-codesign

mkdir -p iOS/Payload
cp -R build/ios/iphoneos/Runner.app iOS/Payload/
cd iOS
zip -r Galingo-iOS-Beta.ipa Payload
rm -rf Payload
cd ..

echo "✅ Paquete iOS Beta listo en: iOS/Galingo-iOS-Beta.ipa"

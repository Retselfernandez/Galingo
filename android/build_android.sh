#!/usr/bin/env bash
# Script para compilar el APK Beta de Android localmente cuando Android SDK y Java estén instalados
set -e

echo "🚀 Compilando APK Beta de Android para Galingo..."
cd "$(dirname "$0")/.."

flutter build apk --release

mkdir -p Android
cp build/app/outputs/flutter-apk/app-release.apk Android/Galingo-Android-Beta.apk

echo "✅ APK generado exitosamente en: Android/Galingo-Android-Beta.apk"

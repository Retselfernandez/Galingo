# Guía rápida para los beta testers (envío)

## Mensaje de invitación (WhatsApp/Telegram)

Hola! Estoy cerrando mi TFM sobre **Galingo**, una app para aprender gallego.
¿Me ayudas probándola 2 semanas? Son 5 minutos al día.

1. Instala el APK: https://github.com/Retselfernandez/Galingo/releases/download/v1.4.0-beta/Galingo-Android-Beta.apk
   - ⚠️ Si ya tenías una versión anterior, **desinstálala primero** (el APK pesa ~744 MB).
2. Abre la app, crea tu perfil y haz al menos 1 lección al día.
3. Prueba los ejercicios de **voz**: acepta el permiso de micrófono y di/escribe la frase.
4. Si algo falla, agita el móvil → reportar problema (va directo a mi servidor).
5. No tienes que hacer nada más: la telemetría sale sola.

¡Gracias! — Lester

## Novedades de esta beta (v1.4.0)
- **Voz más precisa**: modelo Whisper **medium** en el dispositivo (100 % de acierto en las frases de prueba; antes 94 %).
- **Voz 100 % offline**: el reconocimiento corre **en el móvil**, sin internet y sin enviar tu audio a ningún servidor.
- Ejercicios de **pronuncia** con **audio del modelo** (voz gallega) para escuchar y repetir.
- La **primera vez** que abras un ejercicio de voz, la app prepara el modelo (~1-2 min, solo una vez).
- ⚠️ Recomendado en **móvil de gama media-alta** (usa ~1,5-2 GB de RAM al reconocer).

## Reglas de la beta

- Mínimo 1 lección/día durante 7 días (ideal 14)
- No desinstales entre medias (perderías la racha de datos)
- Reporta cualquier cosa rara con el shake
- La **voz funciona sin internet** (todo en el dispositivo). La primera vez tarda ~1-2 min en preparar el modelo.

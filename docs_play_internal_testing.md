# Publicar Galingo en Google Play (Internal testing)

## 0. Requisitos
- **Cuenta de desarrollador** de Google Play (25 $ pago único): https://play.google.com/console
- El **AAB firmado** ya generado:
  `build/app/outputs/bundle/release/app-release.aab` (60.6 MB)
- (Recomendado) **Política de privacidad** publicada en una URL pública
  → ver `docs/privacy_policy.md` (se puede publicar con GitHub Pages del propio repo).

## 1. Crear la app en Play Console
1. Play Console → **Crear app**.
2. Nombre: **Galingo** · Idioma predeterminado: **Español (España)** · App · Gratis.
3. Acepta las declaraciones.

## 2. Subir el AAB a Internal testing
1. **Probar y lanzar → Pruebas internas → Crear nueva versión**.
2. Sube `app-release.aab`.
3. Notas de la versión (ej.): *"Beta inicial: nivel A1, voz (dictado y pronuncia), rediseño de inicio."*
4. **Guardar → Revisar → Iniciar lanzamiento**.
5. En **Testers**, añade los correos de tus testers (o crea una lista) y comparte el **enlace de participación**.

> Google gestiona la firma (Play App Signing). El `android/app/galingo-release.keystore`
> es la **clave de subida**; guárdala: la necesitarás para futuras versiones.

## 3. Completar "Contenido de la app" (obligatorio)
- **Política de privacidad**: URL pública (ver §5).
- **Seguridad de los datos**: ver respuestas abajo (§4).
- **Clasificación de contenido**: cuestionario (app educativa; sin violencia/adultos).
- **Público objetivo**: 13+ (o el que corresponda).
- **Anuncios**: No.
- **Acceso**: la app no requiere login con cuenta.

## 4. Seguridad de los datos (respuestas)
- ¿Recopila o comparte datos? **Sí**.
  - **Actividad en la app** → *Funcionalidad de la app* → no compartido → cifrado en tránsito.
    (progreso y telemetría anónima con un ID aleatorio, sin datos personales).
  - **Audio (voz)** → *Funcionalidad de la app* → no compartido → cifrado en tránsito.
    (solo en ejercicios de pronuncia; se transcribe para evaluar y **no se almacena**).
- El **micrófono** solo se usa en ejercicios de voz, con permiso explícito del usuario.

## 5. Ficha de la tienda (textos listos)
- **Nombre** (≤30): `Galingo — Aprende galego`
- **Descripción corta** (≤80): `Aprende galego A1 con leccións curtas, voz e repetición espazada.`
- **Descripción completa** (≤4000):
  > Galingo é unha app para aprender **galego** (nivel A1) con microleccións gamificadas,
  > seguindo a metáfora do **Camiño de Santiago**: cada lección é unha parada no teu camiño.
  >
  > Inclúe:
  > - 12 unidades con vocabulario, gramática, escoita, ortografía e lectura.
  > - **Exercicios de voz**: ditado (escoita e escribe) e pronuncia (le en alto).
  > - **Repetición espazada** (SM-2 e un modelo propio HLR) para lembrar mellor.
  > - Progreso, rachas e XP.
  >
  > Ideal para iniciarse no galego dun xeito ameno e diario.
- **Categoría**: Educación.
- **Gráficos**: icono (512×512), imagen destacada (1024×500) y **capturas** (móvil).

## 6. Compilar el AAB de nuevo (cuando cambies algo)
```bash
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://retselfernandez--galingo-backend.modal.run
```

## Notas
- **Internal testing** no pasa revisión completa, pero exige la ficha y las declaraciones de contenido.
- Sube la **versión** (`pubspec.yaml` `version: X.Y.Z+N`) con `N` creciente en cada subida.
- El APK de GitHub Releases sigue disponible en paralelo para los testers.

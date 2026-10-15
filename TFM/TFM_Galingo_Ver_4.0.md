# TFM Galingo — Ver 4.0

---

**Universidade de Vigo**

**Escola Superior de Enxeñaría Informática**

Memoria del Trabajo de Fin de Máster que presenta

**Lester Andre Fernández Cedeño**

para la obtención del Título de Máster en Enxeñaría Informática

## Diseño, implementación y validación de una plataforma gamificada basada en modelos probabilísticos de repetición espaciada para el aprendizaje del idioma gallego (Galingo)

Curso 2025/2026

Trabajo de Fin de Máster Nº: ______

Tutor/a: Francisco Javier Rodríguez

Área de conocimiento: ______

Departamento: ______

---

## Dedicatoria

*(Página reservada para la dedicatoria, opcional)*

---

## Agradecimientos

*(Página reservada para los agradecimientos, opcional)*

---

## Resumen

Este Trabajo de Fin de Máster aborda el diseño, la implementación y la validación de **Galingo**, una plataforma multiplataforma (Android, iOS, macOS, Windows y Web) para la adquisición del idioma gallego en el nivel A1 del Marco Común Europeo de Referencia, dirigida a personas no gallegoparlantes. El problema que se aborda es la exclusión sistemática de las lenguas minorizadas de los ecosistemas comerciales de *microlearning*, lo que constituye una barrera tecnológica para la integración lingüística de la población migrante en Galicia.

Para responder a esta carencia se ha construido un sistema completo que integra: (i) un cliente Flutter *offline-first* con un motor de repetición espaciada; (ii) un backend desacoplado en FastAPI desplegado en la nube; (iii) un motor de retención de memoria que combina la heurística determinista **SM-2** como línea base con un modelo probabilístico de **Regresión de Vida Media (HLR)**, tanto en el dispositivo (Dart) como en servidor (scikit-learn); y (iv) una **capa de voz en gallego totalmente local**, con síntesis de voz (Proxecto Nós) para los ejercicios de escucha y reconocimiento automático del habla *on-device* (sherpa-onnx + Whisper) para la evaluación de la pronunciación sin conexión y sin enviar audio a terceros.

La plataforma se ha internacionalizado a **ocho idiomas de interfaz**, manteniendo el gallego como lengua objetivo, y se ha validado mediante una beta cerrada con telemetría de uso, reporte de incidencias integrado y análisis de retención (D1/D7) y de error del modelo HLR (MAE, AUC-ROC).

**Palabras clave:** microlearning, repetición espaciada, aprendizaje automático, regresión de vida media, procesamiento del lenguaje natural, arquitectura de software, lenguas minorizadas, reconocimiento automático del habla, integración sociocultural.

---

## Abstract

This Master's Thesis presents the design, implementation and validation of **Galingo**, a cross-platform application (Android, iOS, macOS, Windows and Web) for learning Galician at the A1 level of the Common European Framework of Reference, aimed at non-Galician speakers. The problem addressed is the systematic exclusion of minority languages from commercial microlearning ecosystems, which creates a technological barrier to the linguistic integration of migrant populations in Galicia.

To address this gap, a complete system has been built that integrates: (i) an *offline-first* Flutter client with a spaced-repetition engine; (ii) a decoupled FastAPI backend deployed in the cloud; (iii) a memory-retention engine that combines the deterministic **SM-2** heuristic as a baseline with a probabilistic **Half-Life Regression (HLR)** model, both on-device (Dart) and server-side (scikit-learn); and (iv) a **fully local Galician voice layer**, with text-to-speech (Proxecto Nós) for listening exercises and *on-device* automatic speech recognition (sherpa-onnx + Whisper) for pronunciation assessment, without connectivity and without sending audio to third parties.

The platform has been internationalised into **eight interface languages**, keeping Galician as the target language, and has been validated through a closed beta with usage telemetry, integrated issue reporting, and retention (D1/D7) and model-error (MAE, AUC-ROC) analysis.

**Keywords:** microlearning, spaced repetition, machine learning, half-life regression, natural language processing, software architecture, minority languages, automatic speech recognition, sociocultural integration.

---

## Índice de contenidos

1. Introducción y justificación del trabajo
2. Objetivos y alcance
3. Resumen de la solución propuesta y metodología
4. Planificación y seguimiento
5. Desarrollo de software
6. Principales aportaciones
7. Conclusiones
8. Vías de trabajo futuro
9. Referencias
10. Anexos

## Índice de ilustraciones

*(Se generará automáticamente en el documento final.)*

## Índice de tablas

*(Se generará automáticamente en el documento final.)*

---

# 1. Introducción y justificación del trabajo

## 1.1 Motivación y contexto sociolingüístico y tecnológico

La combinación de ingeniería de software, gamificación y aprendizaje automático ha transformado la manera de aprender una segunda lengua durante la última década. Las plataformas globales de microaprendizaje han demostrado una gran capacidad para retener a las personas usuarias mediante bucles de retroalimentación inmediata tras cada ejercicio. Sin embargo, el modelo de negocio que sostiene estas plataformas impone un límite claro: el desarrollo algorítmico avanzado se reserva para las lenguas con mayor tamaño de mercado, mientras que las lenguas minorizadas quedan cubiertas por recursos digitales estáticos, fragmentados y sin metodologías de retención adaptativa.

En el caso del gallego, esta desigualdad tecnológica no es únicamente un problema académico. Galicia recibe población migrante de forma continuada y la lengua propia constituye un factor central para el arraigo territorial, la inserción laboral y la cohesión de las familias que se instalan en la comunidad. La falta de herramientas accesibles para la inmersión lingüística —especialmente en los niveles iniciales A1 y A2 del Marco Común Europeo de Referencia (MCER)— dificulta que personas adultas y menores en edad escolar aprendan el idioma de forma progresiva. **Galingo** nace de la idea de aplicar ingeniería de producto e inteligencia artificial para facilitar el acceso al gallego, con una experiencia interactiva que reduzca la percepción de barrera cultural al comenzar a estudiarlo.

Además del valor sociolingüístico, el proyecto aborda un reto de ingeniería: construir, con recursos limitados (sin infraestructura de pago ni personal dedicado), un sistema completo que capture datos de interacción, los procese de forma asíncrona, entrene un modelo predictivo y ofrezca reconocimiento de voz *offline* de calidad suficiente para una lengua minorizada.

## 1.2 Formulación del problema

El problema técnico que se aborda es la ineficiencia de los métodos de repaso estático en las herramientas de aprendizaje del gallego disponibles en la actualidad. Las plataformas institucionales y los diccionarios en línea existentes carecen de sistemas capaces de optimizar el tiempo de estudio de cada persona según su propio ritmo de olvido.

La ciencia cognitiva describe la retención de la información mediante la curva de olvido de Ebbinghaus, según la cual la probabilidad de recuerdo $p$ tras un tiempo $t$ decae de forma aproximadamente exponencial en función de la fuerza de memoria o vida media $h$:

$$p = 2^{-\frac{t}{h}}$$

Los sistemas de *flashcards* disponibles para lenguas minorizadas tratan $h$ como una variable determinista que se incrementa mediante multiplicadores fijos tras cada acierto, como ocurre en el algoritmo **SM-2**. Este enfoque no tiene en cuenta la latencia de respuesta, el historial real de aciertos y fallos, ni la complejidad intrínseca —léxica y sintáctica— del ítem evaluado.

A este problema algorítmico se suma un problema de **accesibilidad de la voz**: ni Android ni iOS ofrecen reconocimiento del habla en gallego de forma nativa, de modo que los ejercicios de pronunciación de una app de este tipo, si dependen de servicios en la nube, exigen conexión permanente y comprometen la privacidad de la persona usuaria.

El reto consiste, por tanto, en diseñar una infraestructura que (i) capture eventos de interacción de forma continua y los use para entrenar un modelo que estime $h$ minimizando el error frente a los resultados reales, y (ii) proporcione voz gallega —síntesis y reconocimiento— **de forma local**, dentro de una aplicación multiplataforma capaz de responder con la rapidez suficiente para no interrumpir la sesión de estudio.

## 1.3 Estado del arte y justificación

Diseñar un sistema de aprendizaje de idiomas que incorpore inteligencia requiere combinar tres áreas: la ingeniería de interfaces aplicada al microaprendizaje, los modelos computacionales de retención de memoria y el procesamiento del lenguaje natural.

- **Sistemas de *microlearning*.** Las plataformas comerciales de mayor difusión han fijado un patrón de interacción que maximiza el tiempo de sesión segmentando el contenido en unidades pequeñas, reforzadas por mecánicas de juego orientadas al compromiso diario. Sin embargo, excluyen de forma sistemática las lenguas minorizadas como el gallego, ya que su desarrollo algorítmico se concentra en los idiomas con mayor tamaño de mercado.

- **Algoritmos de repetición espaciada.** El algoritmo **SM-2** de Wozniak sigue siendo el estándar de facto en aplicaciones de *flashcards* [2]. Introduce un factor de facilidad $EF$ que se ajusta tras cada intento ($EF' = EF + (0{,}1 - (5-q)\,(0{,}08 + (5-q)\,0{,}02))$), pero sus parámetros de penalización están fijados por quien diseña el sistema y no se aprenden a partir de los datos.

- **Regresión de Vida Media (HLR).** Para superar estas limitaciones, modelos estadísticos entrenables como HLR asumen la curva de Ebbinghaus pero estiman la vida media $h$ a partir de un vector de características $\mathbf{x}$ del intento de estudio proyectado mediante un vector de pesos $\boldsymbol{\theta}$ [1]:

$$\hat{h}_{\boldsymbol{\theta}}(\mathbf{x}) = 2^{\boldsymbol{\theta}\cdot\mathbf{x}}, \qquad \hat{p} = 2^{-\frac{t}{\hat{h}}}$$

En producción, HLR redujo el error de predicción del recuerdo en más de un 45 % frente a los modelos de referencia y aumentó el compromiso diario en un 12 % [1].

- **Recursos PLN y voz para el gallego.** El Instituto da Lingua Galega (ILG) ofrece recursos como **CORILGA** [4], relevantes para una futura integración de reconocimiento de voz. El **Proxecto Nós** de la Universidade de Santiago de Compostela publica voces neuronales (entre ellas *Celtia*) y modelos ASR afinados para el gallego, que constituyen la base de la capa de voz de Galingo. Asimismo, se ha demostrado la viabilidad de aprovechar la cercanía entre el gallego y el portugués normativo para sistemas de traducción automática [6].

Galingo se ubica en la intersección de estas brechas. No se plantea únicamente como una interfaz de usuario, sino como una **infraestructura de software** que traslada un modelo probabilístico de predicción de memoria a una lengua minorizada y que resuelve la voz **en el propio dispositivo**, justificando así la necesidad técnica y social del proyecto.

# 2. Objetivos y alcance

## 2.1 Objetivo general

El objetivo central de este trabajo es **diseñar, implementar y validar** una plataforma multiplataforma, Galingo, estructurada bajo el paradigma del microaprendizaje, que integre un algoritmo probabilístico de Regresión de Vida Media entrenado con datos de interacción para optimizar la curva de asimilación del gallego en personas no gallegoparlantes, comparando su rendimiento frente a la heurística clásica SM-2, y que resuelva íntegramente la capa de voz (síntesis y reconocimiento) **en el propio dispositivo**.

## 2.2 Objetivos específicos

- **Algorítmicos.** Diseñar una base de datos relacional y un proceso de ingesta continua que capture la telemetría de interacción; implementar e integrar tanto la línea base determinista (SM-2) como un modelo entrenable (HLR); y evaluar ambos mediante error absoluto medio (MAE) y área bajo la curva ROC (AUC-ROC) con particionado por usuario.
- **Arquitectónicos.** Construir una API desacoplada del cliente móvil, con procesamiento en segundo plano y cola *offline* en el cliente, garantizando que la telemetría no se pierda y que la latencia percibida no se degrade.
- **De producto.** Implementar una interfaz que reduzca la fricción inicial, con un sistema de componentes reutilizable y mecánicas de gamificación (racha, XP, niveles), e integrar en una sola aplicación el aprendizaje guiado (**O Camiño**), la evaluación predictiva y la consulta léxico-verbal (**O Laboratorio**).
- **De voz.** Proporcionar ejercicios de escucha (síntesis de voz gallega) y de pronunciación/dictado (reconocimiento automático del habla) **sin conexión**, sin dependencia de servicios en la nube y sin enviar el audio a terceros.
- **De internacionalización.** Ofrecer la interfaz y los enunciados de los ejercicios en ocho idiomas, manteniendo el gallego como lengua objetivo.

## 2.3 Alcance del MVP y limitaciones

- **Nivel cubierto: A1.** El corpus de evaluación se limita al nivel **A1** del MCER, con **12 unidades**, **70 lecciones** y **573 ejercicios**. Los niveles A2, B1 y B2 quedan **desactivados en la interfaz** (se conserva su contenido en el repositorio, reactivable mediante un único conmutador de configuración).
- **Motor verbal.** La consulta de conjugación se limita a verbos regulares en presente, pretérito y futuro de indicativo.
- **Voz.** La síntesis de voz emplea una voz neuronal gallega publicada por el Proxecto Nós. El reconocimiento del habla emplea un modelo Whisper multilingüe (tamaño *small*, cuantizado a int8) ejecutado *on-device*; la precisión es buena pero inferior a la de un modelo afinado específicamente para el gallego, lo que se compensa con una normalización fonética del texto reconocido.
- **Distribución.** La beta se distribuye como APK firmado vía *GitHub Releases* (Android) y como compilación local para iOS/macOS/Windows/Web, sin publicación en tiendas (limitación por coste de las cuentas de desarrollador de Google y Apple).

## 2.4 Hipótesis de investigación

- **H1 (eficiencia predictiva).** Un modelo entrenable basado en HLR obtendrá un menor error absoluto medio (MAE) y una curva de calibración más ajustada que la heurística SM-2.
- **H2 (retención de producto).** La combinación de microaprendizaje gamificado con voz local producirá una retención en el día 7 superior a la de los recursos estáticos, con una menor fricción inicial.

---

# 3. Resumen de la solución propuesta y metodología

La solución aportada consiste en sustituir los intervalos heurísticos fijos por una **función probabilística de pesos entrenada**, orquestada dentro de una arquitectura cliente-servidor, y en trasladar toda la **capa de voz al dispositivo**. La figura siguiente resume el flujo de datos.

```text
┌────────────────────────────── Cliente Flutter (offline-first) ──────────────────────────────┐
│  UI (8 idiomas) · O Camiño / lecciones / O Laboratorio                                       │
│  Motor de repetición: SM-2 (línea base) + HLR (on-device, Dart)                              │
│  Capa de voz: TTS gallego (Proxecto Nós) · ASR on-device (sherpa-onnx + Whisper small)       │
│  Cola de telemetría persistente (Hive) + reporte de incidencias (shake)                      │
└───────────────┬─────────────────────────────────────────────────────────────▲───────────────┘
                │ eventos / feedback (HTTPS, sincronización por lotes)         │ métricas
                ▼                                                             │
┌──────────────────────────────────── Backend FastAPI (nube) ────────────────────────────────┐
│  /api/v1/interaccion · /feedback · /sesion · /estado_memoria · /metricas · /export          │
│  PostgreSQL/SQLite (SQLAlchemy): Item_Lexico · Estado_Memoria · Traza_Interaccion · ...      │
│  Entrenamiento HLR (scikit-learn) · análisis de retención (D1/D7)                            │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

Para cuantificar la ganancia de la solución se implementa **SM-2** como línea base determinista. El modelo propuesto (**HLR**) define su vector de características de entrada como $\mathbf{x} = [\mathbf{x}_{\text{léxico}}, 1]$, donde $\mathbf{x}_{\text{léxico}}$ es el subvector léxico y $1$ el sesgo. La vida media estimada se calcula como $\hat{h}_{\boldsymbol{\theta}}(\mathbf{x}) = 2^{\boldsymbol{\theta}\cdot\mathbf{x}}$ y la probabilidad de acierto como $\hat{p} = 2^{-t/\hat{h}}$. El entrenamiento minimiza la siguiente función de pérdida con regularización L2 de peso $\lambda$:

$$\mathcal{L}(\boldsymbol{\theta}) = \sum_{i} \left( p_i - \hat{p}_{\boldsymbol{\theta}}(\mathbf{x}_i) \right)^2 + \lambda \lVert \boldsymbol{\theta} \rVert_2^2$$

El rendimiento se evalúa con el **error absoluto medio (MAE)** y el **área bajo la curva ROC (AUC-ROC)**. Para evitar la filtración de datos, la validación cruzada se realiza particionando **usuarios** (80 % entrenamiento, 20 % evaluación), garantizando la generalización sobre perfiles no vistos durante el entrenamiento.

**Metodología de desarrollo.** Se siguió un enfoque iterativo e incremental (sprints) con un *gate* de calidad automático (análisis estático + pruebas) previo a cada compilación, y una fase final de **beta cerrada** instrumentada analíticamente. La validación combina tres niveles: pruebas unitarias del motor de repetición, pruebas de *widget* y de responsividad, y validación empírica con datos reales de uso (retención y error del modelo).

---

# 4. Planificación y seguimiento

El desarrollo se estructuró en fases (sprints) y se mantuvo un documento de seguimiento (*As Built*) que registra, para cada fase, las decisiones y los artefactos generados. La tabla compara la planificación inicial con el resultado real.

| Fase | Peso | Estado real | Evidencia |
|---|---|---|---|
| 0 — Higiene del repositorio (README, `.gitignore`, CI con *gate* de tests) | 10 % | ✅ Completada | `.github/workflows`, `README.md` |
| 1 — Internacionalización (i18n) de la interfaz y del contenido | 20 % | ✅ Completada | 8 locales en `lib/l10n/`, curso traducido |
| 2 — Robustez del motor SM-2/HLR (casos límite, MAE persistido) | 10 % | ✅ Completada | `test/*`, MAE en Ajustes |
| 3 — Backend FastAPI + base de datos + telemetría + feedback | 25 % | ✅ Completada | `backend/`, endpoints desplegados |
| 4 — Responsividad multiplataforma, firma y CI | 15 % | ✅ Completada | Android/iOS/macOS/Windows |
| 5 — Voz local (TTS + ASR on-device) | — | ✅ Completada (ampliación) | sherpa-onnx + Whisper, Proxecto Nós |
| 6 — Beta y métricas reales | 15 % | 🟡 En curso | telemetría D1/D7, HLR |
| 7 — Memoria Ver 4.0 | 5 % | 🟡 En curso | este documento |

**Cronograma y ajustes.** Las fases 0–4 se completaron según lo previsto. La **voz local** (fase 5) surgió como una ampliación no planificada inicialmente: al comprobar que ni Android ni iOS ofrecen ASR en gallego, se decidió trasladar el reconocimiento al dispositivo con sherpa-onnx, lo que eliminó la dependencia de la nube y mejoró la privacidad. Esta decisión implicó una recalibración del alcance (nivel A1) para garantizar la calidad del contenido sobre la cantidad. La fase de beta (fase 6) se mantiene abierta con telemetría fluyendo, lo que ya permite el entrenamiento del modelo HLR.

**Herramientas de seguimiento.** Control de versiones con Git (rama `main`), documentación de estado en `AS_BUILT_*.md`, y un flujo de trabajo con agentes de IA como apoyo a la implementación, revisión y pruebas. La instrumentación de la propia aplicación (telemetría y reporte de incidencias) actúa además como fuente de seguimiento del uso real.

# 5. Desarrollo de software

## 5.1 Arquitectura

Galingo sigue un patrón **cliente-servidor con tres capas** separadas por responsabilidad, más una **capa de inferencia local** en el propio cliente.

1. **Capa de presentación (cliente Flutter).** Aplicación multiplataforma que centraliza el estado, la lógica de ejercicios, el motor de repetición espaciada y **toda la capa de voz**. Se comunica con el servidor mediante HTTPS. Implementa un diseño *offline-first*: si no hay conexión, los eventos de telemetría y los reportes se almacenan en una cola persistente local y se sincronizan al recuperar la red.
2. **Capa de aplicación (backend FastAPI).** Servidor en Python que valida la ingesta de telemetría (de forma **idempotente** por `event_id`), almacena los reportes de incidencia y expone métricas agregadas. No bloquea la experiencia del cliente.
3. **Capa de aprendizaje automático.** Proceso de entrenamiento del modelo HLR (scikit-learn) que consume la telemetría histórica y recalcula los parámetros del modelo, además del análisis de retención (D1/D7). El modelo HLR también se ejecuta **en el dispositivo** (Dart) como *fallback* offline.

El MVP se despliega como un **backend único** (no como microservicios) para evitar complejidad innecesaria, alojado en una plataforma *serverless* con escalado automático. El cliente no depende del backend para funcionar: el aprendizaje y la voz operan localmente.

```text
lib/
├── main.dart                    # arranque: Hive, audio, telemetría, router, tema, shake
├── core/
│   ├── constants/app_constants.dart
│   ├── ml/{hlr_engine, sm2_engine}.dart
│   ├── router/app_router.dart
│   ├── services/               # audio, tts, asr, telemetría, shake
│   └── theme/app_theme.dart
├── data/                       # datasources, models, repositories (Hive)
└── presentation/
    ├── providers/              # estado (Riverpod): progreso, ajustes
    ├── screens/                # onboarding, home (O Camiño), lesson, settings, feedback
    └── widgets/                # gabi, camino_map, speech_exercise, …
```

## 5.2 Tecnologías e integración de productos de terceros

| Componente | Tecnología | Justificación |
|---|---|---|
| Cliente | **Flutter / Dart** | Un único código para Android, iOS, macOS, Windows y Web. |
| Estado | **Riverpod** | Gestión de estado reactiva y testeable. |
| Persistencia local | **Hive** | Base de datos *key-value* rápida y sin servidor, ideal para *offline-first*. |
| Backend | **FastAPI (Python)** | API REST asíncrona, documentación automática y buena integración con el ecosistema de datos. |
| ORM / BD | **SQLAlchemy** sobre **PostgreSQL** (producción) / **SQLite** (desarrollo) | Modelo relacional claro y portable. |
| ML | **scikit-learn** | Regresión logística regularizada para HLR; sencillo y reproducible. |
| Despliegue | **Modal** (serverless) | Alojamiento **gratuito** con escalado automático; se calienta el contenedor al abrir la app. |
| TTS gallego | **Proxecto Nós (USC)** — voz *Celtia*, modelo VITS ONNX | Voz neuronal gallega real; se descartó *edge-tts* por sonar a portugués. |
| ASR | **sherpa-onnx + Whisper** (multilingüe, int8) | Reconocimiento **on-device** sin conexión; alternativa a los ASR nativos, que no soportan gallego. |
| Audio | `audioplayers`, `record` | Reproducción de los audios del modelo y grabación del micrófono. |

**Productos de terceros y su integración.** La voz *Celtia* y los modelos del Proxecto Nós son recursos externos publicados bajo licencias abiertas; el modelo ASR Whisper (OpenAI) se distribuye con licencia permisiva y se empaqueta cuantizado. Los *plugins* de Flutter (audio, sensores, almacenamiento seguro, conectividad) son software libre. Se documentan sus licencias y se justifica su uso por la ausencia de alternativas específicas para el gallego.

## 5.3 Especificación y análisis de requisitos

**Requisitos funcionales.**

- **RF1.** Registrar eventos de interacción por cada ejercicio: identificador de ítem, resultado (acierto/fallo), intervalo transcurrido y latencia de respuesta.
- **RF2.** Calcular y persistir el estado de memoria por par (usuario, ítem) y proponer el próximo repaso (SM-2 y HLR).
- **RF3.** Ofrecer el flujo de aprendizaje guiado (**O Camiño**): mapa de unidades y lecciones con progreso y desbloqueo.
- **RF4.** Evaluar ejercicios de **ocho tipos** (opción múltiple, huecos, emparejar, traducción, ordenar, lectura, imagen, y voz) con retroalimentación inmediata.
- **RF5.** Proporcionar **audio del modelo** (síntesis gallega) y **evaluación de pronunciación** (ASR local) con acierto por palabra.
- **RF6.** Reportar incidencias desde la app (gesto de agitado o Ajustes) con categoría, texto y metadatos.
- **RF7.** Sincronizar la telemetría y los reportes de forma diferida cuando no haya conexión.
- **RF8.** Permitir elegir el idioma de interfaz entre ocho locales, con el gallego como lengua objetivo.

**Requisitos no funcionales.**

- **RNF1 (latencia).** Las transiciones de estado de la interfaz deben percibirse instantáneas (< 0,1 s; límite < 1 s) [7].
- **RNF2 (privacidad).** El audio de voz **nunca** abandona el dispositivo; el reconocimiento se ejecuta localmente.
- **RNF3 (disponibilidad offline).** El aprendizaje y la voz deben funcionar sin conexión.
- **RNF4 (portabilidad).** Un único código para Android, iOS, macOS, Windows y Web.
- **RNF5 (rendimiento de la voz).** El modelo ASR debe ejecutarse en un teléfono de gama media en pocos segundos por frase.
- **RNF6 (mantenibilidad).** Análisis estático sin avisos y batería de pruebas en verde como *gate* de integración.

## 5.4 Diseño del software

**Diseño estático.** El cliente se organiza por capas (*core*, *data*, *presentation*) con dependencias unidireccionales. El modelo de dominio del contenido (`Level → Unit → Lesson → Exercise`) se carga desde JSON. `ExerciseModel` incorpora un campo `i18n` por idioma que permite **localizar los enunciados sin alterar el contenido gallego**. El backend define las entidades relacionales descritas en 5.5 y una capa de esquemas (Pydantic) para la validación de entrada.

**Diseño dinámico.** El flujo principal es: *onboarding → O Camiño → lección → ejercicios → resumen*. En cada ejercicio, el cliente evalúa la respuesta, actualiza el estado de memoria (SM-2 y HLR) y **encola** un evento de telemetría. Periódicamente (o al recuperar conectividad) la cola se envía por lotes al backend, que valida la idempotencia y persiste los datos. Un proceso asíncrono entrena el modelo HLR y actualiza las predicciones. El diseño *offline-first* garantiza que el flujo del usuario nunca se interrumpe por falta de red.

```text
Usuario → Ejercicio → Evaluación local (SM-2 + HLR)
                              │
                              ├─ feedback inmediato (UI)
                              └─ evento → cola Hive ──(sync)──► /api/v1/interaccion → BD
Reporte (shake) ──────────────────────────────────────────► /api/v1/feedback → BD
```

## 5.5 Gestión de datos e información

La persistencia remota recae en **PostgreSQL** (SQLite en desarrollo). Entidades principales:

- **`Item_Lexico`.** Vocabulario: lema, categoría gramatical y complejidad.
- **`Estado_Memoria`.** Vida media $h$ y próximo repaso para cada par (usuario, ítem).
- **`Traza_Interaccion`.** Registro de solo-escritura de cada evaluación (marca temporal, latencia, resultado, intervalo), que forma el *dataset* de entrenamiento. Los datos crudos se preprocesan aplicando una transformación logarítmica a la latencia para atenuar valores atípicos.
- **`Reportes_Feedback`.** Incidencias enviadas desde la app.
- **`SesionDiaria`.** Registro de sesiones diarias para el cálculo de retención (D1/D7).

En el cliente, la persistencia local usa **Hive** (progreso, ajustes, usuario y **cola de telemetría**). La telemetría se almacena con un identificador único (`event_id`) que garantiza la **idempotencia** en el servidor. Los identificadores de usuario son anónimos (UUID) y se generan en el dispositivo; no se recogen datos personales.

## 5.6 Pruebas llevadas a cabo

- **Pruebas algorítmicas.** `hlr_engine_test` y `sm2_telemetry_test` cubren casos límite del motor de repetición: $t\to 0$, $h\le 0$, rachas de fallos, estabilidad tras 200 eventos y entradas vacías. Se verifica el piso $EF \ge 1{,}3$ de SM-2 y las invariantes de acierto.
- **Pruebas de *widget* y de integración.** `widget_test` (humo + múltiples tamaños de pantalla), `responsive_screens_test` (5 pantallas × 6 tamaños) y pruebas de los *widgets* de emparejar y de voz.
- **Pruebas de contenido.** Un test verifica que los 573 ejercicios tienen traducción en los siete idiomas adicionales y que la localización mantiene el contenido gallego (preguntas traducidas, respuestas en gallego).
- **Validación de la voz.** El modelo ASR se evaluó con las 33 frases de pronunciación del curso: similitud media 0,88 y **94 % de aciertos** con el modelo *small*, y **100 %** con el modelo *medium* (descartado por su consumo de memoria en móviles). El conjunto de control (frases cruzadas) no produjo falsos positivos.
- **Validación de la internacionalización.** Se detectó y corrigió un defecto por el que los enunciados de los ejercicios de escucha traducían la frase gallega y rompían el ocultado del contenido; se verificó la ausencia de comillas desemparejadas en los ocho idiomas.
- **Pruebas de responsividad y plataforma.** Se corrigieron desbordamientos y se añadió soporte para el modo *edge-to-edge* de Android 15/16 (márgenes de sistema).
- **Gate de calidad.** El *pipeline* de integración continua ejecuta `flutter analyze` y la batería completa de pruebas (36/36 en verde) antes de compilar.

**Beta cerrada.** Se instrumentó una beta con usuarios reales, con telemetría anónima y reporte de incidencias. Los resultados se detallan en el capítulo 7.

## 5.7 Manual de usuario

### Requisitos mínimos

| Plataforma | Requisitos |
|---|---|
| Android | Android 6.0 o superior, ~1,5 GB de almacenamiento libre (incluye el modelo de voz). |
| iOS | iOS 13 o superior; instalación vía Xcode con Apple ID personal (validez de 7 días). |
| macOS / Windows | Versión de escritorio; ejecución local. |
| Web | Navegador moderno (la voz local no está disponible en Web). |

### Instalación y uso

1. **Instalación.** En Android, instalar el APK firmado publicado en *GitHub Releases*. En iOS/macOS/Windows, compilar desde el código fuente (Anexo A).
2. **Primer arranque.** Introducir el nombre, elegir el idioma de interfaz y entrar en **O Camiño**.
3. **Estudio diario.** Realizar al menos una lección al día. Cada lección combina varios tipos de ejercicio con retroalimentación inmediata.
4. **Voz.** En los ejercicios de escucha, la app reproduce el audio del modelo. En los de pronunciación/dictado, la **primera vez** prepara el modelo de reconocimiento (~1 minuto) y, a partir de ahí, evalúa la voz localmente sin conexión.
5. **Reporte de incidencias.** Agitar el dispositivo (o usar Ajustes) abre un formulario; el reporte se envía al servidor.
6. **Ajustes.** Idioma, tipografía, tamaño de letra, tema y sonido; muestra el MAE del modelo y el progreso.

El despliegue del backend y la compilación por plataforma se detallan en el **Anexo A**.

# 6. Principales aportaciones

La aportación principal es aplicar a una lengua minorizada como el gallego un enfoque de **modelado de la memoria** y una **arquitectura de software** que hasta ahora se han usado casi en exclusiva en plataformas comerciales de alcance masivo, añadiendo dos elementos diferenciales: la **internacionalización** de la interfaz con el gallego como lengua objetivo, y una **capa de voz íntegramente local**.

1. **Un proceso completo de datos, de extremo a extremo.** Desde la captura del evento de interacción en el cliente, pasando por la ingesta idempotente y el almacenamiento relacional, hasta el entrenamiento del modelo HLR y su evaluación. El sistema es reproducible y puede servir de base para otros idiomas minorizados.

2. **Doble motor de repetición espaciada.** La implementación conjunta de la línea base determinista (SM-2) y del modelo entrenable (HLR), tanto en el dispositivo (Dart) como en servidor (scikit-learn), permite comparar ambos de forma directa y ofrece una métrica de mejora visible para la persona usuaria (MAE) en los ajustes de la aplicación.

3. **Voz gallega offline y privada.** La resolución del reconocimiento del habla **en el propio dispositivo** (sherpa-onnx + Whisper), sin conexión y sin enviar el audio a terceros, es un resultado relevante: ni Android ni iOS ofrecen ASR en gallego, y las alternativas en la nube comprometen la privacidad y exigen conectividad. La síntesis de voz emplea una voz neuronal gallega real (Proxecto Nós).

4. **Internacionalización con lengua objetivo.** Ocho idiomas de interfaz y **573 ejercicios traducidos** en sus enunciados, manteniendo el contenido gallego como objeto de aprendizaje. Esto amplía el público potencial sin renunciar a la inmersión en la lengua meta.

5. **Producto real, distribuido y medido.** Una aplicación multiplataforma firmada, con telemetría anónima, reporte de incidencias integrado y una beta en funcionamiento.

## 6.1 Resultados preliminares de la beta

La beta cerrada se instrumentó con telemetría anónima. En el momento de redactar esta memoria, los datos acumulados eran:

| Métrica | Valor |
|---|---|
| Personas usuarias distintas | 2 |
| Sesiones diarias registradas | 5 |
| Eventos de interacción (repasos) | 26 |
| Reportes de incidencia | 2 |

El **volumen de eventos ya supera el mínimo (≈20)** necesario para entrenar el modelo HLR, por lo que la fase de entrenamiento queda desbloqueada. Los reportes de incidencia recibidos (texto de botones recortado en un dispositivo Android 15/16 y un error de traducción en un ejercicio de escucha) se han traducido en correcciones concretas de la aplicación, lo que demuestra el valor del canal de *feedback* integrado.

**Validación de la voz.** El modelo ASR se evaluó con las 33 frases de pronunciación del curso, comparando la transcripción con el texto objetivo mediante una métrica fonética:

| Modelo | Tamaño | Similitud media | Aciertos (umbral 0,65) |
|---|---|---|---|
| Whisper *small* (adoptado) | 374 MB | 0,88 | **94 %** |
| Whisper *medium* | 945 MB | 0,94 | **100 %** |
| *large-v3-turbo* | 989 MB | 0,94 | 97 % |

El modelo *medium* ofrece una precisión mayor, pero su consumo de memoria (~1,5–2 GB) lo hace inviable en dispositivos de gama media; se adoptó el modelo *small* por su equilibrio entre precisión, tamaño y compatibilidad. El conjunto de control (comparar la frase objetivo con un audio distinto) **no produjo ningún falso positivo**, lo que valida la capacidad discriminativa de la métrica.

**Limitación reconocida.** El tamaño muestral de la beta es reducido, por lo que los resultados de retención deben considerarse **preliminares**. El sistema está preparado para escalar la muestra (solo requiere más tiempo de uso), y el análisis de retención y el entrenamiento del modelo se automatizan a partir de los datos ya recogidos.

---

# 7. Conclusiones

Este trabajo demuestra que es viable, técnica y arquitectónicamente, diseñar un sistema de microaprendizaje nativo para el gallego que sustituya las heurísticas de repaso fijas por un **modelo probabilístico de retención de memoria**, y que resuelva la **voz de forma local**. Se ha logrado orquestando un despliegue sobre una arquitectura backend desacoplada, capaz de procesar la telemetría de interacción sin degradar la experiencia en tiempo real, y trasladando el reconocimiento del habla al dispositivo para eliminar la dependencia de la nube.

**Conclusiones técnicas.**

- La sustitución de SM-2 por HLR es viable con recursos limitados: el modelo se entrena con scikit-learn a partir de la telemetría y se ejecuta también *on-device*, lo que permite ofrecer predicciones incluso sin conexión.
- La arquitectura *offline-first* (cola persistente + ingesta idempotente) garantiza que no se pierde telemetría, un requisito crítico para un sistema cuyo valor depende de los datos.
- Es posible ofrecer reconocimiento de voz en una lengua minorizada **sin servicios en la nube**: la combinación sherpa-onnx + Whisper *on-device* alcanza un 94 % de aciertos en las frases de prueba con una huella de memoria compatible con teléfonos de gama media.
- La internacionalización con una **lengua objetivo distinta** de la de la interfaz exige separar el contenido (gallego) del andamiaje (enunciados traducidos), un diseño que resultó robusto una vez corregidos los defectos detectados en la beta.
- El coste de distribución se puede mantener en cero (APK firmado vía *GitHub Releases* y despliegue del backend en una plataforma *serverless* gratuita), lo que hace viable un proyecto de este tipo sin presupuesto.

**Conclusiones personales.** El desarrollo ha supuesto un ejercicio completo de ingeniería de producto: no solo de programación, sino de toma de decisiones con restricciones reales (coste, memoria, precisión, multiplataforma). La detección de defectos a partir de datos reales de la beta —y su corrección— ha sido probablemente la parte más formativa del trabajo. Asimismo, el proyecto evidencia cómo la inteligencia artificial y la ingeniería pueden ponerse al servicio de la inclusión lingüística.

---

# 8. Vías de trabajo futuro

- **Escalar la beta** para obtener una muestra significativa que permita validar H1 y H2 con potencia estadística (retención D1/D7 y MAE HLR frente a SM-2).
- **Completar y revisar las traducciones** de los enunciados (cobertura ya del 100 % generada por traducción automática, pendiente de revisión humana fina) y ampliar a más idiomas.
- **Explorar un modelo ASR afinado específicamente para el gallego** y exportarlo a ONNX para el dispositivo, mejorando la precisión sin aumentar el tamaño.
- **Publicar en tiendas**: AAB en Google Play e IPA en TestFlight (requiere cuentas de desarrollador) y notarización para macOS.
- **Deep Knowledge Tracing (DKT)**: sustituir la regresión por una red neuronal recurrente capaz de modelar secuencias completas de interacción [3].
- **Colaboración con el ILG (CORILGA)** para la generación de dictados con voz natural y para una modelización léxica real de la dificultad $d$ de cada ítem [4].
- **Ampliar `O Laboratorio`** a verbos irregulares completos y a la mesóclisis, y extender el alcance a los niveles A2/B1/B2 (contenido ya presente en el repositorio).

---

# 9. Referencias

[1] B. Settles and B. Meeder, "A Trainable Spaced Repetition Model for Language Learning," in *Proc. 54th Annual Meeting of the Association for Computational Linguistics (ACL)*, Berlin, Germany, 2016, pp. 1848–1858.

[2] P. A. Wozniak, "Optimization of learning," Master's thesis, University of Technology in Poznan, Poznan, Poland, 1990.

[3] C. Piech, J. Bassen, J. Huang, S. Ganguli, M. Sahami, L. J. Guibas, and J. Sohl-Dickstein, "Deep Knowledge Tracing," in *Advances in Neural Information Processing Systems (NeurIPS)*, vol. 28, 2015.

[4] Instituto da Lingua Galega, "CORILGA: Corpus Oral Informatizado da Lingua Galega," Universidade de Santiago de Compostela. [En línea]. Disponible en: https://ilg.usc.gal

[5] Instituto da Lingua Galega, "Interoperabilidade de recursos e produción automática de linguaxe natural," Universidade de Santiago de Compostela. [En línea]. Disponible en: https://ilg.usc.gal

[6] J. C. Pichel Campos, "Carvalho: Un sistema de traducción estadística inglés-galego construido a partir del corpus paralelo inglés-portugués EuroParl," *Procesamiento del Lenguaje Natural*, SEPLN.

[7] J. Nielsen, "Response Times: The 3 Important Limits," Nielsen Norman Group, 1993. [En línea]. Disponible en: https://www.nngroup.com/articles/response-times-3-important-limits/

[8] Proxecto Nós, Universidade de Santiago de Compostela. Recursos de voz e lingua para o galego (voz *Celtia*; modelos ASR). [En línea]. Disponible en: https://nos.gal

[9] A. Radford, J. W. Kim, T. Xu, G. Brockman, C. McLeavey, and I. Sutskever, "Robust Speech Recognition via Large-Scale Weak Supervision (Whisper)," OpenAI, 2022.

[10] k2-fsa, "sherpa-onnx: Real-time speech recognition and synthesis without internet." [En línea]. Disponible en: https://github.com/k2-fsa/sherpa-onnx

[11] Consejo de Europa, *Marco Común Europeo de Referencia para las lenguas: aprendizaje, enseñanza, evaluación*. Estrasburgo: Consejo de Europa, 2001.

---

# 10. Anexos

## Anexo A. Manual de despliegue

### Backend (FastAPI + PostgreSQL)

```bash
cd backend
docker compose up --build
# API en http://localhost:8000  ·  Documentación: http://localhost:8000/docs
```

Variables de entorno:

| Variable | Valor por defecto | Descripción |
|---|---|---|
| `DATABASE_URL` | `postgresql://galingo:galingo@db:5432/galingo` | Cadena de conexión SQLAlchemy |
| `EXPORT_TOKEN` | *(secreto)* | Token de administración para `/api/v1/export` |

Endpoints principales:

| Método | Ruta | Descripción |
|---|---|---|
| POST | `/api/v1/interaccion` | Ingesta idempotente de eventos de repaso (SM-2/HLR) |
| POST | `/api/v1/feedback` | Ingesta de reportes de incidencia |
| POST | `/api/v1/sesion` | Registro de sesión diaria (retención D1/D7) |
| GET | `/api/v1/estado_memoria/{user_id}` | Estado de memoria por usuario |
| GET | `/api/v1/metricas` | Contadores agregados |
| GET | `/api/v1/export` | Exportación completa (protegida por token) |

Despliegue en la nube: el backend se publica en una plataforma *serverless* (Modal) mediante `deploy/modal/modal_app.py`, con las credenciales en un secreto. El contenedor se "calienta" al abrir la app para evitar la latencia de arranque en frío.

### Reentrenamiento del modelo HLR

```bash
cd backend
python train_hlr.py     # exporta MAE y AUC-ROC en JSON
python analisis_beta_remote.py   # retención D1/D7 + totales
```

### Cliente Flutter

```bash
flutter pub get
bash tool/fetch_asr_model.sh small     # descarga el modelo ASR on-device (~370 MB)
flutter run
flutter build apk --release --dart-define=API_BASE_URL=<backend>   # Android firmado
flutter build ios --release --dart-define=API_BASE_URL=<backend>   # iOS (requiere firma)
flutter build macos --release
```

## Anexo B. Corpus de evaluación

Muestra de un ejercicio del nivel A1 con soporte de internacionalización (extracto de `assets/content/a1_course.json`):

```json
{
  "id": "1V01",
  "type": "multiple_choice",
  "question": "¿Cómo se dice «hola» en gallego?",
  "options": ["Hola", "Ola", "Olá"],
  "correctAnswer": "Ola",
  "i18n": {
    "en": { "question": "How do you say \"hello\" in Galician?",
            "explanation": "In Galician \"hello\" is written without an initial h: \"ola\"." },
    "de": { "question": "Wie sagt man auf Galizisch „Hallo“?" },
    "pt": { "question": "Como se diz “olá” em galego?" },
    "fr": { "question": "Comment dit-on « bonjour » en galicien ?" },
    "it": { "question": "Come si dice «ciao» in galiziano?" },
    "ro": { "question": "Cum se spune „salut” în galiciană?" },
    "zh": { "question": "加利西亚语“你好”怎么说？" }
  }
}
```

**Resumen del corpus:** 12 unidades, 70 lecciones y 573 ejercicios, con apartados de Vocabulario (V), Gramática (G), Escucha (E), Ortografía (O), Lectura (L) y Pronuncia (P). Tipos de ejercicio: opción múltiple (200), rellenar huecos (126), traducción (63), emparejar (56), lectura (54), pronunciación (33), dictado (29), ordenar (6) e imagen (6).

## Anexo C. Resultados de la beta y validación de la voz

Reproducción de las tablas de resultados (capítulo 6.1) y de los comandos de análisis:

```bash
EXPORT_TOKEN=<token> python3 backend/analisis_beta_remote.py
```

| Métrica | Valor (fecha de corte) |
|---|---|
| Usuarios | 2 |
| Sesiones diarias | 5 |
| Eventos de repaso | 26 |
| Reportes de incidencia | 2 |

Validación del reconocimiento de voz (33 frases de pronunciación, umbral 0,65):

| Modelo | Similitud media | Aciertos |
|---|---|---|
| Whisper *small* (adoptado) | 0,88 | 94 % |
| Whisper *medium* | 0,94 | 100 % |

---

*Fin de la memoria — Ver 4.0.*




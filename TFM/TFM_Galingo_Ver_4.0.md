# TFM Galingo — Ver 4.0

---

**Universidade de Vigo** · **Escola Superior de Enxeñaría Informática**

Memoria del Trabajo de Fin de Máster que presenta **Lester Andre Fernández Cedeño**
para la obtención del Título de **Máster en Enxeñaría Informática**

## Diseño, implementación y validación de una plataforma gamificada basada en modelos probabilísticos de repetición espaciada para el aprendizaje del idioma gallego (Galingo)

Curso 2025/2026 · Tutor/a: Francisco Javier Rodríguez

---

## Resumen

Este Trabajo de Fin de Máster aborda el diseño, la implementación y la validación de **Galingo**, una plataforma multiplataforma (Android, iOS, macOS, Windows y Web) para la adquisición del gallego en el nivel A1 del Marco Común Europeo de Referencia, dirigida a personas no gallegoparlantes. El problema que se aborda es doble: (i) la exclusión sistemática de las lenguas minorizadas de los ecosistemas comerciales de *microlearning*, que constituye una barrera tecnológica para la integración lingüística de la población migrante en Galicia, y (ii) la falta de herramientas de voz en gallego que funcionen sin conexión.

Se ha construido un sistema completo que integra: un cliente Flutter *offline-first*; un backend desacoplado en FastAPI desplegado en la nube; un motor de retención de memoria que combina la heurística determinista **SM-2** (línea base) con un modelo probabilístico de **Regresión de Vida Media (HLR)**, tanto en el dispositivo como en servidor; y una **capa de voz íntegramente local**, con síntesis de voz (Proxecto Nós) para los ejercicios de escucha y reconocimiento automático del habla *on-device* (sherpa-onnx + Whisper) para la evaluación de la pronunciación. La interfaz y los enunciados están internacionalizados a **ocho idiomas**, manteniendo el gallego como lengua objetivo. La plataforma se ha validado mediante una beta cerrada con telemetría anónima, reporte de incidencias integrado y análisis de retención (D1/D7) y del error del modelo.

**Palabras clave:** microlearning, repetición espaciada, aprendizaje automático, regresión de vida media, procesamiento del lenguaje natural, arquitectura de software, lenguas minorizadas, reconocimiento automático del habla, integración sociocultural.

## Abstract

This Master's Thesis presents the design, implementation and validation of **Galingo**, a cross-platform application (Android, iOS, macOS, Windows and Web) for learning Galician at the A1 level of the Common European Framework of Reference, aimed at non-Galician speakers. The problem addressed is twofold: (i) the systematic exclusion of minority languages from commercial microlearning ecosystems, which creates a technological barrier to the linguistic integration of migrant populations in Galicia, and (ii) the lack of Galician voice tools that work offline.

A complete system has been built that integrates: an *offline-first* Flutter client; a decoupled FastAPI backend deployed in the cloud; a memory-retention engine combining the deterministic **SM-2** heuristic (baseline) with a probabilistic **Half-Life Regression (HLR)** model, both on-device and server-side; and a **fully local voice layer**, with text-to-speech (Proxecto Nós) for listening exercises and *on-device* automatic speech recognition (sherpa-onnx + Whisper) for pronunciation assessment. The interface and the exercise statements are internationalised into **eight languages**, keeping Galician as the target language. The platform has been validated through a closed beta with anonymous telemetry, integrated issue reporting, and retention (D1/D7) and model-error analysis.

**Keywords:** microlearning, spaced repetition, machine learning, half-life regression, natural language processing, software architecture, minority languages, automatic speech recognition, sociocultural integration.

## Índice de contenidos

1. Introducción · 2. Fundamentos y estado del arte · 3. Objetivos, alcance e hipótesis · 4. Planificación y seguimiento · 5. Metodología y solución propuesta · 6. Arquitectura y diseño de software · 7. Tecnologías, datos y reproducibilidad · 8. Especificación y análisis de requisitos · 9. Evaluación experimental · 10. Verificación y calidad del software · 11. Manual de instalación y uso · 12. Discusión · 13. Conclusiones y trabajo futuro · Referencias · Anexos

## Índice de ilustraciones / Índice de tablas

*(Se generarán automáticamente en el documento final.)*

---

# 1. Introducción

## 1.1 Contexto y motivación

La combinación de ingeniería de software, gamificación y aprendizaje automático ha transformado la manera de aprender una segunda lengua durante la última década. Las plataformas globales de microaprendizaje retienen a las personas usuarias mediante bucles de retroalimentación inmediata, pero reservan el desarrollo algorítmico avanzado para las lenguas con mayor tamaño de mercado. Las lenguas minorizadas quedan cubiertas por recursos digitales estáticos, fragmentados y sin metodologías de retención adaptativa.

En el caso del gallego, esta desigualdad tecnológica tiene consecuencias sociales concretas. Galicia recibe población migrante de forma continuada y la lengua propia es un factor central para el arraigo territorial, la inserción laboral y la cohesión familiar. La falta de herramientas accesibles para la inmersión lingüística —sobre todo en los niveles iniciales A1/A2— dificulta el aprendizaje progresivo de adultos y menores. A ello se suma una segunda barrera, específicamente técnica: **ni Android ni iOS ofrecen reconocimiento del habla en gallego de forma nativa**, de modo que cualquier ejercicio de voz que dependa de servicios en la nube exige conexión permanente y compromete la privacidad.

Galingo nace de aplicar ingeniería de producto e inteligencia artificial a este doble problema: facilitar el acceso al gallego con una experiencia interactiva y resolver la voz **en el propio dispositivo**.

## 1.2 Problema de investigación

El problema técnico abordado es la **ineficiencia de los métodos de repaso estático** en las herramientas existentes para el gallego. La ciencia cognitiva describe la retención mediante la curva de olvido de Ebbinghaus, según la cual la probabilidad de recuerdo $p$ tras un tiempo $t$ decae exponencialmente con una fuerza de memoria o vida media $h$:

$$p = 2^{-\frac{t}{h}}$$

Los sistemas de *flashcards* para lenguas minorizadas tratan $h$ como una variable determinista que crece con multiplicadores fijos (algoritmo **SM-2**), sin aprovechar la latencia de respuesta, el historial real de aciertos/fallos ni la dificultad del ítem. El reto es construir una infraestructura que **capture eventos de interacción de forma continua** y los use para **entrenar un modelo que estime $h$** minimizando el error frente a los resultados reales, dentro de una aplicación multiplataforma capaz de responder sin interrumpir la sesión de estudio.

A este reto algorítmico se añade el **reto de voz**: proporcionar síntesis y reconocimiento del habla en gallego **sin conexión**, sin enviar el audio a terceros y funcionando en dispositivos de gama media.

## 1.3 Contribuciones

Las contribuciones principales de este trabajo son:

1. **Un sistema completo y desplegado** de microaprendizaje del gallego (A1), multiplataforma, con cliente Flutter *offline-first* y backend desacoplado.
2. **Doble motor de repetición espaciada** (SM-2 como línea base y HLR como modelo entrenable) implementado tanto en el dispositivo como en servidor, con métrica de error visible para la persona usuaria.
3. **Capa de voz gallega 100 % local**: síntesis neuronal (Proxecto Nós) y reconocimiento *on-device* (sherpa-onnx + Whisper), sin conexión y sin envío de audio.
4. **Internacionalización con lengua objetivo**: interfaz y enunciados en ocho idiomas, con 573 ejercicios y el gallego como contenido.
5. **Ciclo de mejora basado en datos**: telemetría anónima y reporte de incidencias integrado, que han permitido detectar y corregir defectos reales durante la beta.
6. **Un análisis metodológico del sesgo de programación adaptativa** en la evaluación de modelos de recuerdo, de aplicación general a este tipo de sistemas.

## 1.4 Organización de la memoria

El documento se estructura así: el capítulo 2 revisa los fundamentos y el estado del arte; el 3 fija objetivos, alcance e hipótesis; el 4 describe la planificación y su seguimiento; el 5 la metodología y la solución propuesta; el 6 la arquitectura y el diseño del software; el 7 las tecnologías, los datos y la reproducibilidad; el 8 la especificación de requisitos; el 9 la evaluación experimental; el 10 la verificación y calidad del software; el 11 el manual de instalación y uso; el 12 discute resultados, limitaciones y amenazas a la validez; y el 13 recoge las conclusiones y las vías de trabajo futuro.

---

# 2. Fundamentos y estado del arte

## 2.1 Microaprendizaje y gamificación

Las plataformas comerciales de mayor difusión han fijado un patrón de interacción que segmenta el contenido en unidades pequeñas reforzadas por mecánicas de juego (rachas, puntos de experiencia, niveles), optimizando el compromiso diario. Este patrón es eficaz para la retención de usuarios, pero su desarrollo algorítmico se concentra en las lenguas con mayor mercado, dejando a las minorizadas fuera del ecosistema. Galingo adopta esas mecánicas de producto pero las aplica a una lengua minorizada, con especial atención a la **reducción de la fricción cognitiva inicial**.

## 2.2 Repetición espaciada: de la heurística al modelo aprendido

- **SM-2.** El algoritmo de Wozniak [2] sigue siendo el estándar de facto en aplicaciones de *flashcards*. Tras cada intento ajusta un factor de facilidad $EF$ y calcula el siguiente intervalo de repaso. Es sensible al historial, pero sus parámetros de penalización están fijados por quien diseña el sistema y **no se aprenden de los datos**.

- **HLR (Half-Life Regression).** Settles y Meeder [1] proponen asumir la curva de Ebbinghaus pero **estimar la vida media** $h$ a partir de un vector de características $\mathbf{x}$ proyectado por un vector de pesos $\boldsymbol{\theta}$:

$$\hat{h}_{\boldsymbol{\theta}}(\mathbf{x}) = 2^{\boldsymbol{\theta}\cdot\mathbf{x}}, \qquad \hat{p} = 2^{-t/\hat{h}}$$

El modelo se entrena minimizando el error de predicción del recuerdo y de la vida media, con regularización L2. En producción, HLR redujo el error de predicción más de un 45 % frente a los modelos de referencia y aumentó el compromiso diario un 12 % [1].

## 2.3 Aprendizaje automático aplicado a la memoria del usuario

La evaluación de este tipo de modelos exige métricas apropiadas para **predicciones probabilísticas de sucesos binarios**: el error absoluto medio (MAE), el *Brier score* (error cuadrático de la probabilidad), el área bajo la curva ROC (AUC-ROC) y las **curvas de calibración** (probabilidad predicha frente a frecuencia observada). Un aspecto crítico, y a menudo ignorado, es que la **programación de repasos suele ser adaptativa** (los sistemas óptimos asignan intervalos largos a los ítems bien conocidos), lo que **confunde** la relación entre el tiempo transcurrido y el recuerdo observado. Este trabajo analiza explícitamente ese sesgo (§9).

## 2.4 Reconocimiento y síntesis de voz para lenguas minorizadas

- **ASR.** Whisper [9] es un modelo de reconocimiento multilingüe de alta calidad; su tamaño *small* cuantizado a int8 es viable en dispositivos móviles. **sherpa-onnx** [10] permite ejecutar modelos ONNX *on-device* sin conexión. La combinación de ambos resuelve el reconocimiento del habla en gallego **sin depender de servicios en la nube**.
- **TTS.** El **Proxecto Nós** [8] de la Universidade de Santiago de Compostela publica voces neuronales en gallego (entre ellas *Celtia*) y modelos ASR afinados, que constituyen la base de la capa de voz del proyecto.
- **Recursos del ILG.** El Instituto da Lingua Galega ofrece recursos como **CORILGA** [4], relevantes para una futura integración de dictados con voz natural, y recursos de generación automática de lenguaje [5].

## 2.5 Internacionalización y aprendizaje de segundas lenguas

El **Marco Común Europeo de Referencia** [11] organiza la competencia lingüística en niveles; Galingo se centra en el **A1**. Para un público no gallegoparlante, es clave separar el **contenido** (la lengua objetivo, el gallego) del **andamiaje** (enunciados e interfaz), que deben ofrecerse en el idioma del usuario. La cercanía entre gallego y portugués, aprovechada en sistemas de traducción [6], informa además la normalización fonética del texto reconocido (§5).

## 2.6 Posicionamiento de Galingo

Galingo se sitúa en la intersección de estas brechas: no es solo una interfaz de usuario, sino una **infraestructura de software** que (i) traslada un modelo probabilístico de predicción de memoria a una lengua minorizada, (ii) resuelve la voz de forma **local y privada**, y (iii) internacionaliza el andamiaje manteniendo la lengua objetivo. Las aportaciones se contrastan con una línea base determinista (SM-2) y se discuten abiertamente sus limitaciones.

# 3. Objetivos, alcance e hipótesis

## 3.1 Objetivo general

Diseñar, implementar y validar una plataforma multiplataforma, **Galingo**, estructurada bajo el paradigma del microaprendizaje, que integre un algoritmo probabilístico de Regresión de Vida Media entrenado con datos de interacción para optimizar la curva de asimilación del gallego en personas no gallegoparlantes, comparando su rendimiento frente a la heurística clásica SM-2, y que resuelva íntegramente la capa de voz (síntesis y reconocimiento) en el propio dispositivo.

## 3.2 Objetivos específicos

- **O1. Algorítmicos.** Diseñar una base de datos relacional y un proceso de ingesta continua de telemetría; implementar la línea base determinista (SM-2) y el modelo entrenable (HLR); evaluar ambos con métricas apropiadas para recuerdo binario (MAE, *Brier*, AUC-ROC, calibración).
- **O2. Arquitectónicos.** Construir una API desacoplada del cliente, con procesamiento en segundo plano y cola *offline* en el cliente, garantizando que la telemetría no se pierda y que la latencia percibida no se degrade.
- **O3. De producto.** Implementar una interfaz que reduzca la fricción inicial, con componentes reutilizables y mecánicas de gamificación (racha, XP, niveles), integrando el aprendizaje guiado (**O Camiño**), la evaluación y la consulta léxico-verbal (**O Laboratorio**).
- **O4. De voz.** Proporcionar ejercicios de escucha (síntesis gallega) y de pronunciación/dictado (ASR) **sin conexión**, sin enviar el audio a terceros.
- **O5. De internacionalización.** Ofrecer la interfaz y los enunciados en ocho idiomas, manteniendo el gallego como lengua objetivo.
- **O6. De validación.** Desplegar una beta cerrada instrumentada y analizar retención, uso y error del modelo, con discusión honesta de las limitaciones.

## 3.3 Hipótesis

- **H1 (eficiencia predictiva).** Un modelo entrenable basado en HLR obtendrá un **menor error** y una **curva de calibración más ajustada** que SM-2 en la predicción del recuerdo.
- **H2 (retención de producto).** La combinación de microaprendizaje gamificado con repetición espaciada y voz local producirá una **retención en el día 7** superior a la de los recursos estáticos, con menor fricción inicial.

## 3.4 Alcance y limitaciones

- **Nivel A1.** Corpus de **12 unidades, 70 lecciones y 573 ejercicios** (apartados de Vocabulario, Gramática, Escucha, Ortografía, Lectura y Pronuncia). Los niveles A2/B1/B2 quedan desactivados (contenido conservado y reactivable por configuración).
- **Motor verbal.** Consulta de conjugación de verbos regulares en presente, pretérito y futuro de indicativo.
- **Voz.** Síntesis con voz neuronal gallega (Proxecto Nós) y ASR con Whisper *small* multilingüe cuantizado a int8, ejecutado *on-device*; la precisión es buena pero inferior a la de un modelo afinado específicamente, lo que se compensa con una normalización fonética (§5).
- **Distribución.** Beta distribuida como APK firmado (GitHub Releases) y compilaciones locales; sin publicación en tiendas por el coste de las cuentas de desarrollador.

---

# 4. Planificación y seguimiento

## 4.1 Estrategia de trabajo

El desarrollo siguió un enfoque **iterativo e incremental (sprints)**, con un **gate de calidad automático** (análisis estático + batería de pruebas) previo a cada compilación, y una fase final de **beta cerrada instrumentada**. Se mantuvo un documento de seguimiento (*As Built*) que registra, para cada fase, decisiones y artefactos.

## 4.2 Hitos y seguimiento

| Fase | Peso | Estado | Evidencia |
|---|---|---|---|
| 0 — Higiene del repositorio (README, `.gitignore`, CI con gate) | 10 % | ✅ | `.github/workflows`, `README.md` |
| 1 — Internacionalización de la interfaz y del contenido | 20 % | ✅ | 8 locales, curso traducido |
| 2 — Robustez del motor SM-2/HLR (casos límite, MAE) | 10 % | ✅ | `test/*`, MAE en Ajustes |
| 3 — Backend FastAPI + BD + telemetría + feedback | 25 % | ✅ | `backend/`, endpoints desplegados |
| 4 — Responsividad multiplataforma, firma y CI | 15 % | ✅ | Android/iOS/macOS/Windows |
| 5 — Voz local (TTS + ASR on-device) | — | ✅ (ampliación) | sherpa-onnx + Whisper, Proxecto Nós |
| 6 — Beta y métricas | 15 % | 🟡 en curso | telemetría D1/D7, HLR |
| 7 — Memoria Ver 4.0 | 5 % | 🟡 en curso | este documento |

El **cronograma real** se ajustó a lo previsto salvo la **voz local** (fase 5), que surgió como ampliación al comprobar que ni Android ni iOS ofrecen ASR en gallego. Esta decisión eliminó la dependencia de la nube y mejoró la privacidad, a costa de recalibrar el alcance (A1) para priorizar calidad sobre cantidad.

## 4.3 Gestión de riesgos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Coste de infraestructura | Alto | Backend *serverless* gratuito (Modal) + *warm-up* al abrir la app. |
| ASR en gallego inexistente en los SO | Alto | ASR *on-device* (sherpa-onnx + Whisper) y normalización fonética. |
| Tamaño del modelo de voz en móvil | Medio | Modelo *small* int8; modelo intercambiable por tamaño. |
| Muestra de beta pequeña | Alto | Beta abierta y continua; análisis como piloto; motor de repasos para generar repeticiones. |
| Sesgo de programación adaptativa | Alto | Análisis explícito (§9) y simulación con verdad conocida. |
| Cuentas de desarrollador de pago | Medio | Distribución gratuita (APK + sideload iOS). |

---

# 5. Metodología y solución propuesta

## 5.1 Visión general

La solución sustituye los intervalos heurísticos fijos por una **función probabilística de pesos entrenada**, orquestada en una arquitectura cliente-servidor, y traslada toda la **capa de voz al dispositivo**. El flujo de datos es:

```text
┌─────────────── Cliente Flutter (offline-first) ───────────────┐
│ UI (8 idiomas) · O Camiño · lecciones · O Laboratorio         │
│ Motor: SM-2 (línea base) + HLR (on-device)                    │
│ Voz: TTS gallego (Proxecto Nós) · ASR on-device (Whisper)     │
│ Cola de telemetría persistente (Hive) + reporte (shake)       │
└───────────────┬──────────────────────────────────▲───────────┘
                │ eventos / feedback (HTTPS)         │ métricas
                ▼                                    │
┌─────────────── Backend FastAPI (nube) ────────────────────────┐
│ /interaccion · /feedback · /sesion · /estado_memoria · /export│
│ PostgreSQL/SQLite · Entrenamiento HLR (scikit-learn)          │
└───────────────────────────────────────────────────────────────┘
```

## 5.2 SM-2 como línea base determinista

SM-2 mantiene, por ítem, un factor de facilidad $EF$, un número de repeticiones y un intervalo. Tras cada intento con calidad $q$ (acierto→4, fallo→1):

$$EF' = \max\big(1{,}3,\; EF + 0{,}1 - (5-q)(0{,}08 + (5-q)\,0{,}02)\big)$$

El intervalo crece (1 → 6 → $intervalo\cdot EF$) mientras $q\ge3$ y se reinicia a 1 tras un fallo. En la app, la predicción de recuerdo de SM-2 usa la vida media aproximada igual al intervalo vigente: $\hat{p}_{SM2} = 2^{-t/intervalo}$.

## 5.3 Modelo HLR

El vector de características es $\mathbf{x} = [1, \sqrt{1+s}, \sqrt{1+f}, d]$, donde $s$ y $f$ son los aciertos y fallos acumulados del ítem y $d$ su dificultad. La vida media y la probabilidad estimadas son:

$$\hat{h}_{\boldsymbol{\theta}}(\mathbf{x}) = 2^{\boldsymbol{\theta}\cdot\mathbf{x}}, \qquad \hat{p} = 2^{-t/\hat{h}}$$

El entrenamiento minimiza el error de predicción del recuerdo y de la vida media observada, con regularización L2 de peso $\lambda$:

$$\mathcal{L}(\boldsymbol{\theta}) = \sum_i \big(p_i - \hat{p}_{\boldsymbol{\theta}}(\mathbf{x}_i)\big)^2 + \alpha \sum_i \big(h_i - \hat{h}_{\boldsymbol{\theta}}(\mathbf{x}_i)\big)^2 + \lambda \lVert \boldsymbol{\theta}\rVert_2^2$$

donde $h_i$ se deriva del resultado observado con suavizado ($p\in\{0{,}95, 0{,}05\}$). El modelo se ejecuta **on-device** (Dart, para funcionar sin conexión) y se reentrena **en servidor** (scikit-learn) con la telemetría acumulada.

## 5.4 Protocolo de evaluación

- **Partición por usuario** (80 % entrenamiento / 20 % evaluación) para evitar filtración de datos y garantizar la generalización a perfiles no vistos.
- **Métricas**: MAE y *Brier score* (error de probabilidad), AUC-ROC (discriminación) y **curvas de calibración**.
- **Análisis del sesgo de programación**: se contrasta la evaluación sobre datos de planificadores adaptativos (logs reales) con una **simulación con verdad conocida** e intervalos aleatorios.

## 5.5 Capa de voz local

- **Síntesis (TTS).** Voz neuronal gallega (*Celtia*, Proxecto Nós) convertida a audio para los ejercicios de escucha y de pronunciación; se reproduce automáticamente y con botón de repetición.
- **Reconocimiento (ASR).** Whisper *small* int8 ejecutado con **sherpa-onnx** en el dispositivo. La grabación (16 kHz mono) se transcribe localmente y se compara con la frase objetivo mediante una **similitud fonética** tolerante a las variantes gallego/portugués (`nh↔ñ`, `camiñar↔caminhar`), a los dígitos escritos como cifra (`7`→`sete`) y a la segmentación de palabras.
- **Privacidad.** El audio nunca abandona el dispositivo.

## 5.6 Internacionalización con lengua objetivo

La interfaz usa `flutter gen-l10n` (8 locales). Los **enunciados** de los ejercicios viven en un campo `i18n` por idioma, generado y revisado de forma que **el contenido gallego (respuestas, opciones, pasajes) se conserva** y solo se traduce el andamiaje. Se corrigió un defecto por el que los ejercicios de escucha traducían la frase gallega (rompiendo su ocultado).

# 6. Arquitectura y diseño de software

## 6.1 Principios arquitectónicos

El sistema sigue un patrón **cliente-servidor con tres capas** más una **capa de inferencia local**:

1. **Presentación (cliente Flutter).** Multiplataforma, *offline-first*: centraliza el estado, la lógica de ejercicios, el motor de repetición y toda la voz. Cola persistente de telemetría que se sincroniza al recuperar la red.
2. **Aplicación (backend FastAPI).** Ingesta **idempotente** de telemetría (por `event_id`), reportes de incidencia y métricas agregadas. No bloquea al cliente.
3. **Aprendizaje automático.** Entrenamiento del modelo HLR (scikit-learn) y análisis de retención; el modelo también se ejecuta *on-device* como *fallback*.

El MVP se despliega como **backend único** (no microservicios) en una plataforma *serverless* con escalado automático. El cliente no depende del backend: el aprendizaje y la voz operan localmente.

## 6.2 Cliente Flutter

```text
lib/
├── main.dart                    # arranque: Hive, audio, telemetría, router, tema, shake
├── core/
│   ├── constants/app_constants.dart
│   ├── ml/{hlr_engine, sm2_engine}.dart
│   ├── router/app_router.dart
│   ├── services/               # audio, tts, asr, review, telemetría, shake
│   └── theme/app_theme.dart
├── data/                       # datasources, models, repositories (Hive)
└── presentation/
    ├── providers/              # estado (Riverpod): progreso, ajustes
    ├── screens/                # onboarding, home (O Camiño), lesson, review, settings, feedback
    └── widgets/                # gabi, camino_map, speech_exercise, …
```

El **motor de repasos** (`ReviewService`) calcula los ítems vencidos según el intervalo SM-2 almacenado por palabra y construye una **lección de repaso** dinámica, que reutiliza la pantalla de lección en "modo repaso" (registra la sesión sin marcar lecciones ni otorgar XP). Esto garantiza que la persona usuaria **vuelva a ver los ítems en días sucesivos**, generando la secuencia de repasos que necesitan HLR y SM-2.

## 6.3 Backend y API

| Método | Ruta | Descripción |
|---|---|---|
| POST | `/api/v1/interaccion` | Ingesta idempotente de eventos de repaso |
| POST | `/api/v1/feedback` | Reportes de incidencia desde la app |
| POST | `/api/v1/sesion` | Registro de sesión diaria (retención D1/D7) |
| GET | `/api/v1/estado_memoria/{user_id}` | Estado de memoria por usuario |
| GET | `/api/v1/metricas` | Contadores agregados |
| GET | `/api/v1/export` | Exportación completa (protegida por token) |

## 6.4 Modelo de datos

Entidades relacionales (PostgreSQL; SQLite en desarrollo): `Item_Lexico` (lema, categoría, complejidad), `Estado_Memoria` (vida media $h$ y próximo repaso por par usuario-ítem), `Traza_Interaccion` (marca temporal, latencia, resultado, intervalo — *dataset* de entrenamiento), `Reportes_Feedback` y `SesionDiaria`. En el cliente, la persistencia usa **Hive** (progreso, ajustes, usuario y cola de telemetría). La telemetría se preprocesa aplicando una transformación logarítmica a la latencia para atenuar valores atípicos.

## 6.5 Capa de voz

```text
Micrófono → grabación WAV 16 kHz mono (record)
          → sherpa-onnx (Whisper small int8) on-device → transcripción
          → similitud fonética vs. frase objetivo → acierto por palabra
```
El modelo se empaqueta en la app y se copia a almacenamiento interno la primera vez. La síntesis (Celtia) se reproduce desde *assets*.

## 6.6 Secuencia de ejecución

*Onboarding → O Camiño → lección/repaso → evaluación → cola de telemetría → sincronización*. En cada ejercicio, el cliente evalúa la respuesta, actualiza el estado de memoria (SM-2 + HLR) y encola un evento. Un proceso asíncrono reentrena el modelo. El diseño *offline-first* garantiza que el flujo no se interrumpe por falta de red.

---

# 7. Tecnologías, datos y reproducibilidad

## 7.1 Tecnologías

| Componente | Tecnología | Justificación |
|---|---|---|
| Cliente | Flutter / Dart | Un código para Android, iOS, macOS, Windows y Web. |
| Estado | Riverpod | Estado reactivo y testeable. |
| Persistencia local | Hive | *Key-value* sin servidor, ideal *offline-first*. |
| Backend | FastAPI (Python) | API asíncrona, documentación automática, ecosistema de datos. |
| ORM / BD | SQLAlchemy + PostgreSQL/SQLite | Modelo relacional claro y portable. |
| ML | scikit-learn, NumPy | Regresión regularizada y experimentos reproducibles. |
| Despliegue | Modal (*serverless*) | Alojamiento gratuito con escalado; *warm-up* al abrir la app. |
| TTS | Proxecto Nós (voz *Celtia*, VITS ONNX) | Voz neuronal gallega real. |
| ASR | sherpa-onnx + Whisper (int8) | Reconocimiento *on-device*, sin conexión. |
| Audio | `audioplayers`, `record` | Reproducción y grabación. |

## 7.2 Información externa (productos de terceros)

La voz *Celtia* y los modelos del Proxecto Nós son recursos publicados por la USC; Whisper (OpenAI) se distribuye con licencia permisiva; sherpa-onnx es software libre. El dataset de evaluación de repetición espaciada empleado en §9 (FSRS/Anki revlogs) se distribuye con licencia MIT. Se justifica el uso de cada componente por la **ausencia de alternativas específicas para el gallego** y se documentan sus licencias.

## 7.3 Información interna y persistencia

Datos internos: contenido del curso (JSON), audios generados (TTS), modelos de voz, y datos del usuario (progreso, historial de repetición, cola de telemetría). Los identificadores de usuario son **anónimos** (UUID generados en el dispositivo); no se recogen datos personales.

## 7.4 Reproducibilidad

El repositorio incluye: scripts de compilación por plataforma, *pipeline* de CI con gate de tests, *scripts* para descargar/regenerar el modelo de voz y los audios, el *docker-compose* del backend y los **experimentos de evaluación** (§9). El modelo de voz (~370 MB) no se versiona (se descarga con un script) para mantener el repositorio ligero.

## 7.5 Consideraciones éticas y de privacidad

- **Privacidad de voz.** El audio se procesa **íntegramente en el dispositivo**; nunca se envía a terceros.
- **Datos mínimos.** La telemetría es anónima y agregada (resultado, intervalo, dificultad); no incluye contenido del audio ni datos personales.
- **Consentimiento.** La beta informa a las personas participantes de qué datos se recogen y con qué finalidad.
- **Lengua e inclusión.** El proyecto se orienta explícitamente a la inclusión lingüística de población migrante, y la documentación respeta el uso de lenguaje inclusivo.

# 8. Especificación y análisis de requisitos

## 8.1 Actores

- **Persona aprendiente (usuario final):** estudia gallego; usa la app a diario; puede reportar incidencias.
- **Investigador/a (autor):** analiza la telemetría y los reportes; reentrena el modelo; mantiene el sistema.
- **Docente/tutor/a (contexto académico):** supervisa el trabajo; puede consultar resultados agregados.

## 8.2 Requisitos funcionales

- **RF1.** Registrar eventos de interacción por ejercicio: identificador de ítem, resultado, intervalo transcurrido y latencia.
- **RF2.** Calcular y persistir el estado de memoria por par (usuario, ítem) y **programar el próximo repaso** (SM-2/HLR).
- **RF3.** Ofrecer el flujo guiado (**O Camiño**): mapa de unidades y lecciones con progreso y desbloqueo.
- **RF4.** Evaluar ejercicios de **nueve tipos** (opción múltiple, huecos, emparejar, traducción, ordenar, lectura, imagen, audio y voz) con retroalimentación inmediata.
- **RF5.** Proporcionar **audio del modelo** (TTS gallego) y **evaluación de pronunciación** (ASR local) con acierto por palabra.
- **RF6.** Ofrecer una **cola de repaso** de los ítems vencidos.
- **RF7.** Reportar incidencias desde la app (gesto de agitado o Ajustes).
- **RF8.** Sincronizar telemetría y reportes de forma diferida sin conexión.
- **RF9.** Permitir elegir el idioma de interfaz entre ocho locales.

## 8.3 Requisitos no funcionales

- **RNF1 (latencia).** Transiciones de estado percibidas como instantáneas (< 0,1 s; límite < 1 s) [7].
- **RNF2 (privacidad).** El audio de voz nunca abandona el dispositivo.
- **RNF3 (disponibilidad offline).** Aprendizaje y voz funcionan sin conexión.
- **RNF4 (portabilidad).** Un único código para Android, iOS, macOS, Windows y Web.
- **RNF5 (rendimiento de voz).** El ASR se ejecuta en un teléfono de gama media en pocos segundos por frase.
- **RNF6 (mantenibilidad).** Análisis estático sin avisos y batería de pruebas en verde como gate de integración.

## 8.4 Trazabilidad (objetivos → requisitos → pruebas)

| Objetivo | Requisitos | Pruebas |
|---|---|---|
| O1 Algorítmicos | RF1, RF2 | `hlr_engine_test`, `sm2_telemetry_test`, §9 |
| O2 Arquitectónicos | RF1, RF8 | `review_service_test`, verificación de cola offline |
| O3 Producto | RF3, RF4, RF6 | `widget_test`, `responsive_screens_test`, `matching_widget_test` |
| O4 Voz | RF5 | validación de voz (§9.5) |
| O5 i18n | RF9 | `exercise_i18n_test` |
| O6 Validación | RF1, RF7, RF8 | beta + análisis (§9) |

---

# 9. Evaluación experimental

## 9.1 Configuración

- **Plataforma**: cliente Flutter en Android (APK firmado) e iOS (sideload), backend en la nube (Modal).
- **Instrumentación**: telemetría anónima (eventos de repaso, sesiones) y reporte de incidencias.
- **Datos de referencia para el modelo**: *logs* reales de repetición espaciada (FSRS/Anki revlogs, licencia MIT; 3,17 M de repasos, 30 usuarios, 312 195 tarjetas) y una **simulación con verdad conocida**.

## 9.2 Beta cerrada (piloto)

En el momento de redactar esta memoria, el piloto acumulaba:

| Métrica | Valor |
|---|---|
| Personas usuarias | 3 |
| Sesiones diarias | 5 |
| Eventos de repaso | 49 |
| Reportes de incidencia | 2 |

El volumen de eventos ya **permite entrenar** el modelo HLR (≥20 eventos). Los reportes recibidos (texto de cabecera recortado en Android 15/16 y un defecto de traducción/emparejado en alemán) se tradujeron en **correcciones concretas**, evidenciando el valor del canal de *feedback*. La muestra es **pequeña**, por lo que los resultados de retención se consideran **preliminares**.

## 9.3 Retención (D1/D7)

La retención se calcula a partir de las sesiones diarias registradas. Con el tamaño muestral actual, los valores de **D1/D7 son indicativos**, no concluyentes para H2. El sistema está preparado para escalar la muestra (solo requiere más tiempo de uso).

## 9.4 Error del modelo (MAE, Brier, AUC-ROC, calibración) y sesgo de programación

Se evaluó HLR frente a SM-2 sobre **datos reales** (FSRS/Anki) y sobre una **simulación con verdad conocida**.

**Datos reales (3,17 M repasos).**

| Modelo | MAE | RMSE | AUC-ROC |
|---|---|---|---|
| HLR | 0,488 | 0,605 | 0,42 |
| SM-2 | 0,563 | 0,636 | 0,50 |

El HLR **reduce el MAE un 13,3 %** frente a SM-2, pero **la AUC-ROC es ≈0,5 o inferior** en ambos. El análisis de los datos revela la causa: el planificador (FSRS/Anki) **ajusta los intervalos de forma adaptativa** para mantener el recuerdo en ~85 % con independencia del tiempo (probabilidad de recuerdo: 0,88 a 1 día → 0,84 a 100 días). Por tanto, el tiempo transcurrido **no discrimina** y la comparación ingenua **no es válida**. Es el **sesgo de programación adaptativa**, un resultado metodológico de aplicación general a la evaluación de modelos de repaso.

**Simulación con verdad conocida (intervalos aleatorios).**

| Modelo | AUC-ROC | Brier | MAE |
|---|---|---|---|
| HLR | 0,978 | 0,063 | 0,146 |
| SM-2 | 0,980 | 0,014 | 0,032 |

Con intervalos aleatorios (sin sesgo), **ambos modelos discriminan bien** (AUC ≈0,98); las métricas de error (*Brier*/MAE) favorecen a SM-2 porque, con salidas binarias y una tasa base alta (~0,84), esas métricas **premian predecir la tasa base** y no aíslan la calidad del modelo. La conclusión metodológica es que, para recuerdo binario, **AUC-ROC y calibración son las métricas apropiadas**, y que la ventaja de HLR depende de **características ricas** (lexema, latencia, usuario) que el piloto aún no genera en volumen suficiente.

> Estas conclusiones se discuten como **limitaciones y amenazas a la validez** en §12.

## 9.5 Validación de la capa de voz

El modelo ASR se evaluó con las **33 frases de pronunciación** del curso, comparando la transcripción con el texto objetivo mediante la métrica fonética:

| Modelo | Tamaño | Similitud media | Aciertos (umbral 0,65) |
|---|---|---|---|
| Whisper *small* (adoptado) | 374 MB | 0,88 | **94 %** |
| Whisper *medium* | 945 MB | 0,94 | **100 %** |
| *large-v3-turbo* | 989 MB | 0,94 | 97 % |

El modelo *medium* es más preciso pero consume ~1,5–2 GB de RAM (inviable en gama media); se adoptó *small* por su equilibrio. El **conjunto de control** (frase objetivo frente a un audio distinto) **no produjo falsos positivos**, lo que valida la capacidad discriminativa de la métrica.

## 9.6 Estado de las hipótesis

- **H1 (eficiencia predictiva):** **parcialmente contrastada**. El HLR reduce el MAE frente a SM-2 en datos reales, pero la comparación con AUC está confundida por el sesgo de programación; se requiere un diseño experimental con intervalos aleatorios o características ricas para una conclusión firme.
- **H2 (retención de producto):** **no concluyente** con la muestra actual; la infraestructura y el motor de repasos están listos para acumular la muestra necesaria.

---

# 10. Verificación y calidad del software

## 10.1 Estrategia de verificación

Se combinan pruebas **unitarias** (motores SM-2/HLR, servicio de repaso), de ***widget*** e interfaz (tipos de ejercicio, emparejado, responsividad) y de **contenido** (cobertura de internacionalización). El *pipeline* de integración continua ejecuta `flutter analyze` y toda la batería antes de compilar.

## 10.2 Matriz de trazabilidad

La matriz de §8.4 relaciona objetivos, requisitos y pruebas. Cada requisito funcional tiene al menos una prueba o evidencia asociada.

## 10.3 Cobertura funcional de las pruebas

- **Algorítmica:** casos límite de HLR/SM-2 (t→0, h≤0, rachas de fallos, estabilidad, entradas vacías, piso $EF\ge1{,}3$).
- **Producto:** renderizado de ejercicios, emparejado (incluido el caso de **valores duplicados**), responsividad (5 pantallas × 6 tamaños).
- **Contenido:** los 573 ejercicios tienen traducción en los 7 idiomas adicionales y la localización conserva el gallego.
- **Repaso:** cálculo de ítems vencidos y orden por antigüedad.
- **Estado:** **41 pruebas en verde**, `flutter analyze` sin avisos.

## 10.4 Prueba de aceptación

Se verificó el flujo completo en dispositivo real (iPhone): instalación, onboarding, lección, ejercicios de voz (offline), repaso y reporte de incidencias, con la telemetría llegando al backend.

## 10.5 Reproducibilidad

Todos los artefactos (código, contenido, scripts de modelo/experimentos, *docker-compose*) están en el repositorio y se regeneran con comandos documentados (§11 y Anexo B).

# 11. Manual de instalación y uso

## 11.1 Requisitos previos

| Plataforma | Requisitos |
|---|---|
| Android | Android 6.0+, ~1,5 GB libres (incluye el modelo de voz). |
| iOS | iOS 13+; instalación con Apple ID personal (validez 7 días). |
| macOS / Windows | Versión de escritorio; ejecución local. |
| Web | Navegador moderno (voz local no disponible). |
| Backend | Docker (o Python 3.11+), 1 GB de RAM. |

## 11.2 Despliegue del backend

```bash
cd backend
docker compose up --build        # API en http://localhost:8000  ·  /docs
```
Variables: `DATABASE_URL` (conexión SQLAlchemy), `EXPORT_TOKEN` (administración del *export*). En la nube se despliega con `deploy/modal/modal_app.py`.

## 11.3 Compilación y distribución de la app

```bash
flutter pub get
bash tool/fetch_asr_model.sh small        # descarga el modelo ASR (~370 MB)
flutter build apk --release --dart-define=API_BASE_URL=<backend>   # Android firmado
flutter build ios --release --dart-define=API_BASE_URL=<backend>   # iOS (requiere firma)
flutter build macos --release
```

## 11.4 Uso

1. **Primer arranque**: introducir el nombre y elegir idioma.
2. **Estudio diario**: al menos una lección al día en **O Camiño**.
3. **Voz**: escuchar el audio del modelo; la primera vez prepara el modelo de reconocimiento (~1 min) y a partir de ahí evalúa sin conexión.
4. **Repaso**: cuando hay ítems vencidos aparece **"Repaso (N)"** en el HOME.
5. **Incidencias**: agitar el dispositivo o usar Ajustes.

## 11.5 Resolución de problemas frecuentes

- **La voz no arranca la primera vez**: es normal; espera a que termine la preparación del modelo (~1 min).
- **No aparece "Repaso"**: los ítems vencen a partir de ~1 día de su último repaso.
- **El backend no responde**: la app sigue funcionando *offline*; la telemetría se sincroniza después.

---

# 12. Discusión

## 12.1 Lectura conjunta de los resultados

El sistema funciona de extremo a extremo y ha permitido **detectar y corregir defectos reales** a partir de datos de uso. La capa de voz local alcanza una precisión útil (94 % con el modelo adoptado). La evaluación del modelo de memoria, en cambio, revela una **dificultad metodológica de fondo**: sobre datos de planificadores adaptativos, la comparación HLR/SM-2 queda confundida, y las métricas de error sobre salidas binarias no aíslan la calidad del modelo.

## 12.2 Aportación científica

La principal aportación científica es **doble**: (i) trasladar un modelo probabilístico de memoria (HLR) a una lengua minorizada con una capa de voz **local y privada**, y (ii) **identificar y caracterizar el sesgo de programación adaptativa** como amenaza a la validez en la evaluación de modelos de repaso, proponiendo la simulación con verdad conocida y las métricas adecuadas (AUC, calibración).

## 12.3 Aportación de ingeniería

Un sistema completo, multiplataforma, *offline-first*, **distribuido con coste cero** (APK + sideload), con telemetría fiable, reporte de incidencias, motor de repasos e internacionalización con lengua objetivo. La solución a la ausencia de ASR en gallego (ejecución *on-device*) es reutilizable por otras lenguas minorizadas.

## 12.4 Limitaciones

- **Muestra de beta pequeña** (3 usuarios, 49 eventos) → resultados de retención y de modelo **preliminares**.
- **Sin repeticiones suficientes** en la muestra original (corregido con el motor de repasos).
- **Dificultad léxica $d$ aproximada** (proxy de tipo de ejercicio), no léxica real (pendiente de frecuencia ILG/CORILGA).
- **Precisión del ASR** limitada por el modelo multilingüe (no afinado en gallego).
- **Traducciones** generadas y revisadas parcialmente (revisión humana fina pendiente).

## 12.5 Amenazas a la validez

- **Validez interna:** el sesgo de programación adaptativa y la dependencia de la tasa base en métricas binarias.
- **Validez externa:** muestra pequeña y sesgada (usuarios próximos); generalización limitada.
- **Validez de constructo:** la "dificultad" y la "similitud fonética" son aproximaciones.
- **Validez de conclusión:** potencia estadística insuficiente para H2.

## 12.6 Consideraciones éticas

Privacidad de voz (procesamiento local), datos anónimos y mínimos, consentimiento informado en la beta, y orientación explícita a la inclusión lingüística. La documentación respeta el lenguaje inclusivo.

---

# 13. Conclusiones y trabajo futuro

## 13.1 Conclusiones técnicas

- Es viable construir, con recursos limitados, un sistema completo de microaprendizaje para una lengua minorizada con **arquitectura desacoplada**, **offline-first** y **telemetría fiable**.
- Es posible ofrecer **reconocimiento y síntesis de voz en gallego sin conexión**, resolviendo la ausencia de ASR nativo y preservando la privacidad.
- La sustitución de heurísticas fijas por un modelo entrenable es viable, pero su **evaluación exige cuidar el diseño experimental** (sesgo de programación, métricas adecuadas).
- El **coste de distribución puede ser cero**, lo que hace viable un proyecto así sin presupuesto.

## 13.2 Conclusiones personales

El trabajo ha supuesto un ejercicio completo de ingeniería de producto bajo restricciones reales (coste, memoria, precisión, multiplataforma). La detección de defectos a partir de datos reales —y su corrección— ha sido la parte más formativa, junto con la constatación de que la inteligencia artificial y la ingeniería pueden ponerse al servicio de la inclusión lingüística.

## 13.3 Trabajo futuro

- **Escalar la beta** (con el motor de repasos ya operativo) para validar H1 y H2 con potencia estadística.
- **Modelo ASR afinado en gallego** exportado a ONNX para el dispositivo.
- **Deep Knowledge Tracing** [3] como sucesor de HLR.
- **Colaboración con el ILG (CORILGA)** [4] para dictados con voz natural y dificultad léxica real.
- **Publicación en tiendas** (AAB/TestFlight/notarización) y ampliación a A2/B1/B2.
- **Ampliar `O Laboratorio`** a verbos irregulares y mesóclisis.

---

# Referencias

[1] B. Settles and B. Meeder, "A Trainable Spaced Repetition Model for Language Learning," in *Proc. 54th Annual Meeting of the ACL*, Berlin, 2016, pp. 1848–1858.

[2] P. A. Wozniak, "Optimization of learning," Master's thesis, University of Technology in Poznan, 1990.

[3] C. Piech et al., "Deep Knowledge Tracing," in *Advances in Neural Information Processing Systems (NeurIPS)*, vol. 28, 2015.

[4] Instituto da Lingua Galega, "CORILGA: Corpus Oral Informatizado da Lingua Galega," USC. [En línea]. https://ilg.usc.gal

[5] Instituto da Lingua Galega, "Interoperabilidade de recursos e produción automática de linguaxe natural," USC. [En línea]. https://ilg.usc.gal

[6] J. C. Pichel Campos, "Carvalho: Un sistema de traducción estadística inglés-galego…," *Procesamiento del Lenguaje Natural*, SEPLN.

[7] J. Nielsen, "Response Times: The 3 Important Limits," Nielsen Norman Group, 1993. [En línea]. https://www.nngroup.com/articles/response-times-3-important-limits/

[8] Proxecto Nós, USC. Recursos de voz e lingua para o galego (voz *Celtia*; modelos ASR). [En línea]. https://nos.gal

[9] A. Radford et al., "Robust Speech Recognition via Large-Scale Weak Supervision (Whisper)," OpenAI, 2022.

[10] k2-fsa, "sherpa-onnx: Real-time speech recognition and synthesis without internet." [En línea]. https://github.com/k2-fsa/sherpa-onnx

[11] Consejo de Europa, *Marco Común Europeo de Referencia para las lenguas*. Estrasburgo, 2001.

[12] Open Spaced Repetition, "FSRS/Anki review logs dataset (licencia MIT)." [En línea]. https://huggingface.co/datasets/open-spaced-repetition/fsrs-dataset

---

# Anexos

## Anexo A. Manual de despliegue

Backend: `docker compose up --build` (API en `:8000`). Variables: `DATABASE_URL`, `EXPORT_TOKEN`. Endpoints en §6.3. Reentrenamiento: `python train_hlr.py`; análisis: `python analisis_beta_remote.py` (retención D1/D7). Cliente: comandos en §11.3.

## Anexo B. Comandos de reproducción

```bash
# Modelo ASR on-device
bash tool/fetch_asr_model.sh small
# Experimento HLR vs SM-2 (datos reales FSRS)
python backend/experimentos/hlr_vs_sm2_fsrs.py
# Simulación con verdad conocida
python backend/experimentos/simulacion_hlr.py
# Traducción de ejercicios (i18n)
python tool/i18n_exercises.py
```

## Anexo C. Corpus de evaluación

**Resumen:** 12 unidades, 70 lecciones, 573 ejercicios (Vocabulario 12, Gramática 11, Escucha 12, Ortografía 12, Lectura 11, Pronuncia 12 lecciones). Tipos: opción múltiple (200), huecos (126), traducción (63), emparejar (56), lectura (54), pronunciación (33), dictado (29), ordenar (6), imagen (6). Ejemplo de ejercicio con `i18n` en §5.6.

Resultados del piloto y de la voz: §9.2 y §9.5.

---

*Fin de la memoria — Ver 4.0.*





/* Galingo — landing page interactions (vanilla JS) */
(() => {
  'use strict';

  const $ = (sel, root = document) => root.querySelector(sel);
  const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));

  const I18N = {
    gl: {
      'a11y.skip': 'Saltar ao contido',
      'nav.how': 'Como funciona', 'nav.science': 'Ciencia', 'nav.voice': 'Voz',
      'nav.proof': 'Probas', 'nav.roadmap': 'Roadmap', 'nav.download': 'Descarga', 'nav.cta': 'Descargar',
      'hero.badge': 'v1.5.0 · Beta · 100% Offline-First · Open Source',
      'hero.title1': 'Aprende galego falando.', 'hero.title2': 'Sen internet, sen esperas.',
      'hero.sub': 'Microaprendizaxe gamificada con repetición espazada probabilística (HLR) e voz neuronal no dispositivo. Unha app para aprender galego A1 ao teu ritmo, con Gabi ao lado.',
      'hero.cta1': 'Descargar APK Beta', 'hero.cta2': 'Ver código', 'hero.cta3': 'Proba a demo',
      'hero.fact1.k': 'Nivel', 'hero.fact2.k': 'Tests', 'hero.fact3.k': 'Plataformas',
      'demo.title': 'Proba Galingo aquí',
      'demo.tab.voice': 'Escoita', 'demo.tab.vocab': 'Vocabulario', 'demo.tab.hlr': 'Memoria',
      'demo.voice.label': 'Pronuncia', 'demo.voice.q': 'Escoita e repite:', 'demo.voice.play': 'Escoitar',
      'demo.voice.record': 'Gravar',
      'demo.voice.hint': 'Locución real do curso. O recoñecemento de voz da app execútase no dispositivo.',
      'demo.vocab.label': 'Vocabulario', 'demo.vocab.q': '¿Cómo se dice «hola» en galego?',
      'demo.vocab.hint': 'Escolle unha opción e mira a reacción de Gabi.',
      'demo.hlr.label': 'En vivo', 'demo.hlr.q': 'Acertas ou fallas. O modelo actualiza a túa memoria:',
      'demo.hlr.halfLife': 'Vida media', 'demo.hlr.probability': 'p(t)', 'demo.hlr.days': 'días',
      'demo.hlr.right': 'Acertei', 'demo.hlr.wrong': 'Fallei',
      'demo.hlr.hint': 'A dificultade d e os acertos/fallos actualizan a vida media. Sen enviar nada á nube.',
      's1.title': 'O Camiño do Galego',
      's1.sub': 'Tres ideas sinxelas: sesións curtas, práctica multimodal e unha mascota que che acompaña.',
      's1.c1.t': 'Leccións curtas',
      's1.c1.p': 'Sesións de 5–10 minutos, 12 paradas e 70 leccións. Un concepto por pantalla, sen fricción.',
      's1.c1.m': 'leccións', 's1.c1.m2': 'exercicios',
      's1.c2.t': 'Práctica multimodal',
      's1.c2.p': 'Selección, escritura, emparellamento, ditado e voz. O mesmo contido, distintas formas de recuperalo.',
      's1.c2.m': 'tipos de exercicio',
      's1.c3.t': 'Rachas e XP',
      's1.c3.p': 'Gabi celebra os acertos, insiste nos fallos e axuda a converter o estudo nun hábito diario.',
      's1.c3.m': 'racha · niveis · insignias',
      's2.title': 'A ciencia detrás da aprendizaxe',
      's2.sub': 'SM-2 planifica os repasos. HLR estima, en paralelo, cando vas recordar. Dous modelos, un mesmo compromiso: ensinar con datos, non con promesas.',
      's2.formula.k': 'Half-Life Regression',
      's2.formula.p': 'O modelo aprende de acertos (s), fallos (f) e dificultade (d). O vector θ entrena no dispositivo; non se envía á nube.',
      's2.t1': 'SM-2 como planificador determinista.',
      's2.t2': 'HLR como predictor probabilístico en paralelo.',
      's2.t3': 'Avaliación honesta: o piloto non demostrou superioridade de HLR.',
      's2.chart.k': 'Retención estimada', 's2.chart.fixed': 'Intervalo fixo',
      's2.chart.note': 'Curvas ilustrativas · o planificador real é SM-2',
      's3.title': 'Voz 100 % no dispositivo',
      's3.sub': 'Síntese neuronal galega e recoñecemento local. O audio nace e morre no teu teléfono.',
      's3.t1': '<strong>Proxecto Nós</strong> para a voz neuronal en galego.',
      's3.t2': '<strong>Whisper</strong> e sherpa-onnx para recoñecemento <em>on-device</em>.',
      's3.t3': 'Sen conexión, sen latencia de servidor, sen enviar o audio.',
      's3.t4': 'En Web non hai voz local; en Android, iOS e macOS si.',
      's3.link': 'Ver como está implementado',
      's3.f1': 'Micrófono', 's3.f1s': 'WAV · 16 kHz · mono', 's3.f2': 'No dispositivo',
      's3.f3': 'Similitud fonética', 's3.f3s': 'acerto por palabra · 0,65',
      's3.quote': 'A voz non viaxa.',
      's3.privacy': '0 bytes de audio enviados',
      's4.title': 'Datos reais, non promesas',
      's4.sub': 'O que está implementado, o que está probado e o que aínda é futuro. Sen inflar o resultado.',
      's4.m1': 'offline no núcleo', 's4.m1s': 'leccións, repaso e voz',
      's4.m2': 'cifrado local', 's4.m3': 'tests en CI', 's4.m4': 'plataformas',
      's4.th1': 'Compoñente', 's4.th2': 'Estado', 's4.th3': 'Nota',
      's4.ok': 'Probado', 's4.warn': 'Compilado',
      's4.r1': 'Release asinada en GitHub', 's4.r2': 'Sideload · iPhone 13 Pro Max',
      's4.r3': 'Janela nativa · sidebar', 's4.r4': 'Pendente de proba en hardware',
      's4.r5': 'Sen voz local',
      's4.note': 'A telemetría é seudonimizada e agrégase para avaliar a beta. O audio nunca se envía.',
      's5.title': 'Roadmap e estado do proxecto',
      's5.sub': 'Un TFM da Universidade de Vigo (ESEI) que segue medrando por fases.',
      's5.t1': 'A1 completo', 's5.t1p': '12 unidades, 70 leccións, 573 exercicios e os 6 tipos de práctica.',
      's5.t2': 'Motor HLR + SM-2', 's5.t2p': 'Repetición espazada, predición probabilística e avaliación con datos reais.',
      's5.t3': 'Voz local', 's5.t3p': 'TTS do Proxecto Nós e ASR Whisper no dispositivo.',
      's5.next': 'Próximo', 's5.t4': 'A2–B2', 's5.t4p': 'Máis niveis, máis contido e máis voces.',
      's5.t5': 'O Laboratorio', 's5.t5p': 'Verbos irregulares, mesóclise e práctica guiada.',
      's5.t6': 'A Forxa', 's5.t6p': 'Novas mecánicas de práctica e comunidade.',
      's6.title': 'Descarga e código aberto',
      's6.sub': 'Probar Galingo é gratis. O código tamén está aberto para aprender, revisar ou continuar.',
      's6.cta1': 'Descargar APK Beta', 's6.cta2': 'Ver no GitHub',
      's6.build.k': 'Compilar desde a fonte',
      's6.build.note': 'O modelo de voz descárgase aparte. O repositorio inclúe scripts e CI.',
      's6.credits': '<strong>Universidade de Vigo · ESEI</strong> · Traballo de Fin de Máster · Lester Fernández · 2026',
      's6.privacy': 'Política de privacidade', 's6.license': 'CC BY-NC 4.0',
      'footer.tag': 'Aprende galego, paso a paso. Feito en Galicia.',
      'footer.release': 'Release', 'footer.repo': 'GitHub', 'footer.privacy': 'Privacidade',
      'footer.license': 'CC BY-NC 4.0',
      'dyn.voice.playing': 'Reproducindo a locución…',
      'dyn.voice.audioError': 'Non se puido reproducir o audio. Proba de novo.',
      'dyn.voice.listening': 'Simulando o ditado…',
      'dyn.voice.demo': 'Demo visual · similitud {n} %. A app real avalia a pronuncia con Whisper no dispositivo.',
      'dyn.vocab.correct': 'Ben feito! +10 XP. «Ola» é o saúdo básico.',
      'dyn.vocab.wrong': 'Case. A forma correcta é «Ola».',
      'dyn.hlr.right': 'Acertei: +10 XP. A vida media sobe.',
      'dyn.hlr.wrong': 'Fallei: a vida media baixa.'
    },
    es: {
      'a11y.skip': 'Saltar al contenido',
      'nav.how': 'Cómo funciona', 'nav.science': 'Ciencia', 'nav.voice': 'Voz',
      'nav.proof': 'Pruebas', 'nav.roadmap': 'Roadmap', 'nav.download': 'Descarga', 'nav.cta': 'Descargar',
      'hero.badge': 'v1.5.0 · Beta · 100% Offline-First · Open Source',
      'hero.title1': 'Aprende gallego hablando.', 'hero.title2': 'Sin internet, sin esperas.',
      'hero.sub': 'Microaprendizaje gamificado con repetición espaciada probabilística (HLR) y voz neuronal en el dispositivo. Una app para aprender gallego A1 a tu ritmo, con Gabi al lado.',
      'hero.cta1': 'Descargar APK Beta', 'hero.cta2': 'Ver código', 'hero.cta3': 'Prueba la demo',
      'hero.fact1.k': 'Nivel', 'hero.fact2.k': 'Tests', 'hero.fact3.k': 'Plataformas',
      'demo.title': 'Prueba Galingo aquí',
      'demo.tab.voice': 'Escucha', 'demo.tab.vocab': 'Vocabulario', 'demo.tab.hlr': 'Memoria',
      'demo.voice.label': 'Pronunciación', 'demo.voice.q': 'Escucha y repite:', 'demo.voice.play': 'Escuchar',
      'demo.voice.record': 'Grabar',
      'demo.voice.hint': 'Locución real del curso. El reconocimiento de voz de la app se ejecuta en el dispositivo.',
      'demo.vocab.label': 'Vocabulario', 'demo.vocab.q': '¿Cómo se dice «hola» en gallego?',
      'demo.vocab.hint': 'Elige una opción y mira la reacción de Gabi.',
      'demo.hlr.label': 'En vivo', 'demo.hlr.q': 'Aciertas o fallas. El modelo actualiza tu memoria:',
      'demo.hlr.halfLife': 'Vida media', 'demo.hlr.probability': 'p(t)', 'demo.hlr.days': 'días',
      'demo.hlr.right': 'Acerté', 'demo.hlr.wrong': 'Fallé',
      'demo.hlr.hint': 'La dificultad d y los aciertos/fallos actualizan la vida media. Sin enviar nada a la nube.',
      's1.title': 'El Camino del Gallego',
      's1.sub': 'Tres ideas sencillas: sesiones cortas, práctica multimodal y una mascota que te acompaña.',
      's1.c1.t': 'Lecciones cortas',
      's1.c1.p': 'Sesiones de 5–10 minutos, 12 paradas y 70 lecciones. Un concepto por pantalla, sin fricción.',
      's1.c1.m': 'lecciones', 's1.c1.m2': 'ejercicios',
      's1.c2.t': 'Práctica multimodal',
      's1.c2.p': 'Selección, escritura, emparejamiento, dictado y voz. El mismo contenido, distintas formas de recuperarlo.',
      's1.c2.m': 'tipos de ejercicio',
      's1.c3.t': 'Rachas y XP',
      's1.c3.p': 'Gabi celebra los aciertos, insiste en los fallos y ayuda a convertir el estudio en un hábito diario.',
      's1.c3.m': 'racha · niveles · insignias',
      's2.title': 'La ciencia detrás del aprendizaje',
      's2.sub': 'SM-2 planifica los repasos. HLR estima, en paralelo, cuándo vas a recordar. Dos modelos, un mismo compromiso: enseñar con datos, no con promesas.',
      's2.formula.k': 'Half-Life Regression',
      's2.formula.p': 'El modelo aprende de aciertos (s), fallos (f) y dificultad (d). El vector θ se entrena en el dispositivo; no se envía a la nube.',
      's2.t1': 'SM-2 como planificador determinista.',
      's2.t2': 'HLR como predictor probabilístico en paralelo.',
      's2.t3': 'Evaluación honesta: el piloto no demostró superioridad de HLR.',
      's2.chart.k': 'Retención estimada', 's2.chart.fixed': 'Intervalo fijo',
      's2.chart.note': 'Curvas ilustrativas · el planificador real es SM-2',
      's3.title': 'Voz 100 % en el dispositivo',
      's3.sub': 'Síntesis neuronal gallega y reconocimiento local. El audio nace y muere en tu teléfono.',
      's3.t1': '<strong>Proxecto Nós</strong> para la voz neuronal en gallego.',
      's3.t2': '<strong>Whisper</strong> y sherpa-onnx para reconocimiento <em>on-device</em>.',
      's3.t3': 'Sin conexión, sin latencia de servidor, sin enviar el audio.',
      's3.t4': 'En Web no hay voz local; en Android, iOS y macOS sí.',
      's3.link': 'Ver cómo está implementado',
      's3.f1': 'Micrófono', 's3.f1s': 'WAV · 16 kHz · mono', 's3.f2': 'En el dispositivo',
      's3.f3': 'Similitud fonética', 's3.f3s': 'acierto por palabra · 0,65',
      's3.quote': 'La voz no viaja.',
      's3.privacy': '0 bytes de audio enviados',
      's4.title': 'Datos reales, no promesas',
      's4.sub': 'Lo que está implementado, lo que está probado y lo que todavía es futuro. Sin inflar el resultado.',
      's4.m1': 'offline en el núcleo', 's4.m1s': 'lecciones, repaso y voz',
      's4.m2': 'cifrado local', 's4.m3': 'tests en CI', 's4.m4': 'plataformas',
      's4.th1': 'Componente', 's4.th2': 'Estado', 's4.th3': 'Nota',
      's4.ok': 'Probado', 's4.warn': 'Compilado',
      's4.r1': 'Release firmada en GitHub', 's4.r2': 'Sideload · iPhone 13 Pro Max',
      's4.r3': 'Ventana nativa · sidebar', 's4.r4': 'Pendiente de prueba en hardware',
      's4.r5': 'Sin voz local',
      's4.note': 'La telemetría es seudonimizada y se agrega para evaluar la beta. El audio nunca se envía.',
      's5.title': 'Roadmap y estado del proyecto',
      's5.sub': 'Un TFM de la Universidad de Vigo (ESEI) que sigue creciendo por fases.',
      's5.t1': 'A1 completo', 's5.t1p': '12 unidades, 70 lecciones, 573 ejercicios y los 6 tipos de práctica.',
      's5.t2': 'Motor HLR + SM-2', 's5.t2p': 'Repetición espaciada, predicción probabilística y evaluación con datos reales.',
      's5.t3': 'Voz local', 's5.t3p': 'TTS del Proxecto Nós y ASR Whisper en el dispositivo.',
      's5.next': 'Próximo', 's5.t4': 'A2–B2', 's5.t4p': 'Más niveles, más contenido y más voces.',
      's5.t5': 'O Laboratorio', 's5.t5p': 'Verbos irregulares, mesóclisis y práctica guiada.',
      's5.t6': 'A Forxa', 's5.t6p': 'Nuevas mecánicas de práctica y comunidad.',
      's6.title': 'Descarga y código abierto',
      's6.sub': 'Probar Galingo es gratis. El código también está abierto para aprender, revisar o continuar.',
      's6.cta1': 'Descargar APK Beta', 's6.cta2': 'Ver en GitHub',
      's6.build.k': 'Compilar desde la fuente',
      's6.build.note': 'El modelo de voz se descarga aparte. El repositorio incluye scripts y CI.',
      's6.credits': '<strong>Universidad de Vigo · ESEI</strong> · Trabajo de Fin de Máster · Lester Fernández · 2026',
      's6.privacy': 'Política de privacidad', 's6.license': 'CC BY-NC 4.0',
      'footer.tag': 'Aprende gallego, paso a paso. Hecho en Galicia.',
      'footer.release': 'Release', 'footer.repo': 'GitHub', 'footer.privacy': 'Privacidad',
      'footer.license': 'CC BY-NC 4.0',
      'dyn.voice.playing': 'Reproduciendo la locución…',
      'dyn.voice.audioError': 'No se pudo reproducir el audio. Prueba de nuevo.',
      'dyn.voice.listening': 'Simulando el dictado…',
      'dyn.voice.demo': 'Demo visual · similitud {n} %. La app real evalúa la pronunciación con Whisper en el dispositivo.',
      'dyn.vocab.correct': '¡Bien hecho! +10 XP. «Ola» es el saludo básico.',
      'dyn.vocab.wrong': 'Casi. La forma correcta es «Ola».',
      'dyn.hlr.right': 'Acerté: +10 XP. La vida media sube.',
      'dyn.hlr.wrong': 'Fallé: la vida media baja.'
    },
    en: {
      'a11y.skip': 'Skip to content',
      'nav.how': 'How it works', 'nav.science': 'Science', 'nav.voice': 'Voice',
      'nav.proof': 'Proof', 'nav.roadmap': 'Roadmap', 'nav.download': 'Download', 'nav.cta': 'Download',
      'hero.badge': 'v1.5.0 · Beta · 100% Offline-First · Open Source',
      'hero.title1': 'Learn Galician by speaking.', 'hero.title2': 'No internet, no waiting.',
      'hero.sub': 'Gamified microlearning with probabilistic spaced repetition (HLR) and on-device neural voice. An app to learn Galician A1 at your own pace, with Gabi by your side.',
      'hero.cta1': 'Download Beta APK', 'hero.cta2': 'View code', 'hero.cta3': 'Try the demo',
      'hero.fact1.k': 'Level', 'hero.fact2.k': 'Tests', 'hero.fact3.k': 'Platforms',
      'demo.title': 'Try Galingo here',
      'demo.tab.voice': 'Listen', 'demo.tab.vocab': 'Vocabulary', 'demo.tab.hlr': 'Memory',
      'demo.voice.label': 'Pronunciation', 'demo.voice.q': 'Listen and repeat:', 'demo.voice.play': 'Listen',
      'demo.voice.record': 'Record',
      'demo.voice.hint': 'Real course audio. The app’s speech recognition runs on-device.',
      'demo.vocab.label': 'Vocabulary', 'demo.vocab.q': 'How do you say “hello” in Galician?',
      'demo.vocab.hint': 'Pick an option and watch Gabi react.',
      'demo.hlr.label': 'Live', 'demo.hlr.q': 'Get it right or wrong. The model updates your memory:',
      'demo.hlr.halfLife': 'Half-life', 'demo.hlr.probability': 'p(t)', 'demo.hlr.days': 'days',
      'demo.hlr.right': 'I got it', 'demo.hlr.wrong': 'I missed',
      'demo.hlr.hint': 'Difficulty d and hits/misses update the half-life. Nothing is sent to the cloud.',
      's1.title': 'The Galician Way',
      's1.sub': 'Three simple ideas: short sessions, multimodal practice and a mascot that keeps you company.',
      's1.c1.t': 'Short lessons',
      's1.c1.p': '5–10 minute sessions, 12 stops and 70 lessons. One concept per screen, no friction.',
      's1.c1.m': 'lessons', 's1.c1.m2': 'exercises',
      's1.c2.t': 'Multimodal practice',
      's1.c2.p': 'Multiple choice, writing, matching, dictation and voice. The same content, different ways to retrieve it.',
      's1.c2.m': 'exercise types',
      's1.c3.t': 'Streaks and XP',
      's1.c3.p': 'Gabi celebrates wins, nudges you on mistakes and helps turn study into a daily habit.',
      's1.c3.m': 'streak · levels · badges',
      's2.title': 'The science behind learning',
      's2.sub': 'SM-2 schedules reviews. HLR estimates, in parallel, when you will remember. Two models, one commitment: teach with data, not promises.',
      's2.formula.k': 'Half-Life Regression',
      's2.formula.p': 'The model learns from hits (s), misses (f) and difficulty (d). The θ vector trains on-device; it is never sent to the cloud.',
      's2.t1': 'SM-2 as the deterministic scheduler.',
      's2.t2': 'HLR as a probabilistic predictor in parallel.',
      's2.t3': 'Honest evaluation: the pilot did not show HLR superiority.',
      's2.chart.k': 'Estimated retention', 's2.chart.fixed': 'Fixed interval',
      's2.chart.note': 'Illustrative curves · the real scheduler is SM-2',
      's3.title': 'Voice 100% on-device',
      's3.sub': 'Galician neural synthesis and local recognition. Audio is born and dies on your phone.',
      's3.t1': '<strong>Proxecto Nós</strong> for Galician neural voice.',
      's3.t2': '<strong>Whisper</strong> and sherpa-onnx for <em>on-device</em> recognition.',
      's3.t3': 'No connection, no server latency, no audio uploads.',
      's3.t4': 'Web has no local voice; Android, iOS and macOS do.',
      's3.link': 'See how it is implemented',
      's3.f1': 'Microphone', 's3.f1s': 'WAV · 16 kHz · mono', 's3.f2': 'On-device',
      's3.f3': 'Phonetic similarity', 's3.f3s': 'word accuracy · 0.65',
      's3.quote': 'Voice never travels.',
      's3.privacy': '0 bytes of audio sent',
      's4.title': 'Real data, not promises',
      's4.sub': 'What is implemented, what is tested and what is still ahead. No inflated results.',
      's4.m1': 'offline core', 's4.m1s': 'lessons, review and voice',
      's4.m2': 'local encryption', 's4.m3': 'tests in CI', 's4.m4': 'platforms',
      's4.th1': 'Component', 's4.th2': 'Status', 's4.th3': 'Note',
      's4.ok': 'Tested', 's4.warn': 'Built',
      's4.r1': 'Signed release on GitHub', 's4.r2': 'Sideload · iPhone 13 Pro Max',
      's4.r3': 'Native window · sidebar', 's4.r4': 'Pending hardware test',
      's4.r5': 'No local voice',
      's4.note': 'Telemetry is pseudonymous and aggregated for beta evaluation. Audio is never sent.',
      's5.title': 'Roadmap and project status',
      's5.sub': 'A University of Vigo (ESEI) Master’s Thesis growing in phases.',
      's5.t1': 'A1 complete', 's5.t1p': '12 units, 70 lessons, 573 exercises and 6 practice types.',
      's5.t2': 'HLR + SM-2 engine', 's5.t2p': 'Spaced repetition, probabilistic prediction and evaluation with real data.',
      's5.t3': 'Local voice', 's5.t3p': 'Proxecto Nós TTS and Whisper ASR on-device.',
      's5.next': 'Next', 's5.t4': 'A2–B2', 's5.t4p': 'More levels, more content and more voices.',
      's5.t5': 'O Laboratorio', 's5.t5p': 'Irregular verbs, mesoclisis and guided practice.',
      's5.t6': 'A Forxa', 's5.t6p': 'New practice mechanics and community.',
      's6.title': 'Download and open source',
      's6.sub': 'Trying Galingo is free. The code is open too, to learn, review or continue.',
      's6.cta1': 'Download Beta APK', 's6.cta2': 'View on GitHub',
      's6.build.k': 'Build from source',
      's6.build.note': 'The voice model is downloaded separately. The repo includes scripts and CI.',
      's6.credits': '<strong>University of Vigo · ESEI</strong> · Master’s Thesis · Lester Fernández · 2026',
      's6.privacy': 'Privacy policy', 's6.license': 'CC BY-NC 4.0',
      'footer.tag': 'Learn Galician, step by step. Made in Galicia.',
      'footer.release': 'Release', 'footer.repo': 'GitHub', 'footer.privacy': 'Privacy',
      'footer.license': 'CC BY-NC 4.0',
      'dyn.voice.playing': 'Playing the recording…',
      'dyn.voice.audioError': 'Audio could not play. Try again.',
      'dyn.voice.listening': 'Simulating dictation…',
      'dyn.voice.demo': 'Visual demo · {n}% similarity. The real app scores pronunciation with Whisper on-device.',
      'dyn.vocab.correct': 'Well done! +10 XP. «Ola» is the basic greeting.',
      'dyn.vocab.wrong': 'Almost. The correct form is «Ola».',
      'dyn.hlr.right': 'Correct: +10 XP. Half-life goes up.',
      'dyn.hlr.wrong': 'Missed: half-life goes down.'
    }
  };

  const META = {
    gl: {
      title: 'Galingo — Aprende galego falando, sen internet',
      desc: 'Galingo é unha app de microaprendizaxe do galego (A1) con repetición espazada, voz neuronal no dispositivo e un modelo probabilístico de memoria. Beta aberta, código aberto.'
    },
    es: {
      title: 'Galingo — Aprende gallego hablando, sin internet',
      desc: 'Galingo es una app de microaprendizaje del gallego (A1) con repetición espaciada, voz neuronal en el dispositivo y un modelo probabilístico de memoria. Beta abierta, código abierto.'
    },
    en: {
      title: 'Galingo — Learn Galician by speaking, offline',
      desc: 'Galingo is a Galician (A1) microlearning app with spaced repetition, on-device neural voice and a probabilistic memory model. Open beta, open source.'
    }
  };

  let lang = localStorage.getItem('galingo-lang') || 'gl';
  if (!I18N[lang]) lang = 'gl';

  const t = (key) => (I18N[lang] && I18N[lang][key]) || I18N.gl[key] || key;

  function applyLang(next) {
    lang = next;
    localStorage.setItem('galingo-lang', lang);
    document.documentElement.lang = lang;
    const meta = META[lang] || META.gl;
    document.title = meta.title;
    const desc = document.querySelector('meta[name="description"]');
    if (desc) desc.setAttribute('content', meta.desc);
    const ogTitle = document.querySelector('meta[property="og:title"]');
    const ogDesc = document.querySelector('meta[property="og:description"]');
    const ogLocale = document.querySelector('meta[property="og:locale"]');
    if (ogTitle) ogTitle.setAttribute('content', meta.title);
    if (ogDesc) ogDesc.setAttribute('content', meta.desc);
    if (ogLocale) ogLocale.setAttribute('content', lang === 'gl' ? 'gl_ES' : lang === 'es' ? 'es_ES' : 'en_GB');
    $$('[data-i18n]').forEach((el) => { el.textContent = t(el.dataset.i18n); });
    $$('[data-i18n-html]').forEach((el) => { el.innerHTML = t(el.dataset.i18nHtml); });
    $$('[data-lang]').forEach((b) => {
      const on = b.dataset.lang === lang;
      b.classList.toggle('is-active', on);
      b.setAttribute('aria-pressed', String(on));
    });
    resetFeedback();
  }

  function resetFeedback() {
    const vf = $('#voice-feedback');
    const vof = $('#vocab-feedback');
    const hf = $('#hlr-feedback');
    if (vf) vf.textContent = t('demo.voice.hint');
    if (vof) vof.textContent = t('demo.vocab.hint');
    if (hf) hf.textContent = t('demo.hlr.hint');
  }

  // Nav + language
  $$('[data-lang]').forEach((b) => b.addEventListener('click', () => applyLang(b.dataset.lang)));
  applyLang(lang);

  const nav = $('#nav');
  const menu = $('#menu');
  if (menu && nav) {
    menu.addEventListener('click', () => {
      const open = nav.classList.toggle('open');
      menu.setAttribute('aria-expanded', String(open));
    });
    $$('a', nav).forEach((a) => a.addEventListener('click', () => {
      nav.classList.remove('open');
      menu.setAttribute('aria-expanded', 'false');
    }));
  }

  // Reveal on scroll
  const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const reveals = $$('.reveal');
  if (reduce || !('IntersectionObserver' in window)) {
    reveals.forEach((el) => el.classList.add('in'));
  } else {
    const io = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('in');
          io.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12 });
    reveals.forEach((el) => io.observe(el));
  }

  // Demo tabs
  const tabs = $$('[data-demo]');
  function showDemo(name) {
    tabs.forEach((tab) => {
      const on = tab.dataset.demo === name;
      tab.classList.toggle('is-active', on);
      tab.setAttribute('aria-selected', String(on));
    });
    $$('.view').forEach((view) => {
      const on = view.id === `view-${name}`;
      view.classList.toggle('is-active', on);
      view.hidden = !on;
    });
  }
  tabs.forEach((tab) => tab.addEventListener('click', () => showDemo(tab.dataset.demo)));

  // XP + Gabi
  let xp = 0;
  const xpEl = $('#xp');
  const gabiWrap = $('.gabi-wrap');
  function addXp(n) {
    xp += n;
    if (xpEl) {
      xpEl.textContent = String(xp);
      xpEl.animate([{ transform: 'scale(1)' }, { transform: 'scale(1.25)' }, { transform: 'scale(1)' }], { duration: 320, easing: 'ease-out' });
    }
  }
  function gabi(mood) {
    if (!gabiWrap) return;
    gabiWrap.classList.remove('happy', 'sad');
    void gabiWrap.offsetWidth;
    gabiWrap.classList.add(mood);
    setTimeout(() => gabiWrap.classList.remove(mood), 760);
  }

  // Voice demo
  const audio = $('#voice-audio');
  const wave = $('#wave');
  const playBtn = $('#play-audio');
  const recordBtn = $('#record');
  const voiceFeedback = $('#voice-feedback');
  if (audio && wave && playBtn) {
    playBtn.addEventListener('click', async () => {
      try {
        audio.currentTime = 0;
        await audio.play();
        wave.classList.add('playing');
        if (voiceFeedback) voiceFeedback.textContent = t('dyn.voice.playing');
      } catch (_) {
        if (voiceFeedback) voiceFeedback.textContent = t('dyn.voice.audioError');
      }
    });
    audio.addEventListener('ended', () => {
      wave.classList.remove('playing');
      if (voiceFeedback) voiceFeedback.textContent = t('demo.voice.hint');
    });
    audio.addEventListener('pause', () => wave.classList.remove('playing'));
  }

  // The demo is intentionally local: no microphone capture and no speech
  // recognition request. The real app runs Whisper on-device.
  let recording = false;
  if (recordBtn && voiceFeedback) {
    recordBtn.addEventListener('click', () => {
      if (recording) return;
      recording = true;
      recordBtn.disabled = true;
      if (audio) audio.pause();
      voiceFeedback.textContent = t('dyn.voice.listening');
      if (wave) wave.classList.add('playing');
      window.setTimeout(() => {
        if (wave) wave.classList.remove('playing');
        const score = 90 + Math.floor(Math.random() * 7);
        addXp(10);
        gabi('happy');
        voiceFeedback.textContent = t('dyn.voice.demo').replace('{n}', String(score));
        recording = false;
        recordBtn.disabled = false;
      }, 1400);
    });
  }

  // Vocabulary demo
  const vocabOptions = $('#vocab-options');
  const vocabFeedback = $('#vocab-feedback');
  let vocabDone = false;
  if (vocabOptions) {
    $$('button', vocabOptions).forEach((btn) => btn.addEventListener('click', () => {
      if (vocabDone) return;
      const right = btn.dataset.answer === 'right';
      btn.classList.add(right ? 'right' : 'wrong');
      if (right) {
        vocabDone = true;
        addXp(10);
        gabi('happy');
        if (vocabFeedback) vocabFeedback.textContent = t('dyn.vocab.correct');
        $$('button', vocabOptions).forEach((b) => { b.disabled = true; });
      } else {
        gabi('sad');
        if (vocabFeedback) vocabFeedback.textContent = t('dyn.vocab.wrong');
      }
    }));
  }

  // HLR live demo
  const theta = [0.5, 0.35, -0.45, -0.25];
  let s = 6;
  let f = 0;
  let d = 0.5;
  let tDay = 1;

  function halfLife() {
    const power = theta[0] + theta[1] * Math.sqrt(1 + s) + theta[2] * Math.sqrt(1 + f) + theta[3] * d;
    return Math.pow(2, Math.max(-10, Math.min(15, power)));
  }
  function recall(h, t) {
    if (h <= 0.001) return 0;
    return Math.pow(2, Math.max(-20, Math.min(0, -t / h)));
  }
  function drawSpark(h) {
    const path = $('#hlr-path');
    const dot = $('#hlr-dot');
    if (!path || !dot) return;
    const x0 = 10, x1 = 350, y0 = 8, y1 = 70;
    const points = [];
    for (let i = 0; i <= 60; i++) {
      const t = i * 0.5;
      const x = x0 + (t / 30) * (x1 - x0);
      const y = y0 + (1 - recall(h, t)) * (y1 - y0);
      points.push(`${i ? 'L' : 'M'}${x.toFixed(1)} ${y.toFixed(1)}`);
    }
    path.setAttribute('d', points.join(' '));
    const x = x0 + (tDay / 30) * (x1 - x0);
    const y = y0 + (1 - recall(h, tDay)) * (y1 - y0);
    dot.setAttribute('cx', x.toFixed(1));
    dot.setAttribute('cy', y.toFixed(1));
  }
  function updateHlr() {
    const h = halfLife();
    const p = recall(h, tDay);
    const hEl = $('#hlr-h');
    const pEl = $('#hlr-p');
    const tv = $('#hlr-t-value');
    if (hEl) hEl.textContent = h.toFixed(1);
    if (pEl) pEl.textContent = `${(p * 100).toFixed(1)}%`;
    if (tv) tv.textContent = String(tDay);
    drawSpark(h);
  }
  const slider = $('#hlr-t');
  if (slider) {
    slider.addEventListener('input', () => {
      tDay = Number(slider.value);
      updateHlr();
    });
    updateHlr();
  }
  const hlrRight = $('#hlr-right');
  const hlrWrong = $('#hlr-wrong');
  const hlrFeedback = $('#hlr-feedback');
  if (hlrRight) {
    hlrRight.addEventListener('click', () => {
      s += 1;
      addXp(10);
      gabi('happy');
      if (hlrFeedback) hlrFeedback.textContent = t('dyn.hlr.right');
      updateHlr();
    });
  }
  if (hlrWrong) {
    hlrWrong.addEventListener('click', () => {
      f += 1;
      gabi('sad');
      if (hlrFeedback) hlrFeedback.textContent = t('dyn.hlr.wrong');
      updateHlr();
    });
  }

  // Science chart (illustrative)
  function drawScience() {
    const fixed = $('#curve-fixed');
    const hlr = $('#curve-hlr');
    if (!fixed || !hlr) return;
    const x0 = 40, x1 = 500, y0 = 20, y1 = 200;
    const path = (fn) => {
      const parts = [];
      for (let i = 0; i <= 60; i++) {
        const t = i * 0.5;
        const x = x0 + (t / 30) * (x1 - x0);
        const y = y1 - fn(t) * (y1 - y0);
        parts.push(`${i ? 'L' : 'M'}${x.toFixed(1)} ${y.toFixed(1)}`);
      }
      return parts.join(' ');
    };
    fixed.setAttribute('d', path((t) => Math.pow(2, -t / 3)));
    hlr.setAttribute('d', path((t) => Math.pow(2, -t / 12)));
  }
  drawScience();

  const year = $('#year');
  if (year) year.textContent = String(new Date().getFullYear());
})();

# Auditoría profunda de ejercicios y traducciones (2026-10-06)

## Hallazgos principales

- **31 incidencias** en preguntas de opción múltiple / rellenar huecos:
  - `trivial` (26): la palabra del enunciado ya coincide con la respuesta correcta (o es el mismo término), p.ej. "Como se di 'azul' en galego?" → "Azul".
  - `missing` / `duplicate`: 0 nuevas en esta pasada.

- Los ejercicios `trivial` surgen porque la fuente del enunciado está en español y el localize **no traduce la palabra entre comillas**; si la misma palabra sirve en gallego, el ejercicio es trivial.

- En matching, la columna de la derecha devolvía siempre el significado en español (ya corregido ampliando `_dict`).

- En preguntas de tipo "¿Qué significa X?" las opciones sí eran significados en español, que ya se localizan con el criterio `optionsAreTranslations`.

## Corrección propuesta

1. Hacer que `ExerciseModel.localize()` **sustituya la palabra entre comillas** del enunciado por su traducción al idioma de la UI, de modo que:
   - Español → "Como se di 'azul' en galego?" (respuesta: Azul)
   - Alemán → "Wie sagt man 'blau' auf Galicisch?" (respuesta: Azul)
   - Inglés → "How do you say 'blue' in Galician?" (respuesta: Azul)
   Esto convierte los casos `trivial` en ejercicios válidos.

2. Regenerar `assets/content/*.json` ya incorpora la plantilla con la palabra local (si se requiere, se puede precalcular aquí o dejarlo en tiempo de ejecución).

3. Revisar manualmente los casos "Que significa 'morriña'?" y "Rosalía de Castro" donde la fuente ya es la respuesta (contenido), sustituyéndola por una definición suficiente.

## Ítems triviales detectados
- a1_course.json a1_u4_l1_e1 [trivial]: Como se di 'azul' en galego?
- a1_course.json a1_u4_l2_1 [trivial]: Como se di 'azul' en galego?
- a1_course.json a1_u4_l3_1 [trivial]: Como se di 'azul' en galego?
- a1_course.json a1_u5_l1_e1 [trivial]: Como se chama en galego o 'pan'?
- a1_course.json a1_u5_l2_1 [trivial]: Como se chama en galego o 'pan'?
- a1_course.json a1_u5_l3_1 [trivial]: Como se chama en galego o 'pan'?
- a1_course.json a1_u6_l1_e1 [trivial]: Como se di 'comer' en galego?
- a1_course.json a1_u6_l2_1 [trivial]: Como se di 'comer' en galego?
- a1_course.json a1_u6_l3_1 [trivial]: Como se di 'comer' en galego?
- a1_course.json a1_u11_l1_e4 [trivial]: Cal é a diferenza entre "son" e "estou"?
- a1_course.json a1_u11_l3_4 [trivial]: Cal é a diferenza entre "son" e "estou"?
- a1_course.json a1_u12_l1_e1 [trivial]: Como se di "grande" en galego?
- a1_course.json a1_u12_l3_1 [trivial]: Como se di "grande" en galego?
- a2_course.json a2_u1_l1_e1 [trivial]: Como se di 'billete' en galego para viaxar?
- a2_course.json a2_u1_l2_1 [trivial]: Como se di 'billete' en galego para viaxar?
- a2_course.json a2_u1_l3_1 [trivial]: Como se di 'billete' en galego para viaxar?
- a2_course.json a2_u2_l1_e1 [trivial]: Como se di 'camisa' en galego?
- a2_course.json a2_u2_l2_1 [trivial]: Como se di 'camisa' en galego?
- a2_course.json a2_u2_l3_1 [trivial]: Como se di 'camisa' en galego?
- a2_course.json a2_u4_l1_e1 [trivial]: Como se di 'médico' ou 'médica' en galego?
- a2_course.json a2_u4_l2_1 [trivial]: Como se di 'médico' ou 'médica' en galego?
- a2_course.json a2_u4_l3_1 [trivial]: Como se di 'médico' ou 'médica' en galego?
- a2_course.json a2_u5_l1_e1 [trivial]: Como se di "cabeza" en galego?
- a2_course.json a2_u5_l3_1 [trivial]: Como se di "cabeza" en galego?
- a2_course.json a2_u9_l1_e1 [trivial]: Como se di "ordenador" en galego?
- a2_course.json a2_u9_l2_1 [trivial]: Como se di "ordenador" en galego?
- a2_course.json a2_u9_l3_1 [trivial]: Como se di "ordenador" en galego?
- a2_course.json a2_u10_l1_e1 [trivial]: Que significa "morriña"?
- a2_course.json a2_u10_l2_1 [trivial]: Que significa "morriña"?
- a2_course.json a2_u10_l3_1 [trivial]: Que significa "morriña"?
- b2_course.json b2_u1_l2_e1 [trivial]: Como se di 'Rosalía de Castro' en galego?

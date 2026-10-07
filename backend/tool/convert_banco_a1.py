import json, re, pathlib

ING = pathlib.Path('banco_aspirante_a1.md')
OUT = pathlib.Path('assets/content/a1_course.json')

TYPE_MAP = {
    'OM': 'multiple_choice', 'CH': 'fill_blank', 'EM': 'matching',
    'TR': 'translation', 'OR': 'fill_blank', 'DI': 'speech',
    'IM': 'image', 'LE': 'reading',
}
def say(t):
    return TYPE_MAP.get(t.strip().upper(), 'multiple_choice')

units = []
cur = None; cur_lesson = None
lines = ING.read_text(encoding='utf-8').splitlines() if ING.exists() else []
for line in lines:
    mU = re.match(r'^### Unidad (\d+)\.\s+(.+?)\s*\((\d+)\)', line)
    mL = re.match(r'^\|\s*([0-9A-Z]+)\s*\|\s*(\w+)\s*\|\s*(.+?)\s*\|\s*(.+?)\s*\|\s*$', line)
    if mU:
        cur = {'id': f"u{mU.group(1)}", 'title': mU.group(2), 'lessons': []}
        units.append(cur)
    elif mL and mL.group(1)[0].isdigit() and len(mL.group(1))>=2:
        # simplificación: agrupamos por lecciones sintéticas
        ex = {
            'id': mL.group(1),
            'type': say(mL.group(2)),
            'question': mL.group(3).strip(),
            'options': [],
            'correctAnswer': mL.group(4).strip(),
            'i18n': {},
        }
        cur['lessons'].append({'id': f"{cur['id']}_l1", 'title': 'Lección 1', 'exercises': [ex]})

result = {
  'id': 'A1', 'title': 'Nivel A1', 'description': 'Banco de 540 preguntas A1',
  'units': units,
}
OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding='utf-8')
print('OK', OUT)

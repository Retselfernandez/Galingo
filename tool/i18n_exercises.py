#!/usr/bin/env python3
"""Xera as traducións (question/explanation/options/pairs) dos exercicios do curso
para os 7 idiomas (en, de, fr, pt, it, ro, zh) usando MT (Google clients5) e
gardándoas no campo `i18n` de cada exercicio.

Regras:
- O contido GALEGO consérvase (lectura, dictado, encher ocos, imaxe, ordenar e as
  palabras citadas nas preguntas de "¿qué significa?").
- O texto ESPAÑOL (enunciados, opcións de significado) tradúcese.

Uso:
  python3 tool/i18n_exercises.py            # todos
  python3 tool/i18n_exercises.py --limit 5  # proba con 5 exercicios
  python3 tool/i18n_exercises.py --lang en  # só un idioma
"""
import json, re, sys, time, urllib.parse, urllib.request, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
JSON_PATH = os.path.join(ROOT, 'assets', 'content', 'a1_course.json')
CACHE_PATH = os.path.join(ROOT, 'tool', '.i18n_cache.json')
LOCALES = ['en', 'de', 'fr', 'pt', 'it', 'ro', 'zh']

# Opcións que se MANTEÑEN en galego (a resposta é galega).
KEEP_OPT = ['en gallego:', 'plural de', 'contracción de', 'femenino de',
            'contrario de', '¿cuál es correcta', '¿cuál lleva tilde',
            '¿cómo se escribe', '¿cómo se dice', '¿cómo se pregunta',
            '¿qué respondes', '¿qué sonido tiene', '¿cómo empieza']

_cache = {}
if os.path.exists(CACHE_PATH):
    try:
        _cache = json.load(open(CACHE_PATH, encoding='utf-8'))
    except Exception:
        _cache = {}

def _save_cache():
    json.dump(_cache, open(CACHE_PATH, 'w', encoding='utf-8'), ensure_ascii=False)

def _http(url):
    for i in range(4):
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req, timeout=30) as r:
                return json.loads(r.read().decode('utf-8'))
        except Exception:
            time.sleep(0.8 * (i + 1))
    return None

def mt_batch(texts, tl):
    """Traduce unha lista de textos. Devolve a mesma lista traducida."""
    out = [None] * len(texts)
    i = 0
    while i < len(texts):
        chunk, ln = [], 0
        while i < len(texts) and ln < 1200:
            chunk.append((i, texts[i]))
            ln += len(texts[i]) + 6
            i += 1
        pending = [(idx, t) for idx, t in chunk if f'{tl}|{t}' not in _cache]
        for idx, t in chunk:
            if f'{tl}|{t}' in _cache:
                out[idx] = _cache[f'{tl}|{t}']
        if not pending:
            continue
        q = '&'.join('q=' + urllib.parse.quote(t) for _, t in pending)
        url = f'https://clients5.google.com/translate_a/t?client=dict-chrome-ex&sl=es&tl={tl}&{q}'
        data = _http(url)
        if not isinstance(data, list):
            data = [data] if data else []
        for j, (idx, t) in enumerate(pending):
            tr = data[j] if j < len(data) and isinstance(data[j], str) else t
            _cache[f'{tl}|{t}'] = tr
            out[idx] = tr
        time.sleep(0.12)
    return [o if o is not None else texts[k] for k, o in enumerate(out)]

def mt(text, tl):
    if not text:
        return text
    return mt_batch([text], tl)[0]

def is_meaning_kept(options_text):
    q = options_text.lower()
    if re.match(r'^\d{2}:\d{2}:', options_text.strip()):
        return True
    return any(k in q for k in KEEP_OPT)

# Enunciados fixos (sen contido variable) -> tradución manual por idioma.
FIXED = {
    'Empareja.': {'en': 'Match.', 'de': 'Ordne zu.', 'fr': 'Associez.', 'pt': 'Emparelhe.',
                  'it': 'Abbina.', 'ro': 'Asociază.', 'zh': '配对。'},
    'Le en alto esta frase:': {'en': 'Read this sentence aloud:',
        'de': 'Lies diesen Satz laut vor:', 'fr': 'Lisez cette phrase à voix haute :',
        'pt': 'Leia esta frase em voz alta:', 'it': 'Leggi questa frase ad alta voce:',
        'ro': 'Citește cu voce tare această propoziție:', 'zh': '朗读这句话：'},
    '¿Cuál es correcta?': {'en': 'Which one is correct?', 'de': 'Welche ist richtig?',
        'fr': 'Laquelle est correcte ?', 'pt': 'Qual é a correta?',
        'it': "Qual è quella corretta?", 'ro': 'Care este corectă?', 'zh': '哪一个是正确的？'},
    '¿Cuál lleva tilde?': {'en': 'Which one has an accent?', 'de': 'Welches hat einen Akzent?',
        'fr': "Lequel porte l'accent ?", 'pt': 'Qual leva acento?',
        'it': "Quale porta l'accento?", 'ro': 'Care are accent?', 'zh': '哪一个带重音符号？'},
}

# Prefixos de enunciado -> tradución manual (o resto trátase aparte).
PREFIX = {
    'Lee: ': {'en': 'Read: ', 'de': 'Lies: ', 'fr': 'Lisez : ', 'pt': 'Leia: ',
              'it': 'Leggi: ', 'ro': 'Citește: ', 'zh': '阅读：'},
    'Escribe lo que oyes: ': {'en': 'Write what you hear: ', 'de': 'Schreibe, was du hörst: ',
        'fr': 'Écrivez ce que vous entendez : ', 'pt': 'Escreva o que ouve: ',
        'it': 'Scrivi ciò che senti: ', 'ro': 'Scrie ce auzi: ', 'zh': '写出你听到的内容：'},
    'Completa: ': {'en': 'Complete: ', 'de': 'Vervollständige: ', 'fr': 'Complétez : ',
        'pt': 'Complete: ', 'it': 'Completa: ', 'ro': 'Completează: ', 'zh': '填空：'},
    'Ordena los días: ': {'en': 'Order the days: ', 'de': 'Ordne die Tage: ',
        'fr': 'Ordonnez les jours : ', 'pt': 'Ordene os dias: ', 'it': 'Ordina i giorni: ',
        'ro': 'Ordonează zilele: ', 'zh': '排列这些天：'},
    'Ordena: ': {'en': 'Order: ', 'de': 'Ordne: ', 'fr': 'Ordonnez : ', 'pt': 'Ordene: ',
                 'it': 'Ordina: ', 'ro': 'Ordonează: ', 'zh': '排列：'},
    'Elige la imagen de ': {'en': 'Choose the image of ', 'de': 'Wähle das Bild von ',
        'fr': "Choisissez l'image de ", 'pt': 'Escolha a imagem de ',
        'it': "Scegli l'immagine di ", 'ro': 'Alege imaginea cu ', 'zh': '选择……的图片：'},
}


def _protect(rest, t):
    spans = []
    def repl(m):
        spans.append(m.group(0))
        return '@@%d@@' % (len(spans) - 1)
    s = re.sub(r'«[^»]*»', repl, rest)
    if t == 'image':
        s = re.sub(r'\([^)]*\)', repl, s)
    return s, spans


def localize_question(e, tl):
    q, t = e['question'], e['type']
    if q in FIXED:
        return FIXED[q][tl]
    for pre in sorted(PREFIX, key=len, reverse=True):
        if q.startswith(pre):
            rest = q[len(pre):]
            if t == 'ordering':
                return PREFIX[pre][tl] + rest
            s, spans = _protect(rest, t)
            tr = mt(s, tl)
            for i, sp in enumerate(spans):
                tr = tr.replace('@@%d@@' % i, sp)
            return PREFIX[pre][tl] + tr.lstrip()
    if t == 'ordering':
        idx = q.find(':')
        if idx >= 0:
            tr = mt(q[:idx + 1] + ' @@0@@', tl)
            return tr.replace('@@0@@', q[idx + 1:])
        return mt(q, tl)
    if t in ('reading', 'dictation', 'fill_blank', 'image'):
        s, spans = _protect(q, t)
        tr = mt(s, tl)
        for i, sp in enumerate(spans):
            tr = tr.replace('@@%d@@' % i, sp)
        return tr
    return mt(q, tl)

def process(e, tl):
    q = localize_question(e, tl)
    entry = {'question': q}
    expl = (e.get('i18n') or {}).get('es', {}).get('explanation') or e.get('explanation')
    if expl:
        entry['explanation'] = mt(expl, tl)
    hint = e.get('hint')
    if hint:
        entry['hint'] = mt(hint, tl)
    if e['type'] == 'multiple_choice':
        if not is_meaning_kept(e['question']):
            entry['options'] = '\u0001'.join(mt_batch(e['options'], tl))
            entry['correctAnswer'] = mt(e['correctAnswer'], tl)
    elif e['type'] == 'matching' and e.get('matchingPairs'):
        rights = [p.get('right', '') for p in e['matchingPairs']]
        tr = mt_batch(rights, tl)
        pairs = []
        for i, p in enumerate(e['matchingPairs']):
            pairs.append(p.get('left', '') + '\u0001' + tr[i])
        entry['pairs'] = '\u0002'.join(pairs)
    return entry

def collect_strings(e):
    """Tódalas cadeas en español que hai que traducir para un exercicio."""
    out = []
    q, t = e['question'], e['type']
    handled = False
    if q in FIXED:
        handled = True
    else:
        for pre in sorted(PREFIX, key=len, reverse=True):
            if q.startswith(pre):
                if t != 'ordering':
                    s, _ = _protect(q[len(pre):], t)
                    out.append(s)
                handled = True
                break
    if not handled:
        if t == 'ordering':
            idx = q.find(':')
            out.append(q[:idx + 1] + ' @@0@@' if idx >= 0 else q)
        elif t in ('reading', 'dictation', 'fill_blank', 'image'):
            out.append(_protect(q, t)[0])
        else:
            out.append(q)
    expl = (e.get('i18n') or {}).get('es', {}).get('explanation') or e.get('explanation')
    if expl:
        out.append(expl)
    if e.get('hint'):
        out.append(e['hint'])
    if t == 'multiple_choice' and not is_meaning_kept(e['question']):
        out.extend(e['options'])
        out.append(e['correctAnswer'])
    if t == 'matching' and e.get('matchingPairs'):
        out.extend(p.get('right', '') for p in e['matchingPairs'])
    return out


def prewarm(ex, langs):
    """Traduce en lotes todas as cadeas necesarias (enche a caché)."""
    uniq = [s for s in dict.fromkeys(s for e in ex for s in collect_strings(e)) if s]
    for tl in langs:
        todo = [s for s in uniq if f'{tl}|{s}' not in _cache]
        print(f'prewarm {tl}: {len(todo)} cadeas', flush=True)
        mt_batch(todo, tl)
        _save_cache()


def main():
    limit = None
    langs = LOCALES
    if '--limit' in sys.argv:
        limit = int(sys.argv[sys.argv.index('--limit') + 1])
    if '--lang' in sys.argv:
        langs = [sys.argv[sys.argv.index('--lang') + 1]]
    d = json.load(open(JSON_PATH, encoding='utf-8'))
    ex = [e for u in d['units'] for l in u['lessons'] for e in l['exercises']]
    if limit:
        ex = ex[:limit]
    total = len(ex) * len(langs)
    n = 0
    prewarm(ex, langs)
    for e in ex:
        i18n = e.setdefault('i18n', {})
        for tl in langs:
            i18n[tl] = process(e, tl)
            n += 1
            print(f'\r{n}/{total}', end='', flush=True)
            if n % 50 == 0:
                _save_cache()
    _save_cache()
    json.dump(d, open(JSON_PATH, 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
    print('\nFeito. Exercicios:', len(ex), '| idiomas:', langs)

if __name__ == '__main__':
    main()

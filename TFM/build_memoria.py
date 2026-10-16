#!/usr/bin/env python3
"""
Constrúe a memoria dunha versión concreta:
  1. Le o Markdown da versión (TFM_Galingo_Ver_<v>.md).
  2. Renderiza cada bloque ```mermaid a PNG (vía mermaid.ink).
  3. Substitúe os bloques por imaxes nun ficheiro temporal.
  4. Xera o DOCX e o PDF (pandoc + tectonic).

Uso:  python3 build_memoria.py 4.1
"""
import base64, os, re, subprocess, sys, urllib.request

VER = sys.argv[1] if len(sys.argv) > 1 else '4.1'
HERE = os.path.dirname(os.path.abspath(__file__))
os.chdir(HERE)
src = f'TFM_Galingo_Ver_{VER}.md'
os.makedirs('figuras', exist_ok=True)

text = open(src, encoding='utf-8').read()

def render_mermaid(mmd: str) -> bytes:
    b = base64.urlsafe_b64encode(mmd.strip().encode()).decode()
    url = f'https://mermaid.ink/img/{b}?type=png&bgColor=white'
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    return urllib.request.urlopen(req, timeout=60).read()

counter = {'i': 0}
def repl(m):
    counter['i'] += 1
    name = f'figuras/diagrama_{counter["i"]}.png'
    try:
        open(name, 'wb').write(render_mermaid(m.group(1)))
        print(f'  ✓ {name}')
        return f'![Diagrama {counter["i"]}]({name})'
    except Exception as e:
        print(f'  ✗ erro renderizando diagrama {counter["i"]}: {e}')
        return m.group(0)

tmp = re.sub(r'```mermaid\n(.*?)```', repl, text, flags=re.S)
tmp_path = f'_build_ver_{VER}.md'
open(tmp_path, 'w', encoding='utf-8').write(tmp)

print(f'→ DOCX ...')
subprocess.run(['pandoc', tmp_path, '-o', f'TFM Galingo Ver {VER}.docx'], check=True)
print(f'→ PDF ...')
subprocess.run([
    'pandoc', tmp_path, '-o', f'TFM Galingo Ver {VER}.pdf',
    '--pdf-engine=tectonic',
    '-V', 'mainfont=Times New Roman', '-V', 'monofont=Menlo',
    '-V', 'geometry:margin=2.5cm', '-V', 'fontsize=11pt',
    '-V', 'lang=es', '-V', 'colorlinks=true', '-H', 'header.tex',
], check=True)
os.remove(tmp_path)
print(f'✓ Listo: TFM Galingo Ver {VER}.docx / .pdf')

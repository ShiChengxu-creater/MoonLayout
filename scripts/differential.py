"""Cross-check our compiled implementation against Python and real ICU C APIs."""
from pathlib import Path
import ctypes as C
import ctypes.util
import json
import os
import platform
import re
import shutil
import subprocess
import textwrap
import unicodedata
ROOT = Path(__file__).resolve().parent.parent
LOGS = ROOT / '.agent-workplace/verification'
LOGS.mkdir(parents=True, exist_ok=True)

def load_icu():
    candidates = [os.path.join(os.environ.get('SystemRoot', r'C:\Windows'), 'System32', 'icu.dll')] if os.name == 'nt' else []
    candidates += [ctypes.util.find_library('icui18n'), ctypes.util.find_library('icuuc')]
    for name in filter(None, candidates):
        try:
            lib = C.CDLL(name)
            for suffix in [''] + ['_' + str(i) for i in range(100, 59, -1)]:
                if hasattr(lib, 'ubrk_open' + suffix):
                    return lib, suffix
        except OSError:
            pass
    raise RuntimeError('ICU required: Windows system ICU or libicu-dev on Linux')

lib, suffix = load_icu()
def symbol(name): return getattr(lib, name + suffix)
open_break = symbol('ubrk_open')
open_break.argtypes = [C.c_int, C.c_char_p, C.POINTER(C.c_uint16), C.c_int32, C.POINTER(C.c_int32)]
open_break.restype = C.c_void_p
first, next_break, close = [symbol(n) for n in ('ubrk_first', 'ubrk_next', 'ubrk_close')]
for fn in (first, next_break, close): fn.argtypes = [C.c_void_p]
first.restype = next_break.restype = C.c_int32
close.restype = None

def icu_breaks(text):
    raw = text.encode('utf-16-le')
    buf = (C.c_uint16 * (len(raw)//2)).from_buffer_copy(raw)
    status = C.c_int32(0)
    iterator = open_break(2, b'root', buf, len(buf), C.byref(status))
    if status.value > 0 or not iterator: raise RuntimeError('ICU status ' + str(status.value))
    result = []
    try:
        first(iterator) # MoonLayout deliberately excludes start-of-text for LB2.
        while True:
            offset = next_break(iterator)
            if offset == -1: break
            result.append(len(raw[:offset*2].decode('utf-16-le').encode('utf-8')))
    finally: close(iterator)
    return result

proc = subprocess.run([shutil.which('moon'), 'run', 'tools/differential', '--target', 'js'], cwd=ROOT, capture_output=True, text=True, encoding='utf-8')
if proc.returncode: raise SystemExit(proc.stdout + proc.stderr)
cases = [json.loads(line) for line in proc.stdout.splitlines() if line.startswith('{')]
assert len(cases) == 15, 'Differential corpus was not completely emitted'
results = []
for i, case in enumerate(cases):
    s = case['text']
    assert case['nfc'] == unicodedata.normalize('NFC', s), ('NFC', s)
    assert case['nfkc'] == unicodedata.normalize('NFKC', s), ('NFKC', s)
    python_lines = textwrap.wrap(s, width=case['width'])
    if i < 4: assert case['greedy'] == python_lines, ('ASCII wrapping', s)
    icu = icu_breaks(s)
    # This stable corpus uses old assigned characters and default root rules.
    assert case['breaks'] == icu, ('ICU line boundaries', s, case['breaks'], icu)
    if case['greedy'] == python_lines: category = 'equal'
    elif '\t' in s: category = 'tab stops: MoonLayout 4, Python 8'
    elif '\n' in s or '\r' in s: category = 'hard breaks preserved by MoonLayout; Python whitespace replacement'
    else: category = 'display-cell/grapheme/UAX14 layout versus Python code-point wrapping'
    results.append({**case, 'python_wrap': python_lines, 'wrap_comparison': category, 'icu_breaks': icu})
version = (C.c_uint8 * 4)()
symbol('u_getVersion')(version)
report = {'status': 'pass', 'cases': len(cases), 'python': platform.python_version(), 'python_unicode': unicodedata.unidata_version,
          'icu': '.'.join(map(str, version)), 'icu_locale': 'root', 'results': results}
(LOGS / 'differential.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
print(f'PASS differential: {len(cases)} cases, 30 normalization comparisons, 15 ICU boundary comparisons')

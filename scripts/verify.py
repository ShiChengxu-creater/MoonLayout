"""Reproduce local initial acceptance; never pushes or publishes."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile

sys.stdout.reconfigure(encoding='utf-8', errors='replace')
ROOT = Path(__file__).resolve().parent.parent
LOGS = ROOT / '.agent-workplace' / 'verification'
LOGS.mkdir(parents=True, exist_ok=True)
MOON = shutil.which('moon')
if not MOON:
    raise SystemExit('moon is not on PATH')
steps = []

def run(label, args, cwd=ROOT):
    result = subprocess.run(args, cwd=cwd, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, encoding='utf-8', errors='replace')
    (LOGS / (label + '.log')).write_text(result.stdout + result.stderr, encoding='utf-8')
    steps.append({'step': label, 'exit_code': result.returncode})
    if result.returncode:
        print(result.stdout + result.stderr)
        raise SystemExit('FAILED: ' + label)
    print('PASS ' + label, flush=True)
    return result.stdout

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

for record in (ROOT / 'testdata/ucd/SHA256SUMS').read_text().splitlines():
    expected, name = record.split('  ')
    if digest(ROOT / 'testdata/ucd' / name) != expected:
        raise SystemExit('UCD checksum mismatch: ' + name)
print('PASS UCD SHA-256', flush=True)
generated = [p for p in (ROOT / 'break_data').glob('*.mbt')
             if p.name not in ('lookup.mbt', 'properties_test.mbt')]
generated += list((ROOT / 'linebreak').glob('*_conformance_test.mbt'))
generated += list((ROOT / 'segment').glob('*_conformance_test.mbt'))
before = {p: digest(p) for p in generated}
run('regenerate_properties', [MOON, 'run', 'tools/ucd_gen', '--target', 'native', '--', 'testdata/ucd', 'break_data'])
run('regenerate_fixtures', [sys.executable, 'scripts/embed_conformance.py', 'line', 'word', 'sentence'])
run('format_generated', [MOON, 'fmt'])
if any(digest(p) != h for p, h in before.items()):
    raise SystemExit('Generated output changed; review the diff before accepting')
print('PASS generator and fixture idempotence', flush=True)
interfaces = {p: digest(p) for p in ROOT.rglob('*.mbti')
              if not any(part.startswith('.') or part == '_build' for part in p.relative_to(ROOT).parts)}
run('interfaces', [MOON, 'info'])
if any(digest(p) != h for p, h in interfaces.items()):
    raise SystemExit('Public interface changed; review and commit generated interfaces')
run('format_check', [MOON, 'fmt', '--check'])
example_outputs = {}
for target in ('native', 'wasm-gc', 'js'):
    run('check_' + target, [MOON, 'check', '--target', target, '--deny-warn'])
    run('tests_' + target, [MOON, 'test', '--target', target, '--deny-warn'])
    for example in ('wrap_terminal', 'cjk_mixed', 'justify_paragraph', 'word_boundaries'):
        output = run(example + '_' + target, [MOON, 'run', 'examples/' + example, '--target', target])
        displayed = '\n'.join(line for line in output.splitlines()
                              if line.startswith(('|', 'word:', 'sentence:', 'word bytes:')))
        if not displayed:
            raise SystemExit('Example produced no display output: ' + example)
        if example in example_outputs and example_outputs[example] != displayed:
            raise SystemExit('Example output differs by backend: ' + example)
        example_outputs[example] = displayed

run('package', [MOON, 'package'])
manifest = (ROOT / 'moon.mod').read_text()
name = re.search(r'^name\s*=\s*"([^"]+)"', manifest, re.M).group(1)
version = re.search(r'^version\s*=\s*"([^"]+)"', manifest, re.M).group(1)
archive = ROOT / '_build/publish' / (name.replace('/', '-') + '-' + version + '.zip')
consumer = Path(tempfile.mkdtemp(prefix='consumer-', dir=LOGS)).resolve()
assert consumer.is_relative_to(LOGS.resolve())
package = consumer / 'package'
package.mkdir()
with zipfile.ZipFile(archive) as z:
    for item in z.infolist():
        if not (package / item.filename).resolve().is_relative_to(package.resolve()):
            raise SystemExit('Unsafe archive member: ' + item.filename)
    z.extractall(package)
app = consumer / 'app'
app.mkdir()
(consumer / 'moon.work').write_text('members = ["./package", "./app"]\n')
(app / 'moon.mod').write_text(f'name = "acceptance/consumer"\nversion = "0.0.1"\nimport {{ "{name}@{version}" }}\n')
(app / 'moon.pkg').write_text(f'import {{ "{name}" @ml }}\n')
(app / 'consumer.mbt').write_text('''///|
pub fn render(text : String) -> Array[String] {
  @ml.layout(text, @ml.LayoutStyle::new(6, alignment=Center)).map(fn(l) { l.aligned_text })
}
''')
(app / 'consumer_test.mbt').write_text('''///|
test "external packaged API" {
  assert_eq(@consumer.render("你好 abc"), [" 你好 ", " abc  "])
  assert_eq(@ml.word_boundaries("Hello"), [0, 5])
  assert_eq(@ml.sentences("A! B?"), ["A! ", "B?"])
}
''', encoding='utf-8')
for target in ('native', 'wasm-gc', 'js'):
    run('consumer_' + target, [MOON, 'test', '-p', 'acceptance/consumer', '--target', target, '--deny-warn'], cwd=consumer)
summary = {'status': 'pass', 'official_cases': {'line': 19338, 'word': 1944, 'sentence': 512},
           'targets': ['native', 'wasm-gc', 'js'], 'example_runs': 12,
           'package': str(archive), 'package_sha256': digest(archive),
           'consumer': str(consumer), 'steps': steps,
           'published': False, 'pushed': False}
(LOGS / 'summary.json').write_text(json.dumps(summary, indent=2), encoding='utf-8')
print('PASS local initial acceptance; publication is a separate step', flush=True)

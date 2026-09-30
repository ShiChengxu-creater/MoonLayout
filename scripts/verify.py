"""Reproduce local final acceptance; never pushes or publishes."""
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
EXAMPLES = ('wrap_terminal', 'cjk_mixed', 'justify_paragraph', 'word_boundaries',
            'hyphen_wrap', 'optimal_wrap', 'bidi_paragraph', 'markdown_like')

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

run('initial_format_check', [MOON, 'fmt', '--check'])
for record in (ROOT / 'testdata/ucd/SHA256SUMS').read_text().splitlines():
    expected, name = record.split('  ')
    if digest(ROOT / 'testdata/ucd' / name) != expected:
        raise SystemExit('UCD checksum mismatch: ' + name)
print('PASS UCD SHA-256', flush=True)
for record in (ROOT / 'testdata/hyphen/SHA256SUMS').read_text().splitlines():
    expected, filename = record.split('  ')
    if digest(ROOT / 'testdata/hyphen' / filename) != expected:
        raise SystemExit('Hyphenation checksum mismatch: ' + filename)
generated = [p for p in (ROOT / 'break_data').glob('*.mbt')
             if p.name not in ('lookup.mbt', 'properties_test.mbt')]
generated += list((ROOT / 'linebreak').glob('*_conformance_test.mbt'))
generated += list((ROOT / 'segment').glob('*_conformance_test.mbt'))
generated += [ROOT / 'hyphen/english.mbt']
before = {p: digest(p) for p in generated}
run('regenerate_hyphenation', [sys.executable, 'scripts/generate_hyphen.py'])
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
    for example in EXAMPLES:
        output = run(example + '_' + target, [MOON, 'run', 'examples/' + example, '--target', target])
        displayed = '\n'.join(line for line in output.splitlines()
                              if line.startswith(('|', 'word:', 'sentence:', 'word bytes:')))
        if not displayed:
            raise SystemExit('Example produced no display output: ' + example)
        if example in example_outputs and example_outputs[example] != displayed:
            raise SystemExit('Example output differs by backend: ' + example)
        example_outputs[example] = displayed

run('differential', [sys.executable, 'scripts/differential.py'])
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
    names = z.namelist()
    forbidden = ('项目申报书.md', 'goal.md', 'AGENTS.md', '.agent-workplace/', '.git/', '.mooncakes/')
    for filename in names:
        if any(filename == f or filename.startswith(f) for f in forbidden):
            raise SystemExit('Private/development file in release archive: ' + filename)
    for required in ('LICENSE', 'THIRD_PARTY.md', 'hyphen/english.mbt', 'integration/integration.mbt', 'testdata/hyphen/hyph-en-us.tex'):
        if required not in names:
            raise SystemExit('Required release file missing: ' + required)
    for item in z.infolist():
        if not (package / item.filename).resolve().is_relative_to(package.resolve()):
            raise SystemExit('Unsafe archive member: ' + item.filename)
    z.extractall(package)
app = consumer / 'app'
app.mkdir()
(consumer / 'moon.work').write_text('members = ["./package", "./app"]\n')
(app / 'moon.mod').write_text(f'name = "acceptance/consumer"\nversion = "0.0.1"\nimport {{ "{name}@{version}" }}\n')
(app / 'moon.pkg').write_text(f'import {{ "{name}" @ml }}\nimport {{ "{name}/integration" }} for "test"\n', encoding='utf-8')
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
  assert_eq(@ml.optimal_wrap("aaa bb bb ccccc", 6).map(fn(l) { l.text }), ["aaa", "bb bb", "ccccc"])
  let h = @ml.Liang::english()
  assert_eq(@ml.layout_hyphenated("hyphenation", @ml.LayoutStyle::new(7), h)[0].text, "hyphen-")
  let visual = @integration.layout("אבג", @ml.LayoutStyle::new(3), bidi=true)
  assert_eq(visual.lines[0].aligned_text, "גבא")
  assert_eq(@integration.layout("Ａ", @ml.LayoutStyle::new(3), normalization=NFKC).logical_text, "A")
}
''', encoding='utf-8')
for target in ('native', 'wasm-gc', 'js'):
    run('consumer_' + target, [MOON, 'test', '-p', 'acceptance/consumer', '--target', target, '--deny-warn'], cwd=consumer)
summary = {'status': 'pass', 'official_cases': {'line': 19338, 'word': 1944, 'sentence': 512},
           'targets': ['native', 'wasm-gc', 'js'], 'example_runs': len(EXAMPLES) * 3,
           'package': str(archive), 'package_sha256': digest(archive),
           'consumer': str(consumer), 'steps': steps,
           'published': False, 'pushed': False}
(LOGS / 'summary.json').write_text(json.dumps(summary, indent=2), encoding='utf-8')
print('PASS local final acceptance; publication is a separate step', flush=True)

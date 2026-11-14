"""Install an exact Mooncakes release and verify public APIs without a workspace."""
import argparse
import json
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
MODULE = "ShiChengxu/moonlayout"
TESTS = '''///|
test "registry public layout and Unicode integration" {
  let lines = @ml.layout("你好 abc", @ml.LayoutStyle::new(6, alignment=Center))
  assert_eq(lines.map(fn(l) { l.aligned_text }), [" 你好 ", " abc  "])
  assert_eq(lines[0].source + lines[1].source, "你好 abc")
  assert_eq(@ml.word_boundaries("Hello"), [0, 5])
  assert_eq(@ml.sentences("A! B?"), ["A! ", "B?"])
  assert_eq(@ml.optimal_wrap("aaa bb bb ccccc", 6).map(fn(l) { l.text }), ["aaa", "bb bb", "ccccc"])
  let h = @ml.Liang::english()
  assert_eq(@ml.layout_hyphenated("hyphenation", @ml.LayoutStyle::new(7), h)[0].text, "hyphen-")
  assert_eq(@integration.layout("אבג", @ml.LayoutStyle::new(3), bidi=true).lines[0].aligned_text, "גבא")
  assert_eq(@integration.layout("Ａ", @ml.LayoutStyle::new(3), normalization=NFKC).logical_text, "A")
}
'''


def run(command, cwd):
    result = subprocess.run(command, cwd=cwd, capture_output=True, encoding="utf-8",
                            errors="replace", timeout=240)
    if result.returncode:
        raise RuntimeError(f"{command!r}\n{result.stdout}\n{result.stderr}")
    return result.stdout


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--version", required=True, help="Exact Mooncakes release")
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()
    if not re.fullmatch(r"[0-9A-Za-z.+-]+", args.version):
        parser.error("--version expects a release version")
    build = ROOT / "_build"
    build.mkdir(exist_ok=True)
    consumer = Path(tempfile.mkdtemp(prefix="registry-consumer-", dir=build)).resolve()
    for parent in (consumer, *consumer.parents):
        if (parent / "moon.work").exists():
            raise RuntimeError(f"A workspace could substitute local source: {parent}")
    (consumer / "moon.mod").write_text(
        'name = "local/moonlayout_registry_consumer"\nversion = "0.0.0"\n', encoding="utf-8")
    (consumer / "moon.pkg").write_text(
        f'import {{ "{MODULE}" @ml, "{MODULE}/integration" }} for "test"\n', encoding="utf-8")
    (consumer / "consumer_test.mbt").write_text(TESTS, encoding="utf-8")
    run(["moon", "update"], consumer)
    run(["moon", "add", f"{MODULE}@{args.version}"], consumer)
    tree = run(["moon", "tree"], consumer)
    if f"{MODULE}@{args.version}" not in tree:
        raise AssertionError(f"Expected exact registry release:\n{tree}")
    targets = {}
    for target in ("native", "wasm-gc", "js"):
        run(["moon", "check", "--target", target, "--deny-warn"], consumer)
        run(["moon", "build", "--target", target, "--deny-warn"], consumer)
        output = run(["moon", "test", "--target", target, "--deny-warn"], consumer)
        if "Total tests: 1, passed: 1, failed: 0" not in output:
            raise AssertionError(output)
        targets[target] = {"check": "passed", "build": "passed", "public_api_tests": "1/1"}
        print("PASS registry " + target, flush=True)
    report = {"module": MODULE, "version": args.version, "source": "Mooncakes registry",
              "local_workspace_override": False, "targets": targets,
              "dependency_tree": "\n".join(tree.strip().splitlines()[1:])}
    rendered = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    (consumer / "result.json").write_text(rendered, encoding="utf-8")
    if args.out:
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(rendered, encoding="utf-8")
    print(rendered, end="")
    print(f"Fresh consumer: {consumer}")


if __name__ == "__main__":
    main()

# Testing

Run `python scripts/verify.py` from the repository root for the reproducible local acceptance checks. It fails on a nonzero subprocess exit or changed generated data, and writes detailed logs under .agent-workplace/verification. Python is developer tooling only, never a library runtime dependency.

The full matrix is fmt, warning-free check/test for native, wasm-gc and js, all eight examples (24 backend/example runs), generated interface synchronization, UCD hashes and generation idempotence. Official case counts are 19,338 line + 1,944 word + 512 sentence. Each official test batch checks its expected case count as well as every break.

Tests also cover UTF-8 offsets, empty input, invalid indices, CRLF and blank lines, oversized graphemes, emoji/combining sequences, tab stops, ambiguous width, CJK justification, alignment widths and exact source reconstruction. Native has 3 additional generator tests because the tool is native-only.

For external consumption, create a separate `moon.work` with two members: this repository and a new consumer module whose moon.mod imports `ShiChengxu/moonlayout@0.2.0`. The consumer moon.pkg imports `"ShiChengxu/moonlayout" @ml`. Use `@ml.LayoutStyle::new(12, alignment=Center)` and `@ml.layout(...)`; enum arguments are inferred from their expected type.
The verification script builds a fresh consumer against the packaged artifact, not just the development checkout, on all three backends.

Correctness tests do not download Unicode data, read the system clock or access the network. Benchmarks deliberately read a monotonic timer. Dependency resolution can use the MoonBit registry before compilation.


Final-acceptance tests add exhaustive small-paragraph optimal-cost comparison, hard-break and oversized-grapheme regressions, configurable glue, Liang odd/even overlay, English exceptions, invalid provider positions, whitespace/punctuation source offsets, normalization coordinate contracts, paragraph-level BiDi and combined hyphenation/integration. The independently compiled packaged consumer exercises both old and new public APIs.

`python scripts/differential.py` needs system ICU (Windows) or `libicu-dev` (Linux). It runs 15 ICU boundary comparisons, 30 Python normalization comparisons and shared ASCII textwrap comparisons; intentional display-metric differences are classified. Versions and recorded results are in `differential-results.json`.

`moon bench -p ShiChengxu/moonlayout/benchmarks --target native --release` runs nine cases with 10 timed samples each. Timing is evidence, not a CI pass/fail threshold. See BENCHMARKS.md.

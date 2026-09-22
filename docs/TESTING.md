# Testing

Run `python scripts/verify.py` from the repository root for the reproducible local acceptance checks. It fails on a nonzero subprocess exit or changed generated data, and writes detailed logs under .agent-workplace/verification. Python is developer tooling only, never a library runtime dependency.

The full matrix is fmt, warning-free check/test for native, wasm-gc and js, all four examples, generated interface synchronization, UCD hashes and generation idempotence. Official case counts are 19,338 line + 1,944 word + 512 sentence. Each official test batch checks its expected case count as well as every break.

Tests also cover UTF-8 offsets, empty input, invalid indices, CRLF and blank lines, oversized graphemes, emoji/combining sequences, tab stops, ambiguous width, CJK justification, alignment widths and exact source reconstruction. Native has 3 additional generator tests because the tool is native-only.

For external consumption, create a separate `moon.work` with two members: this repository and a new consumer module whose moon.mod imports `ShiChengxu/moonlayout@0.1.0`. The consumer moon.pkg imports `"ShiChengxu/moonlayout" @ml`. Use `@ml.LayoutStyle::new(12, alignment=Center)` and `@ml.layout(...)`; enum arguments are inferred from their expected type.
The verification script builds a fresh consumer against the packaged artifact, not just the development checkout, on all three backends.

No test downloads Unicode data, reads the system clock or accesses the network. Dependency resolution can use the MoonBit registry before compilation.

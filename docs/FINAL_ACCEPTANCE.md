# Final acceptance 0.2.0

The user selected 0.2.0 instead of the original 1.0.0 plan. Final functional scope is retained. Local verification completed on 2026-09-30 with `python scripts/verify.py`; remote publication evidence is recorded separately below.

| Requirement | Evidence |
|---|---|
| Initial behavior retained | Original tests plus complete Unicode 17 fixtures |
| UAX #14/#29 | 19,338 line + 1,944 word + 512 sentence cases, no skipped fixtures |
| Greedy and optimal | Both APIs and facade dispatch; 486 exhaustive paragraph cost cases |
| Configurable glue/penalties | Stretch/shrink, line and hyphen penalties; boundary tests |
| Pluggable hyphenation | Open trait, Liang trie, 4,938 licensed English patterns and 14 exceptions |
| BiDi / normalization | Optional integration package; NFC/NFKC coordinate contract and paragraph-level visual output |
| Eight examples | All eight run on native, wasm-gc and js; displayed outputs agree |
| Three-backend correctness | Native 66/66, wasm-gc 63/63, js 63/63 tests |
| Independent consumption | Extracted 0.2.0 archive tested by a fresh consumer on all three backends |
| Differential validation | 15 real ICU boundary comparisons, 30 Python NFC/NFKC comparisons and shared ASCII textwrap cases |
| Benchmarks | Nine cases, ten timed samples each; raw before/after data in docs/benchmarks |
| UAX matrix and documentation | UAX_SUPPORT, DESIGN, TESTING, LIMITATIONS, BENCHMARKS and RELEASE |
| Licensing | Unicode and English data notices preserved; dependencies pinned in moon.mod |
| Per-step Git | Separate feature/fix/test/performance/documentation commits by ShiChengxu-creater |
| Proposal preserved | SHA-256 BF895368A3E0C93E5E94C7F837DA4A1C60D2C0FAD3443FDF72EF06E9028EBE38 unchanged |

## Measured performance

Native release on the development machine: caching grapheme widths reduced the large optimal-layout benchmark from 2.17 s mean to 102.09 ms mean. Small optimal layout decreased from 85.57 ms to 6.28 ms. This is measured evidence for the cache, not a general throughput guarantee. Quadratic worst-case behavior remains documented.

## Scope qualifications and size

BiDi, normalization and width dependencies use Unicode 16, while the project's own UAX #14/#29 tables and grapheme dependency use Unicode 17. Upstream integration is tested but no new full UAX #9/#15 conformance claim is made. There is no font shaping, full TeX layout, all-language hyphenation or reversible normalization map.

Physical nonblank, non-comment MoonBit lines at final implementation review: 1,994 handwritten implementation/example lines; 568 handwritten test/benchmark lines; 10,570 generated Unicode table lines; 2 compact generated English string lines; 21,974 generated conformance fixture lines. These categories deliberately remain separate. The plan's estimated 7,500–9,500 effective-line target is not met as a handwritten-code count; generated tables also exceed their estimated allocation. No padding or duplicate algorithms were added to imitate that estimate. Functional acceptance is supported by the checks above, not by claiming a false line count.

## Publication evidence

Local implementation and package consumption: passed. The final package excludes the proposal, goal.md, AGENTS.md and local process/cache directories. GitHub clean CI, Mooncakes publication and fresh registry installation are pending at this checkpoint; this local report does not claim they have already succeeded.

For repeatable checks run `python scripts/verify.py`; detailed logs are under `.agent-workplace/verification`. That directory is deliberately excluded from distribution. See RELEASE.md for the migration and rollback plan.

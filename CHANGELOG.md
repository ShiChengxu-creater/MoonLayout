# Changelog

## 0.2.1 — toolchain compatibility (2026-11-14)

- Migrate deprecated derives, optional argument declarations and integer spellings using the current official MoonBit formatter; regenerate public interfaces.
- Update the Unicode table generator to emit current syntax and retain generation idempotence.
- Check, build and test every supported backend, record the actual toolchain and dependencies, and run compatibility CI weekly against the current official release.
- Record source and packaged public API validation in `docs/TOOLCHAIN_COMPATIBILITY.md`; package the verified maintenance as 0.2.1.

## 0.2.0 — final acceptance (2026-09-30)

- Simplified optimal paragraph breaking with space stretch/shrink and configurable penalties.
- Open Hyphenator trait, independently implemented Liang trie, licensed US-English patterns and source-preserving hyphenated layouts.
- Optional NFC/NFKC and paragraph-aware BiDi composition with explicit normalized coordinates.
- Four additional examples, nine benchmarks, measured width-cache optimization, Python/ICU differential corpus and a complete active UAX rule matrix.
- Three-backend checks/tests, eight examples per backend and independent packaged API consumption in CI.
- Fixed discretionary-break offsets after whitespace/punctuation and hard breaks after oversized graphemes.
- Migration: WrapAlgorithm adds Optimal, BreakKind adds Hyphenated, LayoutStyle adds optimal. Use constructors and update exhaustive enum matches. Existing functions retain their default behavior.

## 0.1.0 — initial acceptance (local implementation)

- Unicode 17 UAX #14 line opportunities and UAX #29 word/sentence boundaries.
- Native UCD generator, compressed tables, pinned data and offline conformance.
- Grapheme-safe greedy wrapping with exact UTF-8 source ranges and break kinds.
- Four alignment modes, CJK justification, tab stops and ambiguous width options.
- Root/layout APIs, four examples, reproducible three-backend verification.
- Package namespace `ShiChengxu/moonlayout`, matching the mooncakes account.

Publication evidence and rollback guidance for 0.2.0 are recorded in docs/RELEASE.md and docs/FINAL_ACCEPTANCE.md.

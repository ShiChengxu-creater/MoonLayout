# Design

The dependency graph is `break_data -> linebreak/segment -> wrap -> align -> layout`, with root re-exports for consumers. `internal/text` translates scalar, UTF-16 and UTF-8 positions; `internal/conformance` is a test-only fixture reader.

All public offsets are UTF-8 byte counts. MoonBit strings index UTF-16 code units, so consumers must not use a returned byte offset directly with `s[a:b]`. `Line.source` provides the exact substring without requiring conversion.

Property lookup uses private read-only arrays of inclusive ranges and binary search. Unicode 17 LB1 resolves ambiguous/unknown classes, then LB9 collapses attached marks. The remaining UAX #14 rules execute in normative order. Word segmentation precomputes significant neighbors around ignored characters. Sentence segmentation keeps paragraph separators and sentence suffix context.

Wrapping considers only extended grapheme boundaries from kawaz/grapheme. Default break candidates are the intersection with UAX #14. Word/Sentence preferences add the corresponding boundary intersection; Grapheme permits all grapheme boundaries. If no preferred point fits, a forced grapheme break ensures progress. One oversized grapheme may exceed the requested width.

Display width sums unicodewidth measurements per grapheme. Tabs expand from column zero on each line, default tab stop 4. Trailing ASCII spaces/tabs are kept in the source span but are not measured for fit. Hard line endings include CRLF, CR, LF, VT, FF, NEL, LINE SEPARATOR and PARAGRAPH SEPARATOR.

Alignment pads to the requested width without truncating overflow. Center puts an odd leftover column on the right. Justify distributes leftover columns left to right across inter-word spaces and UAX-permitted CJK grapheme gaps. Final lines and hard-break lines are padded on the right without stretching gaps. No glyph shaping or dictionary analysis occurs. Optional preprocessing and visual output are described below.


## Optimal line breaking

`optimal_wrap` enumerates fitting grapheme edges and uses backwards dynamic programming. It minimizes the number of emergency breaks first, then the sum of nonfinal squared slack, cubic glue adjustment badness, line penalties and hyphen penalties. Last/hard lines have zero slack cost when underfull. Natural boundaries and valid discretionary hyphens outrank forced splits. Ties prefer the farther boundary deterministically. The selected source intervals remain contiguous and lossless.

ASCII spaces may stretch (0–1024 added cells each) or shrink (0–1 removed cell each), with negative options clamped to zero. Final/hard lines are never stretched by the optimizer. Tab expansion remains column-dependent; only non-tab grapheme measurements are cached. The optimizer uses O(n) auxiliary memory and O(n²) worst-case time, with a usually width-bounded candidate window. It is a simplified Knuth–Plass-style model, without fitness classes, TeX boxes or consecutive-hyphen demerits. The exhaustive four-word test checks 486 configurations against an independent enumeration oracle.

## Hyphenation

The `hyphen` package implements a caller-owned Liang trie. Pattern weights combine by maximum; odd maxima permit breaks. Boundary dots, case folding, left/right margins and explicit exceptions are supported for ASCII English. The built-in dataset has 4,938 patterns and 14 exceptions. No runtime data IO occurs. Malformed patterns are ignored. Construct a trie once and reuse it.

The wrapping layer obtains full UAX #29 segment intervals, calls the provider and validates its interior UTF-8 positions against grapheme boundaries. A selected `Hyphenated` edge adds an ASCII hyphen only to display text. The provider can be any downstream implementation of the open `Hyphenator` trait.

## Optional integration

The `integration` package imports pinned ecosystem normalization and BiDi primitives. NFC/NFKC run before layout. `LayoutResult` explicitly contains original and normalized logical text; line offsets address the latter. No reversible normalization map is implied.

BiDi resolves each paragraph once, keeps those embedding levels across soft line breaks, applies the line-specific whitespace reset, then uses upstream reordering and mirroring on grapheme units. Logical source and text remain unchanged; visual alignment happens after reordering. Inserted spaces and hyphens inherit local levels. This terminal-cell adapter preserves combining/ZWJ clusters but is not a font shaping engine and does not claim a new complete UAX #9 implementation.

## API maintenance

Construct options with constructors rather than public struct literals. Generated `.mbti` files are reviewed and checked for drift. Releases within 0.x may extend closed enums or option records; migration notes name such changes. Pure functions and explicit configuration keep output deterministic across supported backends.

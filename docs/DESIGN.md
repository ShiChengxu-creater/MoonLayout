# Design

The dependency graph is `break_data -> linebreak/segment -> wrap -> align -> layout`, with root re-exports for consumers. `internal/text` translates scalar, UTF-16 and UTF-8 positions; `internal/conformance` is a test-only fixture reader.

All public offsets are UTF-8 byte counts. MoonBit strings index UTF-16 code units, so consumers must not use a returned byte offset directly with `s[a:b]`. `Line.source` provides the exact substring without requiring conversion.

Property lookup uses private read-only arrays of inclusive ranges and binary search. Unicode 17 LB1 resolves ambiguous/unknown classes, then LB9 collapses attached marks. The remaining UAX #14 rules execute in normative order. Word segmentation precomputes significant neighbors around ignored characters. Sentence segmentation keeps paragraph separators and sentence suffix context.

Wrapping considers only extended grapheme boundaries from kawaz/grapheme. Default break candidates are the intersection with UAX #14. Word/Sentence preferences add the corresponding boundary intersection; Grapheme permits all grapheme boundaries. If no preferred point fits, a forced grapheme break ensures progress. One oversized grapheme may exceed the requested width.

Display width sums unicodewidth measurements per grapheme. Tabs expand from column zero on each line, default tab stop 4. Trailing ASCII spaces/tabs are kept in the source span but are not measured for fit. Hard line endings include CRLF, CR, LF, VT, FF, NEL, LINE SEPARATOR and PARAGRAPH SEPARATOR.

Alignment pads to the requested width without truncating overflow. Center puts an odd leftover column on the right. Justify distributes leftover columns left to right across inter-word spaces and UAX-permitted CJK grapheme gaps. Final lines and hard-break lines are padded on the right without stretching gaps. No glyph shaping, bidi reordering, normalization or dictionary analysis occurs.

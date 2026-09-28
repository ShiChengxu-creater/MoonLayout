# Unicode support matrix

MoonLayout 0.2.0 implements default Unicode 17.0.0 UAX #14 revision 55 and UAX #29 revision 47. Every active rule is listed below; obsolete numbers are not invented as supported rules. Raw line breaks obey UAX #14; wrapping separately intersects with extended grapheme boundaries. No dictionary tailoring or NLP segmentation is claimed.

All 21,794 official cases are executed: 19,338 LineBreakTest, 1,944 WordBreakTest and 512 SentenceBreakTest, without exclusions. Generated test functions enforce case counts and compare every expected offset. Official case coverage is evidence of conformance, not a formal proof for all strings.

## Line breaks

| Rule | Status | Implementation | Validation |
|---|---|---|---|
| [LB1](https://www.unicode.org/reports/tr14/tr14-55.html#LB1) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB2](https://www.unicode.org/reports/tr14/tr14-55.html#LB2) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB3](https://www.unicode.org/reports/tr14/tr14-55.html#LB3) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB4](https://www.unicode.org/reports/tr14/tr14-55.html#LB4) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB5](https://www.unicode.org/reports/tr14/tr14-55.html#LB5) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB6](https://www.unicode.org/reports/tr14/tr14-55.html#LB6) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB7](https://www.unicode.org/reports/tr14/tr14-55.html#LB7) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB8](https://www.unicode.org/reports/tr14/tr14-55.html#LB8) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB8a](https://www.unicode.org/reports/tr14/tr14-55.html#LB8a) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB9](https://www.unicode.org/reports/tr14/tr14-55.html#LB9) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB10](https://www.unicode.org/reports/tr14/tr14-55.html#LB10) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB11](https://www.unicode.org/reports/tr14/tr14-55.html#LB11) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB12](https://www.unicode.org/reports/tr14/tr14-55.html#LB12) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB12a](https://www.unicode.org/reports/tr14/tr14-55.html#LB12a) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB13](https://www.unicode.org/reports/tr14/tr14-55.html#LB13) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB14](https://www.unicode.org/reports/tr14/tr14-55.html#LB14) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB15a](https://www.unicode.org/reports/tr14/tr14-55.html#LB15a) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB15b](https://www.unicode.org/reports/tr14/tr14-55.html#LB15b) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB15c](https://www.unicode.org/reports/tr14/tr14-55.html#LB15c) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB15d](https://www.unicode.org/reports/tr14/tr14-55.html#LB15d) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB16](https://www.unicode.org/reports/tr14/tr14-55.html#LB16) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB17](https://www.unicode.org/reports/tr14/tr14-55.html#LB17) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB18](https://www.unicode.org/reports/tr14/tr14-55.html#LB18) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB19](https://www.unicode.org/reports/tr14/tr14-55.html#LB19) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB19a](https://www.unicode.org/reports/tr14/tr14-55.html#LB19a) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB20](https://www.unicode.org/reports/tr14/tr14-55.html#LB20) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB20a](https://www.unicode.org/reports/tr14/tr14-55.html#LB20a) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB21](https://www.unicode.org/reports/tr14/tr14-55.html#LB21) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB21a](https://www.unicode.org/reports/tr14/tr14-55.html#LB21a) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB21b](https://www.unicode.org/reports/tr14/tr14-55.html#LB21b) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB22](https://www.unicode.org/reports/tr14/tr14-55.html#LB22) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB23](https://www.unicode.org/reports/tr14/tr14-55.html#LB23) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB23a](https://www.unicode.org/reports/tr14/tr14-55.html#LB23a) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB24](https://www.unicode.org/reports/tr14/tr14-55.html#LB24) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB25](https://www.unicode.org/reports/tr14/tr14-55.html#LB25) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB26](https://www.unicode.org/reports/tr14/tr14-55.html#LB26) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB27](https://www.unicode.org/reports/tr14/tr14-55.html#LB27) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB28](https://www.unicode.org/reports/tr14/tr14-55.html#LB28) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB28a](https://www.unicode.org/reports/tr14/tr14-55.html#LB28a) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB29](https://www.unicode.org/reports/tr14/tr14-55.html#LB29) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB30](https://www.unicode.org/reports/tr14/tr14-55.html#LB30) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB30a](https://www.unicode.org/reports/tr14/tr14-55.html#LB30a) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB30b](https://www.unicode.org/reports/tr14/tr14-55.html#LB30b) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |
| [LB31](https://www.unicode.org/reports/tr14/tr14-55.html#LB31) | Implemented | [line_break_opportunities](../linebreak/linebreak.mbt) | [Official suite](../linebreak/line_conformance_test.mbt) |

## Word boundaries

| Rule | Status | Implementation | Validation |
|---|---|---|---|
| [WB1](https://www.unicode.org/reports/tr29/tr29-47.html#WB1) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB2](https://www.unicode.org/reports/tr29/tr29-47.html#WB2) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB3](https://www.unicode.org/reports/tr29/tr29-47.html#WB3) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB3a](https://www.unicode.org/reports/tr29/tr29-47.html#WB3a) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB3b](https://www.unicode.org/reports/tr29/tr29-47.html#WB3b) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB3c](https://www.unicode.org/reports/tr29/tr29-47.html#WB3c) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB3d](https://www.unicode.org/reports/tr29/tr29-47.html#WB3d) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB4](https://www.unicode.org/reports/tr29/tr29-47.html#WB4) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB5](https://www.unicode.org/reports/tr29/tr29-47.html#WB5) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB6](https://www.unicode.org/reports/tr29/tr29-47.html#WB6) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB7](https://www.unicode.org/reports/tr29/tr29-47.html#WB7) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB7a](https://www.unicode.org/reports/tr29/tr29-47.html#WB7a) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB7b](https://www.unicode.org/reports/tr29/tr29-47.html#WB7b) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB7c](https://www.unicode.org/reports/tr29/tr29-47.html#WB7c) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB8](https://www.unicode.org/reports/tr29/tr29-47.html#WB8) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB9](https://www.unicode.org/reports/tr29/tr29-47.html#WB9) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB10](https://www.unicode.org/reports/tr29/tr29-47.html#WB10) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB11](https://www.unicode.org/reports/tr29/tr29-47.html#WB11) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB12](https://www.unicode.org/reports/tr29/tr29-47.html#WB12) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB13](https://www.unicode.org/reports/tr29/tr29-47.html#WB13) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB13a](https://www.unicode.org/reports/tr29/tr29-47.html#WB13a) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB13b](https://www.unicode.org/reports/tr29/tr29-47.html#WB13b) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB15](https://www.unicode.org/reports/tr29/tr29-47.html#WB15) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB16](https://www.unicode.org/reports/tr29/tr29-47.html#WB16) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |
| [WB999](https://www.unicode.org/reports/tr29/tr29-47.html#WB999) | Implemented | [word_boundaries](../segment/word.mbt) | [Official suite](../segment/word_conformance_test.mbt) |

## Sentence boundaries

| Rule | Status | Implementation | Validation |
|---|---|---|---|
| [SB1](https://www.unicode.org/reports/tr29/tr29-47.html#SB1) | Implemented | [sentence_boundaries](../segment/sentence.mbt) | [Official suite](../segment/sentence_conformance_test.mbt) |
| [SB2](https://www.unicode.org/reports/tr29/tr29-47.html#SB2) | Implemented | [sentence_boundaries](../segment/sentence.mbt) | [Official suite](../segment/sentence_conformance_test.mbt) |
| [SB3](https://www.unicode.org/reports/tr29/tr29-47.html#SB3) | Implemented | [sentence_boundaries](../segment/sentence.mbt) | [Official suite](../segment/sentence_conformance_test.mbt) |
| [SB4](https://www.unicode.org/reports/tr29/tr29-47.html#SB4) | Implemented | [sentence_boundaries](../segment/sentence.mbt) | [Official suite](../segment/sentence_conformance_test.mbt) |
| [SB5](https://www.unicode.org/reports/tr29/tr29-47.html#SB5) | Implemented | [sentence_boundaries](../segment/sentence.mbt) | [Official suite](../segment/sentence_conformance_test.mbt) |
| [SB6](https://www.unicode.org/reports/tr29/tr29-47.html#SB6) | Implemented | [sentence_boundaries](../segment/sentence.mbt) | [Official suite](../segment/sentence_conformance_test.mbt) |
| [SB7](https://www.unicode.org/reports/tr29/tr29-47.html#SB7) | Implemented | [sentence_boundaries](../segment/sentence.mbt) | [Official suite](../segment/sentence_conformance_test.mbt) |
| [SB8](https://www.unicode.org/reports/tr29/tr29-47.html#SB8) | Implemented | [sentence_boundaries](../segment/sentence.mbt) | [Official suite](../segment/sentence_conformance_test.mbt) |
| [SB8a](https://www.unicode.org/reports/tr29/tr29-47.html#SB8a) | Implemented | [sentence_boundaries](../segment/sentence.mbt) | [Official suite](../segment/sentence_conformance_test.mbt) |
| [SB9](https://www.unicode.org/reports/tr29/tr29-47.html#SB9) | Implemented | [sentence_boundaries](../segment/sentence.mbt) | [Official suite](../segment/sentence_conformance_test.mbt) |
| [SB10](https://www.unicode.org/reports/tr29/tr29-47.html#SB10) | Implemented | [sentence_boundaries](../segment/sentence.mbt) | [Official suite](../segment/sentence_conformance_test.mbt) |
| [SB11](https://www.unicode.org/reports/tr29/tr29-47.html#SB11) | Implemented | [sentence_boundaries](../segment/sentence.mbt) | [Official suite](../segment/sentence_conformance_test.mbt) |
| [SB998](https://www.unicode.org/reports/tr29/tr29-47.html#SB998) | Implemented | [sentence_boundaries](../segment/sentence.mbt) | [Official suite](../segment/sentence_conformance_test.mbt) |

## Composed primitives and higher layers

| Capability | Version / status | Evidence |
|---|---|---|
| Extended graphemes | kawaz/grapheme 0.10.4, Unicode 17 | wrap source/grapheme property tests |
| Cell widths | unicodewidth 0.2.1, Unicode 16 | width/tab/ambiguity tests; no font shaping |
| UAX #9 BiDi | bidi 0.5.0, Unicode 16, delegated | paragraph-level integration and mixed-direction tests; not a new full BiDi conformance claim |
| UAX #15 NFC/NFKC | normalization + ucd 0.5.0, Unicode 16, delegated | integration tests and Python differential corpus |
| Liang hyphenation | 4,938 US-English patterns + 14 exceptions | trie overlay, margin, exception and wrapping tests |
| Greedy / optimal wrapping | display cells, not part of UAX #14 conformance | wrap tests, benchmarks, source preservation |
| Alignment | left/right/center/justify, basic CJK | align tests and all-backend examples |

UTF-8 offsets always describe logical input. The integration result makes normalized logical text explicit; it does not claim a reversible map through NFC/NFKC. Visual strings are unsuitable for reconstructing the original input.

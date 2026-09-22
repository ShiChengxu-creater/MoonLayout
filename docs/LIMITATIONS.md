# Scope and limitations of 0.1.0

- UAX #14/#29 and grapheme segmentation are Unicode 17.0.0. The pinned width dependency reports Unicode 16.0.0; new Unicode 17 characters may have width behavior inherited from that older table. This is a documented dependency limitation, not a claim of Unicode 17 width-table conformance.
- Width is an additive grapheme cell metric from unicodewidth, not shaped font width. Cross-grapheme ligatures, proportional fonts and terminal differences are outside the contract. Tabs expand to configurable stops; other controls follow the dependency's behavior except hard line endings (zero width).
- Default Unicode boundaries do not perform dictionary-based Thai/Lao/Khmer breaking, abbreviation dictionaries or Chinese NLP word segmentation. Empty text returns no layout lines. Trailing hard breaks produce a final empty line. Whitespace-only input retains its source and has empty display content.
- Width <= 0 normalizes to 1. Oversized graphemes remain intact and may overflow. Alignment never truncates text to hide overflow.
- Display text trims trailing ASCII spaces/tabs and removes hard breaks. Raw source ranges remain lossless. Padded/aligned strings cannot reconstruct the source; use Line.source.
- The raw linebreak API follows UAX #14 exactly. It is not itself a promise that every break is an extended-grapheme boundary. The wrap API adds that guarantee.
- Only Greedy is exposed. Optimal breaking, Liang hyphenation, bidi and optional normalization are deferred. Public offsets are UTF-8 bytes, not UTF-16 indices.
- The plan's line counts are estimates. Generated data, generated conformance fixtures, handwritten algorithms and handwritten tests are reported separately; no repeated code is added to meet a line quota.

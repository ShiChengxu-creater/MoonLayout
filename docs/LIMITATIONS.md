# Scope and limitations of 0.2.0

- UAX #14/#29 and grapheme segmentation are Unicode 17.0.0. The pinned width dependency reports Unicode 16.0.0; new Unicode 17 characters may have width behavior inherited from that older table. This is a documented dependency limitation, not a claim of Unicode 17 width-table conformance.
- Width is an additive grapheme cell metric from unicodewidth, not shaped font width. Cross-grapheme ligatures, proportional fonts and terminal differences are outside the contract. Tabs expand to configurable stops; other controls follow the dependency's behavior except hard line endings (zero width).
- Default Unicode boundaries do not perform dictionary-based Thai/Lao/Khmer breaking, abbreviation dictionaries or Chinese NLP word segmentation. Empty text returns no layout lines. Trailing hard breaks produce a final empty line. Whitespace-only input retains its source and has empty display content.
- Width <= 0 normalizes to 1. Oversized graphemes remain intact and may overflow. Alignment never truncates text to hide overflow.
- Display text trims trailing ASCII spaces/tabs and removes hard breaks. Raw source ranges remain lossless. Padded/aligned strings cannot reconstruct the source; use Line.source.
- The raw linebreak API follows UAX #14 exactly. It is not itself a promise that every break is an extended-grapheme boundary. The wrap API adds that guarantee.
- Optimal is simplified: no full TeX fitness classes, shaping or paragraph pagination. Worst-case quadratic time can be expensive for very wide or zero-width-heavy input. Greedy remains the interactive default.
- English Liang patterns do not cover all languages or guarantee every linguistic syllable boundary. The built-in provider accepts ASCII words only; custom providers can implement other languages. Soft-hyphen substitution and language-specific dictionaries are not a complete browser CSS hyphenation implementation.
- BiDi and normalization dependencies target Unicode 16. Integration tests validate composition, not full upstream UAX #9/#15 conformance. Arabic output is reordered but not shaped. Terminals may themselves apply BiDi; avoid applying visual reordering twice.
- Normalization can change length or compatibility distinctions. Integration line offsets address normalized logical text; use original_text to retain the input. Visual strings are not source maps.
- Optimal glue adjusts ASCII space cells; it is not proportional-font justification. Leading ASCII spaces participate in that configurable adjustment. Public offsets remain UTF-8 bytes, not UTF-16 indices.
- The plan's line counts are estimates. Generated data, generated conformance fixtures, handwritten algorithms and handwritten tests are reported separately; no repeated code is added to meet a line quota.

# References

- Unicode 17.0.0 UAX #14 revision 55:
  https://www.unicode.org/reports/tr14/tr14-55.html
- Unicode 17.0.0 UAX #29 revision 47:
  https://www.unicode.org/reports/tr29/tr29-47.html
- Unicode Character Database: https://www.unicode.org/Public/17.0.0/ucd/
- Grapheme dependency: https://github.com/kawaz/grapheme.mbt
- Width dependency: https://github.com/moonbit-community/unicodewidth.mbt

Boundary algorithms are independently implemented from normative Unicode rules.
The official test files are the conformance oracle. No ICU or Python algorithm
source is copied. UTF-8 public byte offsets are explicitly translated from
MoonBit scalar/UTF-16 iteration.

## Differential validation

Run `python scripts/differential.py`. It executes the compiled MoonBit probe, checks 30 NFC/NFKC results against Python `unicodedata`, 4 common ASCII wrapping cases against `textwrap`, and 15 UTF-8 boundary sets against the actual ICU C API (`ubrk_open`, root locale). Windows uses system `icu.dll`; Linux needs `libicu-dev`. ICU UTF-16 positions are converted to UTF-8 bytes; ICU's initial boundary is excluded to match LB2.

Recorded outputs and tool versions are in [docs/differential-results.json](docs/differential-results.json). The corpus covers Latin words, CJK, combining marks, emoji/flags, CRLF, spaces/tabs, NBSP, Hebrew and Hangul. This small differential corpus complements, and does not replace, the complete Unicode 17 conformance suites.

Intentional Python differences: `textwrap` counts code points rather than terminal cells or graphemes, converts hard line endings to whitespace, and defaults to 8-column tabs rather than 4. These differences are recorded per case; shared ASCII cases and normalization results are strict assertions. Every ICU comparison in this corpus is a strict assertion, not an ignored mismatch. New upstream Unicode versions may require investigating genuine rule changes before updating the corpus.

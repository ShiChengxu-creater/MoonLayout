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

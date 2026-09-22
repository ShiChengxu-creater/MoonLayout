# Third-party materials

MoonLayout original code is Apache-2.0 (LICENSE).

| Material | Source/version | License | Use |
| --- | --- | --- | --- |
| Unicode property and test data | Unicode 17.0.0, unicode.org | Unicode License v3 | Generated property tables and conformance fixtures |
| kawaz/grapheme | 0.10.4, github.com/kawaz/grapheme.mbt | MIT | Extended grapheme segmentation |
| moonbit-community/unicodewidth | 0.2.1, github.com/moonbit-community/unicodewidth.mbt | Apache-2.0 | Display widths (Unicode 16.0.0 table) |
| moonbitlang/x | 0.4.44 (direct generator IO; also transitive via unicodewidth) | Apache-2.0 | Dependency support |

Unicode data retains its original headers. The full Unicode License v3 is in
testdata/ucd/LICENSE.txt. scripts/fetch_ucd.ps1 records SHA-256 hashes and versioned
source URLs. Generated tables identify their source and generator.

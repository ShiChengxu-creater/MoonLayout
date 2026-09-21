# Unicode data pipeline

Sources are pinned to https://www.unicode.org/Public/17.0.0/ucd/ . The 9 original
files and SHA256SUMS are committed under testdata/ucd. Git preserves their raw
bytes. The full Unicode License v3 is included as LICENSE.txt.

```powershell
./scripts/fetch_ucd.ps1
moon run tools/ucd_gen --target native -- testdata/ucd break_data
python scripts/embed_conformance.py line word sentence
moon info
moon fmt
```

The native MoonBit generator parses semicolon records, strips comments, rejects
invalid/reversed/out-of-range/overlapping ranges, sorts records and coalesces
adjacent equal values. Emoji input is filtered to Extended_Pictographic before
overlap checking because other emoji properties legitimately overlap.

Outputs are Line_Break, Word_Break, Sentence_Break, Extended_Pictographic,
General_Category and East_Asian_Width tables. General category and EAW support
LB1, LB15, LB19, LB30, LB30b and word-content filtering. The defaults are XX,
Other, Other, Other, Cn and N respectively; relevant reserved ranges are explicit
in the pinned files. Regeneration followed by moon fmt must be byte-identical.

The Python fixture tool only copies the official break markers/code points
without comments into batches of up to 1,000 cases. It does not calculate expected
boundaries. Test execution parses these embedded strings with MoonBit and
compares all expected byte positions with the public algorithm results.

For upgrades: change the version, review new UAX rules and @missing defaults,
regenerate, inspect hashes/ranges, run every official case on all targets and
review API changes. Do not update snapshots to conceal a conformance failure.

# MoonLayout

Pure MoonBit Unicode 17.0.0 paragraph layout for native, wasm-gc and JavaScript.
Package: `hbYlj/moonlayout`, planned initial release: `0.1.0`.

MoonLayout implements UAX #14 line breaking and UAX #29 word/sentence boundaries,
then composes `kawaz/grapheme` and `moonbit-community/unicodewidth` for greedy
wrapping and alignment. It does not perform shaping, rendering or bidi reordering.

Acceptance evidence: [docs/INITIAL_ACCEPTANCE.md](docs/INITIAL_ACCEPTANCE.md).
Licenses: [THIRD_PARTY.md](THIRD_PARTY.md).

```sh
moon check --deny-warn
moon test --deny-warn
```

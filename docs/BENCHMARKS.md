# Benchmarks

Run `moon bench -p ShiChengxu/moonlayout/benchmarks --target native --release`.
Each case uses MoonBit's batching/warm-up harness with 10 timed samples and retains results through `Bench.keep`. No timing thresholds are used as correctness assertions. Corpus construction and trie compilation occur outside measured closures. Alignment measures already wrapped input.

Baseline recorded 2026-09-28 on Windows x64, Moon 0.1.20260920 / native release. Raw evidence: [native-baseline.txt](benchmarks/native-baseline.txt).

| Operation | Mean |
|---|---:|
| Line boundaries / 64 corpus repeats | 342.82 µs |
| Word boundaries | 80.37 µs |
| Sentence boundaries | 92.24 µs |
| Greedy / width 80 | 3.18 ms |
| Optimal / width 80 | 85.57 ms |
| Justify | 2.09 ms |
| Greedy / 1024 repeats | 55.38 ms |
| Optimal / 1024 repeats | 2.17 s |
| English word / reused trie | 1.59 µs |

The labels 4K/64K indicate approximate corpus sizes; exact input is the UTF-8 encoding of `MoonLayout measures Unicode 段落 and emoji 👩‍🔬. ` repeated 64/1024 times. See the source for reproduction.

Optimal wrapping enumerates feasible grapheme edges and minimizes emergency breaks first, then paragraph cost. O(n²) worst-case time, O(n) auxiliary space; fixed column widths usually bound the candidate window. Very wide or zero-width-heavy paragraphs remain expensive. Greedy is the default for interactive or untrusted large input. These figures measure this machine, not a cross-machine performance guarantee.

Quality example at width 6: `aaa bb bb ccccc` has nonfinal squared slack 16 for greedy and 10 for optimal (final line unpenalized). Optimal is a quality/time tradeoff, not a faster greedy algorithm.

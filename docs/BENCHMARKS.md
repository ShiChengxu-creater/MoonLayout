# Performance status

No cross-platform performance baseline is claimed for initial acceptance.
The goal.md benchmark milestone belongs to final acceptance. Data lookup uses
binary search; word neighbors and RI parity use precomputed/running state.
Sentence suffix scans and repeated greedy candidate traversal have not yet been
optimized for adversarial long input. Future benchmarks should include long
punctuation/space runs, CJK, Latin words, combining marks and emoji, and report
toolchain, backend, corpus size, repeated timings and memory use.

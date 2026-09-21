# Initial acceptance 0.1.0

Source of requirements: goal.md, sections 9 and 11 (M0–M4).

| Milestone | Acceptance | Status |
| --- | --- | --- |
| M0 | Repository identity, pinned dependencies, data and provenance | Verified baseline (no functional tests yet) |
| M1 | Native UCD generator, compressed property tables, idempotence | Passed: 3 parser + 2 lookup tests; three targets; idempotent |
| M2 | UAX #14, complete Unicode 17 LineBreakTest | Passed: 19,338 / 19,338 cases on all three targets |
| M3a | UAX #29 word boundaries, complete WordBreakTest | Passed: 1,944 / 1,944 cases |
| M3b | UAX #29 sentence boundaries, complete SentenceBreakTest | Passed: 512 / 512 cases; all three suites verified on three targets |
| M4a | Grapheme-safe greedy wrapping, UTF-8 source ranges | Passed: normal/edge/policy/property tests on three targets |
| M4b | Left/right/center/justify including CJK gaps | Pending |
| M4c | Layout facade, four examples, executable README | Pending |
| M4d | Three backend checks/tests, external consumer, packaging | Pending |
| Release | Public repository and mooncakes 0.1.0 install | Not published |

Each milestone is committed separately as ShiChengxu-creater. No push during
initial implementation. Local acceptance and remote publication are reported
separately; a local package cannot prove a registry installation.

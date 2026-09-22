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
| M4b | Left/right/center/justify including CJK gaps | Passed: widths, overflow, emoji, CJK and final/hard-line policy |
| M4c | Layout facade, four examples, executable README | Passed: 12 example runs; README test; three-backend external consumer |
| M4d | Three backend checks/tests, external consumer, packaging | Passed: native 50/50; wasm-gc 47/47; js 47/47; packaged consumer 3/3 |
| Release | Public repository and mooncakes 0.1.0 install | Not published |

Each milestone is committed separately as ShiChengxu-creater. No push during
initial implementation. Local acceptance and remote publication are reported
separately; a local package cannot prove a registry installation.

## Verified local result — 2026-09-22

Local functional/technical acceptance passes. Full initial release acceptance
is **not yet complete**: no public remote is configured, no push occurred, and
mooncakes publication and a clean registry installation remain pending. The user
approved the package namespace `ShiChengxu/moonlayout`.

| Evidence | Result |
| --- | --- |
| `python scripts/verify.py` | All steps passed |
| `moon fmt --check`, interface synchronization | Passed |
| `moon check --deny-warn` on native / wasm-gc / js | Passed, zero warnings |
| Native tests | 50 / 50 (includes 3 native generator tests) |
| wasm-gc / js tests | 47 / 47 on each |
| Unicode LineBreakTest | 19,338 / 19,338 on each backend |
| Unicode WordBreakTest | 1,944 / 1,944 on each backend |
| Unicode SentenceBreakTest | 512 / 512 on each backend |
| Official data SHA-256 | All 9 original files match |
| Table + conformance-fixture regeneration | Byte-identical after formatting |
| Four examples x three backends | 12 successful runs, equal display output |
| Packaged archive consumed in fresh workspace | native / wasm-gc / js passed |
| Core runtime IO/network/clock | None; generator IO is native development tooling |
| Git authorship | All local commits: ShiChengxu-creater |
| Remote CI | Not run; no push |
| `moon-audit` | Not installed; optional audit not claimed |

Local toolchain: moon 0.1.20260824 (dae026a), moonc v0.10.10+f8a486b6f,
moonrun 0.1.20260824. CI uses the official stable installer and records its
version on each run. Logs and machine-readable summary are under the ignored
`.agent-workplace/verification/` directory; regenerate them with the script.

## Scale versus plan estimates

Counts exclude dependencies and build outputs. Nonblank/noncomment counts include
syntax lines such as braces. Generated fixtures are test data, not algorithm code.

| Category | Physical lines | Nonblank / noncomment |
| --- | ---: | ---: |
| Handwritten core | 1,224 | 1,062 |
| Native generator | 149 | 140 |
| Handwritten tests | 315 | 271 |
| Examples / demo | 54 | 49 |
| Generated property tables | 10,612 | 10,558 |
| Embedded official conformance fixtures | 22,023 | 21,974 |

The goal.md size estimates were not reached in the planned distribution:
handwritten code is smaller and generated data is larger. Full general-category
and break-property ranges contribute to the table count. No duplicate code was
added to inflate the handwritten total. If the contest treats effective line
count as a hard gate, this discrepancy remains a separate acceptance issue.

## Publication conditions still open

- GitHub CLI/gitauth active account: ShiChengxu-creater, verified by GitHub API.
- Local author email: 236543694+ShiChengxu-creater@users.noreply.github.com.
- No Git remote configured. The lookup of ShiChengxu-creater/MoonLayout returned
  not found; this does not assert that no differently named repository exists.
- The user approved `ShiChengxu/moonlayout`, matching the installed mooncakes
  session (`moon whoami`: ShiChengxu). Module metadata, imports and documentation
  use this namespace. No successful registry publication is claimed.
- Width data supplied by unicodewidth 0.2.1 is Unicode 16.0.0; break/segment and
  grapheme data are Unicode 17.0.0. See LIMITATIONS.md.

See RELEASE.md for the remaining public release and clean registry install steps.

# AI assistance record

Codex assisted with implementation, tests, documentation and local validation
of M0–M4. The human supplied goal.md, the acceptance scope, Git identity and
commit/push constraints. Algorithm and edge-policy choices are documented in
DESIGN.md and LIMITATIONS.md for human review; no human code review is claimed.

The implementation was written from Unicode 17 UAX #14 revision 55 and UAX #29
revision 47. No third-party algorithm source was copied. Official Unicode data
and test vectors are redistributed under Unicode License v3. Grapheme and width
behavior is provided by pinned ecosystem dependencies, with original licenses
retained. See THIRD_PARTY.md and REFERENCES.md.

Verification includes full official conformance, blackbox API/edge/property
tests, all three backends, runnable examples, generator idempotence and an
external consumer. Passing tests do not establish remote publication or a human
review; those statuses are tracked separately in INITIAL_ACCEPTANCE.md.

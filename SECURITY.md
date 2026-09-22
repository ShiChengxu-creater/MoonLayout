# Security

The core library performs no IO, network access, process execution or clock
reads. Inputs are strings and style values. Extremely large input/output widths
can require correspondingly large memory. Do not render untrusted terminal
control sequences without application-level sanitization; layout is not a
terminal escape sanitizer. Report defects with a minimal string/style example
and backend/toolchain version through the repository's issue tracker once public.

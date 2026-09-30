# Release 0.2.0

The user selected 0.2.0 for final acceptance. Package: `ShiChengxu/moonlayout`; GitHub: `ShiChengxu-creater/MoonLayout`. The Mooncakes namespace and GitHub author are intentionally different account names.

## Migration

Use `LayoutStyle::new` instead of record literals: the record now includes `optimal`. Exhaustive matches must handle `WrapAlgorithm::Optimal` and `BreakKind::Hyphenated`. Existing constructors/functions keep greedy, no-hyphenation defaults. To opt into BiDi/NFC/NFKC, import the separate `integration` package and read its explicit `logical_text` coordinate space.

## Publication procedure

1. Verify author/account and review `git diff` plus generated `.mbti` files.
2. Run `moon info`, `moon fmt`, then `python scripts/verify.py`.
3. Confirm the archive excludes goal.md, AGENTS.md, the proposal and process/cache directories. The script enforces this and tests an extracted package on native/wasm-gc/js.
4. Commit all release files, push the reviewed main branch, and require the clean GitHub CI run to pass.
5. Publish with `moon publish`, create the version tag and verify a fresh registry consumer using 0.2.0. Record actual outcomes in FINAL_ACCEPTANCE.md; local verification alone is not publication evidence.

## Rollback

Trigger rollback investigation if installation fails, a supported target fails, or consumers report corrupt logical source intervals. Mooncakes 0.1.0 was confirmed published before this release. Consumers using only initial APIs can pin `ShiChengxu/moonlayout@0.1.0` with `moon add ShiChengxu/moonlayout@0.1.0`, then rerun their check/tests for native, wasm-gc and js. Consumers using 0.2.0-only APIs must revert their integration changes or wait for a tested 0.2.1 fix.

Published versions and tags should not be overwritten. Correct the defect on a branch, use targeted git revert only after reviewing the specific faulty commit if appropriate, run full verification, and publish a patch version. Keep 0.2.0 history for reproducibility. Restoring a dependency pin normally takes minutes plus local build time; a new patch depends on diagnosis and registry availability. No destructive history reset or blanket package deprecation is part of rollback.

# Release checklist

Local initial acceptance precedes any push or registry publication. The user
requires Git identity ShiChengxu-creater. Verify with gitauth status (GitHub CLI
must be on PATH) and git var GIT_AUTHOR_IDENT. No global identity change is needed.

1. Run python scripts/verify.py and review INITIAL_ACCEPTANCE.md plus interfaces.
2. Resolve the namespace: goal.md says hbYlj/moonlayout; the installed mooncakes
   session currently reports ShiChengxu. Do not claim permission for hbYlj.
3. Configure the correct public GitHub repository and moon.mod repository URL.
4. After the local acceptance is complete and publication is authorized, push
   the local history, run remote CI and inspect its result.
5. Publish version 0.1.0 using an authorized namespace account; then install
   exactly that version in a fresh consumer without a workspace override.
6. Record public repository URL, CI URL, registry install result and release tag.

A local moon package archive and workspace consumer are preparation evidence,
not evidence that mooncakes.io has accepted or serves the release.

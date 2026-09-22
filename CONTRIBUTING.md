# Contributing

Use the toolchain version recorded in docs/INITIAL_ACCEPTANCE.md, pinned module
dependencies and the committed Unicode 17 data. Add a regression test before
changing behavior. Run python scripts/verify.py, then moon info and moon fmt.
Review generated interface changes and use one Conventional Commit per subgoal.
Do not edit generated property or conformance files by hand. See DATA_PIPELINE.

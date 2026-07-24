# After-task report — development benchmark pedigree generator

## Goal

Make `dev-test/test.R` generate ordinary diploid pedigrees that satisfy the
v0.1 rule that known sire and dam must differ.

## Active lenses and lane

- Active lenses: Ada, Shannon, Boole, Curie, Henderson, Rose.
- Spawned subagents: none.
- Lane: R, with coordinator evidence updates.

## Files changed

- `dev-test/test.R`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- this report

## Change

The generator previously called `sample()` directly on the numeric vector from
`setdiff()`. When that vector had length one, base R interpreted its sole value
as the upper bound of `1:x`, allowing the selected sire to be sampled as the
dam. The generator now samples an index into `dam_candidates` and asserts that
no pedigree row has identical known parents.

## Checks and tests of the test

- Reproduced the old failure deterministically: with `set.seed(1)` and the
  script's sequential sizes, the old generator created one invalid row at
  `n = 500`.
- Generated `n = 200, 500, 1000, 2000`, asserted zero identical-known-parent
  rows, and passed all four through `model_spec()`.
- Ran the complete script against the local `HSquared.jl` checkout. All four
  Julia-backed fits completed, and the command exited 0.
- `air` was not installed. The first live attempt lacked the Julia project
  setting; a sandboxed retry then could not write Julia's user-state log. The
  approved unrestricted retry completed successfully.

## Public-claim and capability audit

Rose audit: clean. This is a local benchmark-fixture correction only. It does
not change pedigree validation, inheritance support, the fitting API,
capability or validation status, or any public claim. Selfing and non-standard
inheritance remain unsupported in v0.1.

## Known limitations and next action

The benchmark assigns parents from all earlier animals without sex roles, so it
is a computational pedigree fixture rather than a biologically realistic
simulation. Its immediate contract is only acyclicity and distinct known
parents. The script remains untracked unless the maintainer intentionally adds
it.

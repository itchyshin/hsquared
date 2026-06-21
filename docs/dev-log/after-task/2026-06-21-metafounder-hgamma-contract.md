# After-task — metafounder + H^Gamma R contract/status (2026-06-21)

## Task Goal

Finish the next Big 3 continuation that is safe on the R side after the
multivariate validation gate and A3/#93 plot-data payload work: keep second
comparator evidence honest, update stale single-step construction wording, and
ratify the R-facing metafounder / single-step `H^Gamma` contract without claiming
an implemented R bridge.

## Active Lenses And Agents

Active lenses: Ada, Shannon, Boole, Noether, Hopper, Henderson, Curie, Fisher,
Jason, Rose, Grace.

Spawned subagents: none.

Current lane: R contract/status, coordinated with the Julia twin.

## Files Changed

- `R/qg-effects.R`, `man/qg_effect_markers.Rd`: `metafounder()` now explicitly
  reserves `group =` alongside supplied `Gamma =`; the marker remains inert.
- `R/formula-status.R`, `tests/testthat/test-phase0-api.R`,
  `tests/testthat/test-formula-animal.R`: added the constructed single-step
  status row, pinned the metafounder supplied-`Gamma` wording, and tested the
  marker/error behavior.
- `R/validation-status.R`, `vignettes/articles/*.Rmd`, `NEWS.md`,
  `docs/design/*`, and `docs/dev-log/issue-map.md`: reconciled stale wording
  around supplied-`Hinv` vs constructed single-step and fenced metafounder /
  `H^Gamma` as contract-only.
- `docs/design/27-metafounder-single-step-contract.md`: new R bridge contract for
  future `target = "metafounder"` and `target = "metafounder_single_step"`.
- `docs/dev-log/check-log.md` and `docs/dev-log/coordination-board.md`: recorded
  commands, outcomes, blockers, and next action.

## Checks Run

- `air format .` — clean.
- `Rscript --vanilla -e 'devtools::document()'` — regenerated
  `man/qg_effect_markers.Rd`.
- `Rscript --vanilla -e 'devtools::test(filter = "phase0-api|formula-animal|single-step-construct")'`
  — 190 pass, 0 fail, 0 warn, 5 skip.
- `Rscript --vanilla -e 'devtools::test()'` — 1220 pass, 0 fail, 0 warn, 55 skip.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` — clean.
- `git diff --check` — clean.
- `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "error")'`
  — 0 errors, 0 warnings, 0 notes.

## Public Claim Audit

Clean. This slice claims only:

- R reserves the `metafounder(..., group =, Gamma =)` syntax.
- R records a future payload contract for metafounder `A^Gamma` and single-step
  `H^Gamma`.
- Ordinary single-step construction is already surfaced experimentally through
  `target = "single_step_construct"`.

It does not claim:

- R fits metafounder models.
- R fits `H^Gamma` single-step models.
- `Gamma` is estimated.
- BLUPF90 comparator evidence exists.
- Any metafounder or multivariate capability moves to covered.

## Tests Of The Tests

The status tests now fail if the constructed single-step row disappears, if the
metafounder row stops saying `Gamma`, or if the supplied-relationship validation
row stops mentioning `single_step_construct`. The formula tests also exercise
the new inert `metafounder(..., group =, Gamma =)` marker and the parser's
planned-not-implemented error.

## Coordination Notes

R PR #37 has been merged into R main (`6a1065e`). The Julia twin reports
HSquared.jl PR #128 merged at `758349d`, with green remote checks and scope
limited to supplied-`Gamma` `H^Gamma` engine primitives. This R slice points at
that merged Julia state but does not wire the bridge.

Julia also banked the BLUPF90 starter-packet generator in PR #127, but both
lanes record the same executable blocker: `renumf90`, `airemlf90`, `blupf90`,
`remlf90`, and `gibbsf90` are absent from PATH locally, so no second-comparator
run is claimed.

## What Did Not Go Smoothly

The first focused test run correctly caught a stale `formula_status()` row-count
expectation after the new constructed single-step row was added. The test was
updated from 30 to 31 rows and rerun green.

## Known Limitations

- `metafounder()` is still an inert marker; there is no R parser branch,
  model-spec payload, bridge target, extractor, or vignette example for a fitted
  metafounder model.
- `single_step(..., group =, Gamma =)` remains planned and is not accepted by the
  current R parser.
- Julia PR #128 evidence is deterministic/engine-side and dense/validation-scale.
  R still needs parser/payload/extractor tests and live bridge parity before any
  R fit claim.
- BLUPF90-family second-comparator evidence is still locally blocked by missing
  executables.

## Next Actions

1. Bank this narrow R contract/status PR.
2. Start the implementation branch from clean R main: live-probe
   `HSquared.jl@758349d`, then wire parser/payload tests for
   `metafounder(..., group =, Gamma =)` and `single_step(..., group =, Gamma =)`.
3. Keep the multivariate covered-promotion gate separate: it still needs
   recovery-gate acceptance or broadening plus another independent same-estimand
   comparator beyond `sommer`.

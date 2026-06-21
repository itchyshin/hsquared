# After-task report: reserved metafounder_effects extractor

Date: 2026-06-21

## Task goal

Close the small R result-surface gap left after the metafounder provenance
extractors: give the future explicit-metafounder-effect table a stable exported
name while making the current boundary impossible to miss.

## Active lenses and spawned agents

- Active lenses: Ada, Shannon, Boole, Emmy, Hopper, Pat, Rose, Grace.
- Spawned agents: none.
- Current lane: R result surface. No `HSquared.jl` files were edited.

## Files changed

- `R/extractors.R`
- `NAMESPACE`
- `man/metafounder_effects.Rd`
- `tests/testthat/test-fit-object.R`
- `_pkgdown.yml`
- `NEWS.md`
- `docs/design/06-public-claims-register.md`
- `docs/design/27-metafounder-single-step-contract.md`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/issue-map.md`

The two pre-existing untracked Codex handover files were left untouched.

## Checks run and outcomes

- `air format .` - passed.
- `Rscript --vanilla -e 'devtools::document()'` - passed; regenerated
  `NAMESPACE` and `man/metafounder_effects.Rd`.
- `Rscript --vanilla -e 'devtools::test(filter = "fit-object|phase0-api")'`
  - 198 passed, 0 failed, 0 warnings, 0 skipped.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` - clean.
- `git diff --check` - clean.
- `Rscript --vanilla -e 'devtools::test()'` - 1290 passed, 0 failed, 0
  warnings, 58 skipped.
- `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'`
  - 0 errors, 0 warnings, 0 notes. Expected INFO only: optional suggested
  packages `enhancer`, `nadiv`, and `pedigreemm` unavailable.

## Public claim audit

Allowed claim: `metafounder_effects()` is now a reserved/error-only extractor
name for a future result shape.

Blocked claims:

- Returned metafounder-specific effects.
- `Gamma` estimation.
- External comparator evidence.
- Production-scale metafounder or `H^Gamma` support.
- Covered-status promotion.

## Tests of the tests

The focused fitted-object tests now assert both the default-method error and
the `hsquared_fit` reserved-method error, including the user-facing pointer back
to current provenance extractors.

## Known limitations

This is a public-surface guard only. It does not change parser behavior, bridge
payloads, Julia execution, or fitted results.

## Next actions

1. Bank as a narrow PR.
2. Continue with the next validation/result-surface slice from refreshed main.

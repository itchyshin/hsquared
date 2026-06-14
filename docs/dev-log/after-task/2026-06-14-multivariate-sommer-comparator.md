# Multivariate sommer comparator

Date: 2026-06-14

## Task goal

Turn the comparator-plan slice into a committed, skip-safe optional `sommer`
test for the shared Phase 4 multivariate fixture.

## Active lenses and spawned agents

Active lenses: Ada, Shannon, Curie, Fisher, Jason, Rose, Grace.

Spawned agents: none.

Current lane: R.

## Files created or changed

- `tests/testthat/test-multivariate.R`: added the optional `sommer` comparator
  test for G0, diag(R0), and diagonal-target h2.
- `R/validation-status.R`: updated the multivariate evidence and claim boundary.
- `docs/design/validation-debt-register.md`: recorded the partial comparator.
- `docs/design/capability-status.md`: recorded the partial comparator boundary.
- `docs/design/11-next-50-slices.md`: updated the slice board.
- `docs/dev-log/coordination-board.md`: added this R-lane row.
- `docs/dev-log/after-task/2026-06-14-multivariate-sommer-comparator.md`: this
  report.

## Checks run and exact outcomes

- `command -v air || true`: no `air` binary on PATH.
- First focused run:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test(filter = 'multivariate|phase0-api')"` failed because the new
  test called `utils::reshape()`; fixed to `stats::reshape()`.
- Second focused run:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test(filter = 'multivariate|phase0-api')"` passed, 0 failures /
  0 warnings / 2 live-Julia skips / 124 passes.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::document()"` passed; no generated Rd changes.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test()"` passed, 0 failures / 0 warnings / 27 live-Julia skips /
  585 passes.
- `git diff --check` passed.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"` passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"` passed, 0 errors
  / 0 warnings / 0 notes.
- Remote checks for `9b9a11d`: R-CMD-check `27500382900`, pkgdown
  `27500382897`, and Pages `27500426971` all passed.

## Public claim audit

Rose verdict: clean if the comparator remains described as partial.

The new test checks a diagonal-residual `sommer` model. It supports G0,
diag(R0), and diagonal-target h2 agreement on a tiny fixture. It does not
validate the off-diagonal residual covariance, full ASReml-style multivariate
parity, t >= 2 recovery, or production-scale conditioning.

## Tests of the tests

The comparator test is skip-safe:

- skips on CRAN;
- skips if `sommer` is unavailable;
- skips if `nadiv` is unavailable;
- skips with an explicit message if the optional `sommer` API stops fitting the
  documented fixture.

## Coordination notes

This advances the multivariate validation row within `partial`; it does not
allow promotion to `covered`.

## What did not go smoothly

The first focused run caught a namespace mistake (`utils::reshape()` instead of
`stats::reshape()`). The first exact-equality tolerance was also too tight for
sommer's tiny-fixture optimizer; the final comparator tolerance is `5e-4`.

The earlier scout showed full residual covariance is not available through the
tested `sommer` syntax on this machine, so the committed test intentionally
checks the diagonal-residual subset.

## Known limitations

The fixture is tiny and deterministic. It is a comparator smoke test, not a
recovery study.

## Next actions

- Record final local and remote checks after CI.
- Leave full residual covariance validation to ASReml/BLUPF90 manual gates or a
  future stable same-estimand `sommer` specification.

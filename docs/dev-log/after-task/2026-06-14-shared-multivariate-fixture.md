# Shared Phase 4 multivariate fixture in R tests

Date: 2026-06-14

## Task goal

Consume the shared deterministic Phase 4 multi-trait fixture on the R side so
`hsquared` can verify its multivariate payload ordering and normalized extractor
shape against the same serialized Julia REML target the twin uses.

## Active lenses and spawned agents

Active lenses: Ada, Shannon, Emmy, Hopper, Curie, Rose, Grace.

Spawned agents: none.

Current lane: R.

## Files created or changed

- `tests/testthat/fixtures/phase4_multitrait_parity/`: copied the shared
  pedigree, phenotype, expected covariance, h2, fixed-effect, EBV, and metadata
  CSV files plus README from the sibling local `HSquared.jl` fixture.
- `tests/testthat/test-multivariate.R`: added fixture readers and an ordinary
  CI-safe parity test for the R payload and normalized result.
- `docs/design/validation-debt-register.md`: recorded the fixture as internal
  parity evidence while preserving the `partial` claim boundary.
- `docs/design/11-next-50-slices.md`, `docs/dev-log/check-log.md`,
  `docs/dev-log/coordination-board.md`: updated slice status and evidence.

## Checks run and exact outcomes

- `command -v air || true`: no `air` binary on PATH.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript -e "devtools::test(filter = 'multivariate')"`:
  0 failures / 0 warnings / 2 live-Julia skips / 48 passes.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript -e "devtools::test()"`:
  0 failures / 0 warnings / 27 live-Julia skips / 580 passes.
- `git diff --check`: passed.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript -e "pkgdown::check_pkgdown()"`:
  passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript -e "devtools::check(document = FALSE, args = '--no-manual')"`:
  0 errors / 0 warnings / 0 notes.

## Public claim audit

Rose verdict: clean.

The fixture README and validation-debt row both state that this is an internal
parity target, not an external comparator and not t>=2 known-truth recovery.
The multivariate capability remains `partial`.

## Tests of the tests

The new fixture test runs in ordinary `devtools::test()` without Julia. It
checks the same R-to-engine contract that the live bridge would use: normalized
pedigree order, observed IDs, dense `Y`, fixed-effect `X`, sparse `Z`, and the
normalized `hsquared_fit` extractor outputs.

## Coordination notes

This R lane copied the local twin fixture for self-contained R tests. It did
not edit `HSquared.jl`. The Julia lane still owns structured covariance,
multivariate recovery, comparator evidence, and any promotion of V4 gates.

## What did not go smoothly

No implementation blocker. `air` remains unavailable on PATH.

## Known limitations

This is a deterministic serialized-target parity fixture. It does not re-run
the dense optimizer in R CI, does not compare against sommer/ASReml/BLUPF90, and
does not prove genetic-correlation recovery from simulated truth.

## Next actions

- Commit and push; watch R-CMD-check, pkgdown, and Pages.
- Update GitHub issue links for the V4 partial gates and R documentation.

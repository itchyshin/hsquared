# After-task report: genomic target fixture mirror

## Task goal

Mirror the Julia-owned genomic GBLUP / SNP-BLUP target fixture into the R test
suite so the R lane can consume the same target without requiring live Julia.

## Active lenses and spawned agents

- Active lenses: Ada, Shannon, Jason, Fisher, Kirkpatrick, Curie, Rose, Grace.
- Spawned agents: none.
- Current lane: R validation / comparator status.

## Files changed

- `tests/testthat/test-genomic.R`
- `tests/testthat/fixtures/genomic_gblup_snpblup_target/README.md`
- `tests/testthat/fixtures/genomic_gblup_snpblup_target/allele_frequencies.csv`
- `tests/testthat/fixtures/genomic_gblup_snpblup_target/expected_beta.csv`
- `tests/testthat/fixtures/genomic_gblup_snpblup_target/expected_gebv.csv`
- `tests/testthat/fixtures/genomic_gblup_snpblup_target/expected_genomic_precision.csv`
- `tests/testthat/fixtures/genomic_gblup_snpblup_target/expected_genomic_relationship.csv`
- `tests/testthat/fixtures/genomic_gblup_snpblup_target/expected_marker_effects.csv`
- `tests/testthat/fixtures/genomic_gblup_snpblup_target/expected_metadata.csv`
- `tests/testthat/fixtures/genomic_gblup_snpblup_target/generate.jl`
- `tests/testthat/fixtures/genomic_gblup_snpblup_target/markers.csv`
- `tests/testthat/fixtures/genomic_gblup_snpblup_target/phenotypes.csv`
- `NEWS.md`
- `docs/design/06-public-claims-register.md`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/comparator-runs/README.md`
- `docs/dev-log/issue-map.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`

## Checks run and outcomes

- `air format tests/testthat/test-genomic.R && /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e 'devtools::test(filter = "genomic")'`
  initially caught a dimname-only identity-check mismatch, then passed
  **54 pass / 0 fail / 0 warn / 2 skip** after normalizing the identity matrix
  comparison.
- `air format .` clean.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e 'devtools::test()'`
  passed **1368 pass / 0 fail / 0 warn / 59 skip**.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e 'pkgdown::check_pkgdown()'`
  clean.
- `_R_CHECK_FORCE_SUGGESTS_=false /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e 'chk <- rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never"); print(chk); if (length(chk$errors) || length(chk$warnings)) quit(status = 1)'`
  passed **0 errors / 0 warnings / 0 notes**.

## Public claim audit

Clean. The fixture is target/internal route evidence only. The R test suite now
recomputes the supplied-frequency VanRaden `G`, `Ginv`, supplied-variance GBLUP
MME solution, and SNP-BLUP marker-effect-to-GEBV route agreement, but no
external comparator was run.

No AGHmatrix, rrBLUP, sommer, JWAS, BGLR, BLUPF90, or other same-estimand
external comparator evidence is claimed. No APY, low-rank, weighted marker
prior, Bayesian marker-prior, production genomic, R model-spec activation, or
covered-status promotion is claimed.

## Tests of the tests

The test recomputes the algebra from primitive fixture inputs rather than
copying expected columns through unchanged. It also perturbs the serialized `G`
target and the marker effects to confirm the fixture check would detect drift.
The first focused run caught a dimname-only identity-check mismatch, which was
fixed by comparing the numeric identity product without dimnames.

## Coordination notes

This mirrors the HSquared.jl PR #140 fixture in the R lane and keeps the Julia
PR #145 comparator manifest as fixture-index/status context only. During
rehydration the local sibling `HSquared.jl` checkout was on
`codex/r-gwas-table-sync` with dirty docs/status files, so this slice did not
modify or rely on local Julia worktree state beyond the already-banked fixture
files.

## What did not go smoothly

The first focused genomic test failed on dimnames for `G %*% Ginv` versus an
unnamed identity matrix. The numeric algebra was correct; the assertion was made
more precise and the focused test passed.

## Known limitations

The fixture is tiny and supplied-variance. It proves internal target consistency
and gives external comparators a stable input/output packet. It does not prove
estimation quality, scale robustness, production marker panels, APY/low-rank
solves, weighted/standardized/Bayesian marker priors, or external comparator
agreement.

## Next actions

- Run an accepted genomic comparator route on a host with AGHmatrix, rrBLUP,
  BLUPF90, JWAS-equivalent, sommer-equivalent, or another reviewed same-estimand
  tool.
- Record versions, scale mapping, fitted beta/GEBVs/marker effects, and max
  deviations against this fixture in a comparator report.
- Keep genomic/SNP-BLUP rows partial until external same-estimand evidence is
  reviewed.

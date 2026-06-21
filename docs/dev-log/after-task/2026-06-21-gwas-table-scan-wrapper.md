# After-task report: scan-result GWAS table views

## Task goal

Add a small R-side table surface for already-computed post-fit marker scans:
`gwas_table(scan)` and `lod_scores(scan)` should work on `hs_gwas` objects while
leaving calibrated thresholds, map joins, formula-level scan grammar, and
fit-level QTL/GWAS/eQTL tables gated.

## Active lenses and spawned agents

- Active lenses: Ada, Shannon, Hopper, Boole, Jason, Fisher, Pat, Rose, Grace.
- Spawned agents: none.
- Current lane: R marker-scan API/status.

## Files changed

- `NAMESPACE`
- `NEWS.md`
- `R/extractors.R`
- `man/marker_extractors.Rd`
- `tests/testthat/test-gwas.R`
- `tests/testthat/test-fit-object.R`
- `vignettes/articles/qtl-gwas-eqtl-status.Rmd`
- `vignettes/articles/genomic-prediction.Rmd`
- `vignettes/articles/model-status.Rmd`
- `docs/design/06-public-claims-register.md`
- `docs/design/11-next-50-slices.md`
- `docs/design/15-qtl-extension-boundary.md`
- `docs/design/19-on-main-bridge-gap.md`
- `docs/design/23-comparator-policy.md`
- `docs/design/28-gwas-threshold-activation-contract.md`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/issue-map.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`

## Checks run and outcomes

- `git -C ../HSquared.jl status --short --branch && git -C ../HSquared.jl log -1 --oneline`
  verified the sibling Julia checkout is clean on `main` at `b0d14ba`.
- `sed -n '1,220p' ../HSquared.jl/test/fixtures/comparator_targets.toml`
  inspected the Julia comparator-target manifest and its claim boundary.
- `air format .` clean.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e 'devtools::document()'`
  updated `NAMESPACE` and `man/marker_extractors.Rd`.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e 'devtools::test(filter = "gwas|fit-object")'`
  passed 168/0/0/2.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e 'pkgdown::check_pkgdown()'`
  clean.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e 'devtools::test()'`
  passed 1347/0/0/59.
- `_R_CHECK_FORCE_SUGGESTS_=false /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e 'chk <- rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never"); print(chk); if (length(chk$errors) || length(chk$warnings)) quit(status = 1)'`
  passed 0 errors, 0 warnings, 0 notes.
- `git diff --check` clean.

## Public claim audit

Clean with explicit limits. The new methods are views of an existing `hs_gwas`
object. They do not compute a scan, add a marker map, calibrate thresholds, or
turn a fitted `hsquared_fit` into a map-annotated GWAS/QTL/eQTL result.

Julia PR #145 is recorded only as a fixture index / manifest. It is not external
comparator evidence and does not promote any validation row.

## Tests of the tests

The focused `gwas|fit-object` tests cover S3 dispatch, table columns, preserved
`scan_method`, preserved future calibration metadata, and default extractor
errors. The full suite and local R CMD check cover generated documentation,
namespace consistency, examples, vignettes, and broader extractor regressions.

## Coordination notes

Live R #23 now says `gwas_table(scan)` and `lod_scores(scan)` are banked for
already-computed `hs_gwas` objects. It remains open for calibrated threshold
activation, formula-level/map-annotated table workflows, QTL/eQTL support, and
external scan comparator evidence.

Julia #145 (`b0d14ba`) is mirrored in R ledgers as a comparator-target manifest
only. It indexes current fixtures and required comparators, but no comparator
was run.

## What did not go smoothly

The first test expectation treated `lod_scores(scan)` as a plain data frame and
missed the intended `scan_method` metadata. I adjusted the test to check columns
and metadata separately.

## Known limitations

`gwas_table(scan)` still reports nominal / Bonferroni / BH p-values from the
existing scan. It is not genome-wide calibrated. `lod_scores(scan)` is marker
and LOD only. Fit-level `gwas_table(fit)`, `qtl_table(fit)`, `eqtl_table(fit)`,
map joins, and formula-level scan grammar remain planned.

## Next actions

- Continue the next-20 sequence from clean main after this PR is banked.
- Good next R slice: consume the Julia #145 manifest structurally in a
  comparator-target availability check, or mirror the genomic GBLUP/SNP-BLUP
  target fixture with an R-side parity/scout probe.
- Keep #48 as the threshold evidence gate before drawing calibrated lines or
  calling any result genome-wide significant.

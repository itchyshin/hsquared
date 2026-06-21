# After-task report: marker-scan payload fixture mirror

## Task goal

Mirror the HSquared.jl PR #142 (`f9fbbb1`) marker-scan result payload fixture on
the R side and prove the current `hs_gwas` normalizer can consume that
row-aligned payload without requiring live Julia.

## Active lenses and spawned agents

- Active lenses: Ada, Shannon, Hopper, Jason, Fisher, Curie, Rose, Grace.
- Spawned agents: none.
- Current lane: R bridge / marker-scan.

## Files changed

- `tests/testthat/fixtures/marker_scan_parity/README.md`
- `tests/testthat/fixtures/marker_scan_parity/expected_marker_scan_payload.csv`
- `tests/testthat/fixtures/marker_scan_parity/expected_metadata.csv`
- `tests/testthat/fixtures/marker_scan_parity/markers.csv`
- `tests/testthat/fixtures/marker_scan_parity/pedigree.csv`
- `tests/testthat/fixtures/marker_scan_parity/phenotypes.csv`
- `tests/testthat/test-gwas.R`
- `docs/design/capability-status.md`
- `docs/design/06-public-claims-register.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/issue-map.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `NEWS.md`

## Checks run and outcomes

- `air format .` clean.
- `Rscript --vanilla -e 'devtools::test(filter = "gwas")'` passed
  65/0/0/2.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean.
- `Rscript --vanilla /Users/z3437171/shinichi-brain/tools/check-after-task.R docs/dev-log/after-task/2026-06-21-marker-scan-payload-fixture.md`
  clean.
- `git diff --check` clean.
- `Rscript --vanilla -e 'devtools::test()'` passed 1339/0/0/59.

## Public claim audit

Clean with boundary notes. The R lane now has a Julia-free fixture check for the
stable `marker_scan_result_payload()` shape, but the public claim stays partial:
`gwas()` remains experimental, dense/validation-scale, and uncalibrated.

No calibrated threshold, map-annotated GWAS/QTL/eQTL table workflow, formula
`marker_scan()`, sparse production scan, external comparator evidence, or
covered-status promotion is claimed.

## Tests of the tests

The new test consumes the serialized Julia payload and checks every public
`hs_gwas` column against the fixture. It also asserts that Julia-only auxiliary
fields (`denominator`, `allele_frequency`) are not silently added to the R table,
and that no calibration metadata appears unless a complete future calibration
payload is supplied.

## Coordination notes

Julia #45 is closed after HSquared.jl PR #142. Julia PR #143 then synced the
`V5-MARKER-THRESHOLD` validation-status/source-doc row while keeping #48 open.
R #23 remains open because #48 is still the active calibrated-threshold evidence
gate and the map-annotated table workflow remains planned.

## What did not go smoothly

The old R issue #23 body still named Julia #45 as a live twin gate. This slice
updates that live issue text along with the repo ledger.

## Known limitations

The fixture is a serialized Julia target, not external comparator evidence. It
does not validate threshold calibration, realistic LD behaviour, LOCO as a
production workflow, map joins, plotting, or formula-level marker-scan syntax.

## Next actions

- Keep #48 focused on calibrated genome-wide threshold evidence.
- Add the map-annotated `gwas_table()` / `qtl_table()` / `eqtl_table()` /
  `lod_scores()` workflow only after the R API contract and evidence gates are
  explicit.
- Use external comparator evidence before changing marker/QTL/eQTL status beyond
  partial.

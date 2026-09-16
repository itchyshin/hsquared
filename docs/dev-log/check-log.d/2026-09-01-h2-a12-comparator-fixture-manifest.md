# 2026-09-01 — A12 R comparator fixture manifest freeze

- Added symmetric R-lane comparator fixture index:
  - `tests/fixtures/comparator_targets.toml` (7 targets, schema v1, mirrors Julia semantics + `r_fixture_path` / `r_mirror`)
  - `tests/fixtures/comparator_fixture_shas.csv` (SHA256 pins for 42 mirrored CSV files)
  - `tests/testthat/helper-comparator-manifest.R` + `tests/testthat/test-comparator-targets-manifest.R`
- Updated `docs/design/23-comparator-policy.md` to name both twin indexes.
- Receipt: `~/local-scratch/h2-a12-fixtures-receipt.md`

Checks:

- `Rscript -e 'devtools::test(filter = "comparator-targets-manifest")'`
  - Passed: 193 assertions, 0 failures.

Claim boundary: fixture index + byte freeze only; no comparator evidence or covered promotion.

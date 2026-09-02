# 2026-09-01 — A13 real-data 3-tier validation manifest (R lane)

- Added machine-readable validation ladder index:
  - `docs/design/real-data-validation-manifest.toml` (17 arcs across tiers 1–4)
  - `tests/testthat/helper-realdata-manifest.R` + `tests/testthat/test-realdata-validation-manifest.R`
- Darwin review stub: `status = "pending"`; Tier 4 `field_empirical_placeholder` only.
- Draft source: `~/local-scratch/h2-a13-realdata-manifest.md`

Checks:

- `Rscript -e 'devtools::test(filter = "realdata-validation-manifest")'`

Claim boundary: manifest index + claim boundaries only; no covered promotion or field-empirical claims.

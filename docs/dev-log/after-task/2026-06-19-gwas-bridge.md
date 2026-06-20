# After-task — post-fit gwas() marker scan bridge (#45/#23, 2026-06-19 s3)

## Goal

Bridge the twin's post-fit marker scan (HSquared.jl #45, `a63bbfd`) as a `gwas()`
verb, with significance kept uncalibrated per the #61 agreement.

## Shipped (`23aab52`, live-verified)

- `gwas(fit, markers, marker_ids = NULL)` (new `R/gwas.R`): reuses a fitted
  Gaussian animal model's `(σ²a, σ²e)` + pedigree `Ainv`, maps per-animal markers
  to per-record via `Z`, and calls `HSquared.mixed_model_marker_scan()` (the
  explicit-argument path — no re-fit). Returns an `hs_gwas` table
  (effect/se/z/chisq/p_value/bonferroni_p/bh_qvalue/lod) with a `print()` caveat.
- Updated the `hs_marker_extractor_default` reservation to point to `gwas()`;
  the tabular `gwas_table()`/`qtl_table()`/`eqtl_table()`/`lod_scores()`
  extractors stay reserved for the planned map-annotated API.

## Honesty

p-values are **NOT genome-wide calibrated** — nominal Wald + Bonferroni/BH over
the supplied markers only; no realistic-LD/design calibration, no permutation,
no LOCO, no external comparator (engine gate twin `#48`). Every surface (roxygen,
print, NEWS, capability-status, validation-debt) carries it. Nothing promoted to
covered. Rose audit CLEAN on all 5 checks.

## Verification

No `marker_scan_result_payload`/fixture exists on the twin, so parity is a **live
element-wise** comparison: the live test fits a tiny (pedigree-structured) animal
model, runs `gwas()`, asserts R == engine `mixed_model_marker_scan` (p + effects,
1e-10), and that it DIFFERS from a fixed-effect `single_marker_scan` (so `Z`/`Ainv`
genuinely enter). Shape-verified normalizer + fit-type/markers guards run
julia-free. `devtools::test()` **917 / 0 / 0 / 35**; `check_pkgdown()` clean;
`devtools::check(args="--no-manual")` **0 / 0 / 0**.

## Cross-lane

Posted on twin `#45` (bridge-landed + asks: export a `marker_scan_result_payload`
+ a `marker_scan_parity` CSV fixture) and R `#23` (R-buildable half closed;
calibrated significance gated on twin `#48`). R-lane only; no twin edits.

# After-task — gwas() single-marker method (2026-06-20 s5, part of #4)

## Goal

Round out `gwas()` with the relatedness-**un**corrected single-marker scan (the
clean, isolated half of backlog #4) as a contrast to the default
relatedness-corrected mixed-model scan. LOCO (the other half) needs a
marker-group map + per-group precisions — deferred as a bigger build.

## Shipped

- **`R/gwas.R`** — `gwas(fit, markers, method = c("mixed", "single"))`. `"single"`
  dispatches to the Julia-owned `single_marker_scan()` (no `Z`/`Ainv`/`σ²a`);
  `"mixed"` is unchanged (default). The result carries a `scan_method` attribute;
  `hs_normalize_gwas_result()` is reused (identical field shape); `print.hs_gwas()`
  is method-aware (flags the absence of relatedness correction for `"single"`).
- **`R/autoplot.R`** — the Manhattan/QQ subtitles + meta note
  "relatedness-UNcorrected (single-marker, OLS)" when `scan_method == "single"`.
- **Tests** — pure-R: normalizer/print method attr, autoplot single-method note;
  **live** (`test-gwas.R`): `method = "single"` matches the engine
  `single_marker_scan()` p-values element-wise and differs from the mixed scan.
- **Docs** — gwas() roxygen `@param method`; NEWS gwas bullet; capability-status
  marker-scan row.

## Honesty

- The single-marker scan is the **naive** screen (ignores relatedness) — labelled
  as a contrast, more inflated than the mixed scan; same "NOT genome-wide
  calibrated (#48)" caveat. No new validated claim (the marker-scan row stays
  `partial`).
- LOCO is still not surfaced (correctly stated in print/NEWS/capability-status).

## Verification

- `air`; `devtools::document()`; `test-gwas` + `test-autoplot` pass;
  `pkgdown::check_pkgdown()` clean; `rcmdcheck(args="--no-manual")` **0/0/0**.
- **LIVE** `test-gwas.R`: the single-marker path == the engine `single_marker_scan`
  p-values (1e-10) and differs from the mixed scan.

## Next

1. LOCO `gwas()` — marker-group map + per-group relationship precisions
   (`loco_mixed_model_marker_scan`); a fresh-context build.
2. Validation depth; the deferred single-step `hs_data()` pedigree shorthand.

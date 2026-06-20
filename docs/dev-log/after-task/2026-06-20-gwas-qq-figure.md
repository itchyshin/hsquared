# After-task — gwas QQ figure + lambda_GC (2026-06-20 s5)

## Goal

Realize the cataloged-but-unbuilt QQ figure (plotting standard §1) for `gwas()`
scans, with the genomic-inflation `lambda_GC` as a diagnostic — completing the
GWAS-diagnostic pair (Manhattan + QQ).

## Shipped

- **`R/autoplot.R`** — `autoplot.hs_gwas` now dispatches
  `type = c("manhattan", "qq")` (Manhattan extracted to `hs_autoplot_manhattan`,
  default). New `hs_autoplot_qq`: observed vs expected `-log10(p)` (sorted-aligned),
  a `y = x` null reference, and `lambda_GC = median(qchisq(1-p, 1)) / qchisq(0.5, 1)`
  in the subtitle. Pure-R from the scan p-values (no engine).
- **Tests** (`test-autoplot.R`): y=x abline present, sorted expected/observed data,
  `type="qq"` / `interval_status="uncalibrated"` meta, `lambda_GC` in the subtitle,
  and Manhattan stays the default.
- **Docs**: standard §1 QQ + λGC rows (built); capability-status viz row updated.

## Honesty

- EXPERIMENTAL: nominal Wald p-values, NOT genome-wide calibrated (gate
  `HSquared.jl#48`) — stated in the subtitle and `hsquared_meta$notes`.
- `lambda_GC` is labelled **diagnostic only** (>1 may reflect structure /
  polygenicity, not corrected) — not a calibration claim.

## Verification

- `air` clean; `devtools::document()`; `test-autoplot` all pass;
  `pkgdown::check_pkgdown()` clean; `rcmdcheck(args="--no-manual")` **0/0/0**.
- Rendered a 50-marker QQ: title/subtitle correct, λGC computed, ranges sensible.

## Cross-lane

- No twin edit; mirrors the standard's §1/§6 (`:qq` / `marker_qq_data`). The
  current QQ is computed R-side from the scan p-values; consuming an engine
  `marker_qq_data` payload (if/when attached) is a future auto-detect follow-up.

## Next

1. Execute the single-step construction bridge build-spec (`docs/design/25`).
2. LOCO / single-marker `gwas()` (#4); rr_surface / rr_eigenfunctions figures.

# After-task — consume variance_components_plot_data Set-B forest (2026-06-20 s5)

## Goal

Continue backlog #2: consume the engine Set-B `variance_components_plot_data`
preparer (twin PR #95) in `autoplot(fit, "variance")` with auto-detect + recompute
fallback, and extend the live R↔engine parity guard.

## Shipped

- **`R/autoplot.R` `hs_autoplot_variance()`** — auto-detects
  `object$result$variance_components_plot_data` (the engine ships
  `term/estimate/lo/hi/panel/level/interval_method/interval_status/supplied`,
  exactly the #93 spec, with RAW unclamped `lo`/`hi`); NaN→NA so ggplot draws no
  whisker where the interval is unavailable; the `[0,1]` boundary annotation is
  scoped to the h² panel only (a variance whisker crossing zero is expected, not a
  boundary crossing). The recompute path is preserved verbatim in the `else`.
- **`tests/testthat/helper-simulation.R`** — `hs_sim_genedrop_phenotypes()`
  (gene-dropping over a clean pedigree) so a live fit converges to interior VCs.
- **`tests/testthat/test-plot-data-parity.R`** — a live variance-forest case: the
  engine preparer on a real `fit_ai_reml` fit, marshalled and consumed through
  `autoplot`, plus a NaN→NA bridge round-trip assertion.
- **`tests/testthat/test-autoplot.R`** — 11 variance cases (consume, boundary,
  h²-only negative control, recompute-branch boundary + CI value, term+estimate
  points-only, NaN, payload precedence).

## Honesty

- The payload path is **forward-looking**: the bridge does not attach
  `variance_components_plot_data` at fit time yet — the **recompute fallback is the
  live path**, stated in the consumer + mock comments.
- The engine h² row is a logit-delta interval (always in `(0,1)`), so the payload
  boundary annotation only fires on raw/non-engine payloads; it is retained as a
  defensive guard symmetric with the recompute path (which uses raw natural-scale
  bounds that genuinely can cross). Documented in a code comment.
- `interval_status` is collapsed to binary because the v1 engine contract emits
  exactly two states; a future third status is a known follow-up (comment).

## Verification

- **Adversarial verify** (Workflow `wf_14b47306-325`, Curie/Rose/Hopper):
  no blockers — Hopper confirmed the engine field/shape contract matches the
  consumer exactly. Applied every should-fix + nit.
- A **test bug** surfaced by the live run (a mixed `[NaN,1.0,NaN]` vector made
  `all(is.na())` correctly FALSE) was fixed to assert NaN→NA at the NaN positions
  and finite passthrough at the finite one.
- `air` clean; `devtools::document()` no man change; `test-autoplot` all pass;
  `pkgdown::check_pkgdown()` clean; `rcmdcheck(args="--no-manual")` **0/0/0**.
- **LIVE** (`test-plot-data-parity`): **16/16** — g-correlation ×2, variance forest
  preparer on a real fit, and the NaN→NA bridge round-trip.

## Cross-lane

- No twin edit. Consumes the already-landed PR #95 preparer, which matches the
  #93-agreed field contract verbatim. When the bridge wires payload attachment at
  fit time, both the g-correlation and variance forest consumers light up with no
  R change (parity tests guard the contract).

## Next

1. RR-variance consumer in `autoplot(fit, "reaction_norm")` once the engine
   `genetic_variance → value` rename lands (still `genetic_variance` on twin main).
2. Single-step H⁻¹ construction bridge (#3).
3. LOCO / single-marker `gwas()` (#4).

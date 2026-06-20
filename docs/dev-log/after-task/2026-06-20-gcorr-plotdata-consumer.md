# After-task — consume genetic_correlation_plot_data in autoplot + low-h² flag (2026-06-20 s5)

## Goal

Backlog #2 (buildable subset, maintainer-chosen): consume the landed engine
`genetic_correlation_plot_data` preparer in `autoplot(fit, "g_matrix")` with
auto-detect + recompute fallback and a low-h² cell flag (plotting standard §2),
plus the live R↔engine parity guard (§5/§7). Hold the RR-variance consumer until
the `genetic_variance → value` rename (answered on #93) lands engine-side.

## Shipped

- **`R/autoplot.R` `hs_autoplot_g_matrix()`** — auto-detects
  `object$result$genetic_correlation_plot_data` (consumes it only when present and
  `rotation_invariant` is not FALSE), else recomputes from `genetic_correlation()`;
  a **low-h² imprecision flag** marks off-diagonal cells where either trait has
  `h² < low_h2` (default `0.1`, configurable), with a dagger marker + subtitle
  caveat; degrades gracefully when h² is absent, NA, or length-mismatched. Trait
  fallback labels aligned to the engine's `trait_%d`. New helper
  `hs_as_square_matrix()` restores a p×p matrix from a flattened bridge vector.
- **`tests/testthat/test-plot-data-parity.R`** (new) — skip-guarded live parity:
  engine `genetic_correlation_plot_data` == `stats::cov2cor(G)` (+ h² passthrough),
  and a live-marshalled NamedTuple consumed end-to-end through `autoplot`.
- **`tests/testthat/test-autoplot.R`** — 13 g_matrix cases: flag, glyph-rendering
  regression guard, low_h2 override, single-NA h², mismatched-length, NULL-traits
  payload, recompute-path value, payload-vs-recompute Julia-free parity,
  non-rotation-invariant payload fallback.
- **Docs** — `24-plotting-standard.md` §1/§7 (parity test LANDED for
  genetic_correlation, extended per preparer); `capability-status.md` new
  visualization/autoplot-layer partial row.

## Honesty

- The payload-consumption path is **forward-looking**: the bridge does NOT attach
  `genetic_correlation_plot_data` to fits today (verified by grep — only the
  consumer + tests reference it). The **recompute fallback is the live path**;
  this is stated in the consumer comment, the mock comment, the standard, and the
  capability-status row. The mock-based payload tests prove the consumer *can*
  read a payload, not that production attaches one.
- The low-h² flag is a **heuristic** (default 0.1), explicitly not a calibrated
  precision statement — stated in the capability-status row.
- Parity coverage is `genetic_correlation` only so far; other preparers pending.

## Verification

- **Adversarial verify before commit** (Workflow `wf_346a322f-608`,
  Hopper/Florence/Rose/Pat) caught a **blocker**: doubled-backslash unicode escapes
  rendered as literal text (`0.30†`), invisible to the ASCII-only assertions.
  Fixed with `intToUtf8()` + a glyph regression test. All 8 should-fix + 7 nits
  applied (rotation_invariant validation, defensive reshape, overclaim comment,
  the edge-case test battery, standard/capability-status doc drift).
- `air format` clean; `devtools::document()` (regen `hsquared-autoplot.Rd`);
  `test-autoplot` all pass; `pkgdown::check_pkgdown()` clean;
  `rcmdcheck(args="--no-manual")` **0/0/0**.
- **LIVE** (bridge): `test-plot-data-parity.R` 7/7; JuliaCall returns the matrix
  field as a real R 3×3 matrix; rendered heatmap shows real glyphs (nchar 5).

## Cross-lane

- No twin edit. The decisions on #93 (field names, payload shape) remain the
  contract; this consumes the already-landed set-C preparer. When the bridge wires
  payload attachment, the marshalling should route the matrix field through
  `hs_matrix_from_julia()` (noted for that future slice).

## Next

1. RR-variance consumer in `autoplot(fit, "reaction_norm")` once the engine
   `genetic_variance → value` rename lands (answered on #93).
2. Single-step H⁻¹ construction bridge (#3) — focused fresh-context build.
3. LOCO / single-marker `gwas()` (#4).

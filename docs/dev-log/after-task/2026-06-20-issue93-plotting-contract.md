# After-task — answered twin #93 plotting plot-data contract (2026-06-20 s5)

## Goal

Top item on session-handoff-7: answer the twin's **8 structured questions on
`HSquared.jl#93`** (the engine will adapt its `*_plot_data` payloads to the R
`autoplot.R` tidy contract) and **settle the h² clamp divergence** (my standard +
`autoplot.R` surface the raw interval + annotate a `[0,1]` crossing; the twin's
set-B note clamped). Cross-lane, R-authoritative (R sets the plotting standard).

## Shipped

- **#93 reply** (`issuecomment-4759668333`) — all 8 answers, each grounded in the
  shipped code (`R/autoplot.R`, `R/extractors.R`) + the standard:
  Q1 `value` (singular); Q2 wide + R-melts with pinned coordinate field names
  (`covariate`/`surface`; `covariate`/`eigenfunctions`/`axis`/`variance_explained`,
  `axis` not `rank`); Q3a `level=` settable, `method` already a read-only field;
  Q3b ship RAW `lo`/`hi`; Q4 flat engine status fields, R owns the canonical enum;
  Q5 auto-detect; Q6 parity test both lanes / one seeded fixture (PLANNED);
  Q7 `loadings_scaled=V·√λ` sufficient + ship sign-canonicalization (directional
  caveat retained); Q8 `breeding_values_plot_data(id, trait, value, pev, pev_scale)`,
  rank stays R-side.
- **Divergence settled: raw + annotate, no clamp** — engine ships raw bounds, R owns
  the `[0,1]` annotation (mirrors the engine's `heritability_interval` boundary-throw
  discipline).
- **Code fix (`R/autoplot.R`)** — `hs_autoplot_reaction_norm()` was attaching
  `hsquared_meta` without `rotation_status` (defaulted to `"not_applicable"`), a
  self-violation of the standard's §3 BINDING rule. Now emits
  `rotation_status="rotation_invariant"` + `interval_status="descriptive"`.
- **Test (`tests/testthat/test-random-regression.R`)** — asserts the reaction_norm
  meta `rotation_status`/`interval_status`, enforcing the §3 rule for that figure
  (g_matrix was already guarded in `test-autoplot.R`).
- **Standard amended (`docs/design/24-plotting-standard.md` §3/§4/§6)** — encodes the
  field decisions (flat engine status fields; pinned coordinate/EBV field names;
  `interval_status`/`interval_method`; `breeding_values_plot_data` in the naming map)
  so the standard and the #93 reply are one source of truth.
- **#61 pointer** (`issuecomment-4759670038`).

## Honesty

- No capability claim changed; this is a cross-lane contract reply + a meta-attribute
  correctness fix + a design-doc amendment. The plotting layer remains as before.
- The reply marks the parity test (Q6) and `loadings_scaled` arrow biplot (Q7) as
  PLANNED / new-figure-beyond-§1, not shipped. The g_pca directional caveat
  (rotation-arbitrary, span-ambiguous under repeated eigenvalues) is stated, not
  glossed — Florence's correction.
- R's own §3 enforcement was *partial* before this slice (reaction_norm); now stated
  honestly in the reply and fixed in code+test.

## Verification

- Draft **adversarially verified** before posting: 4-lens Workflow
  `wf_009f0a43-922` (Hopper bridge / Florence honest-status / Rose claims / Pat UX).
  All `minor_gaps`; every should-fix + nit applied (Q8 `ebv`→`value` mismatch,
  Q2 under-specified coords, Q7 directional caveat, Q4 §3 binding rule + the real
  reaction_norm bug, Q3a read-only `method` field, TL;DR parity-net PLANNED).
- `air format` clean; `devtools::document()` no man-page diffs;
  `testthat::test_file` test-autoplot **36 pass**, test-random-regression **60 pass
  / 1 on-CRAN skip**; `pkgdown::check_pkgdown()` clean;
  `rcmdcheck(args="--no-manual")` **0 errors / 0 warnings / 0 notes**.
- No live engine required (reaction_norm fixture is a pure-R `hs_new_fit`).

## Cross-lane

- Posted to `#93` (answers) + `#61` (pointer). Awaiting the twin's confirmation of
  the §6 naming map and the landing of `variance_components_plot_data` (Set-B).

## Next

1. **Consume the landed preparers** in `autoplot` (auto-detect per Q5, recompute
   fallback): swap `genetic_correlation()` → `genetic_correlation_plot_data` + flag
   low-h² cells; consume `rr_genetic_variance_plot_data` for the RR variance panel.
2. **Live R↔engine parity test** (Q6 / standard §7) — engine-ready now.
3. On twin payloads landing: Set-B forest unpack; metafounder/FA eigenbasis (#61).

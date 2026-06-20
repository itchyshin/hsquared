# hsquared plotting standard (R-authored; the Julia lane mirrors it)

Status: **proposed standard v1**, 2026-06-20 (R lane / Florence). Flexible — this
is the shared figure contract both lanes follow, open to the twin's refinement on
`HSquared.jl#61` / `#93`. *Updated 2026-06-20: §3/§4/§6 encode the `#93` plot-data
field decisions (flat engine status fields; pinned coordinate/EBV field names;
`interval_status`/`interval_method`).* It formalizes what is shipped in `R/autoplot.R` and aligns with
the twin's plotting **architecture** (`HSquared.jl docs/design/13-plotting-layer.md`)
and the sister precedents (`gllvmTMB` Confidence Eye / rotated loadings; `drmTMB`
corpairs / parameter surfaces). Reviewed by Florence / Pat / Rose / Hopper.

## 0. Principle — R sets the standard, both lanes draw to it

The two lanes split the work but draw **the same figures with the same
conventions**:

- **R owns the STANDARD** — the figure catalog, the honest-status contract, the
  data shapes, the `hsquared_meta` schema, the naming map, the theme. This doc.
- **R draws** with `ggplot2` (`autoplot()`, the mature reference, brms/bayesplot
  style); base-graphics `plot.hsquared_fit()` remains the low-dependency fallback
  tier (out of the ggplot2 standard's scope, kept for `type="residuals"` etc.).
- **Julia draws** with a thin Makie weak-dependency extension (twin
  `13-plotting-layer.md`), reproducing each figure to this standard.
- **Julia ships the plot-DATA** (`*_plot_data` NamedTuple preparers); R consumes
  those payloads **or** recomputes from the fit. A live parity test keeping the
  two in step has **LANDED for `genetic_correlation_plot_data`** (skip-guarded
  live; `tests/testthat/test-plot-data-parity.R`) and is extended per preparer as
  the rest land (see §7). The recompute fallback is still the live source today
  (the bridge does not yet attach the payloads at fit time); the engine preparers
  are the cross-check.

Goal: an R user and a Julia user looking at the same figure see the same encoding,
caveats, and honest-status — only the rendering engine differs.

## 1. The figure catalog (the standard set)

| Figure | R call | Julia kind | Shows | Honest-status |
| --- | --- | --- | --- | --- |
| Variance + h² forest | `autoplot(fit, "variance")` | `:variance` | variance components + per-trait h² with intervals | experimental asymptotic SE; no fabricated whiskers |
| EBV caterpillar | `autoplot(fit, "breeding_values")` | `:breeding_values` | sorted EBVs + PEV bands | validation-scale PEV (dense denominator), not production reliability |
| Genetic-correlation heatmap | `autoplot(fit, "g_matrix")` | `:g_matrix` | genetic correlations (rotation-invariant; the `D⁻¹GD⁻¹` scaling of G) | rotation-invariant; never raw loadings; low-h² cells imprecise (flag) |
| G geometry / evolvability | plot planned; numbers via `eigen_G()`/`evolvability()` | `:g_geometry` | eigenvalues (variance per genetic axis) + sign-canonical axes + evolvability | rotation-invariant eigenstructure only |
| Reaction-norm trajectories | `autoplot(fit, "reaction_norm")` | `:reaction_norm` | RR genetic-variance + h²(t) over the covariate | supplied-`K_g` descriptive; h²(t) can overstate (no PE term) |
| Reaction-norm surface | plot planned (R) | `:rr_surface` | covariate×covariate genetic covariance/correlation surface | supplied-`K_g` descriptive |
| Manhattan | `autoplot(scan)` where `scan <- gwas(fit, markers)` | `:manhattan` | marker −log10(p) along the genome | nominal Wald; NOT genome-wide calibrated (#48) |
| QQ | `autoplot(scan, "qq")` (planned) | `:qq` | observed vs expected −log10(p), y=x reference | deviation uncalibrated, not LD/structure-corrected |
| Genomic inflation (λGC) | annotation/diagnostic (planned) | `:genomic_inflation` | λGC = median χ² / expected | diagnostic only; >1 may reflect structure/polygenicity, not corrected |
| Recovery forest | `hs_recovery_forest(study)` | `:recovery` | bias ± 2·MCSE | interval covering 0 = no detectable bias; descriptive, not a power claim |

**Roadmap (not yet cataloged):** selection-response (breeder's equation `R = h²S`,
realized-vs-predicted) and a P-vs-G comparison (phenotypic vs genetic correlation,
Cheverud display) — both expected by QG users; planned, not in v1.

## 2. Honest-status figure contract (BINDING) — per figure

Every figure carries a **subtitle caveat** AND the machine-readable
`hsquared_meta` (§3). Mirrors twin `13-plotting-layer.md` §4.

- **Variance / h²** — asymptotic delta/AI-matrix intervals, EXPERIMENTAL, not
  coverage-calibrated; small-n coverage may be < 95%. No whiskers when SEs absent.
  **h² interval boundary:** surface the raw asymptotic bounds and **annotate** when
  they cross `[0,1]`; do not silently clamp (aligning with the engine's
  boundary-throw discipline). *(Implemented in `R/autoplot.R`: raw bounds + a
  "h² CI crosses the [0,1] boundary" subtitle note.)*
- **EBV** — PEV bands are validation-scale (the reliability denominator is dense),
  not a production large-pedigree reliability claim. Band only when PEV present.
- **G correlation** — rotation-invariant `D⁻¹GD⁻¹`, unit diagonal; **cells
  involving low-h² traits are imprecise — flag them** (the engine
  `genetic_correlation_plot_data` takes a `heritabilities` arg for exactly this;
  the R heatmap should consume it). **Raw factor loadings are never plotted.**
- **G geometry** — rotation-invariant eigenstructure (eigenvalues + sign-canonical
  axes + evolvability) only; eigenvalue SEs / raw axis directions not bridged (FA
  rotation convention). Never raw loadings; a `sign_only` flag does not make a
  rotation-arbitrary axis interpretable.
- **Reaction norm (trajectories + surface + eigenfunctions)** — supplied-`K_g`,
  descriptive; eigenfunction signs arbitrary, span-ambiguous under repeated
  eigenvalues; h²(t) without a permanent-environment term can overstate.
- **Manhattan / QQ / λGC** — nominal Wald p-values, NOT genome-wide calibrated
  (#48); any threshold/envelope/y=x line is visual guidance only; λGC diagnostic
  only; raw p preserved (a display floor caps rendering only).
- **Recovery forest** — bias ± 2·MCSE; interval covering 0 = no detectable bias;
  descriptive (a low-power non-rejection), not a proof of unbiasedness.

A figure that cannot state its caveat does not ship.

## 3. The `hsquared_meta` schema (R-side; maps to engine flags)

Every **R** figure carries `attr(p, "hsquared_meta")`. The **engine** carries the
same status as **flat top-level fields** on each `*_plot_data` NamedTuple (not a
nested `meta` sub-tuple, so R's unpack is single-path): `supplied`,
`rotation_invariant`, `is_eigenstructure_not_loadings`, `interval_status`,
`interval_method`, …; the R schema is the canonical cross-lane vocabulary they map
onto:

```
hsquared_meta = list(
  type            = "variance" | "breeding_values" | "g_matrix" | "g_geometry"
                    | "reaction_norm" | "rr_surface" | "manhattan" | "qq"
                    | "genomic_inflation" | "recovery_forest",
  source          = "fit" | "gwas" | "study",
  interval_status = "none" | "experimental_asymptotic" | "pev_band"
                    | "mcse_band" | "uncalibrated" | "descriptive",
  rotation_status = "not_applicable" | "rotation_invariant",
  notes           = <one-line caveat string>
)
```

**Mapping to engine flags:** `rotation_invariant=true` ↔ `rotation_status="rotation_invariant"`;
`is_eigenstructure_not_loadings=true` ↔ enforced for `g_geometry`; `supplied=true`
↔ `interval_status="descriptive"` (reaction-norm).

**Machine-checkable rule (BINDING):** for `type ∈ {g_matrix, g_geometry,
reaction_norm, rr_surface}` `rotation_status` MUST equal `"rotation_invariant"`;
any other value is a contract violation a downstream tool may reject. R enforces
this in `testthat` for the built members (`g_matrix`, `reaction_norm`);
`g_geometry`/`rr_surface` are guarded when they ship.

## 4. Data contract — engine NamedTuple fields ↔ R tidy shape

So R and Julia render identically, each figure pins the **engine** preparer's
field names (authoritative, as landed) and the **R** tidy/long shape derived from
them:

| Figure | Engine `*_plot_data` fields (HSquared.jl) | R tidy shape |
| --- | --- | --- |
| forest (variance/recovery) | `variance_components_plot_data` (planned): components, estimates, lo (raw, unclamped), hi (raw, unclamped), interval_status, interval_method | `data.frame(term, estimate, lo, hi, panel)` |
| caterpillar (EBV) | `breeding_values_plot_data` (planned): id, trait, value (EBV), pev, pev_scale | `data.frame(rank, value, lo, hi, trait)` (rank is R-side presentation) |
| g_matrix | `genetic_correlation_plot_data`: `traits`, `genetic_correlations`, `heritabilities`, `rotation_invariant` | long `data.frame(row, col, value, label)` + low-h² flag |
| g_geometry | `genetic_pca_plot_data`: `eigenvalues`, `variance_explained`, `eigenvectors`, `loadings_scaled`, `axis_labels`, `rotation_invariant`, `is_eigenstructure_not_loadings` | `data.frame(axis, eigenvalue, variance_explained)` |
| reaction_norm | `rr_genetic_variance_plot_data`: covariate, value; `rr_eigenfunctions_plot_data`: covariate, eigenfunctions (m×k wide), axis (k), variance_explained (k) | `data.frame(covariate, value, panel)`; eigenfns melt + facet by `axis` |
| rr_surface | `rr_covariance_surface_plot_data`: covariate (shared grid vector), surface (m×m wide) | long `data.frame(covariate_i, covariate_j, value)` |
| manhattan | `marker_manhattan_data`: `marker`, `chromosome`, `position`, `plot_position`, neglog10p | `data.frame(marker, chromosome, position, plot_position, neglog10p)` + threshold; degrades to row-index when no map metadata |
| qq | `marker_qq_data`: observed/expected | `data.frame(observed_neglog10p, expected_neglog10p, marker)` |
| λGC | `marker_genomic_inflation`: median χ², expected | labelled scalar |

(Field names above are the landed/planned engine preparers; R recompute matches
them. The current `autoplot.hs_gwas` uses row-index — aligning it to
`chromosome`/`plot_position` is a follow-up R task.)

## 5. Theme, palette, labels

- `theme_hsquared()` — minimal, bold title, grey subtitle (the caveat), no minor
  grid. Exported; users restyle from it.
- Palette: primary `#2c6fbb` (estimates/series), alert `#b2182b` (thresholds /
  negative correlations), diverging `#b2182b`–white–`#2166ac` for correlations.
- Every figure: bold title, subtitle = the canonical honest-status caveat (the
  `hsquared_meta$notes` string is the single source; §1/§2/the rendered subtitle
  quote from it), axis labels in estimand language.

## 6. Naming map (R ↔ Julia ↔ engine preparer)

The landed preparer names do **not** follow a single `<type>_plot_data` rule, so
the map is explicit per figure:

| R `autoplot` type | Julia `plot(...; kind=)` | Engine preparer |
| --- | --- | --- |
| `variance` | `:variance` | `variance_components_plot_data` (planned) |
| `breeding_values` | `:breeding_values` | `breeding_values_plot_data` (planned) |
| `g_matrix` | `:g_matrix` | `genetic_correlation_plot_data` |
| `g_geometry` | `:g_geometry` | `genetic_pca_plot_data` |
| `reaction_norm` | `:reaction_norm` | `rr_genetic_variance_plot_data` / `rr_eigenfunctions_plot_data` |
| `rr_surface` | `:rr_surface` | `rr_covariance_surface_plot_data` |
| `manhattan` | `:manhattan` | `marker_manhattan_data` |
| `qq` | `:qq` | `marker_qq_data` |
| `genomic_inflation` | `:genomic_inflation` | `marker_genomic_inflation` |

## 7. Process + flexibility

This is a **proposed v1** — deliberately flexible. The twin refines + mirrors; both
lanes converge on the same catalog. New figures: R proposes (adds to §1), both
implement. **Live R↔engine parity test — landed for `genetic_correlation` so
far:** a skip-guarded `testthat` case (`tests/testthat/test-plot-data-parity.R`)
that, when Julia is available, checks the engine `genetic_correlation_plot_data`
preparer == `stats::cov2cor(G)` and consumes a live-marshalled payload end-to-end
through `autoplot()` — the mitigation for the twin's §5 parity-drift risk. The
variance/EBV/RR/surface cases are added as those preparers are consumed. Changes
are coordinated on `HSquared.jl#61` / `#93`. R leads the
standard (mature `ggplot2` layer + brms/bayesplot reference); Julia mirrors via the
Makie extension + plot-data preparers.

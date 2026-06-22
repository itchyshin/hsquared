# Design — Random-regression (reaction-norm) R surface: next increments

Date: 2026-06-22. Lane: R (with engine dependencies in the Julia twin).
Author lens: Kirkpatrick (G-matrix / reaction-norm), with Falconer (quant-gen
interpretation), Henderson (MME), Fisher (inference), Hopper (bridge), Curie
(tests), and Rose (claim boundary).

**This is a PLAN, not an implementation. It promotes nothing.** The existing
opt-in experimental `rr()` surface stays `partial`. No capability-status row, no
`validation_status()` row, and no public claim changes as a result of this note.
Each increment below is gated on engine support landing in `HSquared.jl` first,
plus R tests, plus — for any recovery or production claim — validation evidence
that does **not exist today** (see *Validation gates*).

This note plans the **next** increments. It does **not** re-plan the surface
that already ships; see *Existing surface* for what is already done so we do not
rebuild it.

## Existing surface (already ships — do not re-plan)

An opt-in, experimental random-regression model already exists end-to-end on the
R side and is recorded as `partial` in `docs/design/capability-status.md`
(random-regression row, ~row 33). It fits
`weight ~ fixed + animal(rr(age, order = k) | id, pedigree = ped)` through
`hs_control(engine = "julia", engine_control = list(target = "random_regression"))`,
surfacing the Julia-owned `HSquared.fit_random_regression_reml()`. Shipping
parts: the `rr()` parser and model-spec (`R/model-spec.R`; default `order = 2`,
opt-in fences, unsupported-syntax rejection), the result normalizer and bridge
(`R/julia-bridge.R`: `hs_fit_julia_random_regression_payload`,
`hs_normalize_random_regression_result`), the `K_g` normalizer plus the
trajectory/geometry extractors in `R/extractors.R`
(`rr_covariance()`, `random_coefficients()`, `rr_genetic_variance()`,
`rr_heritability()`, `rr_correlation()`, `rr_eigenfunctions()`), the
normalized-Legendre basis on standardized `t ∈ [-1, 1]` ratified by the twin on
`HSquared.jl#61`, the `rr_eigenfunctions()` rotation-invariant eigen-decomposition
of `K_g` (live-verified `== HSquared.rr_eigenfunctions()`), reaction-norm
autoplot trajectories with fit-time plot-data attachment, and a skip-guarded live
bridge smoke. **Explicit current limitations** (all stated in the capability row
and the `R/extractors.R` roxygen): the residual is **homogeneous**; there is **no
permanent-environment (PE) term**, so `rr_heritability()` can **overstate `h²(t)`
for repeated-records designs**; it is **univariate, single-effect, REML-only,
dense/validation-scale**; and it is **not a known-truth recovery claim** and has
**no external (WOMBAT/ASReml/JWAS) comparator**. Those limitations are the
starting point for the increments below.

## The increments

Ordered by correctness priority, not by ease. Each lists *what*, *why it matters
scientifically*, *which lane owns it*, and the *gate* that must clear before the
increment can change any status or claim. "Engine = Codex" means the numerical
work lands first in `HSquared.jl` (twin lane; this repo does not edit it).
"R glue = Claude-draftable" means the R-side parser/payload/extractor/test work
can be drafted in this lane once the engine path exists and is exercisable.

### (1) Permanent-environment (PE) term for repeated records — highest priority

- **What.** Add a second random effect to the RR model so an individual's
  repeated records share an individual-level non-genetic deviation:
  `animal(rr(age, order = k) | id, pedigree = ped) + permanent(rr(age, order = m) | id)`
  in the natural form, with a constant-PE special case
  (`+ permanent(1 | id)`) as the first rung. The PE coefficients get their own
  `k_pe × k_pe` covariance `K_pe` (or a scalar `σ²_pe`), distinct from the
  genetic `K_g`. The marginal becomes
  `V = W_g (A ⊗ K_g) W_gᵀ + W_pe (I ⊗ K_pe) W_peᵀ + σ²e I`.
- **Why it matters scientifically.** This is the highest-priority *correctness*
  increment. With repeated records and no PE term, permanent individual
  environmental effects are absorbed into the additive genetic curve, which
  **inflates `K_g` and therefore inflates `v_g(t)` and `h²(t)`**. The current
  `rr_heritability()` is honest about this caveat but cannot remove it; the only
  real fix is to model PE. Until PE exists, every `h²(t)` from a repeated-records
  RR fit is an upper bound, not an estimate. (This mirrors why the scalar
  repeatability model exists: `σ²a` and `σ²pe` are identifiable only with
  repeated records per individual.)
- **Lane.** **Engine = Codex** owns the RR+PE marginal, the extra variance block,
  the joint REML optimization (`K_g`, `K_pe`/`σ²_pe`, `σ²e`), and the BLUP form
  with two random-effect blocks. The scalar `fit_repeatability_reml` already
  estimates a PE variance for the *non-RR* model and the RR Kronecker assembly
  already exists, so this is an extension, not a greenfield kernel — but it is
  still a new engine slice (no RR+PE path exists today; `permanent()` is an inert
  planned marker in the twin's `planned_terms.jl`). **R glue = Claude-draftable**
  once the engine path exists: extend the `rr()`/`permanent()` parser to accept
  the second term, widen the bridge payload (a second basis + covariance block),
  normalize `K_pe`, and split the variance partition so `rr_heritability()`
  divides by `v_g(t) + v_pe(t) + σ²e` (with a `permanence`/`repeatability`-style
  trajectory extractor as a likely companion).
- **Gate.** Engine slice merged in `HSquared.jl` with its own deterministic
  self-consistency tests (reduction to the homogeneous-residual RR model when the
  PE variance is pinned at zero; reduction toward the scalar repeatability model
  in the `order = 1`/constant-PE corner; marginal-oracle log-likelihood) and a
  green `validation_status()` row; then R parser/payload/extractor tests + a
  skip-guarded live parity smoke. **Only after this lands may `rr_heritability()`
  stop carrying the overstatement caveat — and only for fits that actually
  include the PE term.** No promotion of the overall RR row from this increment
  alone.

### (2) Heterogeneous / structured residual across the covariate

- **What.** Replace the single homogeneous `σ²e` with a residual that can vary
  along the covariate: at minimum class-specific residual variances (residual
  bins over `t`), with a structured/function-valued residual (e.g. a smooth
  `σ²e(t)`) as the richer option. Surfaced through an `rr()`-side or
  `engine_control` residual specification.
- **Why it matters scientifically.** Test-day and growth-curve data almost always
  have residual variance that changes across the trajectory (e.g. larger at curve
  extremes). Forcing one `σ²e` mis-partitions variance and distorts `h²(t)` —
  often in the opposite direction to the PE problem at some covariate values — so
  the homogeneous-residual `h²(t)` is not just an upper bound but can be
  mis-shaped. Heterogeneous residuals are standard in WOMBAT/ASReml RR practice.
- **Lane.** **Engine = Codex** owns the residual parameterization, its REML
  estimation, and conditioning (the dense GLS path already degrades as
  `O(1/σ²e)` near the residual boundary; a per-class residual multiplies that
  concern). **R glue = Claude-draftable** for the residual-spec syntax, payload
  fields, and a residual-variance-trajectory extractor, once the engine returns
  the structure.
- **Gate.** Engine slice + tests (reduction to the homogeneous model when classes
  are merged; oracle agreement) and a green twin `validation_status()` row;
  then R syntax + extractor tests. Interacts with (1): `h²(t)` is only trustworthy
  once **both** PE and residual heterogeneity are modelled, so neither increment
  alone lifts the `h²(t)` caveat for general repeated-records data.

### (3) Curve-valued EBV PEV / reliability (function-valued prediction error)

- **What.** Prediction-error variance and reliability **along the trajectory**:
  for each animal a `PEV(t)` / `reliability(t)` curve derived from the
  coefficient-level prediction-error covariance of its random-regression
  coefficients, i.e. `PEV(t) = φ(t)ᵀ Cov(â − a | y) φ(t)`. Companion extractors
  to the existing `random_coefficients()` and `rr_genetic_variance()`.
- **Why it matters scientifically.** A random-regression EBV is a *curve*, so its
  uncertainty is also a curve: accuracy of predicted breeding value typically
  varies across the covariate (often worse at the extremes where data are
  sparse). A single scalar reliability is the wrong object for a function-valued
  EBV. This is what makes RR EBVs usable for selection decisions at specific
  covariate values (e.g. early vs. late performance).
- **Lane.** **Engine = Codex** owns the coefficient-level prediction-error
  covariance from the mixed-model equations (the analogue of the `:selinv` PEV
  path, but blocked over each animal's `k` coefficients) and the curve
  evaluation. **R glue = Claude-draftable** for the `at`-grid extractor surface
  (mirroring `hs_rr_eval_points()`), the result fields, and autoplot PEV bands on
  the reaction-norm trajectory.
- **Gate.** Engine PEV/reliability slice + tests (coefficient-block PEV matches a
  dense MME-inverse oracle; curve evaluation matches a hand check on a tiny
  fixture) and a green twin row; then R extractor + plot tests. **Honesty note
  for this increment specifically:** validation-scale PEV inherits the existing
  `pev_scale = "validation"` honest-status flag; a curve-valued PEV is not a
  production-reliability or calibrated-uncertainty claim.

### (4) Multivariate random regression, and combining `rr()` with a second random effect

- **What.** Two related generalizations: (a) **multivariate RR** — random
  regression on more than one trait jointly, so the genetic structure is a
  block/covariance-function object across traits and coefficients; and (b) the
  more general **`rr()` + a second random effect** pattern beyond PE (e.g.
  `rr()` genetic + a `common_env()`/maternal term), i.e. lifting the current
  single-effect restriction in directions other than PE. The capability row
  already lists both as planned.
- **Why it matters scientifically.** Reaction norms for correlated traits, and
  separating reaction-norm genetic variance from other structured random effects,
  are central to evolutionary and breeding questions (genotype-by-environment
  covariance across traits; partitioning curve variance from litter/maternal
  effects). This is the RR analogue of the multivariate-G work already underway in
  the multivariate lane.
- **Lane.** **Engine = Codex** owns the multi-block marginal, the larger Kronecker
  assembly, and the REML optimization over the combined covariance (this is a
  substantial engine slice and should reuse the multivariate-REML machinery).
  **R glue = Claude-draftable** for the multi-trait / multi-term `rr()` grammar,
  payload, and extractors, once the engine path exists.
- **Gate.** Engine slice(s) + tests + green twin rows; then R grammar/payload/
  extractor tests. Inherits **all** the multivariate-lane gates (recovery +
  second same-estimand comparator) on top of the RR gates. The rotation/
  interpretation convention is **already ratified**: bridge only
  rotation-invariant functionals (eigenfunctions/eigenvalues), **never raw,
  rotation-arbitrary loadings** — same rule as the FA convention
  (`docs/design/29-structured-covariance-eigenbasis-bridge-contract.md`).

### (5) `rr()` formula-grammar promotion, and basis options (splines)

- **What.** Two coupled threads: (a) move `rr()` from an opt-in experimental
  *engine target* (`engine_control = list(target = "random_regression")`) toward
  **first-class grammar** on the default fit path; and (b) add **basis options**
  beyond normalized Legendre — chiefly **spline / B-spline** bases — selectable in
  `rr()` (e.g. `rr(age, basis = "bspline", ...)`), since splines are often
  preferred over high-order polynomials for flexible trajectories without
  end-point artefacts.
- **Why it matters scientifically.** Promotion is a *user-interface* and
  *trust* step: a first-class `rr()` should read like the model an applied user
  already has in mind and should only happen once the model is honest by default
  (PE + residual handled) and validated. Spline bases matter because Legendre
  polynomials of high order oscillate at covariate extremes; splines give better-
  behaved curves and are standard in test-day evaluation.
- **Lane.** **R glue = Claude-draftable** for the grammar promotion (parser,
  `formula_status()` row, default-path routing, error wording) and for surfacing
  a basis choice. **Engine = Codex** owns any new basis kernel (spline design
  matrix + the covariance-function interpretation under that basis) and must
  ratify the basis convention the way Legendre was ratified on `#61` — `K_g`
  values are **not comparable across bases or normalization conventions**, which
  must be stated wherever a basis option is exposed.
- **Gate.** Promotion of the grammar is gated on: long/wide trait-ordering
  resolved for repeated records (coordinate with
  `docs/design/17-trait-ordering-contract.md` and the wide-response work), the
  honesty increments (1)+(2) landed so the default path does not silently
  overstate `h²(t)`, **and** a known-truth recovery study (below). Spline bases
  are additionally gated on a twin-ratified basis convention + its own recovery
  check. **No promotion of `rr()` to first-class grammar before recovery +
  comparator evidence exists.**

## Validation gates (none of these exist today)

These are shared gates that sit on top of the per-increment engine gates. The RR
row is `partial` precisely because **none of the following exist yet**:

- **Known-truth `K_g` recovery study.** Simulate repeated records from a known
  `K_g` (and, for increment (1), a known `K_pe`/`σ²_pe`; for (2), a known
  residual structure) over a clean pedigree, fit the RR model, and check that the
  estimated coefficient covariance — and the derived `v_g(t)`/`h²(t)`/eigenvalues
  — are near-unbiased (bias within `± 2·MCSE`, ADEMP-style, mirroring the
  multivariate and DGP recovery studies in `data-raw/`). This is the
  statistical-correctness gate; it does not exist for RR today. **Crucially, a
  recovery study that omits PE/residual structure can only validate the
  misspecified model — recovery must be run against the increment it claims to
  validate.**
- **External RR comparator (WOMBAT / ASReml, optionally JWAS).** A same-estimand
  comparison of `K_g` (and PE/residual where applicable) against an established RR
  implementation. WOMBAT and ASReml are the canonical RR/covariance-function
  tools; JWAS is a Bayesian cross-check (agreement, not same-estimand parity).
  **State in any comparator slice that `K_g` is not comparable across
  normalization conventions or bases** — the comparator must use the same basis
  convention or the comparison is meaningless. None of these comparator runs
  exist today, and the local host comparator stack is known-incomplete
  (`sommer`/`MCMCglmm` only; ASReml/WOMBAT/BLUPF90-family absent — see the
  comparator-availability rows on the coordination board), so this is a
  capable-host / Codex execution item.

A capability or claim moves only when the matching engine slice, the R tests, the
recovery study, and (for any production or recovery claim) the external comparator
are all in place. Until then everything here is roadmap.

## Lane split (summary)

| Increment | Engine (Codex, `HSquared.jl` first) | R glue (Claude-draftable, after engine) |
| --- | --- | --- |
| (1) PE term | RR+PE marginal, extra variance block, joint REML, two-block BLUP | `permanent()`+`rr()` parser/payload, `K_pe` normalizer, variance-partition split in `rr_heritability()`, permanence extractor |
| (2) Heterogeneous residual | residual parameterization + REML + conditioning | residual-spec syntax, payload fields, residual-trajectory extractor |
| (3) Curve-valued PEV/reliability | coefficient-block prediction-error covariance, curve eval | `at`-grid PEV/reliability extractors, autoplot PEV bands |
| (4) Multivariate RR / second effect | multi-block marginal, Kronecker assembly, combined REML | multi-trait/multi-term grammar + extractors |
| (5) Grammar promotion + spline basis | spline kernel + ratified basis convention | grammar promotion, `formula_status()`, basis-option surface |

The Julia twin's own RR roadmap
(`HSquared.jl/docs/dev-log/decisions/2026-06-20-random-regression-roadmap.md`)
lists the same "later" set (curve-valued EBV PEV/reliability; PE term;
heterogeneous/function-valued residual; spline bases; R-facing spec) as deferred
after its engine slices 1–4, so these increments are jointly owned and must be
sequenced cross-lane (engine first, then R), not built independently here.

## Claim boundary

- **The existing `rr()` surface stays `partial`.** This note plans next work; it
  promotes nothing and changes no capability-status row, `validation_status()`
  row, or public claim.
- **`h²(t)` overstatement caveat stands.** Until increment (1) (PE) and, for
  general data, increment (2) (heterogeneous residual) land *and are recovery-
  validated*, `rr_heritability()` from a repeated-records RR fit can **overstate
  `h²(t)`** and must keep its caveat. The PE term, heterogeneous residual, and
  curve-valued PEV/reliability described above **do not work yet** — they are
  planned engine slices with no implementation, no tests, and no validation.
- **Nothing here is a recovery or comparator claim.** No known-truth `K_g`
  recovery study and no WOMBAT/ASReml RR comparator exists today; both are
  required before any RR capability moves past `partial`.
- **Basis/normalization comparability.** `K_g` values are not comparable across
  normalization conventions or bases; any new basis (increment (5)) needs its own
  twin-ratified convention, stated wherever exposed.

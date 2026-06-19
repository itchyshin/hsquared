# Rubin–Thayer EM as a Warm-Start / Initializer for FA-G REML

Status: **design note / planning proposal only**. Nothing here is implemented,
validated, or claimed as working. Neither `hsquared` nor `HSquared.jl` can fit
a factor-analytic genetic covariance (`fa(K)`) today; the engine's Phase 4B
`factor_analytic_covariance` + `fit_multivariate_reml(...; genetic_structure=
:factor_analytic, rank=K)` exists on `HSquared.jl origin/main` but its recovery
calibration **did not pass** (FA 8/10, LR 9/10 seeds; validation row V4-FA =
**partial**). This note proposes — for the twin engine to consider, design, and
independently validate — using a Rubin–Thayer EM as a *warm-start* (or an
alternative estimator) for the constrained FA-G REML fit, with the aim of
improving that failing calibration.

**Lane:** this is twin advice. The proposed estimator is **engine-side and
twin-led**; the R lane only reserves a control name. The math sketch below is a
*proposal* that maps a known phenotypic-FA algorithm onto the genetic-FA
setting. It needs to be derived, implemented, and validated independently in
the engine — it copies **no** statistical correctness claim from the source.

**Provenance.** The EM recurrence cited here is the phenotypic factor-analysis
EM in the sister package `GLLVM.jl`, file
`/Users/z3437171/Dropbox/Github Local/GLLVM.jl/src/em_fa.jl`
(`em_fa(y, K; ...)`), which implements Rubin & Thayer (1982), *Psychometrika*
47, 69–76. That code fits a **phenotypic** FA `y_s ~ N(0, ΛΛ' + diag(ψ))` with
a Woodbury E-step and closed-form M-step. The genetic mapping below is **not**
in that file and is the new, unvalidated part.

Related planning context: `docs/design/14-factor-analytic-production-plan.md`
(parameterization, identifiability policy, result contract, validation gates),
`docs/design/18-structured-covariance-r-control.md` (R-side `engine_control`
boundary), and `HSquared.jl/docs/dev-log/decisions/2026-06-14-loading-rotation-
identifiability.md` (sign convention).

---

## 1. The math (proposed mapping: phenotypic FA EM → genetic FA)

### 1.1 The source phenotypic EM (provenance, unchanged)

`em_fa.jl` fits, over independent columns `y_s` of an `(p × n)` matrix,

```text
y_s ~ N(0, Σ_y),   Σ_y = Λ Λ' + Ψ,   Λ ∈ R^{p×K},   Ψ = diag(ψ), ψ > 0.
```

E-step (per observation, Woodbury form so only `K×K` inverses appear):

```text
β    = Λ' (Λ Λ' + Ψ)^{-1}                              (K × p)
E[η_s | y_s]        = β y_s
E[η_s η_s' | y_s]   = I − β Λ + β y_s y_s' β'
```

M-step (closed form, aggregated over `s`; `S_yy = Y Y'`):

```text
S_yη  = S_yy β'
S_ηη  = n (I − β Λ) + β S_yy β'
Λ_new = S_yη S_ηη^{-1}
ψ_new = diag(S_yy − Λ_new S_yη') / n
```

The Woodbury identity keeps the cost in `K` (one `K×K` Cholesky of
`M = I + Λ'Ψ⁻¹Λ`), and the log-likelihood is evaluated *before* each M-step so
monotone non-decrease is testable. All of the above is the cited source's claim,
not ours.

### 1.2 Where the relationship matrix A enters (the new, unvalidated mapping)

The genetic problem is **not** a set of `n` i.i.d. observation vectors. For a
`t`-trait animal model on `q` individuals with additive relationship matrix `A`
(`q × q`), the additive breeding values stack as `a ~ N(0, G0 ⊗ A)`, with the
FA structure imposed on the **`t × t` cross-trait** matrix:

```text
G0 = Λ Λ' + Ψ,   Λ ∈ R^{t×K},   Ψ = diag(ψ), ψ > 0.
```

The phenotypic EM treats columns as independent because their covariance is `I`.
Here the "columns" are individuals and their covariance is `A ≠ I`. Two routes
make the source recurrence reusable; **both are proposals to be derived and
checked in the engine, not asserted correct here:**

1. **A-whitening (decorrelate the individuals).** With breeding-value
   predictions or realized deviates arranged as a `t × q` matrix `U` (rows =
   traits, columns = individuals), the cross-individual correlation is `A`.
   Whitening on the right by a factor of `A⁻¹` (e.g. `A = L Lᵀ`, form `U L⁻ᵀ`)
   yields columns whose cross-trait scatter is, in expectation, `G0` times an
   identity in the individual index. The source's `S_yy = Y Yᵀ` is then replaced
   by an **A⁻¹-weighted genetic scatter**

   ```text
   S_gg = U A^{-1} U'        (t × t),   effective count = q (or its rank).
   ```

   Substituting `S_gg` for `S_yy` and `q` for `n` gives a candidate EM on `G0`.
   The sparse `A⁻¹` already available in the engine (pedigree path) is the
   natural operator; `U A⁻¹ U'` should be formed without densifying `A⁻¹`.

2. **EM on the genetic sufficient statistic from the mixed-model solve.** In an
   animal-model REML iteration the breeding values are not observed; the
   relevant genetic sufficient statistic is `\hat C = \hat a' (something) \hat a
   + trace correction`, i.e. the estimated genetic second moment that REML
   already needs for its `G0` update (the `t × t` matrix whose unstructured
   REML update is the usual `(\hat U A⁻¹ \hat U' + tr-correction)/q`-style
   quantity). The proposal is to feed **that** `t × t` matrix as the `S_gg`
   driving the Rubin–Thayer M-step, so the EM produces a **structured** `(Λ, ψ)`
   consistent with the current REML genetic moment, rather than an unstructured
   `G0`.

The honest status of 1.2: the substitution `S_yy → S_gg`, `n → q` is a
**conjecture** about how the phenotypic recurrence transports to the genetic
setting. It must be derived from the genetic likelihood (or the EM complete-data
likelihood with `a ~ N(0, G0 ⊗ A)`), implemented, and validated before it can be
trusted. The trace/uncertainty correction (route 2) is exactly the part the
phenotypic source does **not** contain.

### 1.3 What this EM is for here

The proposed use is **not** to replace REML. REML on `G0 = ΛΛ' + Ψ` remains the
estimator of record (it carries the correct fixed-effect projection and the
trace terms EM-on-predictions omits). The EM is proposed as a **fast, derivative-
free producer of a feasible, PSD, well-separated `(Λ⁰, ψ⁰)`** to hand to the
constrained REML optimizer as a starting point.

---

## 2. Why a good init should help the failing calibration

The Phase 4B calibration fails on a minority of seeds (FA 8/10, LR 9/10). That
pattern — most seeds pass, a few do not — is the signature of an estimator that
is correct but **start-sensitive**, not one that is structurally wrong. Factor-
analytic likelihoods are known to be multimodal and to have rotation-flat
ridges and `ψ → 0` Heywood boundaries; a derivative-based REML optimizer started
from a poor point can stall on a saddle, converge to a non-global mode, or be
dragged to a Heywood boundary. Plausible mechanisms by which a Rubin–Thayer
warm start helps (to be confirmed empirically, not assumed):

- **Basin placement.** EM from a data-driven point typically lands in the
  neighborhood of the dominant mode, so the subsequent REML solve refines rather
  than searches. This directly targets the "few bad seeds" failure shape.
- **Feasibility / PSD by construction.** `Λ⁰Λ⁰' + diag(max(ψ⁰, ε))` is PSD with
  positive uniquenesses, so REML starts inside the feasible region instead of
  being projected onto it from a random `G0`.
- **Boundary avoidance.** A sensible `ψ⁰` keeps the optimizer off the `ψ = 0`
  wall on iteration 1, where AI/Newton steps are least reliable.
- **Conditioning.** Well-separated starting columns reduce near-rotational
  degeneracy in the early Hessian/AI matrix.
- **Cheap insurance via multi-start.** EM is closed-form per iteration; running
  it from a few seeds and keeping the best `(Λ⁰, ψ⁰)` by log-likelihood is a
  low-cost guard against the residual bad-seed cases — at far lower cost than
  multi-starting full REML.

This is a **hypothesis about the calibration failure**, offered for the engine
to test. If profiling shows the bad seeds fail for a different reason (e.g. a
genuine objective/derivative bug, or `t,K` identifiability rather than
start sensitivity), a warm start will not fix it, and the engine should fix the
root cause instead. The EM init is not a substitute for diagnosing *why* those
seeds fail.

---

## 3. Proposed interface boundary

**Engine-side, twin-led.** All of the following live in `HSquared.jl`:

- the genetic-FA EM (the `S_gg`/`A⁻¹` mapping of §1.2), as an internal helper;
- a `fit_multivariate_reml` option to obtain the FA start from EM vs. a default;
- the multi-start logic and the "keep best by log-likelihood" selection;
- all numerical tolerances, iteration caps, and boundary guards.

**R reserves the control only.** The R lane adds **no** estimator. At most it
threads a single opt-in field through the existing `engine_control` boundary
documented in `docs/design/18-structured-covariance-r-control.md`, e.g.

```text
engine_control$fa_init = "em" | "default"   # planned, names not final
```

R must **not** expose this as a user-facing argument, document it as a feature,
or imply that FA-G is fitted, until §5 gates pass. It is an internal engine
tuning knob reachable through the expert-control channel, nothing more. The
default remains whatever the engine validates as most reliable; `"em"` stays
opt-in until evidence says otherwise.

This respects the production plan's rule that the R object stores/reconstructs
`G0` first and treats loadings as metadata. The EM changes only *how the engine
reaches* `(Λ, ψ)`; it changes nothing in the result contract.

---

## 4. Identifiability and rotation caveats

These are first-order, not afterthoughts. The EM does nothing to resolve them —
if anything it makes them more visible because it produces an explicit `Λ⁰`.

- **`Λ` is rotation-nonunique.** For any orthogonal `R` (`R Rᵀ = I`),
  `(ΛR)(ΛR)' = ΛΛ'`, so `Λ` and `ΛR` give the *identical* `G0`, likelihood, and
  REML objective. The EM will converge to *some* `Λ` in the equivalence class
  determined by its initialization and update path; that particular `Λ` carries
  **no** privileged meaning. Per
  `docs/design/14-factor-analytic-production-plan.md`: `G0` is interpretable,
  `Λ` is not, absent a declared rotation/constraint.
- **A warm-start `Λ⁰` must not leak as the "answer."** Because EM yields an
  explicit loading matrix, there is a temptation to report it. Do not. The init
  feeds the optimizer; the *reported* loadings (if/when loadings are ever
  reported) must still pass through the documented rotation/sign convention, not
  the EM's incidental orientation.
- **Sign convention.** The engine's existing decision
  (`2026-06-14-loading-rotation-identifiability.md`) makes each column's
  largest-absolute loading non-negative for deterministic metadata. The EM's
  output must be put through the **same** canonicalization before any comparison
  or storage, so that warm-start runs are reproducible and comparable to the
  default path. Sign canonicalization removes column sign flips only; it does
  **not** identify rotations for `K > 1`.
- **The source's triangular init is a symmetry-breaker, not an identification.**
  `em_fa.jl` zeroes the strict upper triangle of the initial `Λ` (lines 51–55)
  purely to break rotational symmetry numerically. If the genetic EM borrows
  that trick, it is a starting-point device only; it does not impose an
  interpretable lower-triangular constraint on the *fitted* `G0` unless the REML
  step is also constrained that way (and then comparators must match it).
- **Heywood / boundary.** `ψ⁰` clamped to `ε` (source line 124) is a numerical
  guard, not evidence the boundary is inactive. Boundary behavior must be
  reported, not silently floored, in any validated fit.

---

## 5. Validation gates before ANY "covered" claim

The EM-init idea may **not** move V4-FA from partial toward covered, and no R
or Julia surface may claim FA-G works, until **all** of the following hold and
are recorded in the engine's validation evidence (and cross-checked against
`docs/design/14-factor-analytic-production-plan.md` gates):

1. **Independent derivation + implementation.** The genetic mapping of §1.2 is
   derived from the genetic likelihood in the engine (not transplanted on faith
   from the phenotypic source) and implemented engine-side.
2. **Monotonicity / sanity test of the EM itself.** The genetic EM's
   log-likelihood (or its complete-data surrogate) is monotone non-decreasing on
   test data, mirroring the testable property the source advertises.
3. **Passing multi-seed calibration.** Recovery passes a pre-registered
   multi-seed threshold materially better than the current FA 8/10 — at minimum
   the agreed FA pass bar across the full seed set — for `t ≥ 3`, `K = 1`, and at
   least one `K > 1` case, *with* and *without* the EM init, so the init's
   contribution is attributable.
4. **REML remains the estimator of record.** The EM is shown to change only the
   *starting point*: warm-started and default-started REML reach the same `G0`
   (up to rotation) on the seeds where both converge, confirming the EM is an
   initializer and not silently the estimator.
5. **Comparator parity.** Covariance-level agreement with an external comparator
   (ASReml / sommer / BLUPF90-family where available), covariance first; loading
   comparison only after rotation conventions are matched on both sides.
6. **Rotation convention declared and roundtrip-tested.** `Λ Λ' + Ψ`
   reconstructs `G0` after any returned rotation/sign convention, and `G0` /
   log-likelihood are invariant under post-fit rotation.
7. **Rose audit** of all wording touching "EM", "warm start", "initializer",
   "latent axis", "factor", "loading", "evolvability" — confirming nothing
   implies FA-G is fitted or that the EM is validated, until 1–6 pass.

Until then this file, the EM mapping, and the `fa_init` control are
**planned/proposed** only.

---

## 6. Proposed next slices (engine-led; no claims)

1. **Engine:** profile the failing FA/LR seeds to confirm (or refute) that the
   failures are start-sensitivity rather than an objective/derivative bug or a
   `t,K` identifiability problem. This decides whether a warm start is even the
   right tool.
2. **Engine:** derive and prototype the genetic EM (§1.2), behind an internal
   flag, with a monotonicity test on synthetic `G0 = ΛΛ' + Ψ` data.
3. **Engine:** run the gate-3 with/without-init calibration to attribute any
   improvement to the warm start.
4. **R/docs:** keep `cov = fa(K)` and any `fa_init` mention planned-only; reserve
   the `engine_control$fa_init` name only if it is inert and documented as
   internal/unvalidated.
5. **Coordinator:** update V4-FA only on passing gate evidence; Rose records a
   clean audit or explicit blockers.

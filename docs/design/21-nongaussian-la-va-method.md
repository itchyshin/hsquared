# Non-Gaussian Animal Models: `method = "LA" | "VA"` Surface (Phase 6)

Status: **implementation note plus remaining gates.** `hsquared` now fits
simple non-Gaussian animal models through the experimental, opt-in
`target = "nongaussian"` bridge: `poisson(log)` and `binomial(logit)`, with
`engine_control$marginal = "laplace"` or `"variational"` (aliases `"la"` /
`"va"`). The default `hsquared()` path is still the covered univariate Gaussian
animal model. This note is retained to document the R/Julia method vocabulary,
payload contract, and validation gates that still block promotion beyond
`partial`.

Lane discipline: the marginal-method machinery is **engine work (twin-led,
`HSquared.jl`)**. `hsquared` (R lane) reserves only the user-facing `method`
control, the family parser route, and the result-shape contract. Nothing here
authorises R to fit, nor authorises edits to `HSquared.jl` from this repo.

Cross-references: `docs/design/07-genomics-qtl-gpu-plan.md` §10 (GLLVM strategy:
"Laplace approximation for non-Gaussian random effects; variational
approximation as an optional high-dimensional path"); `docs/design/16-wide-
response-syntax-plan.md` (wide/long response boundary, `gllvm`'s `method =
"LA"/"VA"/"EVA"` anchor); `docs/design/03-engine-contract.md` (result-shape
vocabulary). Open coordination item: `HSquared.jl#44` now tracks the R-twin
handoff for the Julia `non_gaussian_parity` fixture and any final bridge-status
reconciliation; it is not a coverage-promotion gate by itself.

## 0. What the twin already has (provenance, not a claim of integration)

On `HSquared.jl origin/main`, `src/nongaussian.jl` carries an **experimental,
dense, validation-scale** non-Gaussian path. It is the factual basis for this
note and now has a committed partial validation/status surface plus the PR #152
`test/fixtures/non_gaussian_parity/` payload fixture. That fixture is a bridge
payload target, not external comparator evidence and not a public-default claim.

- Family markers: `ResponseFamily` abstract type with `GaussianResponse`,
  `PoissonResponse` (log link), `BernoulliResponse` (logit), `BinomialResponse`
  (logit, with an `n_trials::Int` field; Bernoulli is the `n_trials = 1` case).
- Marginals: `laplace_marginal_loglik(...)` (LA) and
  `variational_marginal_loglik(...; covariance = :full | :diagonal)` (VA / ELBO).
- Exported fitters: `fit_laplace_reml(y, X, Z, Ainv; family, marginal, n_trials,
  ids, ...)` returning a `NonGaussianFit`, and `laplace_reml_interval(...)`
  (Poisson `sigma_a2` profile-LRT interval only).

The note maps these onto an R control; it does not assume they are stable.

## 1. `MarginalMethod` dispatch (engine-side, twin-led)

Adopt DRM.jl's selection surface (`DRM.jl/src/variational.jl`) wholesale, because
it is the cleanest split of "which approximation" from "which family":

```julia
abstract type MarginalMethod end
struct Laplace     <: MarginalMethod end   # mode + curvature; the default
struct Variational <: MarginalMethod end   # maximise an ELBO over Gaussian q
```

DRM.jl resolves a user symbol case-insensitively (`_marginal_method(:LA) →
Laplace()`, `:VA → Variational()`, anything else throws naming both options).
The twin's current `fit_laplace_reml(...; marginal = :laplace | :variational)`
already encodes the same choice as a `Symbol` keyword; `HSquared.jl#44`'s
requested refactor is to lift that `Symbol` into a `MarginalMethod` type so
fitters dispatch on it rather than branch on a symbol. Recommendation for the
twin lane (not an instruction): converge on the DRM.jl type names so the bridge
payload carries one vocabulary across DRM.jl, GLLVM.jl, and HSquared.jl.

Why type dispatch over a symbol branch: the inner kernels differ structurally
(LA finds a conditional mode then takes curvature; VA runs a self-consistent
fixed point for `(m, S)` then an ELBO). Dispatch keeps each kernel in its own
method and lets the family markers (`PoissonResponse`, …) dispatch independently,
exactly as GLLVM.jl's `laplace.jl` separates the family-agnostic mode-finder from
the per-family `_glm_score` / `_glm_weight` / `_glm_logpdf` / `_clamp_mu`.

## 2. Family set and the R `family =` route

Target Phase 6 family set (matching what the twin can honestly carry):
`gaussian`, `poisson`, `bernoulli`, `binomial` (the last requires `n_trials`).
NB2, Gamma, Beta exist as VA proof kernels in DRM.jl and as Laplace `aux`
families in GLLVM.jl, but they are **not** in the twin's animal-model
`nongaussian.jl` yet, so they stay out of the first R surface.

R must change in two honest steps, each independently reversible:

1. **Stop blanket-rejecting non-Gaussian.** Today `R/model-spec.R` errors on any
   non-numeric / non-Gaussian response. The reservation step keeps fitting
   Gaussian-only but lets the parser *recognise* `family = poisson()`,
   `binomial()`, etc., and route them to a clear "parsed, reserved, not fitted"
   error (named family + nearest planned path), rather than a generic rejection.
   This is parser/claims work only — no engine call.
2. **Route a family enum to Julia** (only after the engine + bridge + validation
   gates in §6 pass). R parses `family =` into a small closed enum and marshals
   it as part of the engine payload, alongside `n_trials` for binomial:

   ```text
   family   ∈ {gaussian, poisson, bernoulli, binomial}   (R-validated, closed set)
   n_trials : required and validated when family = binomial; integer ≥ 1;
              0 ≤ y ≤ n_trials enforced R-side before marshalling
   method   ∈ {"LA", "VA"}  → engine MarginalMethod (default "LA")
   ```

   R owns response-domain validation up front (Poisson: non-negative integers;
   Bernoulli: 0/1; Binomial: integers in `0:n_trials`) so the engine's
   `_check_counts` is a backstop, not the user's first error. R's `family =`
   accepts the familiar `stats::` family objects where the names line up
   (`gaussian()`, `poisson()`, `binomial()`); the link is fixed per family for
   v-Phase-6 (log for Poisson, logit for Bernoulli/Binomial) and a non-default
   `link =` is a reserved error, not a silent override.

Boole/Hopper review barrier required on the enum names and the `n_trials`
contract before any bridge wiring.

## 3. `NonGaussianFit` result shape (distinct from `AnimalModelFit`)

The twin returns a deliberately **smaller and differently-labelled** object than
the Gaussian animal-model result, and R should mirror that distinction rather
than overload one S3 shape. The twin's `NonGaussianFit` fields are:
`variance_components` (a `NamedTuple`: `(sigma_a2, sigma_e2)` for Gaussian,
`(sigma_a2,)` only for the count/binary families — there is **no residual
variance** on the link scale), `marginal_loglik`, `beta`, `breeding_values`,
`ids`, `converged`, `family`, `marginal`.

Key shape differences R must surface honestly:

- **No `sigma_e2` for Poisson/Bernoulli/Binomial.** The link-scale model has no
  free residual variance; `variance_components()` returns one component. An R
  extractor that assumes a two-component `(sigma_a2, sigma_e2)` decomposition (or
  a naive `h2 = sigma_a2 / (sigma_a2 + sigma_e2)`) is **wrong** for these
  families. Heritability on the data scale needs a link-specific transformation
  (Fisher/Falconer lens, separate note) — do not reuse the Gaussian ratio.
- **`marginal_loglik` is method-dependent.** Under LA it is a Laplace
  approximation to `log p(y)`; under VA it is an **ELBO — a lower bound**, not
  the marginal log-likelihood. DRM.jl flags exactly this ("`loglik` field
  carries the ELBO (a lower bound)"). R must label the value as `LA` or `VA`
  (carry `marginal` through) and must **not** compare an ELBO to a Laplace
  loglik as if both were the same quantity (no AIC/LRT across methods).
- **No PEV/reliability block** in the current struct (the Gaussian Henderson
  bridge in `03-engine-contract.md` carries those; `NonGaussianFit` does not).
  Reserve those extractors as not-implemented for non-Gaussian fits.
- `converged` is load-bearing: VA results are "meaningful only when `converged
  == true`" (twin docstring). R must refuse to report estimates from a
  non-converged fit rather than silently returning boundary values.

Proposed R contract: a separate S3 result (e.g. `hsquared_fit` carrying a
`result_kind = "nongaussian"` tag, or a distinct subclass) whose
`variance_components()`, `heritability()`, and `summary()` methods know they are
on the link scale and know whether the objective is a loglik or an ELBO.

## 4. LA vs VA trade-off (bias / speed) and when each applies

| | Laplace (LA) | Variational (VA / ELBO) |
| --- | --- | --- |
| Objective | mode + curvature approximation to `log p(y)` | ELBO = lower bound on `log p(y)` |
| Cost | one inner mode solve per outer step | self-consistent `(m, S)` fixed point per outer step (more inner work) |
| Gaussian family | exact REML loglik | tight: ELBO == LA == `sparse_reml_loglik` (KL vanishes) |
| Failure mode | sharp/skewed conditional posterior ⇒ curvature bias | mean-field/diagonal `q` discards relatedness (see §5) |
| Default | yes | opt-in |

Guidance (mirrors `gllvm`'s `method="LA"/"VA"` and DRM.jl's "opt-in, steadier on
dispersion/shape"):

- **LA is the default.** It is cheaper, and for the Gaussian family it is exact,
  so it is the safe baseline and the natural comparator for VA.
- **VA is the opt-in alternative** for bias-sensitive cases — small clusters,
  heavy skew, or where the Laplace curvature is a poor local Gaussian. For the
  Gaussian family the two coincide, which is itself the first cross-check: any
  VA implementation must reproduce the LA/REML number on Gaussian data before it
  is trusted on a non-Gaussian one.
- The two are **not interchangeable in fit statistics**: an ELBO is a lower
  bound, so it cannot be compared to a Laplace marginal loglik across methods.
  R should make the user's `method` choice visible in `summary()` and block
  cross-method likelihood comparisons.

## 5. Honest caveats the twin flagged (carry these verbatim into R docs)

These are not hypothetical; they are written into `HSquared.jl`'s own code and
docstrings and must survive into any R-facing documentation.

1. **`sigma_a2` is downward-biased / boundary-prone for single-trial
   Bernoulli (the information effect).** Twin docstring: "Binary `:bernoulli`
   data carries little variance information at small scale, so `sigma_a2` is
   prone to running to a search-bound boundary; `:binomial` with more trials per
   record is more informative and recovers `sigma_a2` far better." This is the
   classic information limit of binary data, not a bug. R must warn when `family
   = bernoulli` and must not present a boundary `sigma_a2` (or a near-zero
   heritability) as a clean estimate — surface `converged`, the boundary flag,
   and the small-information caveat.
2. **Binomial `m = 20` is a hard internal gate, not a tunable.** The VA expected
   kernels for logit families integrate by a fixed 20-node Gauss–Hermite rule
   (`const _GH_NODES, _GH_WEIGHTS = let m = 20 ... end` in `nongaussian.jl`).
   That rule is built once at load and is **not** exposed as a control. R must
   not advertise an adjustable quadrature order for these families; if a user's
   `n_trials` or link-scale spread pushes the 20-node rule outside its accurate
   range, that is an engine-side accuracy limit to validate (§6), not an R knob.
3. **VA `covariance = :full` is the only REML-honest setting, and it
   densifies.** The twin: "a diagonal / mean-field `S` would discard [pedigree
   relatedness] and would not be REML-exact." `:full` forms and inverts the joint
   `q × q` covariance `S = (Zᵀ W̃ Z + Ainv/σ²a)⁻¹` densely. The `:diagonal`
   (mean-field) option is faster but **drops the relationship structure** — it is
   a performance/experimentation path, not a valid animal-model estimator. R
   must not expose `:diagonal` as a default or as equivalent.
4. **`laplace_reml_interval` is Poisson-only.** The profile-LRT interval throws
   for any family other than `:poisson` ("multi-parameter profiling under nuisance
   profiling ... is future work"). R interval extractors must error clearly for
   Bernoulli/Binomial/Gaussian non-Gaussian fits rather than returning a wrong
   interval.

## 6. Numerical risks and validation gates (before any "covered" claim)

Numerical risks I (Gauss) flag for the eventual integration:

- **Accidental densification.** The twin path is explicitly dense
  (`Matrix{Float64}(Z)`, `inv(Symmetric(Huu))`, `Matrix{Float64}(Ainv)`); it is
  validation-scale only. Promoting it to a sparse production path is a separate
  engine effort. R must not imply non-Gaussian fits scale like the sparse
  Gaussian Henderson path until a sparse non-Gaussian kernel exists and is
  benchmarked. Watch for `Ainv` being materialised dense on the R-to-Julia
  boundary.
- **Boundary / convergence reporting.** Brent (`sigma_a2` only) and NelderMead
  (Gaussian two-component) can stop at a search bound; for Bernoulli this is the
  expected information effect. The bridge must marshal `converged` and a
  boundary flag, and R must propagate both.
- **Gradient/Hessian risk for intervals and SEs.** `variational_marginal_loglik`
  reports a `gradient_norm`; the LA path solves an MME-shaped system per record.
  Any SE/interval beyond the Poisson profile-LRT needs its own derivation and
  finite-difference check — do not reuse the Gaussian REML Hessian machinery.
- **ELBO/loglik confusion** (see §3/§4): a single mislabelled field silently
  invalidates downstream model comparison.

Validation gates (must all pass before the public claims register /
`capability-status.md` may promote non-Gaussian beyond `partial`; aligns with
`04-validation-canon.md` and the gates in `16-wide-response-syntax-plan.md`):

1. **Gaussian self-consistency.** For `family = gaussian`, both `method = "LA"`
   and `method = "VA"` must reproduce `fit_sparse_reml` to tolerance (the twin
   asserts they should; needs a committed fixture).
2. **Poisson recovery** against a simulated-truth `sigma_a2` (the twin references
   `sim/phase6_binomial_recovery.jl`-style simulation; a Poisson analogue plus
   the existing binomial recovery sim must be committed, not just present).
3. **Binomial information gradient.** Demonstrate the documented effect:
   single-trial Bernoulli boundary/downward bias vs. improving recovery as
   `n_trials` grows — as a recorded, reproducible result, not a verbal claim.
4. **LA vs VA agreement envelope.** Characterise where the two diverge on
   non-Gaussian data (they must coincide on Gaussian); record it.
5. **External comparator** where an estimand matches — `gllvm` (`method =
   "LA"/"VA"`), `GLLVM.jl`, or `MCMCglmm` for a Poisson/binomial animal model —
   per `07-...`§15 promotion rule.
6. **Bridge round-trip parity** (Hopper): R `method`/`family`/`n_trials` →
   `NonGaussianFit` → R extractors, with the loglik-vs-ELBO label and
   link-scale `variance_components` preserved.
7. **Rose audit** of README, claims register, and `formula_status()` before any
   public exposure; resolve `HSquared.jl#44`'s `MarginalMethod` refactor and the
   missing validation row first.

**Update (shipped `31f200c`).** The Laplace path is now surfaced
**experimentally**: `family = poisson()` and `family = binomial()` (binary) fit
through the opt-in `target = "nongaussian"` (`HSquared.fit_laplace_reml`),
reporting the latent-scale additive-genetic variance, breeding values, and
marginal log-likelihood, and **no heritability** (no residual-variance scale) —
mirroring the twin `V6-LAPLACE`/`VA` `partial` gate. **Now SURFACED** (this and the
prior session): the marginal control as `engine_control$marginal = "laplace" |
"variational"` (with R mapping the DRM-style `"la"`/`"va"` aliases onto the engine's
`"laplace"`/`"variational"`, `5f0e25f`), and `binomial` with `n_trials` via a
`cbind(successes, failures)` counts response (single common trial count). What
remains `planned`: per-record varying `n_trials` (the engine `BinomialResponse`
holds one common count), and promotion past `partial` (the validation gates below).

**Update (HSquared.jl PR #152 / R mirror).** The twin now serializes
`nongaussian_result_payload(::NonGaussianFit)` fixture cases for Poisson
Laplace and Binomial variational fits, including a vector `n_trials` payload for
the binomial case. The R mirror consumes that fixture in a Julia-free normalizer
test and preserves `n_trials` when the engine payload supplies it. This still
does not activate per-record varying-trial R formula syntax: the current R
`cbind(successes, failures)` route remains restricted to equal row totals until
the live bridge contract is widened deliberately.

---

**Summary (3 lines).**
Phase 6 surfaces non-Gaussian animal models behind a `method = "LA" | "VA"`
control adapted from DRM.jl's `MarginalMethod` dispatch (twin-led; R reserves
the control, the `family ∈ {gaussian, poisson, bernoulli, binomial}` enum + `n_trials`,
and a distinct link-scale `NonGaussianFit` result shape where LA returns a
marginal loglik and VA returns an ELBO lower bound). The twin's experimental
`fit_laplace_reml`/`variational_marginal_loglik` already flag the load-bearing
caveats — Bernoulli `sigma_a2` downward bias from the information effect, the
hard `m = 20` Gauss–Hermite gate, VA `:full`-covariance densification, and
Poisson-only intervals — none of which `hsquared` may paper over.
The Laplace path fits **experimentally** (`31f200c`), and so now do VA
(`5f0e25f`), the `marginal =` control (`"laplace"`/`"variational"` + `"la"`/`"va"`),
and `binomial` with `n_trials` (`cbind(successes, failures)` counts); per-record
varying `n_trials` and promotion past `partial` stay gated behind the validation
gates (Gaussian
self-consistency, Poisson/binomial recovery, LA-vs-VA envelope, external
comparator, bridge parity, Rose audit) and the `HSquared.jl#44` `MarginalMethod`
refactor.

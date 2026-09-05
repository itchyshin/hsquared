# 37 · Non-Gaussian heritability-scale estimand contract (NG-1)

> **Status: NG-2 SIGNED OFF — ratify-with-fixes (3–1), 2026-07-11.** Framework and
> all math independently re-derived and confirmed sound (no mathematical or
> estimand error); resolved decisions in the sign-off block below (§0a) and §6;
> the remaining ratification is labelling/wording (this revision). Owner phrases
> `freeze NG-1 Boole` and `nod NG-1` are **PAID** (fired off-PR, 2026-09-05).
> This is a pure
> design / symbolic-alignment slice: no code, no API change, no default change,
> no `validation_status` flip. It ratifies **how `hsquared` (the R lane) will
> define, compute, label, and surface heritability for non-Gaussian animal
> models** once the bridge exposes it — the single longest **non-compute** pole
> to 1.0 per `docs/design/36-phase3-6-execution-plan.md:52-62`. Nothing here
> reports a heritability today; the current non-Gaussian R surface is
> deliberately **heritability-free** (`R/hs_control.R:120-130`,
> `R/julia-bridge.R:625`).
>
> **DRAFT / PROPOSED wording — merge gate only.** §8 items 3–12 below are
> proposed body text awaiting merge of **#173**. Owner phrases `freeze NG-1
> Boole` and `nod NG-1` are **PAID** (fired off-PR, 2026-09-05); this PR does
> **not** re-fire them. **WAITING** explicit owner paste `merge 173`. Do **not**
> merge on green CI alone. `public_covered_count` stays **7**. Experimental
> stays **0.8.0**. Engine `V6-NS-H2` stays **partial**. No Poisson/Binomial
> covered claim travels here. NG-1 is **not** covered.
>
> **Live pins (2026-09-05).** NG-2 remains SIGNED (2026-07-11). Both mains at
> experimental 0.8.0 sprint (Julia `f8abd105`, R `7a5215d`, count **7**). That
> does **not** ratify NG-1, surface non-Gaussian heritability, or start 0.9.
> Until **#173** merges, the R non-Gaussian path stays **heritability-free**.

**Lane / twin discipline.** The estimand *mathematics* is engine work and is
already implemented and QGglmm-validated in the twin
(`HSquared.jl/src/nongaussian.jl` — `nongaussian_heritability`, gate `V6-NS-H2`
in `HSquared.jl/src/validation_status.jl:489-493`), under the engine's own scale
contract `HSquared.jl/docs/design/19-h2-scale-contract.md`. This R-lane document
does **not** re-derive that math nor authorise edits to `HSquared.jl`; it fixes
the R-facing **surface contract** — which scales `hsquared` promotes, the
extractor grammar, the honesty gates, and the locked citations — so that when the
bridge carries a heritability across, the scale label travels with the number and
no bare `h²` ever appears R-side. **Engine-covered ≠ R-public-covered**
(`docs/dev-log/decisions.md`, 2026-07-11 Release Model; §5 non-negotiable in the
execution plan).

## 0a. NG-2 sign-off record

**NG-2 sign-off — 2026-07-11 (integrator).** Ratified-with-fixes 3–1 (Fisher,
Falconer, Darwin: ratify-with-fixes; MathCheck: ratify). The framework, all
constants/denominators/transforms, and the honesty/NaN gates were independently
re-derived and confirmed sound — **no mathematical or estimand error found**; the
required edits are labelling, wording, citation-attribution, and one flag flip
only (§8). Resolved decisions (§6): **Q1** logit `primary` = **latent
(logistic-liability)**, both scales always surfaced, observation-primary reserved
for genuine multi-trial Binomial (m ≫ 1); **Q2** default = conditional h²
(`predictor_variance = 0`; marginal opt-in and labelled only); **Q3** ordinal
per-category behind `observation_heritability()`, scalar `NaN`, liability primary;
**Q4** Gamma/probit/ordinal remain `planned` in R until an R fitter exists;
**Q5** the A=I anchor is necessary-not-sufficient, paired with a pedigree-A
recovery gate across the m = 1→5→20 ladder (Bayesian = concordance, not parity);
**Q6** μ defaults to the single intercept and hard-errors on the multi-β case.

---

## 0. Why this contract exists (the decision it pins)

Off the identity link there is **no single heritability**. The Gaussian ratio
`σ²a / (σ²a + σ²e)` is only one of several defensible quantities, and it is the
*wrong* number to hand a breeder or ecologist who measured counts or 0/1
outcomes. Three scales coexist — **latent (link)**, **observation (data)**, and
**liability (threshold)** — and which one is meaningful is family-dependent. The
cross-cutting, expensive-to-retrofit decision this contract pins:

> **A non-Gaussian heritability is never returned as a bare `h²`. It always
> carries an explicit scale label — `latent`, `observation`, or `liability` — and
> a degenerate scale is returned as `NaN` with a caveat, never silently dropped
> or back-filled from another scale.**

This mirrors the engine rule (`HSquared.jl/docs/design/19-h2-scale-contract.md`
§1) and the same-shaped R precedent already shipped for the direct–maternal
correlated model, where `heritability()` returns a **labelled triple** (direct
`h²_d`, maternal `m²`, Willham total `h²_T`, `r_am`) rather than a scalar
(`R/extractors.R:74-124`). The non-Gaussian case reuses that grammar with a
`scale` axis in place of the Willham decomposition.

**Symbolic-alignment discipline.** Per the house method (`skills/symbolic-alignment`),
the symbolic math is written **first** (§1–§2), the alignment table is built
**before** the contract (§3), and only then are the surface rules stated (§4).
This catches the failure mode where prose-math claims one scale and the extractor
returns another.

---

## 1. The latent / link-scale model (symbolic, written first)

**Generative model (one univariate non-Gaussian animal model).** For record `i`,

```
η_i = μ + f_i + a_i                          (linear predictor, "latent scale")
a   ~ N(0, A σ²a)                             (breeding values; V_A ≡ σ²a)
E[y_i | η_i] = g⁻¹(η_i)                       (link g maps η to the conditional mean)
y_i | η_i    ~ Family(mean = g⁻¹(η_i), …)     (family-specific conditional law)
```

- `μ` — intercept (link-scale population mean).
- `f_i` — fixed-effect contribution beyond the intercept; its variance across the
  data is `V_fixed` (the `predictor_variance` term; Nakagawa & Schielzeth's
  "variance explained by fixed effects").
- `a_i` — additive breeding value; `V_A = σ²a` is the **additive genetic variance
  on the latent scale** — the only genetic-variance the fit estimates directly.
- `V_pred ≡ V_A + V_fixed` — the **linear-predictor variance**; the spread of `η`
  contributed by predictors (this, and only this, is the integration variance on
  the observation scale — see §2.2).
- `g` — the family's link (log for Poisson/Gamma, logit for Bernoulli/Binomial,
  probit for the threshold families).

**Key structural fact.** On the latent scale there is generally **no free
residual variance component** the way `σ²e` exists for the Gaussian identity link.
Instead the family/link implies a *distribution-specific latent residual*
`V_link` (§2.1). Whether `V_link` is finite, zero, or an added parameter is the
crux of the honesty gates (§4.3). This is why the family-uniform result payload
carries **no** `sigma_e2` and **no** `heritability` for count/binary families
(`docs/design/21-nongaussian-la-va-method.md` §3;
`HSquared.jl/src/nongaussian.jl:807-819`).

---

## 2. The three scales (symbolic definitions)

Terminology follows de Villemereuil, Schielzeth, Nakagawa & Morrissey (2016,
*Genetics*) and Nakagawa, Johnson & Schielzeth (2017, *J. R. Soc. Interface*).

### 2.1 Latent (link) scale

The scale of `η` itself. The total latent variance adds the link's implied latent
residual `V_link` (the "distribution-specific variance"):

```
h²_latent = V_A / (V_A + V_link + V_fixed)
```

`V_link` is a property of the **family and link, not of the data**:

| link | `V_link` | note |
|---|---|---|
| identity (Gaussian) | `σ²e` | the ordinary residual variance |
| logit | `π²/3` | variance of the standard logistic (exact) |
| probit | `1` | Gaussian liability variance (Dempster–Lerner) |
| log (Poisson) | `0` | **no latent residual → h²_latent degenerate (NaN)** |
| log (Gamma, shape ν) | `ψ₁(ν)` = trigamma(ν) = `Var[log Y]` | genuine multiplicative log-scale residual, EXACT |
| cloglog | `π²/6` | Gumbel/extreme-value variance (planned family) |

The **log link is family-dependent**: `0` for Poisson (no dispersion parameter,
so no finite latent residual), but `ψ₁(ν) > 0` for Gamma (a genuine dispersion).
This asymmetry is the reason a single "log-link latent h²" cannot be stated
generically. (`HSquared.jl/docs/design/19-h2-scale-contract.md` §2.1, §3.1.)

> **Proposed / not frozen (NG-2 §8 item 12).** `V_link` here is the link's
> intrinsic latent residual, **not** the Nakagawa–Schielzeth delta-method
> observation-level term `1/[p(1−p)]`. The engine uses QGglmm integration, not
> that delta approximation. Do not swap the two.

### 2.2 Observation (data) scale

The scale of the **measured `y`** (counts, proportions, positive reals). The
additive genetic variance is transported through the *average* inverse-link
derivative `Ψ = E[g⁻¹′(η)]`:

```
Ψ        = E[ g⁻¹′(η) ]                              over η ~ N(μ, V_pred)
V_A,obs  = Ψ² · V_A                                  (Stein's lemma)
h²_obs   = V_A,obs / ( Var(E[y|η]) + E[Var(y|η)] )   (law of total variance denominator)
```

with all expectations taken over the **linear-predictor distribution
`η ~ N(μ, V_A + V_fixed)`**.

> **Load-bearing subtlety (documented spec trap).** The integration spreads `η`
> by the *predictor* variance `V_pred = V_A + V_fixed` **only** — the latent
> residual `V_link` (e.g. `π²/3`) is **NOT** added to the integration variance.
> `V_link` is an observation-process term; on the data scale it reappears inside
> the sampling variance `E[Var(y|η)]`, not as predictor spread. Adding it to the
> integration variance double-counts it. This matches QGglmm's `binom1.logit`
> (`HSquared.jl/docs/design/19-h2-scale-contract.md` §2.2;
> `HSquared.jl/src/nongaussian.jl:1170-1176`).

> **Three quantities that must never be swapped** (the genuinely confusing bit):
> `π²/3` (logit latent residual, denominator of `h²_latent` only); `E[p(1−p)]`
> (data-scale sampling variance, the engine's `var_dist`); and `1/[p(1−p)]` (the
> Nakagawa–Schielzeth delta-method *latent* observation-level term, **not used**
> by the engine's integration method). The engine uses the QGglmm integration
> method, not the NS delta approximation.

By Stein's lemma `Ψ² V_A ≤ Var(E[y|η])`, so `h²_obs ∈ (0,1)` by construction
(verified numerically in the twin suite, not assumed). **Estimand per family:**
PROPORTION for Bernoulli/Binomial, COUNT for Poisson, positive-continuous for
Gamma. For the Gaussian identity link both scales coincide.

> **Non-monotonicity warning.** `h²_obs` is **not** monotone in `σ²a` for some
> families (notably Poisson): raising `V_A` inflates the denominator's sampling
> term too, because the mean–variance coupling moves both. "More `σ²a` ⇒ higher
> data-scale h²" is false in general.

### 2.3 Liability (threshold) scale

For binary/ordinal traits modelled with a threshold/cumulative link there is an
underlying continuous liability `ℓ = η + ε`, observed as `y = 1[ℓ > τ]` (Wright;
Dempster & Lerner 1950). The **liability scale is the latent scale**, with
`V_link = Var(ε)`:

```
h²_liability = V_A / (V_A + V_link + V_fixed)      V_link = 1 (probit), π²/3 (logit)
```

This is the **selection-relevant** heritability for threshold traits and the
natural estimand for the `:bernoulli_probit` and ordinal families. It is
**independent of μ and the cutpoints** (those set the observed incidence, not the
liability partition). The observed-0/1 scale connects to it by the
Dempster–Lerner transform

```
h²_obs = h²_liab · z² / [ p(1−p) ]                 z = φ(threshold), p = incidence
```

> **Proposed / not frozen (NG-2 §8 item 10).** The transform
> `h²_obs = h²_liab · z² / [p(1−p)]` and the ordering "observed-0/1 < liability"
> are Gaussian-**probit** facts (Dempster & Lerner 1950). They apply to
> `:bernoulli_probit` / ordered-probit. The logit "liability" is a **logistic
> analogue** (`V_link = π²/3`). Logit observed-0/1 comes from Gauss–Hermite
> quadrature, not from quoting the probit `z²/[p(1−p)]` formula. A logit caveat
> must not cite that ordering as if it were the logit proof.

The engine computes the probit observed-0/1 scale by QGglmm probit integration
and verifies it equals this transform
(`HSquared.jl/src/nongaussian.jl:1228-1238`). Engine `V6-NS-H2` already scopes
D-L equality to probit and logit observation to GH.

> **Proposed / not frozen (NG-2 §8 item 4).** For **logit** Bernoulli/Binomial,
> the `latent` row **is** the logistic-liability scale (`V_link = π²/3`). The
> table's "(logit liability)" label names that same row. It is **not** a fourth
> scale. `liability_heritability()` on a logit fit may later be a documented
> **alias** of the latent row (same number). That alias is **optional** and is
> **not frozen** until Boole says so. Until then, logit returns `latent` +
> `observation` only. Probit/ordinal keep a distinct `liability` row because
> their primary label is `liability` (`V_link = 1`), which equals their latent
> row by definition. Do not implement the alias in R from this wording, and do
> not add a `liability` row to a logit data.frame. R stays heritability-free
> either way.

---

## 3. Symbolic-alignment table (family → link → V_link → scales defined → estimand)

Built **before** the contract, per symbolic-alignment discipline. This is the
term-by-term map the R surface, the bridge payload, and the engine must agree on.
"Defined scales" is what is mathematically well-posed; "R-surface status" (§4.2)
is what `hsquared` will actually expose.

| Family | Link | `V_link` (distribution-specific variance) | Latent h² | Observation/data h² (Ψ, sampling term) | Liability h² | Primary estimand | Scales defined |
|---|---|---|---|---|---|---|---|
| Gaussian | identity | `σ²e` | `V_A/(V_A+σ²e)` | = latent (coincide) | n/a | trait value | latent = observation |
| **Poisson** | log | `0` | **NaN** (degenerate) | `Ψ=λ=e^{μ+V_pred/2}`; `V_A,obs=λ²V_A`, denom `λ²(e^{V_pred}−1)+λ` | n/a | count | observation only |
| **Bernoulli** | logit | `π²/3` | `V_A/(V_A+π²/3+V_fixed)` | `Ψ=E[p(1−p)]`, `var_dist=Ψ`; GH quadrature | (logit liability) | proportion | latent + observation (info-limited) |
| **Binomial (m>1)** | logit | `π²/3` | same as Bernoulli | `Ψ=E[p(1−p)]`, `var_dist=Ψ/n_trials`; GH quadrature | (logit liability) | proportion | latent + observation |
| Bernoulli-probit | probit | `1` | = liability | Dempster–Lerner `z²/[p(1−p)]` = QGglmm probit integration | `V_A/(V_A+1+V_fixed)` | binary → liability | liability (primary) + observation |
| Ordered-probit (K>2) | cumulative probit | `1` | = liability | **per-category vector** `Ψ_k²V_A/[p_k(1−p_k)]`; scalar stays NaN | `V_A/(V_A+1+V_fixed)` | ordinal → liability | liability (primary) + per-category observation |
| Gamma (shape ν) | log | `ψ₁(ν)` = trigamma, EXACT | `V_A/(V_A+ψ₁(ν)+V_fixed)` (non-degenerate) | `V_A/[e^{V_pred}(1+1/ν)−1]` (NS-2017 multiplicative) | n/a | positive continuous | latent + observation |
| Negative-binomial (NB2) | log | `0` + overdispersion `θ` | needs NS-2017 NB derivation | NS-2017 log-normal form | n/a | count | **owed** |
| Beta-binomial | logit + Beta ρ | `π²/3` + overdispersion | needs derivation | needs derivation | (logit) | proportion | **owed** |

**Rules for owed rows (so future slices do not drift):**

1. `V_link` comes from the link's implied latent residual; where an
   overdispersion parameter adds latent variance (NB2, beta-binomial) it is
   **added to `V_link`** with its own derivation (cite the NS-2017
   distribution-specific-variance table; do not guess the constant).
2. Observation transport is **always** `V_A,obs = Ψ² V_A` integrated over
   `η ~ N(μ, V_A + V_fixed)`; only `Ψ` and the sampling term `E[Var(y|η)]` change
   per family.
3. Threshold **probit** families report **liability h² as primary**, observed as
   secondary via the Dempster–Lerner transform (verified equal to QGglmm probit
   integration). Logit families report **latent** as primary (Q1); their
   observation row is GH quadrature, not a D-L quote.
   *(Proposed / not frozen — NG-2 §8 item 10.)*
4. Each new family lands `experimental`/`partial` until it has its own Laplace
   oracle + pre-declared recovery gate + a same-estimand comparator (§5).

---

## 4. The R-surface contract

### 4.1 Which scales `hsquared` surfaces, and the default

`hsquared` surfaces **all three scale families** — `latent`, `observation`, and
`liability` — as a **scale-labelled object**, never a bare scalar. The returned
object always contains **one row per mathematically-defined scale** for the
fitted family; a degenerate scale is present as an explicit `NaN` row with a
caveat (not omitted, so the user sees *why* it is unavailable).

**Default / recommended scale (`primary` flag).** There is **no silent
bare-scalar default**. The object flags one row `primary` — the
selection/interpretation-relevant scale for that family — which is the value a
printed `summary()` leads with and the one a downstream reduction should prefer:

| Family class | `primary` scale | Rationale |
|---|---|---|
| Gaussian | latent (= observation) | scales coincide |
| Poisson (log) | **observation/data** | Latent is **forced** `NaN` (`V_link = 0`). Observation is the only defined scale, not a preference. *(Proposed / not frozen — NG-2 §8 item 11.)* |
| Gamma (log) | **observation/data** *(R-planned; Tier B)* | Latent is **non-degenerate** (`V_link = ψ₁(ν)`). Observation is a **chosen** primary (measured trait). Do not reuse the Poisson "forced NaN" rationale. *(Proposed / not frozen — NG-2 §8 item 11.)* Gamma stays **R-planned** (Q4). Engine-covered ≠ R-public-covered. |
| Bernoulli, Binomial (logit) | **latent (= logistic-liability)** *(NG-2 ruling 2026-07-11)* | incidence-independent, selection-relevant, and consistent with the probit row (same threshold-trait class); observation surfaced alongside. Observation-primary is reserved for genuine multi-trial Binomial (m ≫ 1); single-trial Bernoulli leads with latent. The `(logit liability)` label names this same latent row — not a fourth scale *(§2.3 item 4)*. |
| Bernoulli-probit, Ordered-probit | **liability** | selection-relevant threshold heritability |

The logit `primary` scale was the one genuinely contestable default; **NG-2
(2026-07-11) ruled it `latent` (the logistic-liability scale)** — Falconer and
Darwin both ruled latent, zero votes for observation. Latent is
incidence-independent, selection-relevant, and consistent with the probit row
(logit vs probit is a near-arbitrary link choice for the same threshold trait),
and it matches this section's own definition of `primary` as the
selection/interpretation-relevant scale. The observation scale is what a breeder
measured but is incidence-dependent and not cross-study comparable; it is
surfaced alongside and is primary only for genuine multi-trial Binomial (m ≫ 1).
Whichever leads, **both are surfaced** — the choice governs only the `primary`
flag, never suppression of a defined scale.

> **Proposed / not frozen (NG-2 §8 item 3).** de Villemereuil et al. (2016)
> recommend *reporting the data scale alongside* the latent scale, not replacing
> the latent scale. This contract follows that: the observation row is always
> present when it is defined. The **field convention** that *leads* with latent
> (QGglmm defaults, MCMCglmm threshold parameterisation, Wilson 2010, Nakagawa–
> Schielzeth 2017 distribution-specific variance) is why NG-2 set logit
> `primary = latent`. Surfacing observation is the de Villemereuil reporting
> rule; leading with latent is the selection/comparability rule. Neither rule
> suppresses a defined scale. Do **not** cite this as "QGglmm says observation
> is primary." That would undo Q1.

### 4.2 Per-family R-surface status (engine-ahead is honestly disclosed)

The R **fitting** surface currently wires only `poisson(log)` and
`binomial(logit)` (incl. Bernoulli as the single-trial case) through the opt-in
`target = "nongaussian"` path (`R/hs_control.R:120-130`;
`docs/design/21-nongaussian-la-va-method.md`). So the heritability surface splits:

**Tier A — R-wired families (this contract's immediate scope).** Poisson-log,
Bernoulli-logit, Binomial-logit (m>1). Their h² math is engine-done and
QGglmm/oracle-validated; the R work is to *expose* it under §4.4 grammar once
NG-2 + a same-estimand comparator (§5) clear. Until then they stay `partial` and
**no h² is reported** (unchanged from today).

**Tier B — engine-ahead, R-planned.** Gamma (engine done: latent trigamma +
data-scale, externally validated ~5e-11 vs QGglmm), Bernoulli-probit and
Ordered-probit (engine done: liability + observed / per-category). These are
**not R-wired fitters yet**; their h² surface is `planned` in R even though the
engine computes it. Twin-discipline forbids reading the engine's coverage as an R
claim.

**Tier C — owed everywhere.** Negative-binomial and beta-binomial: `V_link`
overdispersion term still needs derivation before any scale is surfaced in either
lane.

### 4.3 Honesty gates (each is a hard NaN-or-warn, never a friendlier scalar)

1. **Poisson latent-scale h² = `NaN` is degenerate by design.** The log-Poisson
   model has no free latent residual (`V_link = 0`): the conditional variance
   equals the mean and is fully determined by `η`, so a finite latent ratio
   would invent a residual the model does not contain. This is a deliberate
   honesty gate, not a missing-value software error. Never back-fill from the
   observation/count scale. A finite latent Poisson h² requires a different
   family (e.g. NB2) with its own derived `V_link`. Contrast Gamma, whose log
   link *does* carry a finite `V_link = ψ₁(ν)` (item 11: chosen primary, not
   forced NaN).
   *(Proposed / not frozen — NG-2 §8 item 6; live engine pin
   `HSquared.jl/src/nongaussian.jl:1191-1201`.)*
2. **Varying `n_trials` → observation-scale h² = `NaN`.** For a per-record
   Binomial with a varying trial denominator `n_trials[i]`, the proportion-scale
   sampling term `var_dist = Ψ/n_trials` differs by record, so a **single**
   data-scale h² is ill-defined. It is returned as `NaN` with a caveat and is
   **not silently averaged** across records
   (`HSquared.jl/src/nongaussian.jl:1364-1372`). The latent-scale h² is still
   defined (`V_link = π²/3` is independent of `n_trials`) and is reported.
3. **Single-trial Bernoulli is information-limited.** Binary data carry little
   variance information, so the Laplace/penalized-IRLS `σ²a` is downward-biased
   and boundary-prone (the information effect;
   `docs/design/21-nongaussian-la-va-method.md` §5.1). Both the latent and
   observation h² inherit that bias. The object sets `information_limited = TRUE`
   with a caveat; the value is **never presented as a clean estimate**. Binomial
   with more trials per record recovers `σ²a` progressively better (an
   engine-validated information gradient, m = 1→5→20).
4. **Non-converged fit refused.** `heritability()` on a non-converged
   non-Gaussian fit errors, mirroring the engine
   (`HSquared.jl/src/nongaussian.jl:1354-1355`); it never reports boundary
   values as estimates.
5. **Ambiguous mean requires `mu` + `predictor_variance`.** Default
   `predictor_variance = 0` is **conditional** h² (labelled). With real
   non-intercept fixed effects, leaving it at 0 also **mis-specifies the
   observation-scale integration**: `Ψ`, the mean, and the sampling term all
   depend on `V_pred = V_A + V_fixed`. That is an estimand error, not a cosmetic
   relabel of the latent denominator. Require the caller to supply
   `predictor_variance` or warn that every reported scale is conditional.
   Marginal h² (V_fixed folded in) is **opt-in and labelled only**. Silent
   auto-fold from the design matrix is forbidden (de Villemereuil et al. 2018;
   Wilson 2008). With >1 fixed effect the intercept is ambiguous; the caller
   must supply the link-scale population mean `mu` as well (§4.3 / Q6). Default
   `μ` is the fit's single intercept. With factors or uncentred covariates that
   intercept is a **reference-level conditional** estimand, not a population
   average. Pass a data-average `η` when the caller wants a population-level
   observation-scale number. **Error, never guess**, on the ambiguous multi-`β`
   case.
   *(Proposed / not frozen — NG-2 §8 items 5 and 8. Q2 and Q6 stay as signed.)*
6. **Ordinal interior categories are descriptive, not selectable.** For K>2 the
   observed scale is a **per-category vector** `h2_observation_by_category`; the
   scalar `h2_observation` stays `NaN`. Interior-category indicators are
   non-monotone in the breeding value, so a per-category value can understate the
   exact indicator genetic variance — it is descriptive, and the **liability
   scale is the selection summary**.
7. **Point estimates only; no calibrated interval.** Every non-Gaussian h² is a
   plug-in point estimate. There is **no** coverage-calibrated interval (interval
   calibration exists for no model in either lane yet — 2026-07-11 Release
   Model). Any interval shown must be labelled experimental and uncalibrated.
8. **Laplace agreement ≠ unbiasedness.** glmmTMB shares the same Laplace `σ²a`
   bias, so glmmTMB agreement is **not** evidence of unbiasedness; it is a
   same-approximation cross-check, not a same-estimand gold standard (§5).
9. **Latent-scale magnitude.** Latent-scale h² is typically **larger** than the
   observed measurable-trait h². It is **not** the proportion of observable
   phenotypic variance among relatives. Never report it without the scale label.
   A printed summary that leads with latent must still show the observation row
   when that row is defined. When the omnibus `heritability()` extractor exists,
   this warning travels with it. Today the extractor does not exist; the warning
   text is contract-only. This does not create a fourth estimand and does not
   authorise printing an R number today.
   *(Proposed / not frozen — NG-2 §8 item 9.)*

### 4.4 Extractor grammar (what `heritability()` returns for a non-Gaussian fit)

**Proposed grammar — Boole freeze PAID, merge gate open.** Owner phrase
`freeze NG-1 Boole` is **PAID** (2026-09-05, off-PR). This section is the
naming draft that **#173** applies on merge; it does not become binding until
that merge. The six naming gaps were answered in the same nod (companion card:
`~/local-scratch/h2-ng1-boole-freeze-card-2026-09-04.md`).

**Contract.** `heritability(fit)` on a non-Gaussian `hsquared_fit` returns a
**scale-labelled data frame**, never a numeric scalar — structurally identical to
the direct–maternal labelled triple already shipped (`R/extractors.R:74-124`),
with a `scale` axis replacing the Willham decomposition:

```r
heritability(fit_poisson)
#>          scale  estimate  primary
#> 1       latent       NaN    FALSE   # degenerate: Poisson log link, V_link = 0
#> 2  observation     0.214     TRUE   # count-scale, log-normal-Poisson closed form
#> attr(,"family")            "poisson"
#> attr(,"method")            "lognormal_poisson"
#> attr(,"information_limited") FALSE
#> attr(,"caveat")   "Poisson log link: latent h2 is degenerate (no latent
#>                    residual) -> NaN; observation/count scale via the
#>                    log-normal-Poisson closed form (NS 2017)."
#> attr(,"interpretation") "<scale-labelled, non-Gaussian; see caveat>"
#> Warning: heritability() on a non-Gaussian fit returns SCALE-LABELLED values;
#>   there is no single h2. Use latent_heritability()/observation_heritability()/
#>   liability_heritability() for a targeted, un-warned accessor.
```

Rules:

- **Columns:** `scale` (`"latent"` | `"observation"` | `"liability"`),
  `estimate` (numeric, `NaN` for a degenerate/ill-defined scale), `primary`
  (logical; exactly one `TRUE`).
- **Attributes carried from the engine NamedTuple:** `family`, `method`,
  `var_link`, `var_distribution`, `information_limited`, `caveat`,
  `interpretation`. These are the engine's self-describing fields
  (`HSquared.jl/src/nongaussian.jl:1313-1315`) and **must survive the bridge**.
- **Ordinal (K>2):** the observation row's `estimate` is `NaN` and an additional
  attribute `h2_observation_by_category` (a named numeric vector) carries the
  per-category values; the `liability` row is `primary`.
- **A warning** fires on the omnibus `heritability()` call (as for
  direct–maternal), signalling scale-dependence and pointing to the targeted
  accessors.
- **Targeted, un-warned accessors** (mirroring `direct_heritability()` /
  `total_heritability()`, `R/extractors.R:2436-2468, 2535-2565`):
  - `latent_heritability(fit)` — errors for Poisson (`NaN`, degenerate) with the
    §4.3(1) message; returns the latent value otherwise.
  - `observation_heritability(fit)` — errors for varying-`n_trials`
    (`NaN`, §4.3(2)); returns the data-scale value (or the per-category vector for
    ordinal) otherwise.
  - `liability_heritability(fit)` — defined only for threshold families; errors
    with a "not a threshold family" message otherwise.
- **`mu` / `predictor_variance` pass-through:** these extractors accept
  `mu = NULL`, `predictor_variance = 0` and forward them to the engine, which
  enforces §4.3(5).
- **The result payload stays heritability-free.** `nongaussian_result_payload`
  remains family-uniform and carries **no** `heritability` field
  (`HSquared.jl/docs/design/19-h2-scale-contract.md` §5); heritability is a
  **separate, opt-in, self-describing call**, not a payload field. The R
  extractor computes it via a dedicated bridge call to `nongaussian_heritability`,
  not by reading a stored scalar.

### 4.5 Locked citations (pinned; a covered flip must reproduce these)

These are the estimand's authorities. Every scale formula above traces to one of
them; a covered flip carries the pinned identity + citation per the
Standard-Tier Covered-Flip Gate (`docs/dev-log/decisions.md`, 2026-07-09).

- **Nakagawa, Johnson & Schielzeth (2017).** The coefficient of determination R²
  and intra-class correlation coefficient from generalized linear mixed-effects
  models revisited and expanded. *J. R. Soc. Interface* 14:20170213. — the
  distribution-specific / observation-level variance; the log-normal–Poisson and
  Gamma multiplicative forms; the NB term.
- **de Villemereuil, Schielzeth, Nakagawa & Morrissey (2016).** General methods
  for evolutionary quantitative genetic inference from generalized mixed models.
  *Genetics* 204:1281–1294. — the QGglmm latent/expected/data scales; `Ψ`;
  Stein's lemma; the integration-over-`N(μ, V_pred)` method (implemented as the
  `QGglmm` R package, the external same-estimand comparator anchor).
- **Dempster & Lerner (1950).** Heritability of threshold characters.
  *Genetics* 35:212–236. — the liability scale and the observed↔liability
  transform `z²/[p(1−p)]`.

Supporting (secondary, for `V_fixed` and threshold context):
de Villemereuil, Morrissey, Nakagawa & Schielzeth (2018), *J. Evol. Biol.*
31:621–632 (`V_fixed`); Robertson & Lerner (1949), *Genetics* 34:395–411; Lynch &
Walsh (1998) ch. 25 (threshold characters).

---

## 5. What blocks a `covered` flip (twin-discipline + Covered-Flip Gate)

Per `docs/design/36-phase3-6-execution-plan.md` §3 non-negotiables and the
Standard-Tier Covered-Flip Gate (`docs/dev-log/decisions.md`, 2026-07-09), a
non-Gaussian h² R surface may flip `partial → covered` only when **all** hold:

1. **Estimand ratified (NG-1, this doc) + NG-2 sign-off.** Fisher (inference),
   Falconer (quantitative-genetic interpretation), and Darwin (biology) each sign
   off which scale is the recovered, biologically-meaningful quantity per family
   (§6). Boole freezes the extractor grammar and argument names (`scale`,
   `mu`, `predictor_variance`, the accessor names) **before** the flip.
2. **Same-estimand comparator.** **There is no free frequentist same-estimand
   estimator for the pedigree-A non-Gaussian animal model.** External
   same-estimand validation is limited to the **A = I** reduction (glmmTMB /
   `ordinal::clmm`). That leg is necessary and **not sufficient** (iid only;
   shares Laplace bias; exercises no pedigree-A machinery). Pedigree-A
   correctness is **recovery-gated**, not comparator-gated, and the recovery
   gate must span the **m = 1 → 5 → 20** information ladder. Bayesian agreement
   (MCMCglmm / brms / INLA) is **concordance, never parity**. A covered flip
   that hides this sentence is a Rose blocker. Component estimand `σ²a` is
   gated by that A = I same-estimand leg **plus** the recovery-substitution
   multi-seed gate, with the gap **explicitly disclosed**. The derived h² (each
   scale) is gated by a within-package identity test (`estimate` equals its
   defining function of the covered `σ²a`, `V_link`, `V_fixed`) + the locked
   citation (§4.5). QGglmm agreement on the *transform* (`V6-NS-H2` owed field)
   is not a pedigree-A fitter comparator. This still blocks NG-7.
   *(Proposed / not frozen — NG-2 §8 item 7. Q5 stays as signed.)*
3. **Pre-registered interval coverage** (committed SHA, no post-hoc relaxation,
   pool by summing counts) before any h² *interval* is called calibrated — §4.3(7).
4. **R↔engine element-wise parity** across the bridge (Hopper), with every scale
   label, `NaN` gate, and caveat preserved.
5. **Rose audit** of README, claims register, `formula_status()`, and
   `capability-status.md` before any public exposure.

Until then: **no heritability is reported for a non-Gaussian fit**
(`docs/dev-log/decisions.md`, 2026-07-11: "no heritability is reported for
non-Gaussian fits until the scale note and a same-estimand comparator exist").
This document is the scale note; the comparator is still owed.

---

## 6. Resolved questions (NG-2, 2026-07-11)

All six resolved by the NG-2 sign-off; recorded here and in §0a.

1. **Logit `primary` scale — `latent` (logistic-liability).** Falconer + Darwin
   ruled latent; Fisher + MathCheck did not oppose and flagged the logit/probit
   inconsistency that latent-primary cures; zero votes for observation. Both
   scales stay surfaced; observation-primary reserved for genuine multi-trial
   Binomial (m ≫ 1). Supersedes the earlier "proposed: observation."
2. **`V_fixed` default — conditional.** Default `predictor_variance = 0` =
   conditional h² (labelled). With non-intercept fixed effects, require the user
   to supply it or warn the h² is conditional; **marginal** (V_fixed folded in) is
   opt-in and labelled only — **no silent auto-computation from the design**
   (de Villemereuil et al. 2018; Wilson 2008).
3. **Ordinal observed-scale — behind the accessor.** Per-category vector held
   behind `observation_heritability()`; the scalar `h2_observation` stays `NaN`
   with a caveat pointing to the accessor; `liability` primary.
4. **Tier-B timing — keep `planned`.** Gamma/probit/ordinal stay fully `planned`
   in R until their R fitter is wired (engine-covered ≠ R-public-covered).
5. **Comparator honesty (NG-6) — necessary-not-sufficient.** The A=I
   glmmTMB/`ordinal::clmm` leg is a necessary same-estimand anchor but **not
   sufficient** (iid reduction only; shares Laplace bias; exercises no pedigree-A
   machinery); it must be paired with a pedigree-A recovery-substitution
   multi-seed gate spanning the **m = 1 → 5 → 20** information ladder. Bayesian
   (MCMCglmm/brms/INLA) agreement = concordance, never same-estimand parity.
6. **Default `μ` — single intercept, hard-error on multi-β.** μ defaults to the
   fit's single intercept (`HSquared.jl/src/nongaussian.jl:1357-1363`); with
   factor/uncentred covariates μ = intercept is a **reference-level conditional**
   estimand, not a population average — R mirrors the engine and errors (never
   guesses) on the ambiguous multi-`β` case. Pass a data-average `η` when the
   caller wants a population-level observation-scale number.
   *(§4.3(5) proposed wording restates this; the ruling line is unchanged.)*

---

## 7. References

**Cornerstones (locked, §4.5).**
- de Villemereuil, Schielzeth, Nakagawa & Morrissey (2016). *Genetics*
  204:1281–1294.
- Nakagawa, Johnson & Schielzeth (2017). *J. R. Soc. Interface* 14:20170213.
- Dempster & Lerner (1950). *Genetics* 35:212–236.

**Supporting.**
- Nakagawa & Schielzeth (2010). *Biol. Rev.* 85:935–956.
- Nakagawa & Schielzeth (2013). *Methods Ecol. Evol.* 4:133–142.
- de Villemereuil, Morrissey, Nakagawa & Schielzeth (2018). *J. Evol. Biol.*
  31:621–632.
- Robertson & Lerner (1949). *Genetics* 34:395–411.
- de Villemereuil (2018). *Ann. N. Y. Acad. Sci.* 1422:29–47.
- Lynch & Walsh (1998). *Genetics and Analysis of Quantitative Traits*, ch. 25.

**Repo cross-references.**
- Engine scale contract: `HSquared.jl/docs/design/19-h2-scale-contract.md`.
- Engine implementation: `HSquared.jl/src/nongaussian.jl`
  (`nongaussian_heritability`, `_nongaussian_h2_core`), gate `V6-NS-H2` in
  `HSquared.jl/src/validation_status.jl:489-493`.
- R LA/VA method + result shape: `docs/design/21-nongaussian-la-va-method.md`.
- R per-record varying-trial plan: `docs/design/31-nongaussian-per-record-trials-activation-plan.md`.
- R extractor precedent (labelled triple): `R/extractors.R:74-124`,
  `2436-2468`, `2535-2565`.
- Release model / covered-flip gate: `docs/dev-log/decisions.md` (2026-07-09,
  2026-07-11); execution plan `docs/design/36-phase3-6-execution-plan.md`.

---

## 8. NG-2 required edits (labelling / wording / citation — no math change)

Enumerated by the NG-2 sign-off; the math is clean. Items 1–2 were already
applied. Items 3–12 are **proposed body text in this DRAFT** — not frozen, not
a Boole freeze, not a maintainer nod. §4.4 extractor grammar stays **proposed**.
There is **no** "apply §8" fire phrase that skips Boole.

1. **[APPLIED]** §4.1 logit `primary` → latent; §6 Q1 recorded as ruled.
2. **[APPLIED]** Bernoulli vs Binomial(m≫1): observation-primary reserved for
   genuine multi-trial proportions; single-trial Bernoulli leads with latent.
3. **[PROPOSED / not frozen]** de Villemereuil citation: report the data scale
   alongside the latent, not demote it — support for surfacing observation; field
   convention (QGglmm, MCMCglmm, Wilson 2010, NS 2017) leads with latent. Applied
   under §4.1.
4. **[PROPOSED / not frozen]** Logit-liability is the latent row, not a fourth
   scale. Optional `liability` alias stays **unfrozen** (Boole card). Applied
   under §2.3 and the §4.1 table gloss.
5. **[PROPOSED / not frozen]** §4.3(5)/Q2 V_fixed: default = conditional h²;
   `predictor_variance = 0` also mis-specifies observation-scale integration —
   an estimand error, not a relabel. Applied as the replacement §4.3(5).
6. **[PROPOSED / not frozen]** §4.3(1) Poisson-latent NaN is a deliberate
   honesty gate, not a software error. Applied as the replacement lead of
   §4.3(1).
7. **[PROPOSED / not frozen]** §5(2)/NG-6: pedigree-A gap is the most prominent
   line. Applied as the new lead of §5(2).
8. **[PROPOSED / not frozen]** §4.3/Q6 μ caveat: intercept is a reference-level
   conditional. Applied in §4.3(5); Q6 ruling line unchanged.
9. **[PROPOSED / not frozen]** Latent-scale magnitude warning. Applied as
   §4.3(9). Contract-only until an extractor exists.
10. **[PROPOSED / not frozen]** Dempster–Lerner scope is probit-specific.
    Applied after the live D-L display and as the replacement §3 rule 3.
11. **[PROPOSED / not frozen]** Poisson-forced vs Gamma-chosen split in the
    §4.1 table. Gamma stays R-planned.
12. **[PROPOSED / not frozen]** (polish) §2.1 V_link footnote: intrinsic latent
    residual, not the NS delta-method `1/[p(1−p)]` term.

**Owner phrase receipt (fired off-PR — not re-fired here):**

| Gate | Phrase | Status | Does not unlock |
|---|---|---|---|
| Boole freeze of the six naming gaps | `freeze NG-1 Boole` | **PAID** 2026-09-05 | Extractor merge · h² numbers · covered · 0.9 · Layer B |
| Maintainer nod | `nod NG-1` | **PAID** 2026-09-05 | Poisson/Binomial covered · `V6-NS-H2` covered · G10 · compute-go · 0.9.0 |
| Apply §8 wording | `merge 173` | **WAITING** (owner paste) | Covered flip · version bump · heritability surface |

---

*NG-1 — NG-2 signed off (2026-07-11). Freeze+nod **PAID** off-PR (2026-09-05).
This DRAFT (#173) proposes the §8 wording; merge waits on explicit owner paste
`merge 173`. No code, no default, no `validation_status` change, no version bump,
and no covered-count change land with this document. NG-1 is **not** covered.
Count stays **7**. Experimental stays **0.8.0**. Pins: R `7a5215d`, Julia
`f8abd105`.*

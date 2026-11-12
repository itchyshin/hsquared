# Why hsquared's SEs are wider than ASReml-R's: great tit check

**2026-11-09. Development evidence only.** ASReml is not a permitted covered
comparator leg (`docs/design/52-v07-exact-G-comparator-recipe.md:21`). Nothing
here flips a capability row. One dataset, two traits, one machine.

## Short answer

There is no bug in either package. They report standard errors from **different
information matrices**, both evaluated at the same REML optimum:

| package | SE is the square root of the diagonal of | source |
| --- | --- | --- |
| ASReml-R 4.2 | inverse **average information** (AI), `1/2 y'P Vi P Vj P y` | the matrix its AI-REML optimiser already has |
| hsquared 0.9.0, `target = "repeatability"` | inverse **observed information**, `-d2 logL / d theta2` | central finite-difference Hessian, `HSquared.jl/src/likelihood.jl:2840-2870` |

For a covariance structure that is linear in the variance components, the two
matrices are tied by an exact identity, `observed = 2 * AI - expected`, where
`expected = 1/2 tr(P Vi P Vj)`. All three converge to the same thing as the sample
grows, but on any one dataset they differ. On these data AI > observed, so
ASReml's SEs come out smaller.

The two packages are not expected to agree 100%. They agree on the estimates and
on the likelihood, but "the SE" is not uniquely defined for REML; three
asymptotically equivalent choices exist and the packages chose differently.

## Evidence

Same data, same pruned pedigree (10,937 / 10,914 rows), same model
(`fixed: year + round + manipulation + age`, `random: animal (A) + permanent
environment (I)`), identical inputs for every leg (`inputs.rds`).

### Clutch size (11,856 records, 7,340 females)

| | V_A | V_PE | V_E | h² |
| --- | --- | --- | --- | --- |
| estimate: ASReml = hsquared (to 8 digits) | 0.595400 | 0.525231 | 1.372760 | 0.238791 |
| **ASReml reported SE** | 0.06633 | 0.06477 | 0.02822 | 0.02558 |
| independent R, inverse AI | 0.06633 | 0.06477 | 0.02822 | 0.02558 |
| **hsquared reported SE** | 0.06980 | 0.06788 | 0.02848 | 0.02695 |
| independent R, inverse observed | 0.06978 | 0.06787 | 0.02848 | 0.02694 |
| independent R, inverse expected | 0.06336 | 0.06210 | 0.02797 | 0.02440 |
| **MCMCglmm posterior SD** | 0.07115 | 0.06814 | 0.02847 | 0.02739 |
| MCSE of posterior SD | 0.00094 | 0.00093 | 0.00024 | 0.00037 |

Distance of the MCMCglmm posterior SD from each SE, in Monte Carlo SEs:

| | V_A | V_PE | V_E | h² |
| --- | --- | --- | --- | --- |
| vs inverse AI (ASReml) | 5.1 | 3.6 | 1.1 | 4.9 |
| vs inverse observed (hsquared) | 1.5 | 0.3 | 0.0 | 1.2 |
| vs inverse expected | 8.3 | 6.5 | 2.1 | 8.0 |

The Bayesian posterior agrees with hsquared's observed-information SEs within
Monte Carlo error and rejects both AI and expected information. That is what
large-sample theory predicts: the posterior variance tracks the inverse
**observed** information (Bernstein-von Mises), not an average of it.

### Laying date (11,642 records, 7,288 females)

| | V_A | V_PE | V_E | h² |
| --- | --- | --- | --- | --- |
| estimate: ASReml = hsquared | 6.26533 | 3.01539 | 28.4227 | 0.166174 |
| ASReml reported SE (= R inverse AI) | 0.8323 | 0.8561 | 0.5605 | 0.02155 |
| hsquared reported SE (≈ R inverse observed) | 0.8440 | 0.8550 | 0.5577 | 0.02185 |
| MCMCglmm posterior SD (MCSE) | 0.896 (0.016) | 0.911 (0.020) | 0.550 (0.005) | 0.0232 (0.0004) |

Laying date can't discriminate. The AI and observed SEs differ by only about 1.5%
here, well below what the chains can resolve. The chains also mix poorly
(ESS 400-500, R-hat 1.02-1.03). The posterior is visibly skewed: V_PE has posterior
mean 2.85 and mode 2.72 against REML 3.02, and V_PE is only 3.5 SEs from zero.
That skew makes the posterior SD about 6% wider than either curvature-based SE.
It is a property of the posterior, not evidence for either SE.

## Method

1. `01-asreml.R`: ASReml-R 4.2.0.482, `vm(animal, Ainv) + ide(animal)`, five
   `update()` calls after convergence; SEs from `summary()$varcomp`, h² SE from
   `vpredict()`. `Ainv` is built with `nadiv::makeAinv()` because asreml's
   `ainverse()` failed with `code = 1` in some R processes on this host.
2. `02-reference.R`: independent base-R + `Matrix` code: Henderson MME,
   sparse Cholesky REML log-likelihood, AI matrix from working variates, observed
   information by 5-point/4-point finite differences (relative steps 1e-2, 3e-3,
   1e-3 agree to 4 significant figures), expected = 2 AI - observed. Optimum
   polished by AI-Newton; ASReml's estimates were already at it (score < 4e-4).
3. `03-hsquared.R`: hsquared on this branch (= `main` `a76ef3f`) with HSquared.jl
   `main` `15e932f`, `target = "repeatability", scale_method = "auto"`.
4. `04-mcmcglmm.R`: MCMCglmm 2.36, flat fixed-effect prior, inverse-gamma
   (nu = 0.002) variance priors centred on Var(y)/3; 6 chains × 65,000 iterations,
   burn-in 5,000, thin 50 (7,200 draws per trait). MCSE of the posterior SD by the
   delta method on the ESS of squared deviations, cross-checked against the
   between-chain spread of chain SDs.
5. `05-compare.R`: the tables above (`log-compare.txt`).

## What this means for hsquared

- **Not a bug.** hsquared computes observed-information SEs correctly (matches the
  independent R reference to 4-5 significant figures).
- **A real inconsistency to fix.** HSquared.jl uses inverse AI for the
  univariate animal model (`fit_ai_reml`, `likelihood.jl:4927`) and the genomic
  GREML route, but inverse observed information for the two-effect and K-effect
  routes (`likelihood.jl:2473/2816/2869/4363`). Adding a `permanent()` term
  therefore silently changes what "SE" means. Neither the output nor the docs say
  which one the user got.
- **A choice for the default.** Observed information is the one a Bayesian
  posterior reproduces and the one usually preferred for inference (Efron & Hinkley
  1978). Average information is what ASReml, WOMBAT, BLUPF90 and DMU report, so
  users comparing against them will see AI numbers. It also costs nothing extra
  after an AI-REML fit, while the observed matrix needs ~13+ extra likelihood
  evaluations.

## Earlier saved results, explained

`hsquared_results.rds` (Sept 2026) gave SE(V_A) = 0.0709 and the RESULTS note gave
0.0696 for the same model. Both came from older engine versions. The current
engine is deterministic: two reruns gave 0.069801212 both times.

## Timing (same inputs, same machine, idle cores)

`06-timing-asreml.R` and `07-timing-hsquared.R`, run one after the other on an
otherwise idle 16-core Mac (after the MCMC chains exited). Medians of 7 runs,
min-max in brackets, seconds.

| step | clutch size | laying date |
| --- | --- | --- |
| ASReml: build `Ainv` (nadiv, R) | 0.31 (0.30-0.31) | 0.33 (0.32-0.37) |
| ASReml: fit incl. AI SEs | 0.48 (0.45-0.57) | 0.42 (0.41-0.44) |
| **ASReml: Ainv + fit** | **0.78** | **0.74** |
| **hsquared, warm: whole `hsquared()` call** (data checks, Ainv in Julia, fit, observed-information SEs) | **0.96 (0.92-1.03)** | **1.07 (1.05-1.13)** |
| hsquared, cold: first call in a fresh R session (Julia start + compile) | 13.3 | — |

Warm, like for like (relationship matrix + fit + SEs), hsquared takes about
1.2-1.45 times as long as ASReml on this problem. hsquared's call also includes
the observed-information Hessian, which needs extra likelihood evaluations that
an AI-based SE would not. The one-off ~12 s Julia start-up and compile cost is
paid once per R session. Settings: Julia 1 thread, BLAS 12 threads; ASReml
`threads = -1` (its default). Fit-only times exclude data loading.

## Update: `se_method` switch, AI by default (same day)

hsquared now takes `hs_control(se_method = "ai")` (default) or `"observed"`.
Engine: HSquared.jl branch `claude/se-information-switch` (worktree
`~/hsq-wt/hjl-se-info`); R: branch `claude/se-asreml-mcmcglmm-investigation`.
With `"ai"`, hsquared's SEs equal ASReml's to every printed digit:

| | SE(V_A) | SE(V_PE) | SE(V_E) | SE(h²) |
| --- | --- | --- | --- | --- |
| clutch size, ASReml | 0.0663271 | 0.0647677 | 0.0282198 | 0.0255754 |
| clutch size, hsquared `"ai"` | 0.0663271 | 0.0647677 | 0.0282198 | 0.0255754 |
| clutch size, hsquared `"observed"` | 0.0698012 | 0.0678846 | 0.0284784 | 0.0269484 |
| laying date, ASReml | 0.832305 | 0.856065 | 0.560512 | 0.0215506 |
| laying date, hsquared `"ai"` | 0.832305 | 0.856065 | 0.560512 | 0.0215506 |
| laying date, hsquared `"observed"` | 0.843961 | 0.855043 | 0.557684 | 0.0218492 |

### Timing, ASReml vs hsquared `"ai"` vs `"observed"`

`06-timing-asreml.R 7` then `08-se-method-timing.R 7`, run back to back on an
idle 16-core Mac (no other R or Julia process). Medians of 7 warm runs, min-max
in brackets, seconds. Julia 1 thread / BLAS 12; ASReml default threads.

| | clutch size | laying date |
| --- | --- | --- |
| ASReml: build `Ainv` (nadiv) | 0.29 | 0.29 |
| ASReml: fit incl. AI SEs | 0.42 (0.42-0.49) | 0.36 (0.36-0.38) |
| **ASReml total** | **0.71** | **0.65** |
| **hsquared, `se_method = "ai"`** (whole call) | **0.77 (0.77-0.82)** | **0.90 (0.89-0.90)** |
| **hsquared, `se_method = "observed"`** (whole call) | **0.90 (0.89-0.91)** | **1.03 (1.02-1.13)** |
| ratio hsquared `"ai"` / ASReml | 1.09 | 1.39 |
| ratio hsquared `"observed"` / ASReml | 1.26 | 1.59 |

Switching to AI saves 0.12-0.13 s per fit here. That is the 24-evaluation
finite-difference Hessian replaced by one factorisation and three solves. The
remaining gap to ASReml is in the fit itself, not the SEs. Each hsquared figure
is the whole `hsquared()` call (data checks, Julia `Ainv`, fit, SEs, result
marshalling). The first call in a fresh R session costs about 12 s more for Julia
start-up and compilation.

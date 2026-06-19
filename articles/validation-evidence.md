# Validation evidence

This article is the honest answer to one question: *what does it mean
when `hsquared` says a model is validated, and what is the actual
evidence?* It is written test-first. Every claim below points at a
fixture, a test, or a study that lives in the repository, and nothing is
advertised as working beyond what those checks demonstrate. One
practical fact up front: the default univariate fit needs a local Julia
engine (`HSquared.jl` via `JuliaCall`); the pure-R reference checks
below run without it, and the “What runs where” section gives the full
split. When in doubt, the live, machine-readable table is
[`validation_status()`](https://itchyshin.github.io/hsquared/reference/validation_status.md)
— read it, not this prose, as the source of truth. Its columns are the
capability, its `status` (one of *planned*, *partial*, or *covered*,
defined just below), and the claim boundary attached to each.

``` r

library(hsquared)
validation_status()
#> <hs_validation_status>
#>   validation: status table only; checks are run by tests and CI
#>   public claims: only `covered` rows may be advertised as working
#>                                                                   capability
#>                                              tiny deterministic Ainv fixture
#>                                              Mrode9 pedigree Ainv comparator
#>                                      supplied-variance Henderson MME fixture
#>                                              sparse REML likelihood identity
#>                                        Mrode-style supplied-variance outputs
#>                                  experimental sparse REML estimator (opt-in)
#>                                experimental repeatability estimator (opt-in)
#>             experimental two-effect estimator (opt-in: common-env, maternal)
#>  experimental supplied-relationship estimator (opt-in: genomic, single-step)
#>        experimental SNP-BLUP marker-effect solve (opt-in, supplied-variance)
#>                            experimental multivariate REML estimator (opt-in)
#>                 univariate Gaussian animal-model fit (default path, AI-REML)
#>                      external published-REML recovery (gryphon, R reference)
#>                    known-truth DGP variance-component recovery (R reference)
#>                                            Mrode fitted animal-model outputs
#>                                                     ASReml comparison policy
#>                                         BLUPF90/DMU/WOMBAT comparison policy
#>                                                        XSim simulation truth
#>                                              genomic and QTL/eQTL validation
#>                                          GLLVM-style multivariate validation
#>                                                   CPU/GPU backend comparison
#>     phase  status
#>   Phase 1 partial
#>   Phase 1 partial
#>   Phase 1 partial
#>   Phase 1 partial
#>   Phase 1 partial
#>   Phase 1 partial
#>   Phase 2 partial
#>   Phase 2 partial
#>   Phase 5 partial
#>   Phase 5 partial
#>   Phase 3 partial
#>   Phase 1 covered
#>   Phase 1 covered
#>   Phase 1 covered
#>   Phase 1 planned
#>   Phase 1 planned
#>   Phase 1 planned
#>  Phase 5+ planned
#>  Phase 5+ planned
#>   Phase 6 planned
#>  Phase 7+ planned
```

## What “validated” means here

`hsquared` treats validation as a product surface, not a footnote. A
public capability is only advertised as working once evidence for it
exists. The status ladder has three rungs, and the meanings are
deliberately narrow:

- **planned** — named in the roadmap, no implementation and no evidence.
  The parser may even reserve the syntax, but it errors as not
  implemented.
- **partial** — implemented behind an opt-in control, with tests that
  pin its *shape* and *internal consistency*, but **not** promoted to a
  working claim. Partial rows are experimental: REML-only, Julia-owned,
  gated on the twin engine’s own status, and explicitly not the default,
  not production, and not validated against a known truth or an external
  comparator.
- **covered** — promoted. The capability fits by default and is backed
  by known-truth recovery and/or a citable external anchor at declared
  tolerances. Only `covered` rows may be described as working.

The gate is real. The v0.1 univariate Gaussian animal model could not
move from `partial` to `covered` until a written, binding promotion rule
(the predicate) was met and audited (see the [V0.1
contract](https://github.com/itchyshin/hsquared/blob/main/docs/design/01-v0.1-contract.md)).
That predicate explicitly rejects the easy mistakes: internal
self-agreement (an R reference solve matching the engine at supplied
variances), start-independence, and dense-vs-sparse-vs-pure-R agreement
all prove the optimizer is *reproducible on the same objective* — they
are **not** known-truth evidence and never satisfied the gate on their
own.

A second discipline runs underneath: a *test of tests*. A fixture that
asserts “the reference matches this pinned number” can be vacuous if the
pinned number came from the same code, or if the tolerance is wide
enough to accept anything. The negative-control suite feeds each real
comparison a deliberately wrong value and proves the comparison rejects
it. Validation that cannot fail is not validation.

## The v0.1 evidence

The promoted capability is the univariate Gaussian animal model,
`y ~ fixed + animal(1 | id, pedigree = ped)`, Gaussian, REML, one record
per animal. Here is the evidence behind that promotion,
weakest-to-strongest, with the file each piece lives in.

### Published-anchor recovery (gryphon birth weight)

The signed-off external anchor is the gryphon birth-weight univariate
animal model from Wilson et al. (2010, *J. Anim. Ecol.* 79:13–26), with
published REML estimates VA = 3.3954, VE = 3.8286, h² = 0.470 (data
shipped in the CRAN package `enhancer`). Two independent recoveries are
checked:

- hsquared’s **own pure-R REML reference** recovers the published VA,
  VE, and h² to within the signed-off band (VA/VE within ~2%, h² within
  ~0.02).
- the **Julia engine** (`fit_sparse_reml` *and* `fit_ai_reml`) recovers
  the same published values within that band, when supplied the
  published relationship matrix `A_gryphon`. The engine *correctly
  rejects* the raw gryphon pedigree — it has ancestral loops that even
  [`nadiv::prepPed`](https://rdrr.io/pkg/nadiv/man/prepPed.html) refuses
  — so the anchor uses the supplied `A`. Engine-vs-pure-R agreement is
  to machine precision.

This is recovery within a maintainer-signed-off band, **not** a
bit-exact match, and the gryphon population is teaching/simulated data.
Tests: `test-validation-fixtures.R` (“hsquared’s R REML reference
recovers the published gryphon estimates”; “the Julia engine recovers
the published gryphon estimates via supplied A”).

### Known-truth recovery (simulated DGP)

The strongest correctness evidence is a known-truth recovery study
following the ADEMP framework (Morris, White & Crowther 2019) — a
standard checklist for simulation studies: Aims, Data-generating
mechanism, Estimands, Methods, Performance measures. Data are simulated
from a univariate Gaussian animal model with **known** variance
components over a clean, non-selfing generational pedigree (n = 420
animals; founders unrelated). True breeding values are drawn as
`u = sqrt(sigma_a2) * U' z` with `A = U'U`, so `Cov(u) = sigma_a2 * A`.
The estimator must recover the generating values and produce EBVs that
track the true breeding values.

Recorded result (engine `ai_reml`, 120 replicates, fixed master seed
20240613, n = 420, all converged):

- σ²ₐ, σ²ₑ, and h² are **near-unbiased** — `0` lies inside
  `bias ± 2·MCSE` for all three (e.g. h² bias −0.0049, MCSE 0.0073);
- EBVs track the true breeding values, mean `cor(EBV, true) ≈ 0.74` at
  h² = 0.4;
- the engine matches the independent pure-R reference to machine
  precision.

Recovery holds across an h² grid (0.2 / 0.4 / 0.6, 100 reps per cell):
all near-unbiased, with EBV accuracy rising with h² (≈ 0.60 / 0.74 /
0.83). The near-boundary cell (h² = 0.1) is reported honestly, not
hidden: mild upward bias, 94% convergence, and 5% boundary pinning of
σ²ₐ (the estimate hitting its lower bound of zero). Recovery also holds
for a model with a fixed effect (`y ~ x + animal`): h² near-unbiased and
the slope recovered (b_x ≈ 0.99 vs 1.0). The full study is reproducible
evidence in `data-raw/dgp-recovery-study.R` (it is `.Rbuildignore`d, not
part of the build). A faster pure-R regression test guards a small-N
case in CI (`test-validation-fixtures.R`, “REML recovers known variance
components from a simulated DGP”).

### External-package agreement

Two external R packages are used as comparators:

- **sommer** is the signed-off `V1-COMPARATORS` agreement check. On the
  gryphon anchor it agrees with the pure-R reference within the
  signed-off band (variance components ~1–2% relative, h² ~0.01–0.02
  absolute). The check is robust to sommer API churn — it skips, rather
  than fails, if the API differs.
- **pedigreemm** provides a *one-sided* floor only: on a deterministic
  replicated dataset, hsquared’s REML solution is verified to be *at
  least as good* by REML log-likelihood (it reaches the true optimum;
  pedigreemm’s optimizer lands slightly off on these pedigree models,
  and cannot fit the saturated one-record-per-animal design at all —
  hence the replicated design). This is a lower bound, not two-sided
  parity.

Tests: `test-validation-fixtures.R` (“hsquared’s REML solution is at
least as good as the pedigreemm comparator”).

### Supplied-variance Henderson / Mrode-style fixtures

At *supplied* variance components, the engine and an independent R
reference are pinned against textbook-style mixed-model-equation
outputs:

- a five-animal Henderson MME fixture (fixed effects, EBVs, fitted
  values, h²);
- a twelve-animal Mrode-style fixture (Ainv, fixed effects, EBVs, fitted
  values, PEV, reliability, h², ML log-likelihood, and dense/sparse REML
  log-likelihood);
- a tiny three-founder likelihood-identity fixture with closed-form ML
  and REML targets (`-0.5(2·log2π + 3·log2 + log1.5 + 1)` for REML),
  checked against Julia’s dense and sparse REML evaluators.

These solve the BLUP/MME at given variances; they do **not** estimate
variance components. Tests: `test-validation-fixtures.R`,
`hs_*_validation_fixture()` helpers in `R/validation-fixtures.R`.

### Independent hand-built-MME anchors (non-circular)

The supplied-variance fixtures above have a known weakness: they pin
numbers the package solver itself produced
(`hs_solve_henderson_mme_reference()`), so a wrong solver would still
pass. Two **independent** anchors close that circularity by building the
MME by hand in lambda form (parameterised by the variance ratio λ =
σ²ₑ/σ²ₐ rather than the variances themselves),

    lambda = sigma_e2 / sigma_a2
    C   = [[ X'X ,        X'Z          ],
           [ Z'X , Z'Z + Ainv * lambda ]]

solving it directly, and asserting the package solver matches *that*
hand solve — never a value the solver produced:

- **diag(3) PEV/reliability anchor** — a tiny intercept-only design with
  `Ainv = I`, anchoring the PEV (`diag(solve(C)) * sigma_e2`) and
  reliability (`1 − PEV / (sigma_a2 · diag(A))`) reference functions
  (`test-pev-reliability-anchor.R`);
- **twelve-animal pedigree anchor** — the Mrode-style pedigree *with
  genuine relatedness* (off-diagonal Ainv entries, two-column X),
  anchoring fixed effects and EBVs (`test-pedigree-mme-anchor.R`).

These prove the solver agrees with an independent hand solve of the same
MME. They do not yet pin the *published* Mrode textbook EBV digits —
that is a flagged maintainer-confirm follow-up, not a silent gap.

### Pedigree-inverse comparator (Mrode9 / nadiv)

Sparse `Ainv` construction is checked against an external reference: the
engine’s `pedigree_inverse()` is compared to
[`nadiv::makeAinv()`](https://rdrr.io/pkg/nadiv/man/makeAinv.html) on
the Mrode example-9.1 pedigree shipped by `nadiv`, when both are
available (`test-mrode-validation.R`). This is a pedigree-inverse
comparator only, not a fitted-output claim.

### The negative controls (tests of tests)

`test-negative-control.R` proves the comparisons above are
*discriminating*. Each control reuses the same pure-R reference and the
same tolerance as a real validation test, feeds it a deliberately wrong
value, and asserts rejection:

- a fixed-effect vector off by ±0.1, or an EBV off by 0.5, fails the
  1e-12 / 1e-8 bands;
- a REML log-likelihood off by 0.01 fails the 1e-10 band;
- a gryphon VA off by 0.5 or h² off by 0.1 fails the 0.02 recovery band;
- a variance estimate scaled by 1.5 fails the 5e-2 cross-check band;
- a DGP statistic biased by 0.1 fails the 0.06 recovery band, and an EBV
  accuracy of 0.3 fails the 0.5 floor.

All negative controls are pure R, fast, and CI-runnable. If a real
fixture ever became vacuous, its paired control would start failing.

## What runs where: public CI vs locally

The split matters because most of the strong evidence needs a live
engine that the public build host does not have.

**Runs in public CI (no Julia):**

- the pure-R REML reference recovery checks (the small-N simulated DGP
  and, when `enhancer` is installed, the gryphon pure-R recovery);
- the supplied-variance fixtures evaluated against the independent R
  references;
- the two independent hand-built-MME anchors;
- the full negative-control suite;
- the pure-R leg of the independent-optimizer cross-check (convergence,
  finite positive estimates).

**Runs only locally (needs a local Julia + `HSquared.jl` +
`JuliaCall`):** all live-engine tests are skip-guarded with
`hs_julia_bridge_available()` and skip cleanly when the bridge is
absent. These include:

- the live-engine gryphon recovery via supplied `A` (`fit_sparse_reml`
  and `fit_ai_reml`);
- the full engine DGP recovery study in `data-raw/dgp-recovery-study.R`;
- the Julia `pedigree_inverse()` / `henderson_mme()` / dense-and-sparse
  REML agreement against the supplied-variance and Mrode9 fixtures;
- the start-independence, sparse-vs-dense, and AI-REML-vs-sparse
  optimizer cross-checks.

This is why CI staying green is necessary but not sufficient: it
confirms the R lane and the discriminating power of the comparisons,
while the engine recovery evidence is established locally with the
engine in place.

## Honest boundaries

What the v0.1 promotion does **not** claim:

- **REML only.** ML estimation is rejected on the fit path
  (`REML = FALSE` errors). The supplied-variance paths (`henderson_mme`,
  `snp_blup`) solve at given variances rather than estimating them.
- **No validated SEs/CIs.** Standard errors and confidence intervals for
  the variance components and heritability are out of v0.1 scope.
  [`summary()`](https://rdrr.io/r/base/summary.html) and the extractors
  report point estimates only and must not print or imply an interval
  for variance components or h². A validated SE/interval is deferred.
- **[`accuracy()`](https://itchyshin.github.io/hsquared/reference/reliability.md)
  is not a validated accuracy.** It is the square root of reliability —
  a model-internal quantity on the dense validation path — not the
  realised `cor(EBV, true)` used as recovery evidence. PEV and
  reliability are reported on the dense validation path only and are
  labelled as such.
- **Opt-in models are partial/experimental.** Repeatability, two-effect
  (common-environment / maternal-genetic), genomic GREML, single-step,
  SNP-BLUP, and multivariate models fit only through
  `hs_control(engine = "julia", engine_control = list(target = ...))`.
  They are REML-only, Julia-owned, gated on the twin engine’s status,
  and are not comparator- or known-truth-validated.
- **Multivariate is not a t ≥ 2 recovery claim.** The multivariate
  target pins R/Julia payload and extractor parity and has an *optional*
  sommer comparator, but that comparator constrains residual covariance
  to diagonal — so it does not validate the off-diagonal residual
  covariance — and there is no known-truth multi-trait recovery claim.
- **No production / ASReml-parity / large-scale claim.** The v0.1
  default fit is validated only on small, clean pedigrees (the gryphon
  anchor and the simulated DGP study). Large, real, or heavily inbred
  pedigrees, and the engine half of boundary stability, are not yet
  validated — they remain post-v0.1 hardening. There is no ASReml /
  BLUPF90 / DMU / WOMBAT parity claim.

For the current, authoritative status of every capability — including
which rows are `planned`, `partial`, and `covered`, and the exact claim
boundary attached to each — call
[`validation_status()`](https://itchyshin.github.io/hsquared/reference/validation_status.md).
It is a status table only: it does not run checks, fit models, or
promote anything.

For v0.1 the `covered` rows are exactly the univariate Gaussian
animal-model fit and the two recovery anchors behind it (the known-truth
DGP study and the published gryphon estimate). Everything else you see
is `partial` or `planned`.

``` r

status <- validation_status()
status[status$status == "covered", c("capability", "phase", "status")]
#> <hs_validation_status>
#>   validation: status table only; checks are run by tests and CI
#>   public claims: only `covered` rows may be advertised as working
#>                                                    capability   phase  status
#>  univariate Gaussian animal-model fit (default path, AI-REML) Phase 1 covered
#>       external published-REML recovery (gryphon, R reference) Phase 1 covered
#>     known-truth DGP variance-component recovery (R reference) Phase 1 covered
```

To actually fit the validated model end-to-end — including installing
and registering the `HSquared.jl` engine — see the *Getting started*
article and its engine-setup section. This article is about the
evidence, not the workflow.

# Multivariate Comparator Plan

Status: design and scout evidence, one Mrode-style published target, one
full-unstructured `sommer` REML comparator, and one `MCMCglmm` Bayesian
agreement probe. This note does not promote the multivariate row beyond
`partial`.

## Purpose

The opt-in multivariate R path can now parse `cbind()` responses, build a
two-trait payload, and normalize a serialized Julia REML target into R
extractors. The next evidence step is not broader wording. It is a comparator
ladder that names exactly which external tools can check the same estimand, and
which tools are only manual or approximate gates.

## Current Evidence

- The R lane consumes the shared Phase 4 fixture in
  `tests/testthat/fixtures/phase4_multitrait_parity/`.
- The fixture checks payload ordering and R extractor shape against serialized
  Julia `fit_multivariate_reml` targets.
- The R lane records a 100-replicate cold-start known-truth recovery study and a
  full-unstructured `sommer` comparator run in `.Rbuildignore`d scripts.
- The R lane records a `MCMCglmm` Bayesian agreement probe in an
  `.Rbuildignore`d script; it supports qualitative agreement but is not a
  same-estimand REML comparator.
- A pure-R CI anchor now reproduces Mrode Example 5.1 multiple-trait
  supplied-G0/R0 BLUP/MME fixed effects and animal BLUPs.
- These are not ASReml/BLUPF90 parity and do not promote multivariate REML to
  covered.

## Sources Checked

- Local `sommer` 4.4.5 package documentation:
  `sommer.qg.Rmd` documents multivariate animal-model syntax with
  `value ~ trait`, `vsm(usm(trait), ism(id), Gu = A)`, and residual
  `vsm(dsm(trait), ism(units))`.
- The existing hsquared univariate validation fixture already uses optional
  `sommer::mmes()` as a skip-safe comparator pattern.
- Local `MCMCglmm` 2.36 package fit on the shared Phase 4 fixture: multivariate
  Gaussian response with `us(trait):animal` and `us(trait):units`, pedigree
  supplied to `inverseA()` via `MCMCglmm()`, and weak inverse-Wishart priors.
- Local `drmTMB` comparator design notes emphasize same-scale matching,
  optional comparator dependencies, and explicit "closest but not identical"
  rows when no faithful comparator exists.
- Local `gllvmTMB` and `GLLVM.jl` notes reinforce the same rule for
  multivariate response ordering and public wording: comparator evidence should
  name the shape and missingness contract it actually checked.
- External comparator references:
  - `sommer`: https://cran.r-project.org/package=sommer
  - `sommer::mmes`: https://www.rdocumentation.org/packages/sommer/versions/4.4.4/topics/mmes
  - LUKE Multiple trait animal model:
    https://www.luke.fi/en/documents/multiple-trait-animal-modelpdf
  - Masuda BLUPF90 Mrode Example 5.1:
    https://masuday.github.io/blupf90_tutorial/mrode_c05ex051_mt_equal_design.html
  - ASReml multivariate cookbook:
    https://asreml.kb.vsni.co.uk/knowledge-base/cookbook-multivariate-analysis/
  - BLUPF90 / AIREMLF90 tutorial:
    https://masuday.github.io/blupf90_tutorial/index.html

## Comparator Ladder

| Tier | Comparator | Role | CI status | Claim boundary |
| --- | --- | --- | --- | --- |
| 0 | Shared Julia fixture | Current R/Julia parity check for payload and extractor shape | ordinary CI | Internal parity only |
| 1 | Mrode Example 5.1 published target | CI anchor for supplied-G0/R0 multiple-trait BLUP/MME fixed effects and animal BLUPs | ordinary CI | Published target only; not VC estimation |
| 2 | `sommer` diagonal residual multivariate model | Optional in-suite external check for genetic covariance and residual variances | skip-safe if installed | Partial comparator; not full residual covariance |
| 3 | `sommer::mmer` full-unstructured residual model | Reproducible external REML comparator for the shared fixture | manual/data-raw | Recorded in `data-raw/multivariate-comparator-study.R`; one independent REML comparator leg |
| 4 | `sommer` known-truth recovery | Deterministic multi-seed recovery for G0/R0-compatible subset | optional or non-CRAN | Recovery evidence only after thresholds are signed off |
| 5 | ASReml-R | Licensed external comparator for full unstructured multivariate animal models | manual | Record version, script, output, and license boundary |
| 6 | BLUPF90/AIREMLF90 | External REML animal-model comparator using parameter files | manual | Record executable, parameter file, output, and scale mapping |
| 7 | DMU/WOMBAT | Later animal-breeding software comparators | manual | Useful only when scripts are reproducible locally |
| 8 | `MCMCglmm` | Bayesian agreement probe | optional/manual | Recorded in `data-raw/multivariate-mcmcglmm-agreement-study.R`; not a REML equality comparator |

## Same-Estimand Contract

A comparator may be used as evidence only when the matched target is explicit:

- Gaussian REML, not ML or Bayesian posterior summaries.
- Same fixed model: trait-specific intercepts and trait-specific `x` slopes.
- Same animal effect: additive genetic covariance `A * G0`.
- Same pedigree order and ID coding.
- Same response ordering and missing-cell policy.
- Same residual covariance target, or a clearly named restricted target.
- Same reported scale before numeric comparisons are made.

For the current fixture, the full hsquared/Julia target estimates an
unstructured residual matrix `R0`. A diagonal-residual comparator can still
check `G0` and `diag(R0)`, but it cannot validate the off-diagonal residual
covariance.

## Local Pilot Results

On 2026-06-21 the local machine has `sommer` 4.4.3 and `MCMCglmm` 2.36
installed; `nadiv`, `asreml`, `pedigreemm`, `enhancer`, `AGHmatrix`, and `JWAS`
are not installed. ASReml-R is not installed, and BLUPF90, AIREMLF90, DMU, and
WOMBAT executables are not on `PATH`.

The current Phase 4 fixture can be reshaped into sommer's documented long
format and fit with:

```r
sommer::mmes(
  value ~ trait + trait:x - 1,
  random = ~ sommer::vsm(sommer::usm(trait), sommer::ism(animal), Gu = A),
  rcov = ~ sommer::vsm(sommer::dsm(trait), sommer::ism(units)),
  data = long,
  verbose = FALSE,
  dateWarning = FALSE
)
```

This pilot reproduced the Julia target genetic covariance and residual
variances within a tight deterministic smoke-test tolerance:

```text
G0 =
  trait1  0.6036285   trait1:trait2  0.1119503
  trait2  0.2703534

diag(R0) =
  trait1  0.2631124
  trait2  0.0906582
```

Two important limits were observed:

- Replacing `dsm(trait)` with `usm(trait)` for a full residual covariance failed
  locally with `Mat::operator(): index out of bounds`.
- Sommer's wide `cbind(trait1, trait2)` route did not accept the same random and
  residual structure under the installed API.

This diagonal-residual route remains useful as an ordinary optional test because
it is quick and stable. A later classic `sommer::mmer` wide-response route did
fit the full unstructured residual model and is recorded in
`data-raw/multivariate-comparator-study.R`: `G0`/`R0`/beta/h2/EBV agree with the
serialized Julia target to <= 8e-5 while recovering the off-diagonal residual
covariance.

## MCMCglmm Bayesian Agreement Probe

`data-raw/multivariate-mcmcglmm-agreement-study.R` runs the same shared Phase 4
fixture through `MCMCglmm` with:

```r
MCMCglmm::MCMCglmm(
  cbind(trait1, trait2) ~ trait - 1 + trait:x,
  random = ~ us(trait):animal,
  rcov = ~ us(trait):units,
  family = c("gaussian", "gaussian"),
  pedigree = ped_mcmc,
  data = phe,
  prior = list(
    G = list(G1 = list(V = diag(2) * 0.02, nu = 3)),
    R = list(V = diag(2) * 0.02, nu = 3)
  ),
  nitt = 50000,
  burnin = 10000,
  thin = 40,
  pr = TRUE
)
```

Recorded 2026-06-21 result:

- 1000 posterior samples; minimum VCV effective sample size 777.4 and minimum
  solution effective sample size 867.4.
- The serialized Julia target is inside the 95% HPD intervals for all 8
  covariance elements, all 4 fixed effects, and both per-trait h2 values.
- Posterior-mean h2 is 0.6771 / 0.7236 versus target 0.6964 / 0.7489.
- Posterior-mean EBV correlations with the target are > 0.9997 for both traits.
- Posterior-mean covariance differences (`max |dG0| = 0.0385`,
  `max |dR0| = 0.00647`) are reported as MCMC posterior-summary differences,
  not REML equality tolerances.

Claim boundary: this leg is useful independent Bayesian agreement evidence, but
it is not a same-estimand REML optimizer comparison and does not clear the
second-comparator blocker.

## Published Mrode Target

Mrode Example 5.1 is now pinned in ordinary CI by
`tests/testthat/test-mrode-multivariate-anchor.R`. The fixture uses the
published two-trait pre-weaning/post-weaning gain data, pedigree, and supplied
covariance matrices `G0 = [[20, 18], [18, 40]]` and
`R0 = [[40, 11], [11, 30]]`, then solves the multivariate Henderson MME in pure
R and checks the published fixed-effect and animal-BLUP digits reproduced by
LUKE and Masuda.

Claim boundary: this closes the published/Mrode-style multivariate target gap
for supplied-covariance BLUP/MME checks. It does not estimate G0/R0, does not
validate REML optimization, and is not a second independent same-estimand
comparator for the dense REML estimator.

## Proposed Optional Test Slice

Add `tests/testthat/test-multivariate-comparator.R` only after the maintainer
accepts this narrower target:

- `skip_on_cran()`.
- `skip_if_not_installed("sommer")`.
- `skip_if_not_installed("nadiv")`.
- Read the shared fixture.
- Convert pedigree `0` parents to `NA`.
- Build `A` with `nadiv::makeA()`.
- Reshape the fixture to long format and sort by `trait` before fitting.
- Fit the diagonal-residual sommer model above.
- Compare:
  - genetic covariance matrix `G0`;
  - residual variances `diag(R0)`;
  - per-trait heritability using the diagonal residual target;
  - convergence flag and variance-component finiteness.

Do not compare the residual off-diagonal until a same-estimand comparator is
available. Do not compare log-likelihoods until constants and residual
structure are aligned.

## Manual Comparator Scripts

ASReml-R and BLUPF90/AIREMLF90 live as manual scripts/templates, not ordinary CI
gates:

- `inst/comparator-scripts/asreml/multivariate-animal.R`
- `inst/comparator-scripts/blupf90/prepare-multivariate-animal.R`
- `inst/comparator-scripts/blupf90/multivariate-animal.renf90`
- `inst/comparator-scripts/blupf90/multivariate-animal.par`
- recorded outputs under `docs/dev-log/comparator-runs/` only when actually
  run by a licensed/installed environment.

Each manual run must record:

- package or executable version;
- platform;
- input fixture checksum;
- model formula or parameter file;
- convergence status;
- covariance estimates on the matched scale;
- any dropped records or missing-cell policy;
- whether the result supports a public wording change.

## Promotion Rule

Rose/Fisher/Curie promotion remains blocked until the twin-owned covered gate
accepts the recovery scope and another independent same-estimand comparator is
recorded. The useful remaining routes are:

1. A same-estimand external comparator checks full `G0` and full `R0`.
2. The current cold-start recovery study is accepted as the declared recovery
   gate, or a broader recovery gate is run and signed off.
3. A manual ASReml/BLUPF90 comparison is recorded with reproducible inputs and
   outputs.

Until then, public docs may say the multivariate path is opt-in and partial,
with internal R/Julia parity, recovery evidence, `sommer` REML comparator
evidence, the `MCMCglmm` Bayesian agreement probe, and a still-open
same-estimand comparator ladder.

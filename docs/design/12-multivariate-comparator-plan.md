# Multivariate Comparator Plan

Status: design and scout evidence only. This note does not promote the
multivariate row beyond `partial`.

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
- This is internal parity only. It is not an external comparator, not a
  known-truth recovery study, and not ASReml/BLUPF90 parity.

## Sources Checked

- Local `sommer` 4.4.5 package documentation:
  `sommer.qg.Rmd` documents multivariate animal-model syntax with
  `value ~ trait`, `vsm(usm(trait), ism(id), Gu = A)`, and residual
  `vsm(dsm(trait), ism(units))`.
- The existing hsquared univariate validation fixture already uses optional
  `sommer::mmes()` as a skip-safe comparator pattern.
- Local `drmTMB` comparator design notes emphasize same-scale matching,
  optional comparator dependencies, and explicit "closest but not identical"
  rows when no faithful comparator exists.
- Local `gllvmTMB` and `GLLVM.jl` notes reinforce the same rule for
  multivariate response ordering and public wording: comparator evidence should
  name the shape and missingness contract it actually checked.
- External comparator references:
  - `sommer`: https://cran.r-project.org/package=sommer
  - `sommer::mmes`: https://www.rdocumentation.org/packages/sommer/versions/4.4.4/topics/mmes
  - ASReml multivariate cookbook:
    https://asreml.kb.vsni.co.uk/knowledge-base/cookbook-multivariate-analysis/
  - BLUPF90 / AIREMLF90 tutorial:
    https://masuday.github.io/blupf90_tutorial/index.html

## Comparator Ladder

| Tier | Comparator | Role | CI status | Claim boundary |
| --- | --- | --- | --- | --- |
| 0 | Shared Julia fixture | Current R/Julia parity check for payload and extractor shape | ordinary CI | Internal parity only |
| 1 | `sommer` diagonal residual multivariate model | Optional external check for genetic covariance and residual variances | skip-safe if installed | Partial comparator; not full residual covariance |
| 2 | `sommer` known-truth recovery | Deterministic multi-seed recovery for G0/R0-compatible subset | optional or non-CRAN | Recovery evidence only after thresholds are signed off |
| 3 | ASReml-R | Licensed external comparator for full unstructured multivariate animal models | manual | Record version, script, output, and license boundary |
| 4 | BLUPF90/AIREMLF90 | External REML animal-model comparator using parameter files | manual | Record executable, parameter file, output, and scale mapping |
| 5 | DMU/WOMBAT | Later animal-breeding software comparators | manual | Useful only when scripts are reproducible locally |
| 6 | `MCMCglmm` | Bayesian qualitative cross-check | optional/manual | Not a REML equality comparator |

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

The local machine has `sommer` 4.4.5, `nadiv` 2.18.0, `MCMCglmm` 2.36, and
`pedigreemm` 0.3.5 installed. ASReml-R is not installed, and BLUPF90,
AIREMLF90, DMU, and WOMBAT executables are not on `PATH`.

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
variances at the printed precision:

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

Therefore the first `sommer` comparator should be a diagonal-residual partial
comparator unless a stable full-residual sommer specification is found.

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

ASReml-R and BLUPF90/AIREMLF90 should live as scripts or design artifacts, not
ordinary CI gates:

- `inst/comparator-scripts/asreml/multivariate-animal.R`
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

Rose/Fisher/Curie promotion remains blocked until at least one of these is true:

1. A same-estimand external comparator checks full `G0` and full `R0`.
2. A signed-off known-truth recovery study checks `t >= 2` covariance recovery.
3. A manual ASReml/BLUPF90 comparison is recorded with reproducible inputs and
   outputs.

Until then, public docs may say the multivariate path is opt-in and partial,
with internal R/Julia parity plus a planned comparator ladder.

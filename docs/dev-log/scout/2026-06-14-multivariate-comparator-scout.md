# Multivariate Comparator Scout

Date: 2026-06-14

## Question

What is the next honest comparator path for the opt-in multivariate animal-model
surface, given the current shared Phase 4 two-trait fixture?

## Active Lenses

Active lenses: Ada, Shannon, Jason, Curie, Fisher, Rose, Grace.

Spawned agents: none.

Current lane: coordinator/docs.

## Local Sister-Package Lessons

- `drmTMB` comparator notes require a matched scale and explicit caveats when a
  comparator is only close, not identical. That pattern fits multivariate
  animal-model validation well because residual covariance, likelihood
  constants, and pedigree relationship scaling can differ by package.
- `gllvmTMB` and `GLLVM.jl` reinforced the need to name response ordering and
  missing-cell policy before comparing multivariate fits.
- The existing hsquared univariate validation fixture already uses optional
  `sommer` as a skip-safe comparator, so multivariate comparator work should
  reuse that optional-dependency style.

## Package And Tool Availability

Local R packages:

- `sommer` 4.4.5: installed.
- `nadiv` 2.18.0: installed.
- `MCMCglmm` 2.36: installed.
- `pedigreemm` 0.3.5: installed.
- `asreml`: not installed.
- `AGHmatrix`: not installed.

Local command-line comparators:

- `asreml`: not on `PATH`.
- `airemlf90`: not on `PATH`.
- `blupf90`: not on `PATH`.
- `renumf90`: not on `PATH`.
- `dmuai`: not on `PATH`.
- `wombat`: not on `PATH`.

## Sommer Pilot

The shared Phase 4 fixture was reshaped to long format and sorted by trait, as
the local `sommer.qg.Rmd` multivariate example does. With `nadiv::makeA()` for
the pedigree relationship matrix, this model fit:

```r
sommer::mmes(
  value ~ trait + trait:x - 1,
  random = ~ sommer::vsm(sommer::usm(trait), sommer::ism(animal), Gu = A),
  rcov = ~ sommer::vsm(sommer::dsm(trait), sommer::ism(units)),
  data = long,
  verbose = FALSE,
  dateWarning = FALSE,
  nIters = 80
)
```

Pilot outcome:

- Genetic covariance matched the serialized Julia target within a tight
  deterministic smoke-test tolerance.
- Residual variances matched the serialized Julia target within a tight
  deterministic smoke-test tolerance.
- The model is not a full residual-covariance comparator, because
  `dsm(trait)` constrains the residual covariance to zero.

Failed pilot paths:

- `rcov = ~ vsm(usm(trait), ism(units))` failed locally with
  `Mat::operator(): index out of bounds`.
- Sommer's wide `cbind(trait1, trait2)` path did not accept the same random and
  residual structure under the installed API.

## Decision

Use `sommer` first as a partial, optional, diagonal-residual comparator. Do not
claim same-estimand full multivariate validation from it. Keep ASReml-R and
BLUPF90/AIREMLF90 as manual gates unless the required licensed package or
executables become available locally.

## Next Slice

If Ada accepts the narrower target, add a skip-safe optional sommer comparator
test for `G0`, `diag(R0)`, and diagonal-target heritability on the shared Phase 4
fixture.

# Fitting quantitative-genetic models

This article shows the models `hsquared` can fit. Fitting is computed in
the sibling `HSquared.jl` engine, so every example needs a local Julia,
the `JuliaCall` package, and an `HSquared.jl` checkout. The code chunks
are not run when this page is built (the build host has no Julia).

All fits are by REML. ML is not implemented; `REML = FALSE` is rejected
on the fit path.

## The default: a univariate Gaussian animal model

This is the v0.1 model, fitted by the default
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
call. It estimates the additive-genetic and residual variances,
heritability, and breeding values.

``` r

library(hsquared)

fit <- hsquared(
  weight ~ sex + age + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian(),
  REML = TRUE
)

variance_components(fit)
heritability(fit)
breeding_values(fit)   # EBVs (aliases: EBV(), BLUP())
summary(fit)
```

The remaining models below are **experimental and opt-in**: they are
reached through `engine = "julia"` with an explicit `target`, and their
[`validation_status()`](https://itchyshin.github.io/hsquared/reference/validation_status.md)
rows are `partial` (they mirror the corresponding `HSquared.jl` gates,
which are still being validated). They are REML-only and are not yet
production- or comparator-validated.

## Repeatability (permanent environment)

A repeated-records model with an additive-genetic effect and a
permanent-environment effect that shares the animal grouping. The
additive (`σ²a`) and permanent-environment (`σ²pe`) variances are only
identifiable with repeated records per individual.

``` r

fit_rep <- hsquared(
  y ~ animal(1 | id, pedigree = ped) + permanent(1 | id),
  data = repeated_dat,
  control = hs_control(
    engine = "julia",
    engine_control = list(target = "repeatability")
  )
)

variance_components(fit_rep)    # animal, permanent, residual
repeatability(fit_rep)          # R = (Va + Vpe) / Vp
heritability(fit_rep)           # h2 = Va / Vp
permanent_effects(fit_rep)
```

## Common environment

A two-effect model: an additive-genetic effect plus an independent IID
environmental effect (for example a litter or cage), grouped by a
separate column.

``` r

fit_ce <- hsquared(
  y ~ animal(1 | id, pedigree = ped) + common_env(1 | litter),
  data = dat,
  control = hs_control(
    engine = "julia",
    engine_control = list(target = "two_effect")
  )
)

variance_components(fit_ce)     # animal, common_env, residual
common_env_effects(fit_ce)
```

## Maternal genetic effects

The other two-effect model: a direct additive-genetic effect plus a
maternal genetic effect expressed through the dam. Both carry the
pedigree relationship (the maternal effect uses `A₂ = pedigree A`), and
the dams must be animals in the
[`animal()`](https://itchyshin.github.io/hsquared/reference/animal.md)
pedigree. This is the independent (uncorrelated) direct–maternal model;
the correlated 2×2 G version is planned.

``` r

fit_mat <- hsquared(
  y ~ animal(1 | id, pedigree = ped) + maternal_genetic(1 | dam),
  data = dat,
  control = hs_control(
    engine = "julia",
    engine_control = list(target = "two_effect")
  )
)

variance_components(fit_mat)    # animal, maternal_genetic, residual
maternal_effects(fit_mat)
```

## Genomic GREML

A single genomic effect whose relationship is a user-supplied genomic
relationship inverse `Ginv` (with id dimnames) instead of a pedigree.
This estimates the genomic and residual variances, genomic heritability,
and genomic breeding values (GEBVs). You can either supply a precomputed
`Ginv`, or pass a raw marker matrix `M` (rows = individuals) as
`genomic(1 | id, markers = M)` and let the engine build the genomic
relationship and its inverse. Single-step (`Hinv`) and
external-comparator validation are planned.

``` r

fit_g <- hsquared(
  y ~ genomic(1 | id, Ginv = Ginv),
  data = dat,
  control = hs_control(
    engine = "julia",
    engine_control = list(target = "genomic")
  )
)

variance_components(fit_g)      # genomic, residual
heritability(fit_g)             # genomic h2
breeding_values(fit_g)         # GEBVs
```

## SNP-BLUP / RR-BLUP marker effects

A supplied-variance marker-effect model on a raw marker matrix
`genomic(1 | id, markers = M)`. You supply the genomic and residual
variances (for example from a prior GREML fit); the engine centres the
markers and returns per-marker effects
([`marker_effects()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md))
together with per-individual genomic breeding values. It does not
estimate the variance components. REML estimation of the marker
variance, weighted/Bayesian priors, and comparator parity are planned.

``` r

fit_snp <- hsquared(
  y ~ genomic(1 | id, markers = M),
  data = dat,
  control = hs_control(
    engine = "julia",
    engine_control = list(
      target = "snp_blup",
      variance_components = c(sigma_g2 = 1, sigma_e2 = 2)
    )
  )
)

marker_effects(fit_snp)         # one effect per marker
breeding_values(fit_snp)        # per-individual GEBVs
```

## What is fitted, and what is planned

[`formula_status()`](https://itchyshin.github.io/hsquared/reference/formula_status.md)
and
[`validation_status()`](https://itchyshin.github.io/hsquared/reference/validation_status.md)
report, from R, exactly which terms fit and how each capability is
validated.

``` r

library(hsquared)
formula_status()
```

    ## <hs_formula_status>
    ##   parsed today: animal(1 | id, pedigree = ped); animal(1 | id) with an hs_data pedigree
    ##   fitting: animal(1 | id) fits by default (v0.1 Gaussian REML); permanent/common_env/maternal_genetic/genomic fit opt-in; others parse-only
    ##                                                     term     phase
    ##                           animal(1 | id, pedigree = ped)   Phase 1
    ##  animal(1 | id) with data = hs_data(..., pedigree = ped)   Phase 1
    ##                                        permanent(1 | id)   Phase 2
    ##                                    common_env(1 | group)   Phase 2
    ##                maternal_genetic(1 | dam, pedigree = ped)   Phase 2
    ##                                    maternal_env(1 | dam)   Phase 2
    ##               paternal_genetic(1 | sire, pedigree = ped)   Phase 2
    ##                                   paternal_env(1 | sire)   Phase 2
    ##                           cytoplasmic(1 | maternal_line)  Phase 3+
    ##  imprinting(1 | id, pedigree = ped, parent = "maternal")  Phase 3+
    ##                        dominance(1 | id, pedigree = ped)  Phase 3+
    ##                        epistasis(1 | id, pedigree = ped)  Phase 3+
    ##                                    relmat(1 | id, K = K)  Phase 3+
    ##                                 precision(1 | id, Q = Q)  Phase 3+
    ##                             genomic(1 | id, Ginv = Ginv)   Phase 5
    ##                         single_step(1 | id, Hinv = Hinv)   Phase 5
    ##                             markers(M, model = "random")   Phase 5
    ##                         marker_scan(M, map = marker_map)   Phase 5
    ##               qtl_scan(position, genotype_probs = probs)   Phase 5
    ##           animal(trait | id, pedigree = ped, cov = us()) Phase 3-4
    ##      animal(trait | id, pedigree = ped, cov = fa(K = 2)) Phase 3-4
    ##  syntax_status                     fitting_status
    ##         parsed              fitted (v0.1 default)
    ##         parsed              fitted (v0.1 default)
    ##         parsed      fitted (opt-in repeatability)
    ##         parsed fitted (opt-in common-environment)
    ##         parsed           fitted (opt-in maternal)
    ##       reserved                      not available
    ##       reserved                      not available
    ##       reserved                      not available
    ##       reserved                      not available
    ##       reserved                      not available
    ##       reserved                      not available
    ##       reserved                      not available
    ##       reserved                      not available
    ##       reserved                      not available
    ##         parsed            fitted (opt-in genomic)
    ##         parsed        fitted (opt-in single-step)
    ##       reserved                      not available
    ##       reserved                      not available
    ##       reserved                      not available
    ##        planned                      not available
    ##        planned                      not available

``` r

validation_status()
```

    ## <hs_validation_status>
    ##   validation: status table only; checks are run by tests and CI
    ##   public claims: only `covered` rows may be advertised as working
    ##                                                                   capability
    ##                                              tiny deterministic Ainv fixture
    ##                                              Mrode9 pedigree Ainv comparator
    ##                                      supplied-variance Henderson MME fixture
    ##                                              sparse REML likelihood identity
    ##                                        Mrode-style supplied-variance outputs
    ##                                  experimental sparse REML estimator (opt-in)
    ##                                experimental repeatability estimator (opt-in)
    ##             experimental two-effect estimator (opt-in: common-env, maternal)
    ##  experimental supplied-relationship estimator (opt-in: genomic, single-step)
    ##        experimental SNP-BLUP marker-effect solve (opt-in, supplied-variance)
    ##                 univariate Gaussian animal-model fit (default path, AI-REML)
    ##                      external published-REML recovery (gryphon, R reference)
    ##                    known-truth DGP variance-component recovery (R reference)
    ##                                            Mrode fitted animal-model outputs
    ##                                                     ASReml comparison policy
    ##                                         BLUPF90/DMU/WOMBAT comparison policy
    ##                                                        XSim simulation truth
    ##                                              genomic and QTL/eQTL validation
    ##                                          GLLVM-style multivariate validation
    ##                                                   CPU/GPU backend comparison
    ##     phase  status
    ##   Phase 1 partial
    ##   Phase 1 partial
    ##   Phase 1 partial
    ##   Phase 1 partial
    ##   Phase 1 partial
    ##   Phase 1 partial
    ##   Phase 2 partial
    ##   Phase 2 partial
    ##   Phase 5 partial
    ##   Phase 5 partial
    ##   Phase 1 covered
    ##   Phase 1 covered
    ##   Phase 1 covered
    ##   Phase 1 planned
    ##   Phase 1 planned
    ##   Phase 1 planned
    ##  Phase 5+ planned
    ##  Phase 5+ planned
    ##   Phase 6 planned
    ##  Phase 7+ planned

Only rows marked `covered` in
[`validation_status()`](https://itchyshin.github.io/hsquared/reference/validation_status.md)
may be relied on as working; the opt-in models above are deliberately
`partial` until their `HSquared.jl` gates and external comparators are
signed off. Multivariate, factor-analytic, non-Gaussian/GLLVM,
unusual-inheritance, and GPU models remain on the roadmap.

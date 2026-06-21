# Inspect formula grammar status

`formula_status()` reports which pieces of the planned
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
formula language are parsed today, reserved as syntax markers, or still
roadmap-only. It is a status table, not a model-fitting helper.

## Usage

``` r
formula_status()
```

## Value

A data frame of formula grammar records with class
`"hs_formula_status"`.

## Examples

``` r
formula_status()
#> <hs_formula_status>
#>   parsed today: animal(1 | id, pedigree = ped); animal(1 | id) with an hs_data pedigree
#>   fitting: animal(1 | id) fits by default (v0.1 Gaussian REML); permanent/common_env/maternal_genetic/genomic/multivariate fit opt-in
#>   planned grammar: rows marked planned/reserved error before fitting
#>                                                               term     phase
#>                                     animal(1 | id, pedigree = ped)   Phase 1
#>            animal(1 | id) with data = hs_data(..., pedigree = ped)   Phase 1
#>                                                  permanent(1 | id)   Phase 2
#>                                              common_env(1 | group)   Phase 2
#>                                          maternal_genetic(1 | dam)   Phase 2
#>              animal(rr(covariate, order = 2) | id, pedigree = ped)   Phase 2
#>                                              maternal_env(1 | dam)   Phase 2
#>                         paternal_genetic(1 | sire, pedigree = ped)   Phase 2
#>                                             paternal_env(1 | sire)   Phase 2
#>                                           group(1 | genetic_group)   Phase 2
#>                                      unknown_parent_group(1 | upg)   Phase 2
#>  metafounder(1 | id, pedigree = ped, group = group, Gamma = Gamma)   Phase 2
#>                                                 inbreeding(1 | id)   Phase 2
#>                                     cytoplasmic(1 | maternal_line)  Phase 3+
#>            imprinting(1 | id, pedigree = ped, parent = "maternal")  Phase 3+
#>                                  dominance(1 | id, pedigree = ped)  Phase 3+
#>                                  epistasis(1 | id, pedigree = ped)  Phase 3+
#>                                              relmat(1 | id, K = K)  Phase 3+
#>                                           precision(1 | id, Q = Q)  Phase 3+
#>                                       genomic(1 | id, Ginv = Ginv)   Phase 5
#>                                       genomic(1 | id, markers = M)   Phase 5
#>                                   single_step(1 | id, Hinv = Hinv)   Phase 5
#>                   single_step(1 | id, pedigree = ped, markers = M)   Phase 5
#>                                       markers(M, model = "random")   Phase 5
#>                                   marker_scan(M, map = marker_map)   Phase 5
#>                         qtl_scan(position, genotype_probs = probs)   Phase 5
#>             cbind(trait1, trait2) ~ animal(1 | id, pedigree = ped) Phase 3-4
#>                     animal(trait | id, pedigree = ped, cov = us()) Phase 3-4
#>                   animal(trait | id, pedigree = ped, cov = diag()) Phase 3-4
#>           animal(trait | id, pedigree = ped, cov = lowrank(K = 2)) Phase 3-4
#>                animal(trait | id, pedigree = ped, cov = fa(K = 2)) Phase 3-4
#>  syntax_status                           fitting_status
#>         parsed                    fitted (v0.1 default)
#>         parsed                    fitted (v0.1 default)
#>         parsed            fitted (opt-in repeatability)
#>         parsed       fitted (opt-in common-environment)
#>         parsed                 fitted (opt-in maternal)
#>         parsed        fitted (opt-in random-regression)
#>       reserved                            not available
#>       reserved                            not available
#>       reserved                            not available
#>       reserved                            not available
#>       reserved                            not available
#>       reserved                            not available
#>       reserved                            not available
#>       reserved                            not available
#>       reserved                            not available
#>       reserved                            not available
#>       reserved                            not available
#>       reserved                            not available
#>       reserved                            not available
#>         parsed                  fitted (opt-in genomic)
#>         parsed       fitted (opt-in genomic / SNP-BLUP)
#>         parsed              fitted (opt-in single-step)
#>         parsed fitted (opt-in single-step construction)
#>       reserved                            not available
#>       reserved                            not available
#>       reserved                            not available
#>         parsed             fitted (opt-in multivariate)
#>        planned                            not available
#>        planned                            not available
#>        planned                            not available
#>        planned                            not available
```

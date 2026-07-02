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
#>                                                                            term
#>                                                  animal(1 | id, pedigree = ped)
#>                         animal(1 | id) with data = hs_data(..., pedigree = ped)
#>                                                               permanent(1 | id)
#>                                                           common_env(1 | group)
#>                                                       maternal_genetic(1 | dam)
#>                                                                     (1 | group)
#>                           animal(rr(covariate, order = 2) | id, pedigree = ped)
#>                                                           maternal_env(1 | dam)
#>                                      paternal_genetic(1 | sire, pedigree = ped)
#>                                                          paternal_env(1 | sire)
#>                                                        group(1 | genetic_group)
#>                                                   unknown_parent_group(1 | upg)
#>               metafounder(1 | id, pedigree = ped, group = group, Gamma = Gamma)
#>                                                              inbreeding(1 | id)
#>                                                  cytoplasmic(1 | maternal_line)
#>                         imprinting(1 | id, pedigree = ped, parent = "maternal")
#>                                               dominance(1 | id, pedigree = ped)
#>                                               epistasis(1 | id, pedigree = ped)
#>                                                           relmat(1 | id, K = K)
#>                                                        precision(1 | id, Q = Q)
#>                                                    genomic(1 | id, Ginv = Ginv)
#>                                                    genomic(1 | id, markers = M)
#>                                                single_step(1 | id, Hinv = Hinv)
#>                                single_step(1 | id, pedigree = ped, markers = M)
#>     single_step(1 | id) with data = hs_data(..., pedigree = ped, genotypes = M)
#>  single_step(1 | id, pedigree = ped, markers = M, group = group, Gamma = Gamma)
#>                                                    markers(M, model = "random")
#>                                                marker_scan(M, map = marker_map)
#>                                      qtl_scan(position, genotype_probs = probs)
#>                          cbind(trait1, trait2) ~ animal(1 | id, pedigree = ped)
#>                                  animal(trait | id, pedigree = ped, cov = us())
#>                                animal(trait | id, pedigree = ped, cov = diag())
#>                        animal(trait | id, pedigree = ped, cov = lowrank(K = 2))
#>                             animal(trait | id, pedigree = ped, cov = fa(K = 2))
#>                                    missing = miss_control(response = "include")
#>                          mi(x) with missing = miss_control(predictor = "model")
#>      phase syntax_status                                  fitting_status
#>    Phase 1        parsed                           fitted (v0.1 default)
#>    Phase 1        parsed                           fitted (v0.1 default)
#>    Phase 2        parsed                   fitted (opt-in repeatability)
#>    Phase 2        parsed              fitted (opt-in common-environment)
#>    Phase 2        parsed                        fitted (opt-in maternal)
#>    Phase 2        parsed                    fitted (opt-in multi-effect)
#>    Phase 2        parsed               fitted (opt-in random-regression)
#>    Phase 2      reserved                                   not available
#>    Phase 2      reserved                                   not available
#>    Phase 2      reserved                                   not available
#>    Phase 2      reserved                                   not available
#>    Phase 2      reserved                                   not available
#>    Phase 2        parsed      fitted (opt-in supplied-Gamma metafounder)
#>    Phase 2      reserved                                   not available
#>   Phase 3+      reserved                                   not available
#>   Phase 3+      reserved                                   not available
#>   Phase 3+      reserved                                   not available
#>   Phase 3+      reserved                                   not available
#>   Phase 3+      reserved                                   not available
#>   Phase 3+      reserved                                   not available
#>    Phase 5        parsed                         fitted (opt-in genomic)
#>    Phase 5        parsed              fitted (opt-in genomic / SNP-BLUP)
#>    Phase 5        parsed                     fitted (opt-in single-step)
#>    Phase 5        parsed        fitted (opt-in single-step construction)
#>    Phase 5        parsed fitted (opt-in single-step bundle construction)
#>    Phase 5        parsed          fitted (opt-in supplied-Gamma H^Gamma)
#>    Phase 5      reserved                                   not available
#>    Phase 5      reserved                                   not available
#>    Phase 5      reserved                                   not available
#>  Phase 3-4        parsed                    fitted (opt-in multivariate)
#>  Phase 3-4       planned                                   not available
#>  Phase 3-4       planned                                   not available
#>  Phase 3-4       planned                                   not available
#>  Phase 3-4       planned                                   not available
#>    Phase 8       planned                                   not available
#>    Phase 8       planned                                   not available
```

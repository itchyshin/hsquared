# Inspect validation evidence status

`validation_status()` reports the current validation atoms and planned
comparator lanes for `hsquared`. It is a status table only: it does not
run validation checks, fit models, or promote any capability to working
status.

## Usage

``` r
validation_status()
```

## Value

A data frame of validation status records with class
`"hs_validation_status"`.

## Examples

``` r
validation_status()
#> <hs_validation_status>
#>   validation: status table only; checks are run by tests and CI
#>   public claims: only `covered` rows may be advertised as working
#>                                                                                                                                    capability
#>                                                                                                               tiny deterministic Ainv fixture
#>                                                                                                               Mrode9 pedigree Ainv comparator
#>                                                                                                       supplied-variance Henderson MME fixture
#>                                                                                                               sparse REML likelihood identity
#>                                                                                                         Mrode-style supplied-variance outputs
#>                                                                                                   experimental sparse REML estimator (opt-in)
#>                                                                                                 experimental repeatability estimator (opt-in)
#>  two-effect / arbitrary-N independent-effect estimator (opt-in; covered: common-env + (1|g) iid / A2=I; experimental: maternal / A2=pedigree)
#>                                                                   experimental supplied-relationship estimator (opt-in: genomic, single-step)
#>                                                       experimental SNP-BLUP marker-effect model (opt-in; supplied-variance or REML-estimated)
#>                                                                                             experimental multivariate REML estimator (opt-in)
#>                                                                                  univariate Gaussian animal-model fit (default path, AI-REML)
#>                                                                                       external published-REML recovery (gryphon, R reference)
#>                                                                                     known-truth DGP variance-component recovery (R reference)
#>                                                                                                             Mrode fitted animal-model outputs
#>                                                                                                                      ASReml comparison policy
#>                                                                                                          BLUPF90/DMU/WOMBAT comparison policy
#>                                                                                                                         XSim simulation truth
#>                                                                                                               genomic and QTL/eQTL validation
#>                                                                                                           GLLVM-style multivariate validation
#>                                                                                                                    CPU/GPU backend comparison
#>     phase  status
#>   Phase 1 partial
#>   Phase 1 partial
#>   Phase 1 partial
#>   Phase 1 partial
#>   Phase 1 partial
#>   Phase 1 partial
#>   Phase 2 partial
#>   Phase 2 covered
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

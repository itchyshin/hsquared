# hsquared 0.0.0.9000

## New features

* `animal()` is now exported as an inert formula marker, and `hsquared()` now parses the narrow v0.1 formula contract `animal(1 | id, pedigree = ped)` before stopping at the planned Julia bridge boundary (#4, #6).
* Added an internal R-to-Julia bridge payload builder for the v0.1 animal-model contract. It creates `y`, `X`, sparse `Z`, normalized pedigree metadata, and the validated Julia `animal_model_spec()` target, but still does not execute Julia or fit models (#6).
* Added a local-only experimental JuliaCall smoke path for the tiny v0.1 payload when a sibling `HSquared.jl` checkout is available. This validates bridge shape against Julia `pedigree_inverse()` and `fit_animal_model()` but is not yet the public `hsquared()` fitting path (#6).
* Added the first `hsquared_fit` object and extractor contract, including `variance_components()`, `heritability()`, `breeding_values()`, `fixef()`, `ranef()`, `logLik()`, `AIC()`, `predict()`, and `summary()` methods over internal fit objects. These are contract plumbing only until the Julia engine returns real fits (#5).
* Added `hs_data()` as a lightweight R data container for phenotype, pedigree, genotype, marker, expression, annotation, and environment inputs. It records ID maps for future integrated genomic/QTL/eQTL workflows, but does not fit models (#8).
* Added Phase 0 project operating documentation, an honest placeholder `hsquared()` entry point, and `hs_control()` for planned engine controls.

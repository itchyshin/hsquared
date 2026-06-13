# hsquared 0.0.0.9000

## New features

* `animal()` is now exported as an inert formula marker, and `hsquared()` now parses the narrow v0.1 formula contract `animal(1 | id, pedigree = ped)` before stopping at the planned Julia bridge boundary (#4, #6).
* `hs_control()` now has an experimental `engine = "julia"` option that lets local developers run the tiny v0.1 animal-model payload through a sibling `HSquared.jl` checkout via JuliaCall. The default engine remains validation-only, and general fitted animal-model support is still planned (#6).
* `prediction_error_variance()` and `reliability()` are now part of the R fitted-object extractor contract. They work for `hsquared_fit` objects containing those result fields; the current Julia bridge payload does not return them yet (#5, #6).
* The experimental Julia bridge now sends sparse `Matrix::dgCMatrix` random-effect designs through Julia CSC slots instead of densifying `Z` (#6).
* Added an internal tiny animal-model validation fixture that pins R payload ordering, sparse `Z` construction, and live Julia `pedigree_inverse()` agreement for a three-animal Henderson-style pedigree when a sibling `HSquared.jl` checkout is available (#7).
* Added an internal R-to-Julia bridge payload builder for the v0.1 animal-model contract. It creates `y`, `X`, sparse `Z`, normalized pedigree metadata, and the validated Julia `animal_model_spec()` target used by the experimental Julia engine (#6).
* Added a local-only experimental JuliaCall smoke path for the tiny v0.1 payload when a sibling `HSquared.jl` checkout is available. This validates bridge shape against Julia `pedigree_inverse()` and `fit_animal_model()` but is not yet the public `hsquared()` fitting path (#6).
* Added the first `hsquared_fit` object and extractor contract, including `variance_components()`, `heritability()`, `breeding_values()`, `fixef()`, `ranef()`, `logLik()`, `AIC()`, `predict()`, and `summary()` methods over internal fit objects. These are contract plumbing only until the Julia engine returns real fits (#5).
* Added `hs_data()` as a lightweight R data container for phenotype, pedigree, genotype, marker, expression, annotation, and environment inputs. It records ID maps for future integrated genomic/QTL/eQTL workflows, but does not fit models (#8).
* Added Phase 0 project operating documentation, an honest placeholder `hsquared()` entry point, and `hs_control()` for planned engine controls.

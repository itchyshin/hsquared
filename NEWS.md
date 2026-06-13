# hsquared 0.0.0.9000

## New features

* `animal()` is now exported as an inert formula marker, and `hsquared()` now parses the narrow v0.1 formula contract `animal(1 | id, pedigree = ped)` before stopping at the planned Julia bridge boundary (#4, #6).
* `hs_control()` now has an experimental `engine = "julia"` option that lets local developers run the tiny v0.1 animal-model payload through a sibling `HSquared.jl` checkout via JuliaCall. The default engine remains validation-only, and general fitted animal-model support is still planned (#6).
* `prediction_error_variance()` and `reliability()` are now part of the R fitted-object extractor contract. They work for `hsquared_fit` objects containing those result fields (#5, #6).
* The experimental local Julia bridge now enriches tiny `hsquared_fit` results with dense validation-path PEV and reliability fields when the sibling `HSquared.jl` checkout exposes `prediction_error_variance()` and `reliability()` (#5, #6).
* The experimental Julia bridge now sends sparse `Matrix::dgCMatrix` random-effect designs through Julia CSC slots instead of densifying `Z` (#6).
* Added an internal tiny animal-model validation fixture that pins R payload ordering, sparse `Z` construction, and live Julia `pedigree_inverse()` agreement for a three-animal Henderson-style pedigree when a sibling `HSquared.jl` checkout is available (#7).
* Added an optional Mrode9/nadiv pedigree-Ainv comparator fixture. When `nadiv` and a sibling `HSquared.jl` checkout are available, local tests compare Julia `pedigree_inverse()` with `nadiv::makeAinv()` for the Mrode9 pedigree (#7).
* Expanded `hs_control()` to preserve planned backend and accelerator vocabulary for CPU threads, CUDA, AMDGPU, Metal, and oneAPI. These are control-surface placeholders only; GPU execution remains planned (#3).
* Added `backend_info()` so users and developers can inspect planned backend names while seeing that backend execution is not available yet.
* `data_status()` now gives users a direct diagnostic view of `hs_data()` component presence, ID overlap, and marker-map/genotype-marker alignment status. It is a status helper only and does not fit models (#8).
* Added `formula_status()` so users and developers can inspect parsed, reserved, and planned formula grammar without reading the full roadmap.
* Added `model_spec()` so users and developers can preview the parsed v0.1 animal-model contract, fixed-effect design columns, sparse animal-effect design dimensions, normalized pedigree ordering, and Julia targets without fitting a model.
* Added inert planned formula markers for `genomic()`, `single_step()`, `markers()`, `marker_scan()`, and `qtl_scan()`. The parser now rejects these terms with explicit planned-not-implemented errors instead of treating them as fixed effects.
* Added inert planned formula markers for `permanent()`, `common_env()`, `maternal_genetic()`, `maternal_env()`, `paternal_genetic()`, `paternal_env()`, `cytoplasmic()`, `imprinting()`, `dominance()`, `epistasis()`, `relmat()`, and `precision()`. They reserve Phase 2+ vocabulary only and currently abort as planned, not implemented.
* Added a pkgdown formula grammar roadmap article that separates parsed v0.1 syntax from planned quantitative-genetic, genomic, multivariate, and inheritance syntax.
* Expanded the genomics/QTL/GLLVM/accelerator design plan and pkgdown roadmap with a source-backed CPU/GPU strategy, QTL/eQTL path, sibling-package lessons, and explicit evidence gates.
* Added an internal R-to-Julia bridge payload builder for the v0.1 animal-model contract. It creates `y`, `X`, sparse `Z`, normalized pedigree metadata, and the validated Julia `animal_model_spec()` target used by the experimental Julia engine (#6).
* Added a local-only experimental JuliaCall smoke path for the tiny v0.1 payload when a sibling `HSquared.jl` checkout is available. This validates bridge shape against Julia `pedigree_inverse()` and `fit_animal_model()` but is not yet the public `hsquared()` fitting path (#6).
* Added the first `hsquared_fit` object and extractor contract, including `variance_components()`, `heritability()`, `breeding_values()`, `fixef()`, `ranef()`, `logLik()`, `AIC()`, `predict()`, and `summary()` methods over internal fit objects. These are contract plumbing only until the Julia engine returns real fits (#5).
* Added `hs_data()` as a lightweight R data container for phenotype, pedigree, genotype, marker, expression, annotation, and environment inputs. It records ID maps for future integrated genomic/QTL/eQTL workflows, but does not fit models (#8).
* `summary(hs_data(...))` now includes an ID overlap table with phenotype, pedigree, genotype, expression, and mismatch counts (#8).
* `summary(hs_data(...))` now includes marker-map and genotype-marker alignment diagnostics when marker or genotype components are supplied (#8).
* `hs_data()` now validates supplied marker maps for marker ID, chromosome, and non-negative numeric position columns. This is metadata validation only; genomic and QTL/eQTL fitting remain planned (#8).
* `hs_data()` now checks that genotype marker column names match marker-map IDs exactly when both `genotypes` and `markers` are supplied (#8).
* `model_spec()` and `hsquared()` can now use an `hs_data()` object directly for the v0.1 parser, reading model variables from `phenotypes` and resolving formula components such as `pedigree = pedigree` from the bundle (#8).
* Added Phase 0 project operating documentation, an honest placeholder `hsquared()` entry point, and `hs_control()` for planned engine controls.

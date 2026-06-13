# Public Claims Register

Use this register before changing README, DESCRIPTION, GitHub issue text, or
public examples.

| Claim | Status | Evidence | Allowed wording |
| --- | --- | --- | --- |
| `hsquared` is an R package scaffold | covered | package loads; local and GitHub Actions R-CMD-check passed after Phase 0 placeholder API | implemented scaffold |
| `hsquared` parses the first animal-model formula contract | partial | local tests for `animal(1 \| id, pedigree = ped)`, `animal(1 \| id)` with an `hs_data()` pedigree bundle, and unsupported-syntax errors | early parser; fitting only through separate opt-in tiny engine path |
| `hsquared` builds the first internal R-to-Julia payload shape | partial | local tests for `y`, `X`, sparse `Z`, normalized pedigree parent indices, method, family, and target metadata | internal bridge payload; no Julia execution |
| opt-in experimental R-to-Julia fit path | partial | local JuliaCall tests pass when a sibling `HSquared.jl` checkout is available; CI skips when unavailable | `hs_control(engine = "julia")` tiny local examples only |
| opt-in supplied-variance Henderson MME bridge | partial | local JuliaCall tests pass through `hsquared()` with `engine_control = list(target = "henderson_mme", variance_components = ...)` when a sibling `HSquared.jl` checkout is available; optional dense validation-path PEV/reliability is attached when Julia exposes applicable extractors | tiny supplied-variance validation target only; no optimizer, log-likelihood, production sparse reliability, production sparse fitting, or general animal-model support |
| sparse `Z` marshalling through the R-Julia bridge | partial | local tests pass `Matrix::dgCMatrix` CSC slots into Julia `sparse_csc_matrix()` for the opt-in bridge | sparse `Z` bridge validation; not production sparse fitting |
| tiny deterministic Ainv validation fixture | partial | local test pins R payload ordering and live Julia `pedigree_inverse()` agreement for a three-animal fixture when a sibling `HSquared.jl` checkout is available | internal tiny validation fixture; not Mrode, ASReml, or production fitting validation |
| Mrode9 pedigree Ainv comparator | partial | optional local test compares Julia `pedigree_inverse()` with `nadiv::makeAinv()` for `nadiv::Mrode9` when `nadiv` and sibling `HSquared.jl` are available | Mrode9 pedigree-Ainv comparator only; not a fitted Mrode animal-model validation |
| supplied-variance Henderson MME validation fixture | partial | local tests compare an independent R MME solve with Julia `henderson_mme()` for fixed effects, EBVs, fitted values, and h2 when a sibling `HSquared.jl` checkout is available | validation fixture only; no general fitted animal-model, optimizer, Mrode fit-output, or production sparse claim |
| `hsquared` defines the first fitted-object/extractor contract | partial | local tests over internal `hsquared_fit` objects, mocked result fields, fitted/residual extraction, and opt-in tiny Julia bridge enrichment for PEV/reliability when available | extractor plumbing and tiny dense validation enrichment only; no production sparse PEV/reliability |
| `hsquared` provides a data container for integrated inputs | partial | local tests for `hs_data()` ID maps, pedigree status, marker-map validation, genotype-marker alignment, ID overlap and marker-status summaries, input validation, and v0.1 parser use including default pedigree lookup | lightweight data container with phenotype/pedigree parser integration and pedigree/marker metadata diagnostics; no file-backed storage, genotype parsing, marker scanning, or automatic genotype/omics model construction |
| `data_status()` reports data-container diagnostics | partial | local tests over `hs_data()` component, ID-overlap, pedigree-status, and marker-status diagnostics | status helper only; no model fitting, genotype parsing, marker scanning, pedigree inverse, or relationship-matrix construction |
| `hs_control()` stores planned backend names | partial | local control-validation tests for `threads`, `cuda`, `amdgpu`, `metal`, and `oneapi` | control vocabulary only; no CPU/GPU execution |
| `backend_info()` reports backend status | partial | local tests check planned backend rows and `execution_available = FALSE` | diagnostic table only; no backend execution or benchmarking |
| `formula_status()` reports grammar status | partial | local tests check parsed, reserved, planned, and `hs_data()` shorthand rows | diagnostic table only; no formula expansion or fitting |
| `validation_status()` reports validation status | partial | local tests check current validation atoms, planned comparator lanes, and claim-boundary wording | diagnostic table only; does not run checks, fit models, or promote any validation row to covered |
| `model_spec()` previews the parsed v0.1 model contract | partial | local tests inspect dimensions, fixed columns, sparse `Z`, normalized IDs, and Julia targets | model preview only; no fitting |
| Genomic/QTL formula markers exist | partial | local tests check inert markers and planned-not-implemented parser errors | syntax reservation only; no genomic, marker-scan, QTL, or eQTL fitting |
| Standard quantitative-genetic formula markers exist | partial | local tests check inert markers and planned-not-implemented parser errors | syntax reservation only; no permanent, common-environment, maternal/paternal, dominance, epistasis, custom-kernel, cytoplasmic, or imprinting fitting |
| `hsquared` fits general animal models | planned | none | planned v0.1 target after validation and production bridge hardening |
| `hsquared` supports genomic, QTL/eQTL, GLLVM, or GPU workflows | planned | none | roadmap only |
| `HSquared.jl` is the Julia engine package identity | covered | public repo exists; Julia package scaffold and CI green | Julia engine scaffold |
| sparse Ainv construction | partial | Julia tiny tests plus R live bridge fixtures cover a three-animal expected `Ainv` path and optional Mrode9/nadiv comparator | HSquared.jl validation only; R-side construction and production sparse fitting remain planned |
| Gaussian animal model REML/ML | planned | none | planned |
| EBVs/BLUPs and heritability extraction | partial | opt-in tiny Julia bridge tests plus internal extractor tests | experimental tiny/local only |
| PEV and reliability extraction | partial | R extractor contract tests over mocked fields; opt-in tiny Julia bridge enrichment uses exported dense validation extractors when available | dense validation-path only; not production sparse PEV/reliability |
| marker/QTL/eQTL extractor names | partial | local tests over mocked `hsquared_fit` fields and default planned-not-implemented errors | output extractor vocabulary only; no marker, QTL, GWAS, or eQTL fitting |
| multivariate G matrices | planned | none | roadmap |
| factor-analytic G matrices | planned | none | roadmap |
| genomic and single-step models | planned | none | roadmap |
| GLLVM-style animal models | planned | none | roadmap |
| non-standard inheritance systems | planned | none | roadmap |

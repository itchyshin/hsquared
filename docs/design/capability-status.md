# Capability Status

| Capability | Status | Evidence | Notes |
| --- | --- | --- | --- |
| R package scaffold | covered | local and GitHub Actions R-CMD-check passed after Phase 0 edits | Package identity and operating memory exist. |
| Team operating system | covered | Phase 0 docs, skills, agents, board, closeout report, issues, milestones, labels | Use this before Phase 1 work. |
| `hs_control()` | covered | local tests | Default `engine = "validate"`; experimental `engine = "julia"` is tiny/local only. Backend vocabulary includes planned CPU threads, CUDA, AMDGPU, Metal, and oneAPI controls but does not execute those backends. |
| `backend_info()` | partial | local tests | Reports planned backend rows and marks execution unavailable for every backend. |
| `formula_status()` | partial | local tests | Reports parsed, reserved, and planned grammar rows, including the `hs_data()` pedigree shorthand; diagnostic only. |
| `validation_status()` | partial | local tests | Reports current validation atoms and planned comparator lanes; diagnostic only. |
| `data_status()` | partial | local tests over `hs_data()` diagnostics | Reports data-container component, ID-overlap, pedigree-status, marker-status, annotation-feature, and environment-key diagnostics; no fitting. |
| `model_spec()` | partial | local tests inspect dimensions, fixed columns, sparse `Z`, normalized IDs, and Julia targets | Preview helper only; does not fit models. |
| `animal()` formula marker | partial | local parser tests | Inert syntax marker; accepts optional `pedigree` only as parsed formula context; not a standalone modelling helper. |
| Genomic/QTL formula markers | partial | local tests | `genomic()`, `single_step()`, `markers()`, `marker_scan()`, and `qtl_scan()` are inert markers that the parser rejects as planned, not implemented. |
| Quantitative-genetic effect markers | partial | local tests | `permanent()`, `common_env()`, maternal/paternal, dominance/epistasis, cytoplasmic/imprinting, `relmat()`, and `precision()` markers are inert and rejected as planned, not implemented. |
| `hsquared()` fit entry point | partial | local tests parse v0.1 animal contract, build bridge payload, stop by default, and fit tiny examples with opt-in Julia engine | General fitting remains planned. |
| R formula parser | partial | local tests parse `animal(1 \| id, pedigree = ped)` and `animal(1 \| id)` with an `hs_data()` pedigree bundle, and reject unsupported future syntax | Production bridge execution and general fitting remain planned. |
| R-to-Julia bridge payload | partial | local tests build `y`, `X`, sparse `Z`, normalized pedigree parent indices, method, family, and Julia target metadata | Tiny live smoke exists separately; production bridge execution remains planned. |
| opt-in experimental Julia engine | partial | local JuliaCall tests against sibling `HSquared.jl` return variance components, EBVs, h², logLik, fitted values, dense validation-path PEV, and reliability for a tiny example | Requires `hs_control(engine = "julia")`; sparse `Z` CSC marshalling now used, production bridge still planned. |
| opt-in supplied-variance Henderson MME bridge | partial | local JuliaCall tests against sibling `HSquared.jl` compare the R validation fixture with Julia `henderson_mme()` through `hsquared()` and attach optional dense validation-path PEV/reliability when Julia exposes the methods | Requires `hs_control(engine = "julia", engine_control = list(target = "henderson_mme", variance_components = ...))`; supplied-variance validation path only, no optimizer, log-likelihood, or production sparse reliability. |
| tiny deterministic Ainv validation fixture | partial | local tests pin R payload ordering, sparse `Z`, and live Julia `pedigree_inverse()` agreement when `HSquared.jl` is available | Internal validation atom only; not Mrode or production fitting coverage. |
| Mrode9 pedigree Ainv comparator | partial | optional local tests compare Julia `pedigree_inverse()` with `nadiv::makeAinv()` for `nadiv::Mrode9` when `nadiv` and sibling `HSquared.jl` are available | Pedigree-Ainv comparator only; full Mrode animal-model outputs remain planned. |
| supplied-variance Henderson MME validation fixture | partial | local R reference solve and live Julia `henderson_mme()` comparison when sibling `HSquared.jl` is available | Internal validation atom only; variance-component optimization and production sparse fitting remain planned. |
| `hsquared_fit` object/extractors | partial | local tests over internal mock fit results and opt-in tiny Julia result | `EBV()`/`BLUP()` aliases, PEV/reliability, derived accuracy, fitted values, and residual extraction exist for `hsquared_fit` objects with the needed fields; the opt-in bridge enriches tiny local Julia results from exported dense validation extractors when available. |
| `hs_data()` container | partial | local tests over phenotype, pedigree, genotype, expression, annotation-feature diagnostics, environment-key diagnostics, pedigree status, marker-map validation, genotype-marker alignment, ID overlap summaries, marker-status summaries, and v0.1 parser use including default pedigree lookup for `animal(1 \| id)` | No file-backed storage, genotype parsing, marker imputation, marker scanning, eQTL/omics models, environmental model terms, or automatic genotype/omics/environment model construction yet. |
| simple Gaussian animal model | planned | none | Phase 1. |
| sparse Ainv | partial | Julia lane has tiny `pedigree_inverse()` tests; R live validation fixtures check the three-animal bridge path and optional Mrode9/nadiv comparator when available | R-side construction and production sparse fitting remain planned. |
| EBVs/BLUPs | partial | opt-in tiny Julia bridge returns breeding values | Experimental tiny/local only. |
| PEV/reliability | partial | R extractor contract tests over mocked `hsquared_fit` fields and opt-in tiny Julia bridge enrichment when available | Dense validation-path only; production sparse PEV/reliability and comparator validation remain planned. |
| marker/QTL/eQTL extractor names | partial | local tests over mocked `hsquared_fit` fields and default planned-not-implemented errors | Output vocabulary only; no marker, QTL, GWAS, or eQTL model fitting. |
| multivariate G matrices | planned | none | Phase 3. |
| factor-analytic G matrices | planned | none | Phase 4. |
| genomic/single-step models | planned | none | Phase 5. |
| GLLVM-style models | planned | none | Phase 6. |
| unusual inheritance | planned | none | Phase 7. |
| CPU/GPU backend execution | planned | none | `hs_control()` stores planned backend names only; Julia execution backends remain future work. |

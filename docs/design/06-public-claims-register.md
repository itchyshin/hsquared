# Public Claims Register

Use this register before changing README, DESCRIPTION, GitHub issue text, or
public examples.

| Claim | Status | Evidence | Allowed wording |
| --- | --- | --- | --- |
| `hsquared` is an R package scaffold | covered | package loads; local and GitHub Actions R-CMD-check passed after Phase 0 placeholder API | implemented scaffold |
| `hsquared` parses the first animal-model formula contract | partial | local tests for `animal(1 \| id, pedigree = ped)` parser and unsupported-syntax errors | early parser; fitting only through separate opt-in tiny engine path |
| `hsquared` builds the first internal R-to-Julia payload shape | partial | local tests for `y`, `X`, sparse `Z`, normalized pedigree parent indices, method, family, and target metadata | internal bridge payload; no Julia execution |
| opt-in experimental R-to-Julia fit path | partial | local JuliaCall tests pass when a sibling `HSquared.jl` checkout is available; CI skips when unavailable | `hs_control(engine = "julia")` tiny local examples only |
| sparse `Z` marshalling through the R-Julia bridge | partial | local tests pass `Matrix::dgCMatrix` CSC slots into Julia `sparse_csc_matrix()` for the opt-in bridge | sparse `Z` bridge validation; not production sparse fitting |
| tiny deterministic Ainv validation fixture | partial | local test pins R payload ordering and live Julia `pedigree_inverse()` agreement for a three-animal fixture when a sibling `HSquared.jl` checkout is available | internal tiny validation fixture; not Mrode, ASReml, or production fitting validation |
| Mrode9 pedigree Ainv comparator | partial | optional local test compares Julia `pedigree_inverse()` with `nadiv::makeAinv()` for `nadiv::Mrode9` when `nadiv` and sibling `HSquared.jl` are available | Mrode9 pedigree-Ainv comparator only; not a fitted Mrode animal-model validation |
| `hsquared` defines the first fitted-object/extractor contract | partial | local tests over internal `hsquared_fit` objects and mocked result fields, including PEV/reliability fields | extractor plumbing; PEV/reliability not yet returned by live bridge payload |
| `hsquared` provides a data container for integrated inputs | partial | local tests for `hs_data()` ID maps and input validation | lightweight data container; no modelling or file-backed storage |
| `hs_control()` stores planned backend names | partial | local control-validation tests for `threads`, `cuda`, `amdgpu`, `metal`, and `oneapi` | control vocabulary only; no CPU/GPU execution |
| `backend_info()` reports backend status | partial | local tests check planned backend rows and `execution_available = FALSE` | diagnostic table only; no backend execution or benchmarking |
| `hsquared` fits general animal models | planned | none | planned v0.1 target after validation and production bridge hardening |
| `hsquared` supports genomic, QTL/eQTL, GLLVM, or GPU workflows | planned | none | roadmap only |
| `HSquared.jl` is the Julia engine package identity | covered | public repo exists; Julia package scaffold and CI green | Julia engine scaffold |
| sparse Ainv construction | partial | Julia tiny tests plus R live bridge fixtures cover a three-animal expected `Ainv` path and optional Mrode9/nadiv comparator | HSquared.jl validation only; R-side construction and production sparse fitting remain planned |
| Gaussian animal model REML/ML | planned | none | planned |
| EBVs/BLUPs and heritability extraction | partial | opt-in tiny Julia bridge tests plus internal extractor tests | experimental tiny/local only |
| PEV and reliability extraction | partial | R extractor contract tests over mocked fields; Julia low-level dense extractors exist | not yet in live R bridge payload |
| multivariate G matrices | planned | none | roadmap |
| factor-analytic G matrices | planned | none | roadmap |
| genomic and single-step models | planned | none | roadmap |
| GLLVM-style animal models | planned | none | roadmap |
| non-standard inheritance systems | planned | none | roadmap |

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
| `hsquared` defines the first fitted-object/extractor contract | partial | local tests over internal `hsquared_fit` objects and mocked result fields, including PEV/reliability fields | extractor plumbing; PEV/reliability not yet returned by live bridge payload |
| `hsquared` provides a data container for integrated inputs | partial | local tests for `hs_data()` ID maps and input validation | lightweight data container; no modelling or file-backed storage |
| `hsquared` fits general animal models | planned | none | planned v0.1 target after validation and production bridge hardening |
| `hsquared` supports genomic, QTL/eQTL, GLLVM, or GPU workflows | planned | none | roadmap only |
| `HSquared.jl` is the Julia engine package identity | covered | public repo exists; Julia package scaffold and CI green | Julia engine scaffold |
| sparse Ainv construction | planned | none | planned |
| Gaussian animal model REML/ML | planned | none | planned |
| EBVs/BLUPs and heritability extraction | partial | opt-in tiny Julia bridge tests plus internal extractor tests | experimental tiny/local only |
| PEV and reliability extraction | partial | R extractor contract tests over mocked fields; Julia low-level dense extractors exist | not yet in live R bridge payload |
| multivariate G matrices | planned | none | roadmap |
| factor-analytic G matrices | planned | none | roadmap |
| genomic and single-step models | planned | none | roadmap |
| GLLVM-style animal models | planned | none | roadmap |
| non-standard inheritance systems | planned | none | roadmap |

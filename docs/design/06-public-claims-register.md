# Public Claims Register

Use this register before changing README, DESCRIPTION, GitHub issue text, or
public examples.

| Claim | Status | Evidence | Allowed wording |
| --- | --- | --- | --- |
| `hsquared` is an R package scaffold | covered | package loads; local and GitHub Actions R-CMD-check passed after Phase 0 placeholder API | implemented scaffold |
| `hsquared` parses the first animal-model formula contract | partial | local tests for `animal(1 \| id, pedigree = ped)` parser and unsupported-syntax errors | early parser; no fitting |
| `hsquared` builds the first internal R-to-Julia payload shape | partial | local tests for `y`, `X`, sparse `Z`, normalized pedigree parent indices, method, family, and target metadata | internal bridge payload; no Julia execution |
| `hsquared` fits animal models | planned | none | planned v0.1 target |
| `hsquared` supports genomic, QTL/eQTL, GLLVM, or GPU workflows | planned | none | roadmap only |
| `HSquared.jl` is the Julia engine package identity | covered | public repo exists; Julia package scaffold and CI green | Julia engine scaffold |
| sparse Ainv construction | planned | none | planned |
| Gaussian animal model REML/ML | planned | none | planned |
| EBVs/BLUPs and heritability extraction | planned | none | planned |
| multivariate G matrices | planned | none | roadmap |
| factor-analytic G matrices | planned | none | roadmap |
| genomic and single-step models | planned | none | roadmap |
| GLLVM-style animal models | planned | none | roadmap |
| non-standard inheritance systems | planned | none | roadmap |

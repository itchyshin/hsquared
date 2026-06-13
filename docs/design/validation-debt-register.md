# Validation Debt Register

| Capability | Status | Evidence | Reviewer | Notes |
| --- | --- | --- | --- | --- |
| R package scaffold | covered | R-CMD-check green on initial scaffold | Grace/Rose | Phase 0 package exists. |
| `hs_control()` validation | partial | local tests planned in current slice | Emmy/Grace | Phase 0 control object only. |
| R formula parser | partial | local parser tests for v0.1 syntax and unsupported errors | Boole/Noether | General fitting remains planned. |
| R-to-Julia bridge payload | partial | local tests for `y`, `X`, sparse `Z`, normalized pedigree order, parent indices, method, family, and target metadata | Hopper/Lovelace | Production bridge execution remains planned. |
| opt-in experimental Julia engine | partial | local JuliaCall tests over tiny payload; skipped when Julia/JuliaCall/sibling `HSquared.jl` is unavailable | Hopper/Lovelace/Grace | Sparse `Z` CSC marshalling now used; not production bridge or general fitting. |
| `hsquared_fit` extractor contract | partial | local tests over mocked result fields and opt-in tiny Julia result | Emmy/Pat | PEV/reliability contract exists; live bridge payload does not return those fields yet. |
| `hs_data()` input container | partial | local ID-map and input-shape tests | Emmy/Jason | No large-file or file-backed tests yet. |
| `hsquared()` bridge-boundary error | partial | local tests | Rose/Pat | Must not imply fitting. |
| sparse Ainv tiny pedigree | planned | none | Curie/Gauss/Henderson | Julia Phase 1. |
| univariate Gaussian animal model | planned | none | Fisher/Henderson | Julia Phase 1. |
| EBVs/BLUPs | partial | opt-in tiny Julia bridge returns breeding values | Fisher/Pat | Needs Mrode/comparator validation. |
| PEV/reliability | partial | R extractor contract tests over mocked fields; Julia low-level dense extractors exist | Fisher/Pat | Needs bridge payload fields and Mrode/comparator validation. |
| Mrode simple animal example | planned | none | Mrode/Curie | First validation canon. |
| multivariate G matrix | planned | none | Noether/Kirkpatrick | Phase 3. |
| factor-analytic G matrix | planned | none | Noether/Fisher/Kirkpatrick | Phase 4. |

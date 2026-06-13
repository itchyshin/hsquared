# Validation Debt Register

| Capability | Status | Evidence | Reviewer | Notes |
| --- | --- | --- | --- | --- |
| R package scaffold | covered | R-CMD-check green on initial scaffold | Grace/Rose | Phase 0 package exists. |
| `hs_control()` validation | partial | local tests planned in current slice | Emmy/Grace | Phase 0 control object only. |
| `hs_control()` backend vocabulary | partial | local tests for CPU threads, CUDA, AMDGPU, Metal, and oneAPI names | Lovelace/Karpinski/Rose | Control metadata only; no backend execution. |
| `backend_info()` status diagnostics | partial | local tests check requested backend flags and `execution_available = FALSE` | Lovelace/Karpinski/Rose | Diagnostic only; no runtime backend probe or benchmark. |
| R formula parser | partial | local parser tests for v0.1 syntax and unsupported errors | Boole/Noether | General fitting remains planned. |
| R-to-Julia bridge payload | partial | local tests for `y`, `X`, sparse `Z`, normalized pedigree order, parent indices, method, family, and target metadata | Hopper/Lovelace | Production bridge execution remains planned. |
| opt-in experimental Julia engine | partial | local JuliaCall tests over tiny payload; skipped when Julia/JuliaCall/sibling `HSquared.jl` is unavailable | Hopper/Lovelace/Grace | Sparse `Z` CSC marshalling now used; not production bridge or general fitting. |
| tiny deterministic Ainv validation fixture | partial | local tests pin R payload ordering and live Julia `pedigree_inverse()` agreement for a three-animal Henderson-style fixture when available | Curie/Gauss/Henderson | First validation atom only; Mrode/comparator validation remains planned. |
| Mrode9 pedigree Ainv comparator | partial | optional local tests compare Julia `pedigree_inverse()` with `nadiv::makeAinv()` for `nadiv::Mrode9` when available | Curie/Gauss/Mrode | Pedigree-Ainv comparator only; fitted Mrode animal-model outputs remain planned. |
| `hsquared_fit` extractor contract | partial | local tests over mocked result fields and opt-in tiny Julia result | Emmy/Pat | PEV/reliability contract exists; live bridge payload does not return those fields yet. |
| `hs_data()` input container | partial | local ID-map and input-shape tests | Emmy/Jason | No large-file or file-backed tests yet. |
| `hsquared()` bridge-boundary error | partial | local tests | Rose/Pat | Must not imply fitting. |
| sparse Ainv tiny pedigree | partial | Julia lane tests exact tiny `pedigree_inverse()` values; R lane checks the three-animal bridge path and optional Mrode9/nadiv comparator when available | Curie/Gauss/Henderson | R-side construction and production sparse fitting remain planned. |
| univariate Gaussian animal model | planned | none | Fisher/Henderson | Julia Phase 1. |
| EBVs/BLUPs | partial | opt-in tiny Julia bridge returns breeding values | Fisher/Pat | Needs Mrode/comparator validation. |
| PEV/reliability | partial | R extractor contract tests over mocked fields; Julia low-level dense extractors exist | Fisher/Pat | Needs bridge payload fields and Mrode/comparator validation. |
| Mrode simple animal example | planned | none | Mrode/Curie | Mrode9 pedigree-Ainv comparator exists; fitted model outputs and estimands remain planned. |
| multivariate G matrix | planned | none | Noether/Kirkpatrick | Phase 3. |
| factor-analytic G matrix | planned | none | Noether/Fisher/Kirkpatrick | Phase 4. |

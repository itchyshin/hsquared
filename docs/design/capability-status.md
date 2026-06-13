# Capability Status

| Capability | Status | Evidence | Notes |
| --- | --- | --- | --- |
| R package scaffold | covered | local and GitHub Actions R-CMD-check passed after Phase 0 edits | Package identity and operating memory exist. |
| Team operating system | covered | Phase 0 docs, skills, agents, board, closeout report, issues, milestones, labels | Use this before Phase 1 work. |
| `hs_control()` | covered | local tests | Default `engine = "validate"`; experimental `engine = "julia"` is tiny/local only. |
| `animal()` formula marker | partial | local parser tests | Inert syntax marker; not a standalone modelling helper. |
| `hsquared()` fit entry point | partial | local tests parse v0.1 animal contract, build bridge payload, stop by default, and fit tiny examples with opt-in Julia engine | General fitting remains planned. |
| R formula parser | partial | local tests parse `animal(1 \| id, pedigree = ped)` and reject unsupported future syntax | Production bridge execution and general fitting remain planned. |
| R-to-Julia bridge payload | partial | local tests build `y`, `X`, sparse `Z`, normalized pedigree parent indices, method, family, and Julia target metadata | Tiny live smoke exists separately; production bridge execution remains planned. |
| opt-in experimental Julia engine | partial | local JuliaCall tests against sibling `HSquared.jl` return variance components, EBVs, h², logLik, and fitted values for a tiny example | Requires `hs_control(engine = "julia")`; dense guarded validation path only. |
| `hsquared_fit` object/extractors | partial | local tests over internal mock fit results and opt-in tiny Julia result | PEV/reliability extractor contract exists; current live bridge payload does not return those fields yet. |
| `hs_data()` container | partial | local tests over phenotype, pedigree, genotype, expression, and marker inputs | No file-backed storage or modelling integration yet. |
| simple Gaussian animal model | planned | none | Phase 1. |
| sparse Ainv | planned | none | Julia lane. |
| EBVs/BLUPs | partial | opt-in tiny Julia bridge returns breeding values | Experimental tiny/local only. |
| PEV/reliability | partial | R extractor contract tests over mocked `hsquared_fit` fields | Current live bridge payload does not return PEV/reliability yet. |
| multivariate G matrices | planned | none | Phase 3. |
| factor-analytic G matrices | planned | none | Phase 4. |
| genomic/single-step models | planned | none | Phase 5. |
| GLLVM-style models | planned | none | Phase 6. |
| unusual inheritance | planned | none | Phase 7. |

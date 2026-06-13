# Capability Status

| Capability | Status | Evidence | Notes |
| --- | --- | --- | --- |
| R package scaffold | covered | local and GitHub Actions R-CMD-check passed after Phase 0 edits | Package identity and operating memory exist. |
| Team operating system | covered | Phase 0 docs, skills, agents, board, closeout report, issues, milestones, labels | Use this before Phase 1 work. |
| `hs_control()` | covered | local tests | Stores planned controls only. |
| `animal()` formula marker | partial | local parser tests | Inert syntax marker; not a standalone modelling helper. |
| `hsquared()` fit entry point | partial | local tests parse v0.1 animal contract, build bridge payload, and stop at bridge boundary | No fitting or Julia execution. |
| R formula parser | partial | local tests parse `animal(1 \| id, pedigree = ped)` and reject unsupported future syntax | Bridge execution and fitting are not implemented. |
| R-to-Julia bridge payload | partial | local tests build `y`, `X`, sparse `Z`, normalized pedigree parent indices, method, family, and Julia target metadata | `Ainv` construction and live Julia execution remain planned. |
| simple Gaussian animal model | planned | none | Phase 1. |
| sparse Ainv | planned | none | Julia lane. |
| EBVs/BLUPs | planned | none | Phase 1. |
| multivariate G matrices | planned | none | Phase 3. |
| factor-analytic G matrices | planned | none | Phase 4. |
| genomic/single-step models | planned | none | Phase 5. |
| GLLVM-style models | planned | none | Phase 6. |
| unusual inheritance | planned | none | Phase 7. |

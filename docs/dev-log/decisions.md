# Decisions

## 2026-06-12: Two Repos, One Identity

`hsquared` is the R package identity and applied-user surface. `HSquared.jl` is
the Julia computational engine. The first phase installs the operating system
and honest placeholders before model fitting.

## 2026-06-12: Phase 0 Public Claims

Public text may describe planned syntax and roadmap, but it must not say that
animal models, Ainv construction, REML/ML, EBVs, G matrices, or Julia bridging
are implemented until there is code, tests, documentation, and check-log
evidence.

## 2026-06-12: Thread Coordination

The R/coordinator thread owns the R repository. The Julia twin thread owns
`HSquared.jl`. Coordination happens through explicit thread messages and
repo-visible design/check-log files.

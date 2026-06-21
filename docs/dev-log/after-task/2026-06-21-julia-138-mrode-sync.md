# After-task report: Julia #138 Mrode/MCMCglmm ledger sync

Date: 2026-06-21

Branch: `codex/julia-138-mrode-sync`

Active lenses: Ada, Shannon, Mrode, Jason, Fisher, Rose, Grace

Spawned subagents: none

Current lane: R coordination/docs

## Scope

Record the Julia-lane confirmation that HSquared.jl PR #138 merged at
`945bd2a` and synced two already-banked R validation evidence legs into the
Julia V4 ledger:

- Mrode Example 5.1 supplied-covariance BLUP/MME anchor from `hsquared`
  `6a1065e`.
- `MCMCglmm` Bayesian agreement probe from `hsquared` `dbf97a7`.

## Files touched

- `docs/dev-log/issue-map.md`
- `docs/design/04-validation-canon.md`
- `docs/design/11-next-50-slices.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-21-julia-138-mrode-sync.md`

## Evidence

- Julia-lane sync reported HSquared.jl PR #138 squash-merged at `945bd2a`.
- R evidence was already banked before this slice; this change only records the
  cross-lane ledger sync and updates the next-step map.

## Boundary

No R code changed. No `validation_status()` row changed. No capability moved to
covered. V4-MV-REML remains partial. `MCMCglmm` remains Bayesian/MCMC agreement
evidence, not same-estimand REML parity. #46 remains open for fitted
textbook/Mrode target evidence, and #49 remains open for a second independent
same-estimand comparator beyond `sommer`.

## Checks

- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'`
- `git diff --check`
- Boundary grep over the changed docs/check-log/after-task files.

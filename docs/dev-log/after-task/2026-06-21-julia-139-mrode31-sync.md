# After-task report: Julia #139 Mrode 3.1 published-anchor sync

Date: 2026-06-21

Branch: `codex/julia-139-mrode31-sync`

Active lenses: Ada, Shannon, Mrode, Curie, Fisher, Rose, Grace

Spawned subagents: none

Current lane: R coordination/validation

## Scope

Record the Julia-lane confirmation that HSquared.jl PR #139 merged at
`934a91e` and added a Julia-native Mrode (2014) Example 3.1 published
animal-model anchor at supplied variance components:

- `sigma_a2 = 20`;
- `sigma_e2 = 40`;
- published EBVs for animals 1-8;
- invariant male-minus-female sex contrast;
- perturbation test-of-test.

## Files touched

- `docs/dev-log/issue-map.md`
- `docs/design/04-validation-canon.md`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-21-julia-139-mrode31-sync.md`

## Boundary

This is R-side status bookkeeping for Julia evidence already banked in
HSquared.jl. No R code changed. The evidence is a supplied-variance textbook
anchor only. It is not estimated variance-component validation, not
same-estimand REML comparator parity, not a sire-model implementation, and not a
covered-status promotion.

## Checks

- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'`
- `git diff --check`
- Boundary grep over the changed docs/check-log/after-task files.

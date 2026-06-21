# After-task report: Julia #140 genomic target sync

Date: 2026-06-21

Branch: `codex/julia-140-genomic-target-sync`

Active lenses: Ada, Shannon, Jason, Fisher, Curie, Rose, Grace

Spawned subagents: none

Current lane: R validation/comparator

## Scope

Mirror the Julia-owned HSquared.jl PR #140 target fixture into the R
validation/comparator ledgers and create a handoff packet for future external
genomic comparator work.

## Julia Source

- HSquared.jl commit: `008ea4d`
- PR: <https://github.com/itchyshin/HSquared.jl/pull/140>
- Fixture:
  `test/fixtures/genomic_gblup_snpblup_target/`

## Fixture Shape

The fixture contains phenotypes, marker dosages, supplied allele frequencies,
VanRaden method-1 `G`, `Ginv`, beta, GBLUP GEBVs, SNP-BLUP marker effects and
GEBVs, metadata, README, and a no-RNG generator.

## Local Comparator Availability

- `AGHmatrix`: missing
- `rrBLUP`: missing
- `sommer`: 4.4.3
- `BGLR`: missing

## Files touched

- `NEWS.md`
- `docs/design/capability-status.md`
- `docs/design/06-public-claims-register.md`
- `docs/dev-log/comparator-runs/README.md`
- `docs/dev-log/comparator-runs/2026-06-21-genomic-gblup-snpblup-target-handoff.md`
- `docs/dev-log/issue-map.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `vignettes/articles/genomic-prediction.Rmd`
- `docs/dev-log/after-task/2026-06-21-julia-140-genomic-target-sync.md`

## Boundary

This is target availability only. No external genomic comparator run was
performed. No AGHmatrix, rrBLUP, sommer, JWAS, BGLR, BLUPF90, or other
external-comparator evidence is claimed. No new R genomic syntax or model-spec
activation, sparse/APY scaling, weighted/standardized marker-prior support,
Bayesian marker-prior support, or covered-status promotion is claimed.

## Checks

- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean.
- `Rscript --vanilla /Users/z3437171/shinichi-brain/tools/check-after-task.R docs/dev-log/after-task/2026-06-21-julia-140-genomic-target-sync.md`
  clean.
- `git diff --check` clean.
- Boundary grep over the touched documentation surfaces confirms target-only,
  no-external-comparator, and no-promotion wording.

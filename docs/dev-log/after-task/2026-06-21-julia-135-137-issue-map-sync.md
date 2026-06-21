# After-Task Report: Julia #135/#136/#137 Issue-Map Sync

## Goal

Refresh the R coordination surfaces after the Julia lane banked three ledger
slices: #135, #136, and #137.

## Active Lenses

Ada, Shannon, Jason, Fisher, Rose, and Grace.

Spawned subagents: none.

## Files Changed

- `docs/dev-log/issue-map.md`
- `docs/design/11-next-50-slices.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-21-julia-135-137-issue-map-sync.md`

## Checks Run

- Live GitHub issue checks:
  - `gh issue view 48 --repo itchyshin/HSquared.jl --json number,title,state,labels,updatedAt,url`
    returned open.
  - `gh issue view 93 --repo itchyshin/HSquared.jl --json number,title,state,closedAt,updatedAt,url`
    returned closed at `2026-06-21T19:25:40Z`.
  - `gh issue view 47 --repo itchyshin/HSquared.jl --json number,title,state,closedAt,updatedAt,url`
    returned closed at `2026-06-21T19:32:38Z`.
- Live GitHub PR checks:
  - `gh pr view 135 --repo itchyshin/HSquared.jl --json number,title,state,mergedAt,mergeCommit,url`
    returned merged at `a815097`.
  - `gh pr view 136 --repo itchyshin/HSquared.jl --json number,title,state,mergedAt,mergeCommit,url`
    returned merged at `ff1fbab`.
  - `gh pr view 137 --repo itchyshin/HSquared.jl --json number,title,state,mergedAt,mergeCommit,url`
    returned merged at `ad7848c`.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'`
  - Result: clean.
- `git diff --check`
  - Result: clean.
- Boundary grep:
  - `rg -n "#135|#136|#137|a815097|ff1fbab|ad7848c|#48|#93|#47|no R threshold|does not promote|no R code" docs/dev-log/issue-map.md docs/design/11-next-50-slices.md docs/dev-log/check-log.md docs/dev-log/coordination-board.md docs/dev-log/after-task/2026-06-21-julia-135-137-issue-map-sync.md`
  - Result: confirms the live issue-state sync and no-promotion boundary.

## Public Claim Audit

Clean. This slice changes coordination docs only.

The refreshed state is:

- #48 is open again as the Julia threshold calibration/evidence gate.
- #93 is closed as a plotting plot-data contract ledger item.
- #47 is closed as a multivariate covariance SE/LRT ledger item.

No R `gwas()` threshold is active. No external scan comparator, realistic-LD
production calibration, structured-fit covariance SE claim, or covered-status
promotion is added.

## Tests Of The Tests

The important test for this slice is the live GitHub issue/PR check plus the
boundary grep. The changed docs now agree with live issue states and still name
the no-promotion boundaries.

## Coordination Notes

The next R-owned action depends on the Julia lane:

- If Julia produces #46 fitted Mrode/textbook evidence, mirror that evidence in
  R validation surfaces only as far as the actual estimand supports.
- If Julia produces #49 comparator evidence, distinguish same-estimand REML
  parity from Bayesian/MCMC or setup-only evidence.
- If Julia produces a calibration payload for #48, consume it only through the
  inert validator/contract path banked in R PRs #59/#60 until evidence gates
  pass.

## What Did Not Go Smoothly

The issue map had drifted naturally during fast cross-lane banking: #48 was
listed as closed and #93 as open. Live GitHub resolved the ambiguity.

## Known Limitations

- No R implementation changed.
- No thresholds were activated.
- No multivariate or structured-covariance validation row was promoted.
- No external comparator evidence was added.

## Next Actions

1. Watch Julia #46/#49 evidence-producing work.
2. Keep R marker-scan threshold wording tied to live #48 evidence.
3. Preserve the BLUPF90/external-comparator blocker until executable-backed
   same-estimand evidence exists.

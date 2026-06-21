# After-task report: issue 9 roadmap sync

## Task goal

Refresh the R roadmap parent after the latest genomic, marker-scan,
non-Gaussian, and Julia scan-result-table syncs so issue #9 no longer says the
whole Phase 5+ runway is only planned.

## Active lenses and spawned agents

- Active lenses: Ada, Shannon, Boole, Jason, Fisher, Pat, Rose, Grace.
- Spawned agents: none.
- Current lane: R coordinator / docs.

## Files changed

- `ROADMAP.md`
- `docs/design/07-genomics-qtl-gpu-plan.md`
- `vignettes/articles/genomics-gpu-roadmap.Rmd`
- `docs/dev-log/issue-map.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`

## Checks run and outcomes

- `gh issue edit 9 --repo itchyshin/hsquared --remove-label status:planned --add-label status:partial --body-file -`
  updated the live roadmap parent body and label.
- `gh issue view 9 --repo itchyshin/hsquared --json title,state,labels,updatedAt,url`
  confirmed the issue is open with `status:partial`.
- `air format .` clean.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e 'pkgdown::check_pkgdown()'`
  clean.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla /Users/z3437171/shinichi-brain/tools/check-after-task.R docs/dev-log/after-task/2026-06-21-issue-9-roadmap-sync.md`
  clean.
- `git diff --check` clean.

## Public claim audit

Clean so far. The wording now says Phase 5+ is mixed: some surfaces are opt-in
partial, while production genomics, QTL/eQTL workflows, GLLVM/omics models,
GPU acceleration, APY/low-rank production scaling, calibrated thresholds,
map-annotated QTL/GWAS/eQTL tables, and external comparator evidence remain
gated.

No capability or validation row is promoted. The default v0.1 Gaussian
animal-model fit remains the covered exception.

## Tests of the tests

This is a docs/status slice. The live issue label/body check guards the GitHub
side; pkgdown and whitespace checks guarded the repo side before banking.

## Coordination notes

The slice incorporates R PRs #82-#84 and the Julia sync for HSquared.jl PR #146
as status context only. Julia PR #146 mirrors R `gwas_table(scan)` /
`lod_scores(scan)` wording and does not add behavior, threshold evidence, or
comparator evidence.

## What did not go smoothly

No unexpected failure yet. The main risk was overcorrecting from stale
"planned-only" wording into overclaim; the edits keep the partial/planned split
explicit.

## Known limitations

Issue #9 remains a parent roadmap issue, not a proof of production readiness.
It now points to implemented partial surfaces, but the actual work remains in
the narrower bridge, validation, and comparator issues.

## Next actions

- Bank the narrow docs/status PR if remote CI is green.
- Continue to the next parent-ledger sync or evidence-producing slice from
  refreshed main.

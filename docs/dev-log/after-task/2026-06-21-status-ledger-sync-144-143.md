# After-task report: structured and threshold status ledger sync

## Task goal

Synchronize the R lane after HSquared.jl PR #144 (`023c675`) and the earlier
PR #143 (`07a3c63`) without changing capability scope: structured covariance
status should separate the banked diagonal/unstructured payload evidence from
still-blocked lowrank/fa work, and marker-threshold wording should keep #48 as
the active gate.

## Active lenses and spawned agents

- Active lenses: Ada, Shannon, Hopper, Boole, Kirkpatrick, Fisher, Rose, Grace.
- Spawned agents: none.
- Current lane: R coordination / status hygiene.

## Files changed

- `R/julia-bridge.R`
- `NEWS.md`
- `vignettes/articles/multivariate.Rmd`
- `docs/design/06-public-claims-register.md`
- `docs/design/18-structured-covariance-r-control.md`
- `docs/design/28-gwas-threshold-activation-contract.md`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/issue-map.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`

## Checks run and outcomes

- `air format .` clean.
- `Rscript --vanilla -e 'devtools::test(filter = "multivariate|formula-animal|phase0-api")'`
  was killed with exit 137 before output. A later bare wrapper `Rscript`
  startup probe was sluggish, so the actual checks used the explicit framework
  Rscript path.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e 'devtools::test(filter = "multivariate")'`
  passed 82/0/0/4.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e 'pkgdown::check_pkgdown()'`
  clean.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e 'devtools::test()'`
  passed 1339/0/0/59.
- `git diff --check` clean.
- Live `gh issue view` checks verified R #22 and #23 are open with the updated
  #144 and #48/#61 issue metadata.

## Public claim audit

Clean with explicit limits. The updated docs say diagonal-G support is
experimental/partial and dense validation-scale only. HSquared.jl #144 is
status hygiene and issue-body alignment, not new R behavior. HSquared.jl #143 is
threshold-status hygiene, not an R threshold.

No calibrated marker threshold, lowrank/fa bridge, raw loading extractor,
formula-level `cov = ...` grammar, comparator/calibration evidence, or covered
promotion is claimed.

## Tests of the tests

The focused multivariate test pass exercises the structured covariance guard
surface affected by the rank diagnostic. The full package test pass confirms no
broader extractor, bridge, marker-scan, or formula-status regression. `git diff
--check` and pkgdown add prose-level guardrails for the documentation changes.

## Coordination notes

Live R #22 now explicitly records the Julia #144 split: diagonal/unstructured
payload evidence is banked, while loading-bearing `lowrank`/`factor_analytic`
work remains gated by #42/#37/#61. Live R #23 is retitled against active #48/#61
because Julia #45 is already closed by PR #142.

## What did not go smoothly

The default `/usr/local/bin/Rscript` wrapper was unreliable in this run: one
focused `devtools::test()` call was killed with exit 137 before output, and a
bare startup probe was sluggish. Re-running with
`/Library/Frameworks/R.framework/Resources/bin/Rscript` produced clean evidence.

## Known limitations

This slice does not consume new Julia payload data, run Julia, run external
comparators, or change any fitted result. It leaves R #22 and #23 open and keeps
Julia #42/#48/#61 as active gates.

## Next actions

- Continue the next-20 sequence from fresh main after this narrow PR is banked.
- Prefer the Julia genomic GBLUP/SNP-BLUP target mirror or marker-threshold
  metadata/table contract next, depending on the cleanest available branch.
- Keep lowrank/fa and calibrated marker thresholds behind their evidence gates.

# After-task report: marker-scan tool availability

## Task goal

Record whether this local machine can produce external marker-scan comparator
or calibrated-threshold evidence for the experimental `gwas()` path.

## Active lenses and spawned agents

- Active lenses: Ada, Shannon, Jason, Fisher, Curie, Rose, Grace.
- Spawned agents: none.
- Current lane: R validation / comparator status.

## Files changed

- `docs/dev-log/comparator-runs/2026-06-21-marker-scan-tool-availability.md`
- `docs/dev-log/comparator-runs/README.md`
- `docs/dev-log/issue-map.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`

## Checks run and outcomes

- `for x in plink plink2 gemma gcta64 gcta bolt-lmm saige step1_fitNULLGLMM.R step2_SPAtests.R; do ...; done`
  found all probed executables missing.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e 'pkgs <- c("GenABEL", "qvalue", "sommer", "rrBLUP", "GAPIT", "SNPRelate", "GWASTools", "SKAT", "BGLR", "AGHmatrix"); ...'`
  found `sommer` 4.4.3 installed and all other probed packages missing.
- `gh issue view 23 --repo itchyshin/hsquared --json title,body,state,url`
  confirmed R #23 remains open.
- `gh issue view 48 --repo itchyshin/HSquared.jl --json title,body,state,url`
  confirmed Julia #48 remains open.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e 'pkgdown::check_pkgdown()'`
  clean.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla /Users/z3437171/shinichi-brain/tools/check-after-task.R docs/dev-log/after-task/2026-06-21-marker-scan-tool-availability.md`
  clean.
- `git diff --check` clean.

## Public claim audit

Clean. This is a blocker report, not evidence. It says this host lacks the
external scan tools and R packages needed to run the marker-scan comparator /
threshold work locally. It does not imply any result agreement.

No calibrated threshold, formula-level `marker_scan()`, fit-level/map-annotated
QTL/GWAS/eQTL table workflow, external comparator evidence, or covered promotion
is claimed.

## Tests of the tests

The probe is deliberately simple and reproducible: command-line tools are
checked with `command -v`, and R packages are checked with `requireNamespace()`
plus `packageVersion()` where available. The result is a local availability
snapshot, not a statistical test.

## Coordination notes

R #23 and Julia #48 both remain open. The local machine can continue with
R-side contracts, payload shape, and documentation slices, but cannot itself
produce PLINK/GEMMA/GCTA/SAIGE/GenABEL/qvalue-style threshold/comparator
evidence today.

## What did not go smoothly

No command failed unexpectedly. The useful finding is negative: this host does
not have the external scan tooling needed for the next threshold/comparator
evidence leg.

## Known limitations

The probe is local to this machine and current PATH/R library state. Another
host with PLINK, GEMMA, GCTA, SAIGE, GenABEL, qvalue, or equivalent reviewed
tools could still run the comparator protocol.

`sommer` 4.4.3 is installed, but that alone is not a marker-scan threshold
comparator. A future `sommer`-derived scan would still need to show the same
background model, test statistic, marker panel, p-value scale, and threshold
estimand.

## Next actions

- Run a same-result scan fixture on a host with an accepted external scan tool.
- Record the result with `docs/dev-log/comparator-runs/TEMPLATE.md`.
- Keep #48 as the threshold evidence gate until negative-control,
  positive-control, comparator, and calibration evidence are reviewed.

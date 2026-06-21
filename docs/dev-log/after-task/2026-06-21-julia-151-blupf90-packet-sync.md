# After-task report — Julia #151 BLUPF90 packet sync

Date: 2026-06-21

Branch: `codex/julia-151-blupf90-packet-sync`

Active lenses: Ada, Shannon, Jason, Fisher, Curie, Rose, Grace

## Scope

Mirrored HSquared.jl PR #151 (`c25bcc1`) into the R-side validation ledgers after
the Julia lane hardened the BLUPF90/AIREMLF90 multivariate starter packet.

The mirror records that the Julia packet now emits:

- numeric BLUPF90-ready multivariate data (`trait1 trait2 intercept x animal_code`);
- integer-coded pedigree rows (`animal_code sire_code dam_code`);
- `animal_id_map.csv` for output alignment;
- matching RENUMF90 records.

## Evidence

- `gh pr view 151 --repo itchyshin/HSquared.jl --json number,state,mergeCommit,statusCheckRollup,url,title,mergedAt,body`
  showed PR #151 merged at `c25bcc1`.
- Julia checks were green before and after merge according to the sync: local
  packet generation/preflight/full tests/docs/after-task/diff checks, PR CI and
  Documenter, and post-merge main CI and Documenter.
- Live R issue #10 was updated to include the #151 packet contract as setup
  evidence only.
- `docs/dev-log/issue-map.md`, `docs/dev-log/check-log.md`, and
  `docs/dev-log/coordination-board.md` were updated.

## Checks

- `air format .`
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e 'pkgdown::check_pkgdown()'`
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla /Users/z3437171/shinichi-brain/tools/check-after-task.R docs/dev-log/after-task/2026-06-21-julia-151-blupf90-packet-sync.md`
- `git diff --check`

## Boundary

Issue/docs sync only. No R or Julia behavior changed. No BLUPF90-family
executable was run; no aligned comparator estimates, second same-estimand
comparator evidence, validation/public-claim promotion, or covered status change
is claimed. V4-MV-REML remains partial.

## Rose audit

Clean. The sync improves future executable-backed BLUPF90/AIREMLF90 readiness,
but it is still setup evidence. The second-comparator gate remains open.

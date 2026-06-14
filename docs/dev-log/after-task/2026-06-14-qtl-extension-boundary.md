# QTL/GWAS/eQTL Extension Boundary

Date: 2026-06-14

## Task goal

Decide and record whether QTL/GWAS/eQTL machinery belongs in `hsquared` core or
optional future extensions before the core API gets crowded.

## Active lenses and spawned agents

Active lenses: Ada, Shannon, Jason, Pat, Rose, Grace.

Spawned agents: none.

Current lane: coordinator/docs.

## Files created or changed

- `docs/design/15-qtl-extension-boundary.md`: new boundary decision note.
- `docs/design/05-roadmap.md`: Phase 5 pointer to the boundary note.
- `docs/design/11-next-50-slices.md`: marked row 38 done.
- `docs/dev-log/check-log.md`: recorded command evidence.
- `docs/dev-log/coordination-board.md`: added this slice row.
- `docs/dev-log/after-task/2026-06-14-qtl-extension-boundary.md`: this report.

## Checks run and exact outcomes

- `git diff --check`: passed.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "pkgdown::check_pkgdown()"`: passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::check(document = FALSE, args = '--no-manual')"`: passed, 0 errors
  / 0 warnings / 0 notes.
- Remote checks for previous commit `1dfbaa0` were green: R-CMD-check
  `27504816062`, pkgdown `27504816046`, Pages `27504863586`.

## Public claim audit

Rose verdict: clean.

The note states that `hsquaredQTL` and `HSquaredQTL.jl` are proposed future
extension names only; neither exists. It keeps core claims to formula/status/
result vocabulary and the current SNP-BLUP marker-effect output, while routing
heavy scans, file-backed data, plotting, fine-mapping, and accelerator/HPC scan
kernels to optional future extensions.

## Tests of the tests

This is a design/docs slice. `pkgdown::check_pkgdown()` confirms no site
registration issue was introduced, and `devtools::check()` rebuilt the package
and ran tests from the built tarball.

## Coordination notes

This closes next-50 row 38. Julia still owns scan kernels. Any future R scan
syntax must dispatch to a validated engine target or to an installed extension
explicitly; no silent unvalidated fallback.

## What did not go smoothly

No implementation blocker.

## Known limitations

No extension package was created. No scan API, scan engine, scan plot, or
result-table producer was added.

## Next actions

- Commit and push.
- Watch R-CMD-check, pkgdown, and Pages for the pushed commit.
- Next R-safe bite: inheritance-systems roadmap examples with hard fences, or
  keep waiting for Julia scan/structured covariance kernels before surfacing
  more executable API.

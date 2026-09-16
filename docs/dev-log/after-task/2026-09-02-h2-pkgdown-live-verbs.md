# After-task — Boole item 8 + Pat item 5: pkgdown first screen

**Date:** 2026-09-02
**Lane:** R (`hsquared`) — campaign worktree
`~/local-scratch/lanes/hsquared-h2-twin-20260901`, branch
`claude/lane-h2-twin-20260901`.
**Active lenses:** Emmy (R package architect). Boole + Pat as the
advice sources (`h2-boole-emmy-ultracode-2026-09-02.md` item 8;
`h2-pat-ux-ultracode-2026-09-02.md` item 5).
**Spawned subagents:** none
**Current lane:** R docs / pkgdown YAML only

**Fence held:** `public_covered_count` **5** · no `validation_status()`
row · draft #141 · no G10 · no merge-to-main claim.

---

## Task goal

Make the pkgdown reference and navbar look like the live animal-model
package, not a finished genomic / G-matrix suite.

## Files changed

- `_pkgdown.yml` — Start here is live verbs only; reserved syntax and
  reserved extractors last; Status navbar drops genomic / G-matrix /
  QTL; those articles move to Developer.
- this report + `docs/dev-log/check-log.d/2026-09-02-h2-pkgdown-live-verbs.md`

Did not edit `R/hsquared.R` or `man/hsquared.Rd`. Coordination board
not edited (shared file; not on this lease).

## Checks run and exact outcomes

- `Rscript -e 'pkgdown::check_pkgdown()'` → **No problems found**.

## Public claim audit

YAML grouping only. No capability-status, validation-debt, or
`validation_status()` edit. Reserved markers stay exported. Specialist
pages stay on the site under Developer, not deleted.

## Tests of the tests

None. `check_pkgdown()` is the contract for this slice.

## Coordination notes

Lease: `_pkgdown.yml`, `docs/dev-log/check-log.d/`,
`docs/dev-log/after-task/`.
`R/hsquared.R` is held by `cursor:hsquared:grace-ascii-141` — refused
when claimed. Sibling dirty files (`DESCRIPTION`, `R/formula-status.R`,
`R/hs_control.R`, tests) were left unstaged.

Foreign Codex v0.7 performance lane remains live — not touched.

## What did not go smoothly

Short `?hsquared` (Pat item 5) is the easy half of this slice only if
`R/hsquared.R` is free. It was not. Left the long genomic / Laplace /
Willham lead paragraph in place rather than hand-edit generated Rd.

## Known limitations

- Live github.io still serves `main`, not this branch.
- `?hsquared` still opens as an audit paragraph.
- Status dropdown no longer lists genomic / G-matrix / QTL; those pages
  are under Developer until the routes are covered.

## Next actions

When Grace releases `R/hsquared.R`, shorten `?hsquared` to the
univariate Gaussian animal model and move genomic / non-Gaussian /
Willham to `@details`. Keep the fence.

# After-task — Pat leftover: shrink noisy attach

**Date:** 2026-09-02
**Lane:** R (`hsquared`) — campaign worktree
`~/local-scratch/lanes/hsquared-h2-twin-20260901`, branch
`claude/lane-h2-twin-20260901`.
**Active lenses:** Pat (applied-user walk). Boole leftover 7 as the
advice source. Ada/Shannon/Rose as perspectives.
**Spawned subagents:** none
**Current lane:** R attach message only

**Fence held:** `public_covered_count` **5** · no `validation_status()` row ·
draft #141 · no G10 · no merge-to-main claim.

---

## Task goal

Finish the remaining Pat/Boole first-screen leftover: shrink `.onAttach`
if it was still a ledger paragraph. Shorten `?hsquared` only if Grace
did not hold `R/hsquared.R`.

## Files changed

- `R/zzz.R` — two short lines plus the current-limits URL. Same honesty
  tokens (experimental, 0.5.0, Julia, validate, Can I fit and report
  this?, not `validation_status()`, not coverage-calibrated). ASCII only.
- `tests/testthat/test-d41-experimental-honesty.R` — length cap so the
  paragraph cannot grow back.
- this report + `docs/dev-log/check-log.d/2026-09-02-h2-pat-attach-shrink.md`
- `docs/dev-log/coordination-board.md` (one row)

Did not edit `R/hsquared.R` or `man/hsquared.Rd`.

## Checks run and exact outcomes

- `devtools::test(filter = "d41-experimental-honesty")` → **FAIL 0 / WARN 0
  / SKIP 0 / PASS 35**.
- `devtools::document()` not run: `zzz.R` has no roxygen; a document pass
  would rewrite dirty sibling Rd files.

## Public claim audit

Wording only. No capability-status, validation-debt, or
`validation_status()` edit. Attach still points at the limits article,
not at `validation_status()` as the user list.

## Tests of the tests

Existing D-41 matches still require experimental / 0.5.0 / Julia /
validate / `validation_status` / coverage-calibrated / Can I fit and
report this / current-limits, and still forbid the old sole-authority
wording, `vignette(`, `not a complete list`, and `random_regression`.
The new `nchar < 400` cap fails if the ledger paragraph returns.

## Coordination notes

Lease: `cursor:hsquared:pat-attach-leftover` on `R/zzz.R` and the
honesty test. `R/hsquared.R` is held by `cursor:hsquared:grace-ascii-141`
— refused for the `?hsquared` half. Sibling dirty `man/*.Rd` files were
left unstaged.

Foreign Codex v0.7 performance lane remains live — not touched.

## What did not go smoothly

`?hsquared` is still the genomic / Laplace / Willham lead paragraph.
That is the easy half of Pat item 5 only when Grace releases
`R/hsquared.R`. Waiting would have blocked the attach shrink; the
attach half was free.

## Known limitations

- Attach still names `validation_status()` because tests and Pat item 3
  option B require "not in `validation_status()`".
- `?hsquared` remains an audit page.

## Next actions

When Grace releases `R/hsquared.R`, shorten `?hsquared` to the
univariate Gaussian animal model and move genomic / non-Gaussian /
Willham to `@details`. Keep the fence.

# After-task - 2026-09-24 post-#366 T3 genomic ordinary-call honesty

## 1. Goal

Theme T3 of the post-#366 overnight arc: keep genomic GREML on the
explicit `target = "genomic"` hold, clear the ordinary-call refusal, and
document why default activation stays held, without flipping covered or
bumping version.

## 2. Implemented

Chose **honest hold** (plan default). Default-path `genomic()` now uses
`hs_abort_genomic_default_path()`: names design-44 G5 /
`BOUNDARY_HOLDOUT_FAIL`, prints a pasteable `target = "genomic"` next
call, labels `genomic_variance_ratio`, and states
`public_covered_count stays 7`. `formula_status()` genomic rows, the
current-limits three-line version, capability-status, NEWS, and the
generated capability ledger mirror the same hold. No silent ordinary
route; no Julia twin edit required.

## 3a. Decisions and Rejected Alternatives

Rejected silent ordinary-route genomic activation and any covered flip.
Activation remains an owner science ticket (sealed holdout runtime fail
still blocks design-44 G5).

## 4. Files Touched

`R/conditions.R`, `R/hsquared.R`, `R/formula-status.R`,
`tests/testthat/test-genomic.R`, `vignettes/articles/current-limits.Rmd`,
`vignettes/articles/includes/capability-ledger-summary.md`,
`tools/write-capability-ledger-summary.R`,
`docs/design/capability-status.md`, `NEWS.md`, this after-task,
`docs/dev-log/check-log.d/2026-09-24-post366-t3-genomic-ordinary.md`,
coordination-board row.

## 5. Checks Run

- Focused `test-genomic.R`: **PASS** (125 pass / 0 fail / 4 live skips).
- `test-capability-ledger-summary.R` + `test-phase0-api.R`: **PASS**.
- Version **0.9.0**; `public_covered_count` **7** unchanged.

## 6. Tests of the Tests

The prior default-path assertion only matched generic
`"experimental and opt-in"` copy. The new assertions fail if the
pasteable next call, hold reason, or count fence is dropped.

## 7a. Issue Ledger

No new issue. Ordinary activation remains ASK / owner science ticket.

## 8. Consistency Audit

Explicit genomic GREML stays covered at validation scale; ordinary call
refuses; count 7; experimental 0.9.0. FA/SS, MV+PE (#237), loglik #365,
and cran-comments were not touched.

## 9. What Did Not Go Smoothly

Ledger include needed a second writer pass after the tool source edit
(first write raced ahead of the saved scope string).

## 10. Next Action

Draft PR on `cursor/post366-t3-genomic-ordinary`; merge-when-green.
Append T3 to overnight handoff.

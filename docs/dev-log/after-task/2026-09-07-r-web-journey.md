# After-task — 2026-09-07 R web journey

## 1. Goal

Make the R documentation site a route for applied readers while preserving exact
current/historical evidence boundaries.

## 2. Implemented

Added the five-stage journey, a bounded progression page, a 78-entry disposition
receipt (71 reader sources plus seven intentional generated routes), route-specific
interval wording, and current R/Julia boundary fences. Added CI cleanup for
pkgdown's duplicate article subtree.
The final validation-evidence follow-up separates evidence scope from route
controls without changing a capability status.

## 3a. Decisions and Rejected Alternatives

Used `directional-conservative` only for named default univariate-pedigree
methods; rejected a generic interval-reporting permission because no method has
nominal coverage calibration. Kept website work draft-only; no release, count,
or capability promotion was made.

## 4. Files Touched

Reader sources: `README.md`, `_pkgdown.yml`, `pkgdown/extra.css`, the listed
article Rmd files, and `vignettes/articles/progression-evidence.Rmd`.
Evidence surfaces: generator/include, their tests, page disposition TSV, pkgdown
workflow, and this check/after-task record.

## 5. Checks Run

See `docs/dev-log/check-log.d/2026-09-07-r-web-journey.md`: targeted tests 101
pass; generator identity and diff check passed; a bounded default fit and static
link audit passed. The renderer follow-up passed 16 route/viewport checks with
the candidate stylesheet; all tracked SVGs are XML-valid. The final
route/evidence prose regression was red then green (65 pass) and rendered only
the affected article; see `docs/dev-log/check-log.d/2026-09-07-r-validation-evidence-prose.md`.
At the exact candidate head `09b679f7588a5dc67e337131863c71c080eaa590`, the
package check (run `34146698142`) and documentation workflow (run `34146694025`)
were successful; documentation deployment was skipped. The final R browser
receipt passed 588 route/viewport checks. See
`docs/dev-log/check-log.d/2026-09-07-r-web-closeout.md` for the dated
cross-review and head-boundary receipt.

## 6. Tests of the Tests

The generator tests assert exactly one directional interval state, pin the named
methods, and reject its appearance on SNP-BLUP and multivariate cards.

## 7a. Issue Ledger

Fixed: stale current 0.7/count-six wording; ambiguous FA denominator; stale
GREML partial wording; blanket interval denial; broken relative article links;
private scratch path comment; duplicate pkgdown article subtree; invalid
G-matrix SVG; and 404/reference/mobile-math horizontal overflows. Deferred:
the draft PR remains unmerged and undeployed. The 588-route browser crawl,
independent claims recheck, technical verification, and usability recheck all
passed at `09b679f`; this report-only follow-up requires its own CI refresh and
does not inherit that commit's CI result.

## 8. Consistency Audit

Reviewed 71 reader sources plus seven intentional generated routes.
Historical counts remain historical; current count is seven. Operational pages
are hidden during rendering and omitted from the public route receipt.

## 9. What Did Not Go Smoothly

Sandboxed pkgdown could not access R cache/CRAN metadata; elevated local render
was required. pkgdown generated a duplicate article subtree, so the workflow now
removes it before artifact upload. The first Julia example attempt was blocked by
manifest-cache permission and succeeded on authorized retry. pkgdown HTML uses
the production absolute stylesheet even when served from localhost, so the
rendered repair probe explicitly routed the candidate local stylesheet.

## 10. Known Residuals

The candidate was pushed by the coordinator using the verified administrator SSH
remote and remains draft PR #198; there was no merge or deployment. The exact
candidate head `09b679f` has successful package and documentation workflows
(documentation deploy skipped), a passing 588-route local browser receipt, Sol
claims CLEAN, independent technical verification PASS, and Terra usability PASS.
This report-only commit is newer than those exact-head checks, so the coordinator
must push it and refresh CI before treating the draft's current head as green.

## 11. Team Learning

Reader-facing generated summaries need claim-level tests, not only a binary
permission enum. A package's current route status must distinguish default R,
opt-in R, and engine-only evidence.

## 12. Cross-Product Coverage

The interval wording covers ✓ the default univariate pedigree h2
delta/profile/bootstrap and sigma-a2 profile/bootstrap methods. It does NOT
cover ✗ nominal calibration, sigma-a2 delta/Wald, genomic intervals,
multivariate intervals, or any route not named in its evidence record. The
reader journey covers ✓ navigation and public article ordering; it does NOT
cover ✗ a deployment, release, count change, or scientific promotion.
This closeout does NOT cover a new CI result for its own report-only commit;
the package and documentation workflows must be refreshed after the coordinator
pushes that commit.

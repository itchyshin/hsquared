# After-task — 2026-09-07 R web journey

## 1. Goal

Make the R documentation site a route for applied readers while preserving exact
current/historical evidence boundaries.

## 2. Implemented

Added the five-stage journey, a bounded progression page, a 78-entry page
disposition receipt, route-specific interval wording, and current R/Julia
boundary fences. Added CI cleanup for pkgdown's duplicate article subtree.

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
the candidate stylesheet; all tracked SVGs are XML-valid.

## 6. Tests of the Tests

The generator tests assert exactly one directional interval state, pin the named
methods, and reject its appearance on SNP-BLUP and multivariate cards.

## 7a. Issue Ledger

Fixed: stale current 0.7/count-six wording; ambiguous FA denominator; stale
GREML partial wording; blanket interval denial; broken relative article links;
private scratch path comment; duplicate pkgdown article subtree; invalid
G-matrix SVG; and 404/reference/mobile-math horizontal overflows. Deferred:
coordinator's full browser crawl, CI draft-PR verification, and independent
final claims review.

## 8. Consistency Audit

Reviewed 69 canonical R sources plus nine intentional new/generated routes.
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

The isolated website commit is local because the push/draft-PR action was denied
by the external-action safety gate. Browser/device acceptance and CI on that
commit remain coordinator gates.

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

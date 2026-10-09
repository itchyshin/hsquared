## 1. Goal

Address Konstanze Lauseker's 8 October CRAN review and prepare a truthful R-only
hsquared 0.9.0 resubmission. This report is a preparation checkpoint, not a
submission or acceptance receipt.

## 2. Implemented

Replaced all three examplesIf FALSE blocks with ordinary runnable examples of
extracting synthetic result objects. The examples say explicitly that no model
was fitted. Shortened DESCRIPTION to implemented Gaussian pedigree functionality,
restricted the AI-REML attribution to the univariate model, and retained the
uncalibrated-interval warning and reporting-limits article. Updated three legacy
metadata assertions and added executable documentation regression checks.

## 3a. Decisions and Rejected Alternatives

Started from the exact prior submitted source, 0cdfb783, not current main, whose
later features would broaden the release. Kept version 0.9.0, count 7, scientific
limitations and Julia registry status unchanged. Rejected hiding examples under
a different false condition, adding features to satisfy a metadata review, and
claiming that partial or planned public routes are fully developed. The proposed
CRAN reply describes implemented scope and leaves acceptance to CRAN.

## 4. Files Touched

- DESCRIPTION
- R/extractors.R
- man/multivariate_extractors.Rd
- man/random_regression_extractors.Rd
- man/direct_maternal_extractors.Rd
- tests/testthat/test-d41-experimental-honesty.R
- tests/testthat/test-hs-control-targets.R
- tests/testthat/test-c1-ext-h1-h3-harness.R
- cran-comments.md
- docs/dev-log/after-task/2026-10-08-cran-examples-scope-repair.md
- docs/dev-log/check-log.md
- docs/dev-log/coordination-board.md

Roxygen briefly normalized NAMESPACE formatting; that unrelated formatting change
was reverted. Rose's graph query refreshed ignored graph files, not release code.

## 5. Checks Run

All 49 example files completed without Julia. Focused metadata and target tests
passed before the full check. The first provisional full check exposed one stale
DESCRIPTION assertion: 2642 passed, one failed, 166 skipped and five test warnings.
That assertion was corrected to check the actual interval warning.

The superseded candidate was built from clean source bb966a4. SHA-256:
54c4c8a1aac00e058f7e1076179bcb067cf6ce09cc5fc46d8a83dbca22baf0b1.
Size: 919162 bytes; inventory: 278 entries. Root docs, graph, development tools,
simulation campaigns and cran-comments.md are absent. The intended installed
inst/tools recovery script remains present. Its check passed tests, but the
candidate was invalidated when Pat found a synthetic random-coefficient shape
inconsistent with the help contract. Corrected that to id/coefficient/value,
clarified trajectory return types and softened the negative-correlation wording.
All three focused test files passed after those corrections. A new clean source
and artifact must be frozen and checked with --as-cran --run-donttest and normal
Suggests requirements before any upload.

## 6. Tests of the Tests

The initial random-regression example failed on a three-column covariance against
a two-column basis; correcting the documented example to two coefficients made
it run. The new regression checks parse and execute each of the three Rd example
blocks and reject if(FALSE). A planted if(FALSE) string is required to fail that
assertion. The full check also caught the legacy release-count assertion.

## 7a. Issue Ledger

The disabled examples and DESCRIPTION roadmap narrative are repaired. The
package-wide maturity assurance requested by CRAN is not asserted: planned and
partial routes remain documented. Windows results, source/tag closure and
action-time submission approval remain open.

## 8. Consistency Audit

Searched R and man for every disabled example of this class. Checked all tests
that read DESCRIPTION, generated help, actual extractor payload shapes, copyright
holders, exclusions and the public count safeguards. No numerical implementation
changed. Actual subagents: Rose for scope, Grace for release hygiene, and Pat for
reader experience. Their independent final readiness decisions remain pending.

## 9. What Did Not Go Smoothly

The default Dropbox checkout was dirty and on an unrelated branch. Used a fresh
isolated worktree instead. Sandbox DNS prevented the initial incoming feasibility
check; a network-authorized rerun reached the normal CRAN checks. Roxygen 8.0.0
was older than the recorded 8.1.0 and changed import formatting; reverted that
unrelated change. An early check command ran before build completion and produced
no useful evidence. Only completed checks count.

## 10. Known Residuals

No resubmission, confirmation, tag movement, main merge, Julia change or registry
action occurred. The candidate is on codex/cran-090-examples-review-20261008, not
main. Current main contains post-release work; the branch-first release exception
and tag movement need explicit resolution. The final check and Windows evidence
are still pending. CRAN may reject retained experimental labels even with an
honest current-scope explanation. The comments file is not upload-ready yet.

## 11. Team Learning

Memory receipt: recalled the prior submitted source and R-only constraints;
ran lane preflight, claimed narrow ownership, used the hsquared route manifest,
and applied the exact-artifact CRAN release gate. Memory does not establish
current readiness. The repository and actual logs do.

Golden Set: no statistical implementation changed. The disabled-example failure
class has a local executable regression and planted negative control; the
release gate still prevents partial checks from becoming submission claims.

Prose assessment: 2/10 perceived AI-like style, moderate confidence; entire report
and current comments draft self-reviewed. Factual and scientific gates are limited
to recorded checks and scope audit. The retained method citation is unchanged;
no new literature claim is introduced. Slop checker is required before handoff.

## 12. Cross-Product Coverage

Covers: R metadata and three extractor documentation examples, ordinary Julia-free
example execution, and honest interval warnings. This repair does NOT cover new
models, fit validation, interval calibration, main's newer features, changed public
coverage, Julia code, Julia registration, or CRAN acceptance.

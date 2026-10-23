## 1. Goal

Harden the bounded FA R-to-Julia bridge by carrying uniqueness identification limits and validating trait and pedigree-ID result order, without widening the opt-in capability.

## 2. Implemented

The R multivariate bridge now reads FA rank, uniqueness values, and the
`not_assessed_by_fit` uniqueness-status marker from Julia's
`structured_genetic_payload` at pinned Julia candidate `a7ca8ed557b23ec23c8486365e97a7bac4b71c16`.
The result normalizer preserves that marker in `fit_diagnostics()` and rejects
FA results with missing or reordered trait, breeding-trait, or pedigree-ID
metadata. Synthetic negative-control cases cover missing and unsupported
status values, each missing order field, and each reordered label vector.

Updated two stale test expectations to match current documentation: FA remains
a bounded experimental opt-in and the R formula grammar remains planned. The
R capability row remains partial and `public_covered_count` remains seven.

## 3a. Decisions and Rejected Alternatives

Used the structured Julia payload as the source of FA uniqueness metadata
because the fitter result itself does not carry the identification-status
contract. Required order metadata specifically for FA results, whose trait
indexed covariance and breeding values must stay aligned; retained existing
fallback behavior for other multivariate result shapes. Did not add a new
public argument, change `cov = fa()` grammar, or claim uniqueness is identified.

## 4. Files Touched

- `R/julia-bridge.R`
- `tests/testthat/test-fa-optin.R`
- `tests/testthat/test-bridge-engine-status-crosslinks.R`
- `tests/testthat/test-package-help-honesty.R`
- `docs/dev-log/after-task/2026-09-27-fa-payload-order-status.md`
- `docs/dev-log/check-log.md` is not yet updated because another lane currently holds that path.
- `docs/dev-log/coordination-board.md` is not yet updated because preflight found conflicting branch work on that shared file.

## 5. Checks Run

Passed on the final code diff:

- `devtools::test(filter = "fa-optin|bridge-engine-status-crosslinks|package-help-honesty")`: 103 passed, 0 failed, 0 warnings, 0 skipped, with live Julia FA enabled.
- `devtools::test()` with `HSQUARED_JULIA_TESTS=true`: 4,126 passed, 0 failed, 26 warnings, 6 skipped. Warnings include existing live-route and comparator messages.
- `rcmdcheck::rcmdcheck(".", args = "--no-manual", error_on = "never")`: Status OK, 0 errors, 0 warnings, 0 notes. The check itself also emitted environment messages for `sysctl` and `quarto -V` after its successful result.
- `pkgdown::check_pkgdown()`: no problems found.
- `devtools::document()`: completed with the installed roxygen2 8.0.0 versus required 8.1.0 notice. It only reformatted `NAMESPACE`; that unrelated formatting diff was restored.
- `bash tools/preamble_cap.sh`: CAP OK.
- `git diff --check`: clean before writing this report.
- `lintr::lint_package()`: completed with style and object-usage warnings across the existing package; it also flags long lines and indentation in the new bridge checks. No package-wide lint cleanup was attempted.
- GitHub API access failed, so CI state for this uncommitted R diff is unverified. No release, tag, or submission action occurred.

## 6. Tests of the Tests

The FA normalizer tests feed deliberately malformed engine payloads: absent or
unknown identification status, each omitted order label field, and reversed
trait, breeding-trait, or pedigree-ID vectors. Each case asserts the specific
refusal, so deleting the corresponding guard would make its negative-control
assertion fail. No production source was deliberately mutated.

## 7a. Issue Ledger

Fixed: uniqueness-status loss at the R-Julia boundary; silent acceptance of
misordered or absent FA order metadata; stale test expectations for already
changed partial-FA documentation.

Deferred: exact-candidate check-log and coordination-board updates until the
active file lease clears; exact-head CI; FA start-dependence and same-model
comparator work tracked in the larger A2 gate.

## 8. Consistency Audit

Checked the R package-help wording, the FA bridge contract, the capability and
validation-debt rows, the live FA result path, `fit_diagnostics()`, and the
Julia structured payload at the exact candidate commit. Hopper signed off the
bridge mapping; Curie signed off the validation design; Rose's exact-candidate
claim audit is clean with limitations. The two FA documentation tests retain
partial status and covered count seven.

## 9. What Did Not Go Smoothly

The first full-suite run exposed a stale package-help assertion and an earlier
run without a writable Julia cache. Updated the stale expectation, set a
writable temporary depot, and reran successfully. The installed Air formatter
rewrote hundreds of unrelated lines in legacy files; discarded that churn and
kept the existing file style. A second Codex lane holds overlapping bridge and
check-log paths, so no check-log edit, commit, or push was made. The shared
coordination-board path also has conflicting ref work, so it was left untouched.

## 10. Known Residuals

This slice does not establish local identifiability or reliable estimation of
FA uniqueness, routine-start recovery, broad calibration, an independent
same-model comparator, or general FA usability. The R route remains fixed rank
one, four Gaussian traits, pedigree relationship, complete responses, trait
intercepts, and estimated unstructured residual covariance. `cov = fa()` and
raw-loading inference remain unavailable. The broader GLLVM, source-review,
and final CI gates remain open. This report and current source diff have not
been committed because of the active overlapping lane claim.

## 11. Team Learning

Memory receipt: loaded the hsquared LOAD-FIRST manifest, R package engineer and
validation-harness guidance, lane-preflight rules, and the after-task protocol.
The R-to-Julia contract boundary and preflight's one-owner rule shaped this
slice.

Golden Set: reviewed `partial-arc-negative-space` and `completion-overclaim`;
kept the scope and incomplete gates explicit. No transcript classifier run.

## 12. Cross-Product Coverage

Covers: result status propagation and trait/ID order refusal for the bounded
Gaussian FA opt-in against Julia candidate `a7ca8ed5`.

Does NOT cover: `cov = fa()` grammar, automatic rank selection, raw loadings,
new trait families, missing or unbalanced responses, FA inference or broad
calibration, GLLVM expansion, Julia whole-source review, GPU execution, CI for
this diff, or any release submission/tag.

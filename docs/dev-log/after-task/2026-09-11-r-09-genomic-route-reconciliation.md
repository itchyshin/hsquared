# After-task — 2026-09-11 R 0.9 genomic-route reconciliation

## 1. Goal

Reconcile the isolated R 0.9.0 candidate with the programme boundary that
defers default genomic activation: retain covered genomic GREML only through
its explicit Julia target, synchronize public records, and produce a fresh
unsubmitted artifact for independent review.

## 2. Implemented

At `d15bbafce151878890c68928f11389d4a4a6cf4e`, `engine = "fit"` no longer
silently dispatches a `genomic()` primary and `engine = "julia"` without an
explicit target no longer selects genomic GREML. The explicit
`target = "genomic"` route retains its existing validation-scale covered
claim; the count remains 7. R source, generated help, capability records,
reader articles, NEWS, and the generated capability summary now agree.

The PATH_ONLY interval smoke writer was also brought to the 0.9.0 candidate
number, and the package-help assertion now tolerates roxygen line wrapping
while preserving its semantic claim.

## 3a. Decisions and Rejected Alternatives

Applied the active 0.9 scope: default genomic and single-step activation stay
deferred. Rejected retaining the signed historical auto-route, silently
mapping an ordinary genomic call to the explicit target, changing its
estimand/fixture/evidence, increasing the covered count, or treating a green
package check as release authorization.

## 4. Files Touched

The commit changes R dispatch and its obsolete warn-once helper, the genomic
regression tests, generated package help, release-facing prose, capability and
bridge-fence records, the generated reader ledger, the PATH_ONLY version field,
and the two affected honesty tests. See `git show --stat d15bbaf` for the
complete 22-file list.

## 5. Checks Run

- Focused genomic tests: **PASS**, 220 passes / 0 failures / 5 explicit
  live-Julia skips.
- Focused stale-record repairs: **PASS**, 47 passes / 0 failures.
- Full `devtools::test(stop_on_failure = TRUE)`: **PASS**, 2,867 passes /
  0 failures / 0 warnings / 75 explicit skips; wall time 177.3 seconds.
- `pkgdown::check_pkgdown()`: **PASS**.
- Fresh `R CMD build` and direct
  `R CMD check --as-cran --run-donttest`: **PASS** with only the expected
  `New submission` NOTE.
- Fresh retained archive:
  `/private/tmp/hsq09-r-090-current/hsquared_0.9.0.tar.gz`, SHA-256
  `8bc86b6a371ddaff8a38c519c69586179d2997b3988cd54349d72aeabea7bfca`.
- Unlazy ledger: **10/10 met**, including a fresh 900-second-capped rerun of
  the full suite and the archive-hash gate.

## 6. Tests of the Tests

The new default-route test was first run against the old implementation and
failed because it attempted a default genomic bridge fit rather than returning
the required opt-in error. It passes only after that dispatch branch is
removed. The full-suite gate initially failed at the checker’s inherited
120-second cap despite a direct 177.3-second green run; after its declared
timeout was set to 900 seconds, the checker reran the suite and passed.

## 7a. Issue Ledger

No issue was opened or closed. The historical default-route record is retained
and explicitly marked superseded for 0.9. The earlier archive remains retained
as superseded evidence; it is not used for this head.

## 8. Consistency Audit

The current source says: default univariate animal plus default t=2
multivariate are the ordinary routes; genomic GREML is explicit; single-step
is opt-in partial; count is 7; the package is experimental 0.9.0 candidate and
not submitted to CRAN. Non-Gaussian language remains Laplace marginal
likelihood/variational ELBO, not non-Gaussian REML. The R source worktree is
isolated; the dirty Dropbox checkout was not edited.

## 9. What Did Not Go Smoothly

Two stale release-adjacent checks surfaced only under the full suite: the
PATH_ONLY TSV still wrote 0.8.0, and an Rd assertion assumed a particular
roxygen line wrap. Both were corrected with focused regressions. The first
Unlazy full-suite rerun was falsely timed out by a 120-second default; the
measured suite needs the declared 900-second cap.

## 10. Known Residuals

The R suite has 75 explicit skips because its candidate has no configured
HSquared.jl project path for the live bridge. Those skips are not parity
evidence. Independent review of the exact fresh R artifact and Julia candidate
is still required before any Gate B action. No CRAN submission, merge, tag,
registry action, or publication occurred.

## 11. Team Learning

Rose artifact review remains valuable even when the source looks synchronized:
generated help and archived artifacts can preserve an older public contract.
For slow package suites, Unlazy’s timeout is part of the oracle identity and
must be declared from a measured run before re-verification.

## 12. Cross-Product Coverage

This closes the isolated R default-genomic-route reconciliation, R source/help
and reader-record agreement, local R checks, and a fresh R archive. It does NOT cover live R-to-Julia parity for this candidate, new scientific evidence,
S10/S11 compute, coverage calibration, capability promotion, external CI,
merge, tag, registry, CRAN submission, publication, or the separate DRM-style
0.9.x hardening campaign.

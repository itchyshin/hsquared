# After-task — 2026-09-08 A4-1 Binomial observation scale (R)

## 1. Goal

Close the maintainer-approved A4-1 R half of the 0.9 three-field contract:
surface a numerically integrated Binomial-logit observation-scale h2 for
Bernoulli and common-trial Binomial inputs, while retaining a loud, non-scalar
varying-trial outcome. This report records the isolated candidate only; it
does not authorize any release action.

## 2. Implemented

At R candidate `82df320ec60391341191994facb34058eed56710`, atop the A4-1
contract commit `354f6bdff67de6f45c8a9730e6e8a31b33a557cd`, the versioned
normalizer accepts a finite [0, 1] logit observation-scale h2 for Bernoulli,
scalar-trial, and common-vector-trial inputs. A heterogeneous trial vector
instead requires literal `NaN` and
`h2_observation_undefined_reason = "varying_trials_no_scalar_estimand"`.
The added live bridge test exercises all three cases against the paired Julia
candidate.

## 3a. Decisions and Rejected Alternatives

Applied the maintainer's A4-1 decision. Rejected retaining the former
all-Binomial `not_yet_ratified` sentinel, silently averaging heterogeneous
trial counts into a scalar, widening the family/estimand contract, changing
the legacy normalizer, or treating this implementation as calibration or
release evidence.

## 4. Files Touched

The A4-1 source slice changed the versioned normalizer/control documentation,
the targeted non-Gaussian tests, generated help, and existing experimental
status/design prose in commits `354f6bd` and `82df320`. The post-closure
regression repair changes only the stale binomial-count test contract, its
adjacent internal explanatory comment, and this evidence record:

- `R/julia-bridge.R` (comment-only)
- `tests/testthat/test-binomial-counts.R`
- `docs/dev-log/after-task/2026-09-08-a4-binomial-observation-scale.md`
- `docs/dev-log/check-log.md`

## 5. Checks Run

- Focused R normalizer test
  `devtools::test(filter = "nongaussian-three-field-v09", reporter = "summary")`:
  **PASS**; it covers finite defined cells and the varying-trial sentinel.
- Broader non-Gaussian R test path: **PASS** at the A4-1 candidate.
- Configured live R-to-Julia exact-candidate parent check: **104 passing
  expectations**, **PASS**. It verifies finite common-trial and Bernoulli
  fields and the heterogeneous-trial sentinel through the paired Julia
  candidate; it is not a coverage or calibration run.
- Post-closure live `binomial-counts` regression: **42 passing expectations,
  0 failures**, **PASS**. It repairs six stale A3 expectations to assert the
  three structural variance components, all three common-trial fields, and the
  varying-trial `NaN` plus exact sentinel.
- A4-1 Unlazy leaf re-verification: **4/4 gates met** (focused wire semantics,
  R-facing wording, configured live Binomial bridge, and the repaired
  `binomial-counts` regression).
- Normal full `devtools::test()` under explicit CRAN-safe routing
  (`NOT_CRAN=false`, `HSQUARED_JULIA_TESTS=false`, empty Julia-project
  overrides, one BLAS/OpenMP thread) — **PASS**, exit 0. The separately focused
  live A4 bridge remains the evidence for the optional Julia path.
- `pkgdown::check_pkgdown()` — **PASS**.
- Full `R CMD check --no-manual` with unavailable optional Suggests disabled
  (`_R_CHECK_FORCE_SUGGESTS_=false`) — **0 errors / 0 warnings / 0 notes**;
  package installation, examples, tests, and vignette rebuild all passed. A
  strict local check still reports the unavailable optional `pedigreemm`
  before running code, so this is not cross-Suggests release evidence.
- Earlier unconstrained test attempts did not reach a final result inside a
  120-second bounded capture and unexpectedly activated stale Julia session
  state. Their retained stack is not reported as an A4 failure. The associated
  direct 25-seed recovery replay completed in 17.332 seconds (max 0.824 seconds;
  zero errors), confirming that the recovery denominator itself is healthy.
- `git diff --check`: **PASS** at the candidate before this closure record.

## 6. Tests of the Tests

The test suite makes the normalizer reject a defined logit cell that is
missing, non-finite, above one, or accompanied by a reason field. Conversely,
the varying-trial mutation fails unless its observation cell is literal `NaN`
with the exact `varying_trials_no_scalar_estimand` reason. The live test proves
that the R consumer sees the producer distinction rather than only accepting a
hand-built R list.

## 7a. Issue Ledger

No issue was opened or closed. A4-1 closes the contract ambiguity for this
narrow R result shape. Calibration, external same-estimand comparator evidence,
and the 0.9 release decision remain separate gates.

## 8. Consistency Audit

The result remains an explicit, experimental, opt-in non-Gaussian route. This
record makes no REML/AI-REML, coverage-calibration, external-comparator,
default-path, capability-promotion, covered-status, version, tag, registry, or
release claim. The R worktree remains isolated; no Dropbox original was
modified.

## 9. What Did Not Go Smoothly

The first live test's all-one count input was classified by the Julia producer
as Bernoulli rather than Binomial. That was a real contract detail, not a test
fluke: the test was repaired to assert the Bernoulli reduction while still
requiring its finite observation-scale h2. The common-trial and genuinely
varying-trial cases remain distinct controls.

The later full-suite regression exposed six stale A3 test expectations: they
treated the three-component result as scalar and expected an obsolete
heritability error. The focused live regression now checks the ratified fields
instead. The full-suite rerun did not finish in the bounded local window, so
its result remains explicitly incomplete rather than silently treated as pass.

## 10. Known Residuals

Varying-trial Binomial deliberately has no scalar observation-scale estimand.
There is no non-Gaussian interval calibration, retained campaign evidence,
external same-estimand pedigree-A comparator, promotion, or release evidence.
The one-seed local timing pre-run above is test-infrastructure measurement, not
claim-bearing compute; no S10/S11, Totoro, or DRAC work was performed.

## 11. Team Learning

Active lenses for the parent A4-1 work were Hopper/Boole for bridge-contract
shape, Fisher/Falconer for the estimand boundary, Curie for tests, and Rose for
claim discipline. This closure owner changed documentation records only and
spawned no child agents. The durable lesson is that an all-one `cbind()` count
input is a Bernoulli reduction at the producer boundary; bridge tests must
assert that classification explicitly.

## 12. Cross-Product Coverage

This closure covers the R normalizer, R-facing contract wording, targeted
mutations, and the paired live R-to-Julia observation-field distinction. It
does not cover heterogeneous-trial scalarization, additional families or
scales, confidence intervals, calibration, external comparator agreement,
campaign compute, a capability/status flip, versioning, tags, registration,
release, or a cross-Suggests / cross-platform completed package check. The
unconstrained stale-session activation is retained for later test-hardening;
the normal CRAN-safe G4 package checks are green.

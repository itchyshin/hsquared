# After-task report — v0.7 genomic recovery-v3 operational R harness

## 1. Goal

Make the prospective D0F/D1 contract executable, resumable, independently
recomputable, and fail-closed before committing exact tools or consuming an
official seed.

## 2. Implemented

- Added the sole public-route R generator/fitter for the frozen
  `hsquared(y ~ genomic(1 | id, markers = M), ...)` call.
- Added independent base-R reconstruction, summary, post-run review,
  adjudication, and final-receipt modes.
- Added a Totoro/DRAC-only launcher with n-ladder and 16-attempt smoke gates,
  RAM-sized concurrency, resumable official/base-R/Julia fan-out, and exact
  phase ordering.
- Duplicated the compute-context guard inside every non-selftest R/Julia entry
  point so direct execution cannot bypass D-50 or the DRAC allocation rule.
- Bound D0F to the immutable D0 diagnostics and fixed panel/phenotype split.
- Added tool/provenance, exact-tree, source-identity, mutation, and synthetic
  end-to-end tests.
- Extended the native K/Q hash rule to D0F/D1 after live R/Julia arithmetic
  showed last-bit byte differences inside the frozen numerical tolerance.

## 3a. Decisions and Rejected Alternatives

- Kept exactly one public `hsquared()` call in the official fitter; no direct
  Julia shortcut is an official route.
- Kept Julia-native K/Q hashes exact on the Julia side, marker/ID hashes exact
  in both languages, and base-R K/Q hashes as descriptive provenance. Requiring
  byte-identical cross-language floating-point matrices was rejected because it
  would falsely reject numerically equivalent construction.
- Kept official R runtime/RSS as the scientific performance source; replay
  resource use remains diagnostic.
- Rejected login-node, GitHub Actions, oversubscribed, partial-output, and
  post-hoc-resume execution.
- Did not generate official data, activate routing, change a capability row, or
  change `public_covered_count`.

## 4. Files Touched

- `docs/design/49-v07-genomic-recovery-v3-sample-size-ladder.md`
- `tools/v07_genomic_recovery_v3_preseal.R`
- `tools/v07_genomic_recovery_v3.R`
- `tools/v07_genomic_recovery_v3_recompute.R`
- `tools/run-v07-genomic-recovery-v3.sh`
- four focused test files for preseal, driver, recomputer, and launcher
- this report, the matching check log, and coordination/check-log indexes
- Julia twin replay tool, sidecar, check log, and after-task report

## 5. Checks Run

The official driver, independent recomputer/adjudicator, pure preseal helper,
launcher guard, and Julia replay selftests passed without consuming an official
seed. All four focused R files passed without `_problems`; the full R test suite
completed with no extracted problems. The full Julia `Pkg.test()` suite passed.
Both worktrees pass `git diff --check`. Exact commands and hashes are in the
matching check log.

## 6. Tests of the Tests

Deliberate mutations turn the gates red for route/provenance laundering,
marker or ID drift, changed ridge/scale, D0F source drift, forged fit metadata,
partial or nonregular outputs, login-node/GitHub execution, worker-cap excess,
fewer than 16 missing smoke rows, child-process failure, altered summaries,
duplicate or removed seeds, post-run receipt drift, and an incomplete final
tree. A real last-bit-perturbed K/Q regression proves that native hashes may
differ only while all numerical comparisons stay within `1e-10`.

## 7a. Issue Ledger

| Issue | Disposition |
| --- | --- |
| Official driver and adjudicator absent | Implemented with create-once phase gates. |
| Worker audited another worker's in-flight tree | Whole-tree verification moved to quiescence. |
| DGP RNG contaminated by construction work | Streams isolated and mutation-tested. |
| R/Julia recomputer keys mismatched | Bound to the operational R recomputer and exact D0 helper. |
| Launcher allowed unsafe post-run compute | Added a common Totoro/live-SLURM guard to every compute mode. |
| Direct recompute/replay could bypass the launcher | Added in-tool no-CI and numeric-SLURM guards with mutations. |
| Interrupted recomputation could not resume | Complete pairs skip; missing pairs emit; partial/nonregular pairs stop. |
| Test reporter could exit zero while saving `_problems` | Every run now inspects `_problems` and uses executable negative controls. |
| Cross-language raw K/Q hashes differed | Frozen native-hash provenance plus `1e-10` numerical parity. |
| R 4.5/4.6 generated parity TSV hashes differed | Localized to last-bit quantiles; kept exact tool/schema binding and typed `1e-10` parity. |

## 8. Consistency Audit

The sweep covered the frozen equations, D0 evidence, D0F/D1 manifests, route
grammar, provenance, commit anchors, tool blobs, marker/ID/K/Q construction,
spectral and recovery summaries, performance sourcing, exact trees, launcher
contexts, receipt ordering, capability wording, and the Julia twin. R anchor
`69b0e6f` and Julia anchor `fc9d39d` remain unchanged across their frozen
implementation surfaces.

## 9. What Did Not Go Smoothly

Several ordinary-green versions were not trustworthy: a mutable-tree race,
two cross-twin tool-key mismatches, DGP RNG contamination, reporter-zero false
greens, Bash-3 incompatibilities, incomplete launcher negative controls, and a
scientifically valid R/Julia last-bit hash difference. Independent Hopper,
Grace, Fisher, and Noether reviews found these before any official seed was
spent.

## 10. Known Residuals

- Exact committed tool hashes and reviewer receipts must be minted before D0F
  or D1 generation.
- D0F and D1 have not run; D2-D4 remain conditional on their preregistered
  decisions.
- No recovery, broad robustness, activation, release, capability promotion, or
  count change is claimed.
- The model remains Gaussian REML, sample-frequency VanRaden1, ridge 0.01,
  HWE/no-LD simulation, and validation-scale dense fitting.

## 11. Team Learning

Cryptographic identity and scientific identity are different contracts.
Exact hashes are right for source bytes, marker/ID order, and same-language
replay; independently evaluated floating-point matrices need a frozen numeric
tolerance plus native provenance. Before trusting a green, make every safety
gate go red on purpose and inspect any saved problem corpus.

## 12. Cross-Product Coverage

This slice covers the prospective operational evidence machinery for the held
genomic route. It does NOT cover successful D0F/D1 recovery, broad robustness,
production-scale fitting, default public activation, release, or a new covered
capability. `public_covered_count` remains 5.

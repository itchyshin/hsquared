# After-task report — v0.7 D0F Retry-5 post-preseal tree blocker

## 1. Goal

Close Retry-5 at its immutable one-fit infrastructure endpoint, audit its
admission chronology, and keep all activation and Retry-6 work deferred.

## 2. Implemented

- Classified Retry 5 as `UNADJUDICATED — POST-PRESEAL TREE-VALIDATION
  BLOCKER (ADMISSION CONTRACT NOT PROVEN)` in a hash- and identity-bound
  recovery checkpoint shared by both twins.
- Recorded the immutable Totoro root audit, exact one-fit boundary, retired
  root and seed spaces, admission chronology, allowed claims, and forbidden
  claims.
- Reconciled README, NEWS, formula grammar, capability status, public claims,
  validation debt, the Retry-5/Retry-6 design record, coordination board, and
  check log.
- Preserved every prospective Retry-6 code/test edit without staging,
  rewriting, or attributing it to Retry 5.
- Made no R implementation, fit, simulation, activation, or public-capability
  change.

## 3a. Decisions and Rejected Alternatives

- The one successful fit is diagnostic evidence only. It is not a partial D0F
  result because no corpus lock, recomputation, replay, or adjudication exists.
- The root is retired whole. Salvaging the one row, repairing the tree in
  place, or spending an unused Retry-5 seed was rejected.
- Clean receipts and preseal do not override the post-run admission audit. The
  missing typed gate, vacuous mutation helper, and missing durable preflight
  and batch proof make the first seed a process breach.
- Retry 6 is a fresh prospective arc with disjoint seeds; later repairs cannot
  cure Retry-5 chronology retroactively.

## 4. Files Touched

- `NEWS.md`
- `README.md`
- `docs/design/02-formula-grammar.md`
- `docs/design/06-public-claims-register.md`
- `docs/design/49-v07-genomic-recovery-v3-sample-size-ladder.md`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/after-task/2026-07-15-v07-d0f-retry5-post-preseal-tree-blocker.md`
- `docs/dev-log/check-log.d/2026-07-15-v07-d0f-retry5-post-preseal-tree-blocker.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/recovery-checkpoints/2026-07-15-v07-d0f-retry5-post-preseal-tree-blocker.md`

## 5. Checks Run

- `git status --short --branch` in both twins: closure docs are separable from
  prospective Retry-6 implementation/test edits and the Julia scaffold.
- Exact-head `gh run list` audit: R check run `29414056635`, Julia Documenter
  run `29414054994`, and Julia CI run `29414054941` completed successfully
  before preseal.
- Read-only Totoro file-mode, sidecar, cardinality, and process probes: the
  frozen root is immutable, hash-valid, inactive, and contains exactly one
  phenotype/packet/attempt.
- Sorted-tree digest before and after audit: identical at
  `f97d1c15600307238eef794c80bfc3644715421ee93f0812527f951727cc1b02`.
- Admission chronology review: five prerequisite groups PASS, typed gate RED,
  mutation execution RED/UNKNOWN, and fixed-preflight/review-batch proof
  UNKNOWN.
- Final local closeout checks are recorded in the paired check log after this
  report is validated.

## 6. Tests of the Tests

- The audit required each mutation to fail for its intended typed reason. This
  exposed the wrong do-block helper argument order and unrelated `MethodError`
  pass path.
- Exact-head CI did not run the standalone replay selftest, so CI green was not
  promoted into mutation-proof evidence.
- The remote audit recomputed all primary/sidecar hashes and the whole-tree
  digest before and after inspection; no root bytes or modes changed.
- Missing persisted preflight and batch receipts were classified UNKNOWN, not
  inferred PASS from prose.

## 7a. Issue Ledger

- Fixed: Retry-5 terminal classification and identity; root/seed retirement;
  live-status drift; exact claim boundary; paired checkpoint/check-log evidence.
- Exposed, not retroactively fixed: untyped infrastructure failures, vacuous
  mutation control, missing CI replay selftest, and non-durable preflight and
  review-batch evidence at the deployed head.
- Deferred to Retry 6: runtime-tree projection, typed mutation contract,
  two-worker regression, durable preflight/batch receipts, fresh preseal, and
  any new RNG.

## 8. Consistency Audit

- README, NEWS, formula grammar, capability status, public claims, validation
  debt, design record, coordination board, checkpoint, and check log agree on
  the one-fit stop, admission failure, retired seeds, held activation, and
  count 5.
- The Julia twin's snapshot/roadmap/status/debt/reader surfaces were reconciled
  in the paired closure slice.
- Historical Retry-4 and earlier records remain intact as history.

## 9. What Did Not Go Smoothly

- Runtime validation treated legitimate generated output as foreign input
  after the first fit.
- A fail-closed-looking mutation helper actually accepted an unrelated dispatch
  error; typed-cause review found the defect.
- The fixed preflight left no artifact, and review receipts lacked timing/batch
  fields, so neither claim is durably provable.
- The closeout helper initially routed its new skeleton to the brain checkout;
  it was moved immediately without overwriting an existing file.
- A concurrent Claude process was inspected and found to contain unrelated,
  finished brain work with no repo mutation.

## 10. Known Residuals

- Initial Retry-6 repair commits are now pushed at Julia `d1914951` and R
  `efda17e`; later R implementation/test edits remain uncommitted. The arc must
  still pass its own contract, mutations, exact reviews, clean deploy, durable
  preflight, preseal, and seed-lock before RNG.
- No D0F scientific adjudication exists. D1/D2, activation, merge, release,
  and G10 remain closed; `public_covered_count` remains 5.

## 11. Team Learning

Memory receipt: loaded evidence-first claim fencing, explicit-path staging,
external-state verification, sample-size ladder, and R-public/Julia-engine
boundary guards; repo and remote evidence remained authoritative.

Golden Set: `memory_regression.py --selftest` passed. Completion-overclaim and
external-state cases were applied by withholding contract-clean/recovery claims
and rechecking Totoro directly.

## 12. Cross-Product Coverage

Covers: Retry-5 terminal classification, immutable-root evidence, admission
chronology, root/seed retirement, and cross-twin status reconciliation.

Does NOT cover: a Retry-5 contract-clean claim, D0F recovery or scientific
adjudication, any Retry-6 repair or RNG, D1/D2, activation, capability
promotion, PR merge, release, or G10.

Active review lenses: Ada/Shannon, Hopper/Boole/Emmy, Curie/Fisher/Mrode,
Grace, and Rose. Actual read-only agents: Carver (remote/root audit), Volta
(contract chronology), and Hilbert (dirty-state and closure-boundary audit).

# Arc 1 bridge and evidence checkpoint

## 1. Goal

Prepare a reviewable R–Julia bridge checkpoint and historical evidence handover
for the Saturday discussion.

## 2. Implemented

Added a live no-fit selector and bootstrap refusal regression, a verifier for
the audit-source archive, negative-control tests, and a handover. Preserved
999 of 1,001 exact historical audit files and seven source-pinned outer33
receipts in verified local archives.

## 3a. Decisions and Rejected Alternatives

The existing seed guards remain fail-closed. We did not change the pinned
occurrence rule or delete later records. Assumption: previously approved no-fit
scope remains in force; live fitting and gate campaigns need separate scope.

## 4. Files Touched

`tests/testthat/test-arc1-selector-preflight-live.R` and this directory's
`CHECKPOINT.md`, `HANDOVER.md`, `AFTER-TASK.md`, `verify_seed_archive.py`,
and `test_verify_seed_archive.py`. The ignored acceptance ledger is
`.unlazy/arc1-r-bridge-20261104/GATES.md`. Local archives and guard replay
receipt are identified in `HANDOVER.md`.

## 5. Checks Run

Focused no-fit JuliaCall tests ran under Julia 1.10.12 and 1.12.6 against
Julia `927b8f11`; the source archive verifier reported 999/1001, two gaps.
Eight verifier unit tests passed. The Julia manifest-amendment suite returned
8/9, with the failed positive test retained as a blocker. Exact commands and
identities appear in `CHECKPOINT.md`, the ignored ledger, and the local guard
receipt. Full package checks and fit parity were not run.

## 6. Tests of the Tests

Archive verifier controls reject altered bytes, incorrect candidate pin,
duplicate members, links, traversal, missing members, and duplicate candidate
paths. The guard replay's isolated positive fixture passed; its changed and
duplicated evidence controls rejected invalid inputs. The first added
bootstrap test expected zero records and failed on both Julia versions; it was
corrected to assert the single explicitly not-run record.

## 7a. Issue Ledger

The trial source has five outer33 seed-context mentions against a pinned
single-occurrence rule. A separate outer32 historical seed collision also
fails closed. Public nested uncertainty output can expose `__HSQ_NONE__`;
its intended treatment needs review. No scientific gate status was changed.

## 8. Consistency Audit

Preserved source archive members were compared against the original
candidate's pinned hashes. The result verifier checks unique paths, member
names, hashes, missing-path classification, and regular file types. Both Julia
versions exercised preflight rejection and serialized refusal without fitting.
The initial branch checkpoint and handover distinguish old receipts from the
new R source. Graft used the current worktree graph; the project routing
manifest kept R public claims separate from Julia engine evidence.

## 9. What Did Not Go Smoothly

The source audit initially had four missing versions; two were found in old
source archives. The outer33 receipts alone did not make the current-source
manifest test pass. The unlazy checker correctly rejected stale gate results
after the test command changed. Full historical seed inventory was not
reconstructed.

## 10. Known Residuals

Two original audit files, original v10/v11 R maps, nine original R candidate
paths and the original Arc 1 gate file remain unresolved. The full LOOP bundle
is not shared. Fit tests, full package checks, Julia's version-specific fixture,
and scientific gates remain open. The local evidence ZIP has not been sent.

## 11. Team Learning

A historical receipt can be intact while later tracked text makes a strict
single-occurrence audit fail. Preserve the positive and negative controls, then
review the provenance rule instead of altering records to obtain a pass.
Active lenses: Ada, Shannon, Hopper, Curie, Rose. Three read-only reviewers
were dispatched. Rose independently checked the archive hashes and handover
claims, and identified the replay script's local-path requirement. Memory receipt: the hsquared route and lane preflight governed source identity and ownership.
Golden Set: not run; no hub guard was changed.

## 12. Cross-Product Coverage

Covered here: no-fit R-to-Julia refusal and transport checks on two Julia
versions, archive integrity and bounded evidence accounting. This does NOT cover fitted-model parity, statistical calibration, the complete seed history,
scientific admission, a merge, release, or evidence delivery to Szymek.

The handoff distillation checker did not pass: it requires a vault note for
carried-over findings, while the findings for this task are recorded in the
repository handover. No vault memory was edited. The scientific and evidence
blockers remain visible in that handover.

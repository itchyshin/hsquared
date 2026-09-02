# After-task report — H2 B4 bridge spine phase 1 (A14 + A15 + A16)

One report for three commits that are one slice of work: the R↔Julia bridge
contract surface. Written as a combined report rather than three, because the
three commits share a single claim boundary and a single barrier sign-off.

Commits: `7193e9a` (A14 dashboard ledgers + validator), `07399a9` (A15
`engine="julia"` smoke harness), `3dbf486` (A16 Tier 0 bridge CI contracts),
plus `6a9fa07` (independent re-verification) and the barrier-tail commit closing
conditions C1–C4.

## 1. Goal

Give the bridge a written contract surface: what payload each R target emits,
which route it takes into Julia, what parity evidence exists for it, and where
each claim stops. Dispatcher convergence was explicitly *not* the goal and stays
in Phase 4.

## 2. Implemented

- Three seeded TSV ledgers under `docs/dev-log/dashboard/`: payload schema per
  route, parity smoke status per model cell, and a claim boundary per target.
- A stdlib-only validator, `tools/validate-bridge-dashboard.py`, which enforces
  exact column sets and status enums and refuses a `covered` row whose
  `evidence_url` does not resolve to a real local path.
- A consolidated `engine="julia"` smoke harness, `test-engine-julia-smoke.R`,
  carrying S2 (dense `fit_animal_model` vs default `ai_reml`) and S3 (explicit
  `target = "ai_reml"` must match the default path).
- Tier 0 fixture-first bridge CI contracts that run inside the ordinary
  `R-CMD-check` with no Julia present, plus a disabled Tier 1 stub workflow.

## 3a. Decisions and Rejected Alternatives

- Kept `maternal_genetic` and `direct_maternal` on separate rows throughout.
  They are different targets and collapsing them would be the easiest way to
  overstate the correlated path.
- Rejected demoting `smoke_explicit_julia_dense` to `partial`. The packet
  offered that as the honest fallback if no local Julia run were available; a
  run *was* available, so the number was measured instead and the row keeps
  `covered` with a real tolerance behind it.
- Rejected asserting numeric disagreement between the two estimators. A test
  that fails when optimizers converge together punishes improvement; the
  distinction belongs in the claim boundary and in structural dispatch
  assertions.
- Gave `boundary_doc_status` a vocabulary disjoint from `bridge_status` rather
  than simply renaming the column. Renaming alone would still have left the word
  `covered` in two columns meaning two things.

## 4. Files Touched

`docs/dev-log/dashboard/` (README + three TSVs + `bridge-ci-tier0.md`),
`tools/validate-bridge-dashboard.py`, `tests/testthat/test-engine-julia-smoke.R`,
`tests/testthat/test-bridge-dashboard-contracts.R`,
`tests/testthat/test-bridge-ci-tier0-contracts.R`,
`.github/workflows/bridge-ci-tier0.NOTES.md`,
`.github/workflows/bridge-parity-tier1.stub.yaml`, and the check-log.d shards
for A14, A15, A16 and the barrier tail.

## 5. Checks Run

- `python3 tools/validate-bridge-dashboard.py` → `bridge_dashboard_ok schema_rows=10 parity_smoke_rows=11 boundary_rows=10`, exit 0.
- `devtools::test(filter = "engine-julia-smoke")` → PASS, 24 assertions, run
  **live** with `HSQUARED_JULIA_PROJECT` pointed at the twin worktree; both S2
  and S3 executed rather than skipping.
- `devtools::test(filter = "bridge-dashboard-contracts")` → PASS, 34 assertions.
- `devtools::test(filter = "bridge-ci-tier0-contracts")` → PASS, 20 assertions.

Exact commands and outcomes are in the four `docs/dev-log/check-log.d/` shards
dated 2026-09-01.

## 6. Tests of the Tests

- The validator was run against two deliberately corrupted copies of
  `bridge-boundary.tsv` and rejected both: `boundary_doc_status = covered` (the
  old collided vocabulary) and `bridge_status = covered` on a `no_smoke` row.
  The tree was restored and re-validated clean afterwards.
- The S2 delta was measured before the tolerance was written, not after, so the
  bound is derived from the fixture rather than fitted to a passing run.
- The skip guard was checked in both directions: with `HSQUARED_JULIA_PROJECT`
  the smoke runs live; without it, it skips even though Julia and JuliaCall are
  installed. That is a worktree-naming artifact of the campaign lane, recorded
  in the A15 shard so a future reader does not read the skip as a regression.

## 7a. Issue Ledger

| Issue | Disposition |
| --- | --- |
| S2 tolerance `< 0.5` on a fixture with total variance 1.17 | Resolved. Measured delta, replaced with relative VC / h2 / logLik bounds. |
| S2 asserted the two optimizers must disagree | Resolved. Assertion dropped; intent moved to structural checks and claim text. |
| `bridge-boundary.tsv` carried two status vocabularies | Resolved. Column renamed to `boundary_doc_status` with a disjoint vocabulary and documented in the dashboard README. |
| No after-task report for A14/A15/A16 | Resolved by this report for these three. Campaign-wide gap remains open. |
| Tier 1 CI, `fit_payload_v2` default migration | Deferred by plan; not barrier failures. |

## 8. Consistency Audit

`public_covered_count` is unchanged; `bridge_status` remains a separate axis
from public coverage. No artefact claims that CI exercises live bridge parity —
every live parity row reads `test_status = skipped_guarded`, which is accurate.
The gryphon vignette stays `eval = FALSE`. The payload-v2 schema is recorded as
FREEZE-READY and not RATIFIED, so all dashboard rows are seed rows.

## 9. What Did Not Go Smoothly

The A15 smoke was committed and logged as passing while, in the ordinary
environment, it silently skipped: `hs_default_julia_project()` resolves a
sibling `HSquared.jl` checkout, and the campaign worktree carries a date suffix.
A skip-guarded test that always skips is not evidence, and the first check-log
entry did not say so. It took a separate re-verification session to establish
that the test genuinely runs.

The tolerance problem is the same shape. `vc_finite_delta_documented` was a
tolerance rule asserting that documentation existed elsewhere; nothing anywhere
held a number. Both are cases of a record that looks like evidence without
containing any, which is the failure mode this dashboard exists to prevent.

## 10. Known Residuals

- Bridge parity evidence remains maintainer-local. Tier 0 proves emitter shape
  and ledger consistency, not that R-via-Julia reproduces Julia-direct.
- The measured S2 delta is one run, one fixture, one machine. It is a floor for
  "these paths agree", not a cross-platform envelope.
- Default `ai_reml` and `two_effect` still take legacy dispatch, not
  `fit_payload_v2`.
- README I2 drift (`engine="fit"` vs `engine="julia"` defaults) is recorded as a
  boundary row but the README itself is unchanged; it must be fixed before any
  0.5.0 public claim.
- After-task reports are still missing for A10, A12 and B5-A17.

## 11. Team Learning

A tolerance that no one can fail is not a guard rail, and a test that requires
two estimators to disagree fails on improvement rather than on breakage. Both
passed review repeatedly because they were syntactically assertions. The cheap
countermeasure is the one used here: measure first, then write the bound, and
put the measured number somewhere a later reader can compare against.

Reused vocabulary across columns is the same defect in a ledger. `covered`
meaning "capability is covered" in one column and "row is written down" in
another survived because each column was locally sensible.

## 12. Cross-Product Coverage

- Contract surface covers the payload route table, per-cell parity status, and a
  claim boundary on every row; it does not cover a ratified schema.
- Smoke coverage covers S2 and S3 on the Mrode supplied-variance fixture under a
  local Julia; it does not cover K>=3, `direct_maternal`, or any CI-run live
  bridge.
- CI coverage covers Tier 0 fixture-first contracts with no Julia; Tier 1 exists
  only as a disabled stub.

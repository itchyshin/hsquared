# After-task: 2026-09-24 R↔Julia engine=julia parity at experimental 0.9.0

## 1. Goal

On experimental 0.9.0, every model HSquared.jl can fit is either reachable from
R with `hs_control(engine = "julia", …)` or fails with a named
unsupported-syntax error that names the closest live path. No covered flip.
`public_covered_count` stays 7.

## 2. Implemented

- S1: `docs/design/55-r-julia-engine-julia-parity-09.md` (REACHABLE /
  HONEST-ERROR / SILENT-GAP matrix against R `ebe18ff` and Julia `d1eb566b`).
- S2 (`4ed37d4`): closed SILENT-GAPs for matfree targets and
  `cbind`+`permanent` (#237) with closest-path tips; banked
  `docs/design/56-r-julia-parity-09-error-audit.md` and
  `tests/testthat/test-engine-julia-unsupported-parity.R`.
- S3 (`c392a5a`): skip-guarded
  `tests/testthat/test-engine-julia-parity-smoke.R` (one cell per REACHABLE
  target).
- S4 (`44d5410`): NEWS experimental note + capability-status pointer; no
  promotion language. Julia twin pointer `b68e8dd8` on
  `docs/design/12-bridge-compatibility.md`.
- S5: this report, check-log receipt, board row closed.

## 3a. Decisions and Rejected Alternatives

- D1 held. FA / lowrank stay named planned errors (engine V4-FA is not
  R-public).
- D2 held. Matfree REML stays engine-only; R refuses named `matrix_free`
  targets rather than growing a new fitter.
- D3 held. `cbind`+`permanent` is honest-error quality only; full MV+PE fit
  deferred (#237).
- Did not touch dirty Dropbox checkouts or Codex PRs #202 / #322.
- Did not bump version, flip any capability row to covered, or claim ASReml
  speed.

## 4. Files Touched

R worktree `cursor/r-julia-parity-09-inventory`:

- `docs/design/55-r-julia-engine-julia-parity-09.md` (new)
- `docs/design/56-r-julia-parity-09-error-audit.md` (new)
- `R/julia-bridge.R`, `R/model-spec.R` (error tips)
- `tests/testthat/test-engine-julia-unsupported-parity.R` (new)
- `tests/testthat/test-engine-julia-parity-smoke.R` (new)
- `NEWS.md`, `docs/design/capability-status.md`
- `docs/dev-log/coordination-board.md`, `docs/dev-log/check-log.md`,
  `docs/dev-log/check-log.d/2026-09-24-r-julia-parity-09.md`,
  `docs/dev-log/after-task/2026-09-24-r-julia-parity-09.md`

Julia worktree `cursor/r-julia-parity-09-inventory`:

- `docs/design/12-bridge-compatibility.md` (parity-09 pointer section)

## 5. Checks Run

- Focused unsupported parity:
  `testthat::test_file("tests/testthat/test-engine-julia-unsupported-parity.R")`
  → FAIL 0 | WARN 0 | SKIP 0 | PASS 28
- Focused smoke (Julia twin
  `HSQUARED_JULIA_PACKAGE_PATH=…/HSquared.jl-r-julia-parity-09`,
  `NOT_CRAN=true`, `HSQUARED_JULIA_TESTS=true`):
  `testthat::test_file("tests/testthat/test-engine-julia-parity-smoke.R")`
  → FAIL 0 | WARN 2 | SKIP 3 | PASS 16
  (fixture skips: `single_step_construct`, `metafounder`,
  `metafounder_single_step`; warnings are known bridge SE / repeated-records
  honesty paths, not failures)
- Unlazy `--reverify` leaf-S4: ALL MET (exit 0) after S4 commit
- Version pin: DESCRIPTION 0.9.0; `public_covered_count` stays 7 in
  `R/validation-status.R`

Full `devtools::check()` / CI not required for this docs+smoke inventory arc;
not pushed.

## 6. Tests of the Tests

Unsupported suite asserts named closest-path substrings for D1–D3 surfaces, not
merely that an error is thrown. Smoke names every REACHABLE target from the S1
matrix; three heavy-fixture cells skip with reasons that still count as matrix
coverage rather than silent omission.

## 7. Rose claim-vs-evidence

CLEAN on S4 public docs: parity smoke + named errors; explicit no promotion; no
ASReml speed claim; no covered-flip language; count 7; version 0.9.0.

## 8. Remaining / handoff

- Owner ASK: push `cursor/r-julia-parity-09-inventory` and/or open a draft PR
  (R + optional Julia pointer). No merge from this lane without ask.
- Still deferred: FA R bridge, ordinary SS default, matfree R target, MV+PE
  fit, covered flips, CRAN / General, extractor asymmetry (#236).

## 9. Shannon

Leases claimed serially (S4 then S5 after S0 board release). Dirty Dropbox trees
left untouched. Foreign Codex lanes (#202 R / #322 Julia) not edited.

# After-task: Codecov first coding pass (hsquared only)

## 1. Goal

Bounded first coding pass after Shinichi approved Codecov rollout. Land
real test-coverage collection and one Codecov upload on hsquared CI, then
open a narrow review PR and hand off without waiting on remote CI.

## 2. Implemented

- New ubuntu-only `test-coverage.yaml`: `covr::package_coverage()` →
  Cobertura → `codecov/codecov-action` v7 with `use_oidc: true`.
- `codecov.yml`: one expected upload (`after_n_builds: 1`), informational
  status checks, ignore tests/docs/vignettes.
- R-CMD-check ubuntu+windows shards preserved; comment only, no covr there.
- Dashboard note distinguishing five evidence stages. No README badge.

## 3a. Decisions and Rejected Alternatives

- Rejected adding covr to the R-CMD-check matrix (double-count).
- Rejected `CODECOV_TOKEN` / `GH_TOKEN` as Codecov token; documented OIDC
  with job-scoped `contents: read` + `id-token: write`.
- Rejected a README badge before an accepted commit report.
- Rejected failing PRs on an unknown coverage baseline (informational
  Codecov status).
- Rejected installing Julia in the coverage job (would change the measured
  suite vs default R-CMD-check).
- Did not merge. Main dashboard coverage requires an authorized merge plus
  a `push` run of `test-coverage.yaml` on `main`.

## 4. Files Touched

- `.github/workflows/test-coverage.yaml` (new)
- `.github/workflows/R-CMD-check.yaml` (comment only)
- `codecov.yml` (new)
- `.Rbuildignore`
- `docs/dev-log/dashboard/test-coverage.md` (new)
- `docs/dev-log/dashboard/README.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/check-log.d/2026-11-08-codecov-coverage-oidc.md`
- `docs/dev-log/after-task/2026-11-08-codecov-coverage-oidc.md`

No `R/`, `tests/`, fixtures, NEWS, DESCRIPTION, capability, or validation
ledgers.

## 5. Checks Run

- `python3` PyYAML load of `test-coverage.yaml` + `codecov.yml`:
  `yaml ok` / `oidc+ubuntu+single-upload ok`.
- R-CMD-check matrix still `[ubuntu-latest, windows-latest]`.
- `bash tools/preamble_cap.sh`: CAP OK.
- `bash tools/build_check_log.sh --check`: 98 shards well-formed.
- `git diff --check`: clean.
- `Rscript` / `R`: **ABSENT**. Local covr **NOT_VERIFIED**. No percent
  fabricated.
- `devtools::document()` / `test()` / `check()`: not run (no R; no R
  source change).
- Hosted `test-coverage`, Codecov upload/acceptance, and main dashboard:
  **NOT_VERIFIED** until GitHub Actions and Codecov produce them.

## 6. Tests of the Tests

Did not add or weaken tests. The coverage job re-runs the existing
Julia-absent testthat suite under covr tracing. Live Julia legs skip, as
on default R-CMD-check.

## 7a. Issue Ledger

No GitHub issue for Codecov existed at start. No scientific issue closed.
pigauto / GLLVModels / HSquared.jl untouched.

## 8. Consistency Audit (Rose, perspective)

- Public claims: README/DESCRIPTION/capability-status/validation_status
  unchanged.
- No badge claiming a dashboard.
- Docs state that config ≠ functioning coverage.
- Verdict: **clean-with-limitations** — limitations are the five
  NOT_VERIFIED stages and the missing local R runtime.

## 9. What Did Not Go Smoothly

`graft` CLI is not on PATH in this environment. No R runtime, so no local
coverage percent could be produced without fabricating one.

## 10. Known Residuals

- CI coverage finish, upload executed, accepted commit report, main
  dashboard: all **NOT_VERIFIED**.
- If OIDC upload fails, that is the moment to consider a Codecov GitHub
  App grant. Do not request it speculatively.
- Subsequent CI wakes should report evidence only and ask the coordinator
  before further edits.

## 11. Team Learning

One coverage job, one flag, `after_n_builds: 1`. Keep check shards and
coverage upload on separate workflows so OS matrices cannot double-count.

## 12. Cross-Product Coverage

Covers hsquared GitHub Actions coverage collection/upload config. Does not
cover HSquared.jl, pigauto, GLLVModels, live Julia coverage, scientific
validation coverage, or a Codecov `main` dashboard.

Active lenses: Ada, Shannon, Grace, Rose, Pat
Spawned subagents: none
Current lane: R (CI/coverage/config/docs only)

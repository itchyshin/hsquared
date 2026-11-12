# 2026-11-08 Codecov first coding pass (collection + OIDC upload)

Goal: land real test-coverage collection and one Codecov OIDC upload on
hsquared CI, without touching science, tests, or the R-CMD-check OS shards.

Branch: `cursor/codecov-hsquared-coverage-723d` from `origin/main`
`a76ef3f1` (PR #353 merge). Isolated; no other codecov/coverage branches.

## Commands

```sh
python3 -c 'import yaml,sys; yaml.safe_load(open(".github/workflows/test-coverage.yaml")); yaml.safe_load(open("codecov.yml")); print("yaml ok")'
python3 -c 'import yaml; w=yaml.safe_load(open(".github/workflows/test-coverage.yaml")); j=w["jobs"]["test-coverage"]; assert j["runs-on"]=="ubuntu-latest"; assert "id-token" in str(j["permissions"]); print("oidc+ubuntu ok")'
bash tools/preamble_cap.sh
bash tools/build_check_log.sh --check
git diff --check
command -v Rscript; command -v R
```

## Results

- YAML parse: `yaml ok` / `oidc+ubuntu+single-upload ok` (PyYAML on
  Python 3.12.3). Asserted ubuntu-only job, job-scoped
  `contents:read` + `id-token:write`, `use_oidc: true`, no `token:`
  input, `after_n_builds: 1`, informational Codecov status.
- R-CMD-check matrix still `[ubuntu-latest, windows-latest]`.
- `bash tools/preamble_cap.sh`: CAP OK (AGENTS.md 9203 B / 193 lines;
  CLAUDE.md 2107 B / 37 lines).
- `bash tools/build_check_log.sh --check`: `check-log.d/: all 98 entries
  well-formed`.
- `git diff --check`: clean.
- `Rscript` / `R`: absent. Local `covr::package_coverage()` is
  **NOT_VERIFIED**. No coverage percent is recorded.
- `devtools::document()` / `devtools::test()` / `devtools::check()`: not
  run (no R; no R source change).
- Hosted `test-coverage` and R-CMD-check: **NOT_VERIFIED** at shard write
  time. Watch the PR runs.

## Claim boundary

This is GitHub Actions + Codecov infrastructure. It is not scientific
coverage, not a `validation_status()` change, not a README badge, and not
proof that Codecov accepted a report. Five stages stay distinct: local
covr, CI coverage finish, upload executed, accepted commit report, main
dashboard. Main dashboard needs an authorized merge; this lane does not
merge.

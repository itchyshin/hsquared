# H2 B4 A15 engine=julia smoke harness — 2026-09-01

Scope: add S2/S3 live smokes + dashboard row updates on
`claude/lane-h2-twin-20260901` (scratch worktree). No julia-bridge.R dispatch
changes; no push.

## Maintainer smoke command

```r
devtools::test(filter = "engine-julia-smoke")
```

Requires local Julia + JuliaCall + `HSQUARED_JULIA_PROJECT` (skip-guarded on CI).

## Dashboard validator

```sh
python3 tools/validate-bridge-dashboard.py
```

Outcome: `bridge_dashboard_ok schema_rows=10 parity_smoke_rows=11 boundary_rows=10`

## Scoped smoke tests

```r
devtools::test(filter = "engine-julia-smoke")
```

Outcome (local, `HSQUARED_JULIA_PROJECT` set, `NOT_CRAN=true`): **PASS** (2 tests, 0 failures)

Outcome (CI / no Julia): **SKIP** (2 tests skip-guarded)

## Contract tests (dashboard drift guard)

```r
devtools::test(filter = "bridge-dashboard-contracts")
```

Outcome: **PASS** (3 tests, 0 failures)

## Files touched

- `tests/testthat/test-engine-julia-smoke.R` (new)
- `docs/dev-log/dashboard/bridge-parity-smoke-status.tsv` (+1 row, S2 row updated)
- `docs/dev-log/dashboard/bridge-boundary.tsv` (F8 gryphon vignette + dense boundary)

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

## Independent re-verification (Ada, integrator lane, 2026-09-01T18:0x)

Re-run fresh in a separate session against commit `07399a9`, because a skip-guarded
test that silently always skips is not evidence for the claim above.

```sh
cd ~/local-scratch/lanes/hsquared-h2-twin-20260901
OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 NOT_CRAN=true \
  HSQUARED_JULIA_PROJECT="$HOME/local-scratch/lanes/HSquared.jl-h2-twin-20260901" \
  Rscript -e 'devtools::load_all(quiet=TRUE); devtools::test(filter="engine-julia-smoke", reporter="summary")'
```

Outcome: **PASS, live** — 23 assertions, 0 failures, Julia project genuinely
activated (`Activating project at ~/local-scratch/lanes/HSquared.jl-h2-twin-20260901`).
Both S2 and S3 executed; neither skipped.

Without `HSQUARED_JULIA_PROJECT`, the same command **SKIPS** both tests even though
JuliaCall and `julia` are present. Cause is path resolution, not a bridge failure:
`hs_default_julia_project()` falls back to `dirname(system.file(package="hsquared"))/HSquared.jl`,
which resolves to `~/local-scratch/lanes/HSquared.jl` — the campaign worktree is named
`HSquared.jl-h2-twin-20260901`. A side-by-side checkout resolves; a suffixed worktree
does not. Worktree-naming artifact, not a defect; recorded so a future reader does not
mistake a skip for a bridge regression.

Also re-run at the same commit:

| Command | Outcome |
|---------|---------|
| `devtools::test(filter="bridge-ci-tier0-contracts")` | **PASS** — 20 assertions, 0 failures |
| `devtools::test(filter="bridge-dashboard-contracts")` | **PASS** — 29 assertions, 0 failures |
| `devtools::test(filter="d41-experimental-honesty")` | **PASS** — 7 assertions, 0 failures |
| `python3 tools/validate-bridge-dashboard.py` | **PASS** — `bridge_dashboard_ok schema_rows=10 parity_smoke_rows=11 boundary_rows=10`, exit 0 |

## Measured S2 delta (B4 barrier condition C1, Hopper lane, 2026-09-01)

The row `smoke_explicit_julia_dense` previously carried
`tolerance_rule = vc_finite_delta_documented` — a rule that asserted documentation
existed without ever stating a number. Measured once, live, on the named fixture:

```sh
cd ~/local-scratch/lanes/hsquared-h2-twin-20260901
OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 NOT_CRAN=true \
  HSQUARED_JULIA_PROJECT="$HOME/local-scratch/lanes/HSquared.jl-h2-twin-20260901" \
  Rscript ~/local-scratch/h2-b4-s2-delta-measure.R
```

Fixture: `hs_mrode_supplied_variance_validation_fixture()`, 12 records,
`var(y) = 1.1711363636`.

| Quantity | default `engine="fit"` (ai_reml) | `engine="julia"` dense | delta |
|---|---|---|---|
| sigma_a2 | 1.65347299 | 1.65320732 | abs 2.657e-04, rel 1.607e-04 |
| sigma_e2 | 0.08286976 | 0.08295201 | abs 8.225e-05, rel 9.925e-04 |
| h2 | 0.9522733854 | 0.9522209711 | abs 5.241e-05 |
| logLik | -16.2894106223 | -16.2894106353 | abs 1.299e-08 |

Reading: the two paths land on the same optimum (logLik agrees to 1.3e-08); the
variance components differ by ~1e-4 relative because the likelihood is flat near
that optimum, not because the estimators disagree about the answer. The old
`< 0.5` absolute bound was ~1,900x looser than the observed delta and ~40% of
total phenotypic variance — it would have passed a materially wrong fit.

Bounds now asserted, with roughly 5x (VC), 19x (h2) and 770x (logLik) headroom:
`vc_rel_lt_5e-3_h2_lt_1e-3_loglik_lt_1e-5`. The row stays `parity_status = covered`
because the number now exists; it is **not** demoted to `partial`.

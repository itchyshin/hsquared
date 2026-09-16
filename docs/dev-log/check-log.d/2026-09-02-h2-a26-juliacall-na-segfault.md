# 2026-09-02 — Grace: JuliaCall NA-matrix segfault workaround

**Arc:** A26 follow-up (Grace). Handed from Hopper A26 finding.
**Lane:** R (`hsquared`), Grace lens.
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Branch:** `claude/lane-h2-twin-20260901`. **Not pushed.**

## Problem measured

Under `NOT_CRAN=true` with a live Julia bridge, `test-multivariate.R`
segfaulted (signal 11) inside Rcpp precious-preserve
(`_JuliaCall_juliacall_docall`). Isolated to the former test
*"JuliaCall sends multivariate response NA cells as NaN"*.

Minimal repro (no `hsquared` fitting code), JuliaCall **0.17.6** / R **4.6.0** /
Julia **1.10.0**:

```r
library(JuliaCall); julia_setup(installJulia = FALSE)
Y <- matrix(c(1, 2, 3, NA_real_), 2)
julia_assign("hsq_Y", Y)                 # succeeds
julia_eval("sum(isnan.(hsq_Y))")         # segfault
```

Root cause, measured: JuliaCall delivers R `NA_real_` as Julia **`Missing`**,
not `NaN`. `isnan.(…)` on a `Missing`-bearing array, returned through
`julia_eval`, crashes. Bare `julia_command` + `Int(sum(ismissing.(…)))` is
safe; assigning an R matrix that already contains `NaN` is also safe.
Engine `fit_multivariate_reml` accepts both `missing` and `NaN` as unobserved
trait sentinels, so live fits with NA in `Y` were not the crash path — only the
round-trip `isnan` eval was.

This is **pre-existing** relative to A26 (reproduces without
`test-multivariate-engine-parity.R`). A26b's green record for
`test-multivariate.R` under `NOT_CRAN=true` had **2 live-Julia skips** (bridge
unconfigured), so the live legs were never exercised.

## Workaround landed

1. New internal helper `hs_y_matrix_for_julia(Y)` — R-side `NA → NaN` copy;
   R payload keeps `NA_real_`.
2. Multivariate bridge assign uses the helper:
   `julia_assign("hsq_Y", hs_y_matrix_for_julia(payload$Y))`.
3. Test split:
   - Julia-free: payload keeps NA; assign-copy is NaN (always runs on CRAN).
   - Live: assign NaN copy; count via `julia_command` + `julia_eval` of an
     `Int` scalar (no `julia_eval(sum(isnan.(…)))` on raw-NA assigns).

Claim surface "R NA → Julia NaN marshalling" is now true again because the
bridge converts explicitly; it no longer relies on JuliaCall's default.

## Commands and outcomes

| Command | Result |
|---|---|
| 4-line raw-NA `julia_eval(isnan)` repro | **segfault 11** (confirmed) |
| Same after R-side `NA→NaN` + `julia_eval(isnan)` | **ok** (count = 1) |
| `test_file("test-multivariate.R")` live (`NOT_CRAN=true`, `HSQUARED_JULIA_PROJECT` set) | **PASS / FAIL 0 / SKIP 0** |
| same, CRAN lane (`NOT_CRAN` unset) | **FAIL 0**; live Julia + sommer legs skip as before; Julia-free NA→NaN helper asserts still run |
| `test_file("test-multivariate-engine-parity.R")` live | **PASS 44 / FAIL 0 / SKIP 0** (A26 parity still green) |
| `air format` on touched R files | clean |

## Fence

- No covered flip; R multivariate stays **partial**.
- `public_covered_count` remains **5**.
- No push; no Totoro/DRAC; no G10; no Registrator; no version bump.
- Julia lane untouched by this commit.

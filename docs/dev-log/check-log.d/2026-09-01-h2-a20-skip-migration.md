# check-log — 2026-09-01 h2 A20 live-Julia skip migration

**Arc:** A20 remaining — migrate live suites to `hs_skip_live_julia()`  
**Lane:** `claude/lane-h2-twin-20260901` @ `~/local-scratch/lanes/hsquared-h2-twin-20260901`  
**Launch:** `~/local-scratch/h2-a20-skip-migration-launch.md`  
**Lens:** Emmy (R package architecture)

## Changes

Replaced bare `testthat::skip_on_cran()` with `hs_skip_live_julia()` at live
Julia gates (**33 sites** across 7 files):

| File | Sites |
|------|------:|
| `test-julia-bridge.R` | 10 |
| `test-single-step-construct.R` | 7 |
| `test-plot-data-parity.R` | 6 |
| `test-genomic.R` | 4 |
| `test-snp-blup.R` | 3 |
| `test-multivariate.R` | 2 (live only; sommer comparators keep `skip_on_cran`) |
| `test-single-step.R` | 1 |

Architecture note (Emmy): helper remains testthat-autoload only
(`tests/testthat/helper-julia-skip.R`); not exported. Call sites stay at the
top of each live test before `hs_julia_setup()` / `engine = "julia"`.

## Commands

```sh
cd ~/local-scratch/lanes/hsquared-h2-twin-20260901
NOT_CRAN=true Rscript -e 'devtools::test(filter = "hs-skip-live-julia|julia-bridge|single-step$|single-step-construct|plot-data-parity|genomic$|snp-blup|multivariate")'
```

## Results

| Check | Outcome |
|-------|---------|
| scoped filter above | **FAIL 0 / WARN 0 / SKIP 35 / PASS 333** |
| CRAN-lane predicate smoke (`NOT_CRAN=false`) | skip condition from `hs_skip_live_julia()` |

## Remaining A20 (named)

- Other live suites still on bare `skip_on_cran()` (e.g. validation-fixtures
  leftovers, relmat-precision, gwas, binomial-counts, nongaussian, maternal,
  RR, repeatability, common-env, evolvability, fitted-target, formula-animal,
  diagonal-multivariate).
- Optional drmTMB-style allowlist filter in `tests/testthat.R` — not this slice.
- DESCRIPTION Version → `0.5.0`; cran-comments SHA / win-builder; Julia General
  then CRAN submit (owner).

## Prohibitions held

No push, no CRAN submit, no G10, no covered flips, no Registrator, no S5,
no `validation_status` row adds, no codex v07 README merge.

# check-log — 2026-09-01 h2 A20 skip leftovers

**Arc:** A20 remaining — leftover live-Julia `skip_on_cran` → `hs_skip_live_julia()`  
**Lane:** `claude/lane-h2-twin-20260901` @ `~/local-scratch/lanes/hsquared-h2-twin-20260901`  
**Launch:** `~/local-scratch/h2-a20-skip-leftovers-launch.md`  
**Lens:** Grace (CI/release) following Emmy helper pattern

## Changes

- **26** bare `skip_on_cran()` → `hs_skip_live_julia()` on live Julia suites
  (binomial-counts, common-env, diagonal-multivariate, evolvability,
  fitted-target, formula-animal, gwas×3, maternal, nongaussian×2, RR,
  relmat-precision×5, repeatability, validation-fixtures×5).
- **2** missing gates added: `formula-animal` scale_method live; `direct-maternal` live.
- **Kept bare** `skip_on_cran()` (not live Julia): sommer MV comparators×2;
  pedigreemm; R REML gryphon; DGP pure-R recovery.
- Optional drmTMB `tests/testthat.R` allowlist filter **deferred** (pattern clear;
  curated allowlist not low-risk this slice).

## Commands

```sh
cd ~/local-scratch/lanes/hsquared-h2-twin-20260901
NOT_CRAN=true Rscript -e 'devtools::load_all(".", quiet=TRUE); ...'
# filter: hs-skip-live-julia|formula-animal|direct-maternal|binomial-counts|
#   repeatability|maternal|fitted-target-fixture|diagonal-multivariate|
#   evolvability|common-env|relmat-precision|nongaussian|random-regression|
#   validation-fixtures|gwas|multivariate
```

## Results

| Check | Outcome |
|-------|---------|
| scoped filter above | **FAIL 0 / WARN 0 / SKIP 35 / PASS 704** |
| CRAN-lane predicate smoke (`NOT_CRAN=false`) | skip condition from `hs_skip_live_julia()` |

## Remaining A20

- Optional allowlist filter in `tests/testthat.R`
- DESCRIPTION Version → `0.5.0`; win-builder; Julia General → CRAN submit (owner)

## Prohibitions held

No push, no CRAN submit, no G10, no covered flips, no Registrator, no S5,
no `validation_status` row adds.

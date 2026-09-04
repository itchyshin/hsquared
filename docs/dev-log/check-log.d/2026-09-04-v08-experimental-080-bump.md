# check-log — 2026-09-04 experimental 0.8.0 version bump

**Arc:** experimental number `0.7.0` → `0.8.0` (engine FA + SS pillars already covered)  
**Lane:** `cursor/08-ver-080-r-20260903` @ `~/local-scratch/lanes/hsquared-08-ver-080-20260903`  
**Base:** `origin/main` `8c475703` (SS pointer merge #171)  
**Fence:** number only. No covered flip. `public_covered_count` stays **7**.
Experimental label **retained**. R FA stays **planned**. R SS stays
**opt-in partial**. No tag / CRAN / 1.0.

## Changes

- `DESCRIPTION` — `Version: 0.8.0`; Description experimental 0.8.0; count 7.
- `NEWS.md` — prepend `# hsquared 0.8.0`.
- `.onAttach`, package.R, README, `_pkgdown.yml`, vignette banners.
- Honesty tests + H1/H3 harness pins follow 0.8.0.
- Capability FA planned / SS opt-in-partial live version lines → 0.8.0.
- `inst/CITATION` fallback 0.8.0.
- Board + this file + after-task.

## Commands

```r
# from the worktree
devtools::document()
devtools::test()
pkgdown::check_pkgdown()
```

## Results

| Check | Outcome |
|-------|---------|
| `packageVersion` / DESCRIPTION | **0.8.0** |
| honesty test | **PASS** |
| `devtools::test()` | exit 0; live-Julia skips only |
| `pkgdown::check_pkgdown()` | No problems found |
| `public_covered_count` | **7** |
| R FA / R SS | planned / opt-in partial |

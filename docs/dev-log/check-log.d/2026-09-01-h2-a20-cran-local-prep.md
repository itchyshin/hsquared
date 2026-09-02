# check-log — 2026-09-01 h2 A20 CRAN local gate prep

**Arc:** A20 — hsquared 0.5.0 CRAN **local** prep (no submit, no push)  
**Lane:** `claude/lane-h2-twin-20260901` @ `~/local-scratch/lanes/hsquared-h2-twin-20260901`  
**Sister pattern:** drmTMB `drm_skip_live_julia()` + `cran-comments.md`; gllvmTMB/drmTMB `^cran-comments\.md$` in `.Rbuildignore`

## Changes

- `cran-comments.md` — draft first-submission comments for experimental **0.5.0** (placeholders for tarball SHA / win-builder / R-hub).
- `inst/CITATION` — Manual entry with honest twin-DOI **pending** note (D-23); ASCII-only.
- `tests/testthat/helper-julia-skip.R` — `hs_skip_live_julia()` (drmTMB predicate).
- `tests/testthat/test-hs-skip-live-julia.R` — predicate coverage.
- Wired `hs_skip_live_julia()` into `test-engine-julia-smoke.R`, live
  `hs_julia_setup()` sites in `test-validation-fixtures.R` (5) and
  `test-mrode-validation.R` (1).
- `.Rbuildignore` — `^\.git$` (clears worktree `.git` NOTE) and
  `^cran-comments\.md$` (sister pattern; file stays in git for maintainers).

## Commands

```sh
cd ~/local-scratch/lanes/hsquared-h2-twin-20260901
Rscript -e 'devtools::test(filter = "hs-skip-live-julia")'
Rscript -e 'meta <- as.list(read.dcf("DESCRIPTION")[1,]); print(utils::readCitationFile("inst/CITATION", meta = meta))'
Rscript -e 'devtools::check(document = FALSE, vignettes = FALSE, args = c("--no-manual", "--no-build-vignettes"), error_on = "never")'
_R_CHECK_FORCE_SUGGESTS_=false Rscript -e 'rcmdcheck::rcmdcheck(args = c("--no-manual","--no-build-vignettes","--no-tests","--no-examples"), error_on = "never", env = c("_R_CHECK_FORCE_SUGGESTS_" = "false"))'
```

## Results

| Check | Outcome |
|-------|---------|
| `devtools::test(filter = "hs-skip-live-julia")` | **PASS** 3/0/0 |
| scoped tests `hs-skip\|engine-julia-smoke\|mrode-validation\|d41` | **PASS** FAIL 0 / SKIP 3 / PASS 25 |
| `readCitationFile(inst/CITATION)` | **OK** — twin DOI pending, no invented DOI |
| `devtools::check(... --no-manual --no-build-vignettes)` (pre–cran-comments ignore) | **0 errors, 0 warnings, 1 NOTE** (`cran-comments.md` top-level); **`.git` NOTE gone** |
| `rcmdcheck` after `^cran-comments\.md$` + ASCII CITATION (`--no-tests --no-examples`) | **Status: OK** — 0/0/0 |

DESCRIPTION Version left at `0.1.0.9000` (bump to 0.5.0 is a release-pass action after Julia General).

## Remaining A20 (named)

- Migrate remaining live suites that still use bare `skip_on_cran()` before
  `hs_julia_setup()` / `engine = "julia"` fits (e.g. `test-julia-bridge.R`,
  `test-single-step-construct.R`, `test-plot-data-parity.R`, genomic / SNP-BLUP /
  multivariate live files).
- Optional CRAN-lane allowlist filter in `tests/testthat.R` (drmTMB pattern) —
  larger slice; not required for local gate draft.
- DESCRIPTION Version → `0.5.0`; fill cran-comments SHA / win-builder / R-hub.
- Julia General first (A19 owner ASK); twin DOI deposit; then CRAN submit.

## Prohibitions held

No push, no CRAN submit, no G10 sign, no covered flip, no S5, no Registrator,
no RR k=2 / maternal `validation_status()` rows, no codex v07 README merge.

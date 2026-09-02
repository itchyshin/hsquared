# check-log — 2026-09-01 h2 R CMD check green (A13/A16 test guards)

**Arc:** A17 phase 3 side-finding (touches A13 + A16 tests)
**Lane:** `claude/lane-h2-twin-20260901` @ `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Goal:** `devtools::check()` clean. A 0.5.0 release gate; found while verifying A17 phase 3.

## The defect

Five test failures under `R CMD check`, **zero** under `devtools::test()`:

| Test file | Failures | Cause |
|---|---|---|
| `test-bridge-ci-tier0-contracts.R` (A16) | 3 | reads `docs/dev-log/dashboard/*` |
| `test-realdata-validation-manifest.R` (A13) | 2 | reads `docs/design/real-data-validation-manifest.toml` |

`docs` is in `.Rbuildignore`, so those paths exist in the source tree but not in
the build tarball that `R CMD check` installs from. `devtools::test()` runs
against the source tree and therefore never saw it. **Local `test()` green is not
evidence of `check()` green** — that is the transferable lesson here.

Both were introduced earlier in this same overnight arc (A13 `02d0a31`,
A16 `3dbf486`), so this is a fix inside the lane, not a foreign-lane repair.

## Fix

Skip guards, matching the pattern the live-Julia tests already use:

- `helper-realdata-manifest.R` — `hs_realdata_manifest_path()` no longer uses
  `mustWork = TRUE` (which turned an expected absence into an error); new
  `hs_skip_without_realdata_manifest()` called by both tests.
- `test-bridge-ci-tier0-contracts.R` — new `bridge_tier0_skip_without_docs()`,
  called in the registry test and immediately before the dashboard-doc assertions
  in the canonical-files test. The part of that test which checks
  `tests/testthat/*.R` still runs under `check()`, because those files *are* in
  the tarball.

The contracts still run in full on every source-tree `devtools::test()`, which is
where they are meaningful.

## Commands

```sh
cd ~/local-scratch/lanes/hsquared-h2-twin-20260901
Rscript -e 'devtools::check(document = FALSE, args = c("--no-manual", "--no-build-vignettes"), error_on = "never")'
```

## Results

| Check | Before | After |
|-------|--------|-------|
| `devtools::check()` | **1 ERROR** (5 test failures), 1 NOTE | **0 errors, 0 warnings, 1 NOTE** |
| In-check test tally | `FAIL 5 \| WARN 2 \| SKIP 85 \| PASS 2036` | `FAIL 0` |

The remaining NOTE is pre-existing and environmental: "Found the following hidden
files and directories: `.git`". This lane runs from a `git worktree`, where
`.git` is a file rather than a directory and is not `.Rbuildignore`d. It is not a
code defect; a `^\.git$` entry would silence it, but that touches release
plumbing and belongs with the A20 CRAN gate.

## Claim boundary

- Test-guard change only. No `R/` code, no capability status, no public claim.
- Does **not** make the package CRAN-clean: the `.git` NOTE and the A20 CRAN gate
  items (`cran-comments.md`, `hs_skip_live_julia()`, `inst/CITATION`) remain open.

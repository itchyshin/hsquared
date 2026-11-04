# Arc 1 handover back to Shinichi: R arm

Date: 2026-11-04. Lane: R and Julia, reassigned for this session by Szymek. The full note
lives in HSquared.jl on branch `claude/arc1-handover-merge-main-20261104` (draft PR HSquared.jl#498), at
`docs/dev-log/after-task/2026-11-04-arc1-handover-to-shinichi.md`. This file covers only
what concerns `hsquared`.

## Finding for this repo

The R half of the Arc 1 paired evidence (the v8/v10/v11 source maps in HSquared.jl
`docs/dev-log/after-task/2026-10-24-arc1-r-lineage-comparison.json`) has these parts:

- **base:** hsquared `5efe0ec4` (PR #259, merged as `e82f5c95`, 2026-09-30). 249 of
  274 mapped paths match byte for byte;
- **plus 25 files that no pushed hsquared ref has ever contained:**
  `R/arc1-uncertainty.R`, `R/fa-rank-selection.R`, and edits to `R/hsquared.R`,
  `R/hs_control.R`, `R/julia-bridge.R`, `R/extractors.R`, `R/qg-effects.R`, `NAMESPACE`,
  `.Rbuildignore`, six `man/*.Rd`, the `auto_fa_rank` fixture, and nine
  `tests/testthat/test-arc1-*` / `test-auto-fa-rank-optin.R` / `test-multivariate.R`.

Those 25 files exist only on Shinichi's Mac (isolated R tree or Dropbox checkout).
hsquared `main` has no Arc 1 R code, and this note adds none.

The method is a read-only search with `tools/arc1_r_lineage_git_search.py` (in HSquared.jl,
on the branch above). It SHA-256-hashed every historical blob at each mapped path
across all refs of this repo (`main` @ `82d8d20`, all `origin` branches fetched
2026-11-04).

## What Shinichi should do on the R side

1. Copy the 25-file layer onto a clean clone at `5efe0ec4`. Don't repair the broken
   `.git`. Push it as `handover/arc1-r-layer-<date>`, then rerun the search script and
   expect 274/274.
2. Rebase that branch onto current `main` (156 commits ahead, including #354 and #266). Expect
   conflicts in `R/julia-bridge.R`, `R/hsquared.R`, `R/hs_control.R`, `NAMESPACE`, and
   `tests/testthat/test-multivariate.R`.
3. Merge it only after the Julia Arc 1 engine is on HSquared.jl `main`. Run the usual
   `air format .`, `devtools::document()`, `devtools::test()` (with
   `HSQUARED_REQUIRE_BRIDGE=true`), and `devtools::check()`.
4. Old G6/G7 receipts bind the unpushed identities. The rebased commit is a new
   identity and earns no gate credit until G6/G7 are re-run on it.

Unchanged: `public_covered_count = 7`, v7 HOLD, G2–G8 open, no fits run.

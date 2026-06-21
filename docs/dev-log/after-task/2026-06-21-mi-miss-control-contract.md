# After-task report: `mi()` / `miss_control()` grammar contract

Date: 2026-06-21

Branch: `codex/mi-miss-control-contract`

Active lenses: Ada, Shannon, Boole, Noether, Jason, Pat, Rose, Grace

Spawned subagents: none

Current lane: R formula/design

## Scope

Ratify the M0 planned missing-data grammar for issue #19 without implementing
missing-data fitting.

## What changed

- Added planned missing-response and missing-predictor rows to
  `formula_status()`.
- Updated `docs/design/02-formula-grammar.md` with the planned
  `miss_control()` / `mi()` syntax.
- Converted `docs/design/08-missing-data-plan.md` from proposal wording to a
  ratified planned grammar contract.
- Added a sister-repo scout note recording the `drmTMB`, `gllvmTMB`,
  `DRM.jl`, and `GLLVM.jl` lessons.
- Updated `NEWS.md`, the issue map, coordination board, and check log.

## Accepted syntax

- `missing = miss_control(response = "include")`
- `mi(x)` with `missing = miss_control(predictor = "model")`
- `impute = list(x = x ~ ...)`
- explicit structured terms in the impute RHS, such as
  `animal(1 | id, pedigree = ped)`.

## Deferred syntax

Transformed or interacting `mi()` terms, multiple `mi()` predictors, missing
values inside impute-model predictors, MNAR sensitivity, multiple imputation,
families beyond the first Gaussian missing-predictor slice, and
REML-with-missing-data claims remain deferred.

## Boundary

This is a grammar contract only. The package still does not export `mi()`,
`miss_control()`, `impute_model()`, or `imputed()`. It does not fit missing-data
models, perform FIML, impute missing predictors, mask responses in the likelihood,
or marshal missing-data payloads to `HSquared.jl`.

## Checks

- `air format R/formula-status.R tests/testthat/test-phase0-api.R`
- `Rscript --vanilla -e 'devtools::test(filter = "phase0-api")'`: 106 pass.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'`
- `Rscript --vanilla /Users/z3437171/shinichi-brain/tools/check-after-task.R docs/dev-log/after-task/2026-06-21-mi-miss-control-contract.md`
- `git diff --check`
- Boundary grep over the changed status/design/NEWS/scout/after-task surfaces.

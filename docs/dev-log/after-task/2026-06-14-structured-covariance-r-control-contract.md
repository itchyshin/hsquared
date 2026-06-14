# After-Task Report: Structured Covariance R-Control Contract

Date: 2026-06-14

## Task Goal

Record the first R-side contract for future structured multivariate genetic
covariance controls while keeping the live R package honest: no `cov = diag()`,
`cov = lowrank(K)`, or `cov = fa(K)` formula support is exposed yet.

## Active Lenses And Spawned Agents

- Active lenses: Ada, Shannon, Jason, Boole, Hopper, Kirkpatrick, Rose, Grace,
  Pat.
- Spawned subagents: none.
- Current lane: coordinator/docs.

## Files Changed

- `docs/design/18-structured-covariance-r-control.md`
- `docs/dev-log/scout/2026-06-14-structured-covariance-r-control-scout.md`
- `docs/design/11-next-50-slices.md`
- `docs/design/14-factor-analytic-production-plan.md`
- `docs/design/09-multivariate-plan.md`
- `docs/design/05-roadmap.md`
- `ROADMAP.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-14-structured-covariance-r-control-contract.md`

## Implementation

- Added a design note for a future expert control:

```r
hs_control(
  engine = "julia",
  engine_control = list(
    target = "multivariate",
    genetic_structure = "diagonal"
  )
)
```

- Recorded planned values: `unstructured`, `diagonal`, `lowrank`, and
  `factor_analytic`.
- Kept long-format formula grammar planned:
  `animal(trait | id, pedigree = ped, cov = diag())`,
  `cov = lowrank(K)`, and `cov = fa(K)`.
- Added gates for Julia-main availability, R bridge tests, rank/initial-value
  validation, covariance reconstruction, and rotation/sign metadata.

## Checks Run

- `git status --short --branch` - clean at start, `main` aligned with
  `origin/main`.
- `/opt/homebrew/bin/gh run list --limit 8` - previous sky-blue commit
  `73f5738` green on R-CMD-check, pkgdown, and Pages.
- Read-only twin check in `HSquared.jl`:
  - `origin/main` is still `f9da6bb`.
  - Phase 4B structured covariance commit `86e316f` is not on
    `origin/main`.
  - `HSquared.jl#17` is open, draft, mergeable, and green.
- `git diff --check` - passed.
- Rose claim grep for high-risk structured-covariance claims - matched only
  the scout note's high-risk wording list and this report's description of that
  grep.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "pkgdown::check_pkgdown()"` - passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::check(document = FALSE, args = '--no-manual')"` - passed, 0 errors / 0 warnings / 0 notes.

## Public Claim Audit

Clean. The new wording says planned, contract, or future bridge. It does not say
that R supports structured covariance, factor-analytic G matrices, low-rank G
matrices, or ASReml-style structured multivariate fitting.

## Tests Of The Tests

The Rose grep deliberately included high-risk phrases such as "supports
`cov = fa(K)`" and "fits factor-analytic G matrices"; it found only the scout
note's explicit do-not-say list and the report sentence describing that check.

## Coordination Notes

No Julia files were edited. The twin branch state was checked read-only. R
should only build the actual bridge after the structured covariance branch lands
on Julia `main`.

## What Did Not Go Smoothly

The local sibling grep initially returned noisy generated/SVG output. The
useful evidence was narrowed to the specific gllvmTMB guard sections,
GLLVM.jl low-rank-plus-diagonal code, and HSquared.jl structured covariance
tests/validation rows.

## Known Limitations

- No live R bridge for `genetic_structure`.
- No `cov = diag()`, `cov = lowrank(K)`, or `cov = fa(K)` parser.
- No R test yet for structured covariance result metadata.
- No claim promotion; Julia PR17 remains draft and not on main.

## Next Actions

- Commit and push the design slice.
- Watch R-CMD-check and pkgdown.
- When `HSquared.jl#17` lands on main, build the R bridge starting with
  `genetic_structure = "diagonal"` tests.

# After-Task Report: Trait Ordering Contract

Date: 2026-06-14

## Task Goal

Record the trait-ordering contract that connects current `cbind(...)`
multivariate fits, future `traits(...)` wide-response syntax, future long data,
Julia payloads, extractors, comparator scripts, and plots.

## Active Lenses And Spawned Agents

- Active lenses: Ada, Shannon, Boole, Noether, Hopper, Curie, Rose, Grace.
- Spawned subagents: none.
- Current lane: coordinator/docs.

## Files Changed

- `docs/design/17-trait-ordering-contract.md`
- `docs/dev-log/scout/2026-06-14-trait-ordering-contract-scout.md`
- `docs/design/09-multivariate-plan.md`
- `docs/design/16-wide-response-syntax-plan.md`
- `docs/design/11-next-50-slices.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-14-trait-ordering-contract.md`

## Contract Summary

- Current live rule: `cbind(...)` trait order is left-to-right response-column
  order and flows into `Y`, `trait_names`, covariance matrices, h2 rows, and EBV
  outputs.
- Future wide rule: `traits(...)` order should be left-to-right argument order.
- Future bundle rule: `traits_from(...)` should use matrix column order unless
  a user explicitly supplies an ordering variable.
- Future long rule: factor levels, first appearance, or explicit `trait_order`
  define order.
- Julia payloads must record orientation, `trait_order`, record order, and
  observed-cell indices if any internal transposition occurs.

## Checks Run

- `git diff --check` — passed.
- `rg -n "long data supported|traits\\(\\.\\.\\.\\) supported|trait_order implemented|wide-to-long equivalence tested|comparator validated trait order|supports trait_order|implemented trait_order" docs/design/17-trait-ordering-contract.md docs/dev-log/scout/2026-06-14-trait-ordering-contract-scout.md docs/design/09-multivariate-plan.md docs/design/16-wide-response-syntax-plan.md docs/design/11-next-50-slices.md` — only the scout note's explicit high-risk phrase list matched.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "pkgdown::check_pkgdown()"` — passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0 errors / 0 warnings / 0 notes.
- Previous commit `24ceb9a` remote checks were green:
  - R-CMD-check `27505661085`
  - pkgdown `27505661091`
  - Pages `27505705113`

## Public Claim Audit

Clean with limitations. The note claims only the current `cbind()` ordering
invariant already exercised by tests. It keeps long data, `traits(...)`,
`trait_order`, wide-to-long equivalence, and comparator-validated trait order as
future gates.

## Tests Of The Tests

This was a documentation/design slice. The tests-of-tests were:

- checking the current parser/payload tests before writing the note;
- targeted Rose grep over the changed docs;
- package and pkgdown checks to make sure docs did not break builds.

## Coordination Notes

No Julia files were edited. The note assigns R responsibility for user-facing
order and Julia responsibility for engine orientation/result-name return. It
also gives Rose a clear reason to block comparator evidence if trait order is
not recorded.

## What Did Not Go Smoothly

No blocker. The main design wrinkle is that future GLLVM-style Julia kernels may
prefer traits x records orientation, while current `HSquared.jl` multivariate
animal-model payload uses records x traits. The note resolves this by requiring
orientation metadata and restoring R trait order on output.

## Known Limitations

- The current R code does not yet enforce unique non-empty multivariate trait
  names; the note records that as a future hardening item.
- There is no live long-data multivariate parser.
- There is no live `traits(...)` parser or `trait_order` argument.
- Wide-to-long equivalence is a future validation gate.

## Next Actions

- Commit and push this contract, then watch R-CMD-check and pkgdown.
- Future R hardening slice: add unique non-empty trait-name checks for current
  `cbind(...)` responses.
- Future Julia/R slice: add a deterministic long-vs-wide equivalence fixture
  when long or `traits(...)` syntax is actually reserved or parsed.

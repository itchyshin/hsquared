# After-task report: close R issue #8

Date: 2026-06-21

Branch: `codex/issue-map-close-8`

Active lenses: Ada, Shannon, Emmy, Hopper, Rose, Grace

Spawned subagents: none

Current lane: R coordination/docs

## Scope

Close R issue #8 after hsquared PR #63 banked the requested live
`hs_data()` to `HSquared.HSData` marshalling parity test.

## Live GitHub Action

- Closed issue: <https://github.com/itchyshin/hsquared/issues/8>
- Close reason: PR #63 added a skip-guarded live JuliaCall test that marshals
  phenotype, pedigree, and genotype data-frame components into `HSquared.HSData`
  and checks ID/status parity.

## Files touched

- `docs/dev-log/issue-map.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-21-issue-map-close-8.md`

## Boundary

Issue close only. `hs_data()` remains partial in capability ledgers. No new code,
file-backed storage, genotype parsing, relationship construction, marker scan,
omics/environment model construction, fitting claim, or covered promotion.

## Checks

- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'`
- `git diff --check`
- Boundary grep over the changed docs/check-log/after-task files.

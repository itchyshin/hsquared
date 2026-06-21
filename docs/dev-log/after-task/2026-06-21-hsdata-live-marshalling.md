# After-task report: hs_data live HSData marshalling parity

Date: 2026-06-21

Branch: `codex/hsdata-live-marshalling`

Active lenses: Ada, Shannon, Emmy, Hopper, Pat, Rose, Grace

Spawned subagents: none

Current lane: R bridge/data

## Scope

Add a skip-guarded live JuliaCall parity test for `hs_data()` to
`HSquared.HSData` marshalling.

The test sends R phenotype, pedigree, and genotype data-frame components across
the bridge, constructs `HSquared.HSData`, and checks:

- phenotype IDs are preserved as `a`, `b`, `c`;
- genotype IDs are preserved as `a`, `c`;
- the Julia ID-overlap map records `b` as phenotyped but ungenotyped;
- Julia `data_status()` reports the `phenotypes`, `pedigree`, and `genotypes`
  components.

## Files touched

- `tests/testthat/test-julia-bridge.R`
- `docs/design/capability-status.md`
- `docs/design/06-public-claims-register.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/issue-map.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-21-hsdata-live-marshalling.md`

## Boundary

This is live data-container marshalling parity only. It does not add file-backed
storage, PLINK/VCF parsing, genotype imputation, pedigree inverse or relationship
construction, marker scanning, eQTL/omics modelling, environment-effect model
construction, or fitting.

## Checks

- `HSQUARED_JULIA_PROJECT='/Users/z3437171/Dropbox/Github Local/HSquared.jl' NOT_CRAN=true Rscript --vanilla -e 'devtools::test(filter = "julia-bridge")'`
- `air format .`
- `devtools::document()`
- `devtools::test(filter = "hs-data|julia-bridge|phase0-api")`
- `devtools::test()`
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'`
- `git diff --check`
- Boundary grep over the changed tests/status docs.

# After-task — formula_status single-step bundle shorthand row (2026-06-21)

## Task Goal

Make the existing `single_step(1 | id)` `hs_data()` pedigree+genotype bundle
shorthand visible in `formula_status()` as its own parsed row.

## Active Lenses And Spawned Agents

- Active lenses: Ada, Shannon, Boole, Emmy, Pat, Rose, Grace.
- Spawned agents: none.
- Lane: R formula/status diagnostics.

## Files Changed

- `R/formula-status.R`
- `tests/testthat/test-phase0-api.R`
- `NEWS.md`
- `docs/design/25-single-step-construction-bridge.md`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`

## What Changed

`formula_status()` now has a distinct parsed row:

```text
single_step(1 | id) with data = hs_data(..., pedigree = ped, genotypes = M)
```

Its fitting status is:

```text
fitted (opt-in single-step bundle construction)
```

The row explains that the shorthand resolves pedigree and genotype components
from an `hs_data()` bundle and still requires
`engine_control = list(target = "single_step_construct")`.

## Public Claim Audit

Clean. This is a diagnostic/status surfacing slice only. It does not change
parser behavior, bridge payload behavior, or fitting behavior. It records the
already-live opt-in single-step construction bundle shorthand.

Single-step construction remains experimental, opt-in, REML-only,
dense/validation-scale, and twin-gated for promotion.

## Tests Of The Tests

`test-phase0-api.R` now checks:

- the `formula_status()` row count;
- the exact bundle-shorthand term;
- parsed syntax status;
- opt-in single-step bundle construction fitting status;
- current behavior mentions genotypes and `target = "single_step_construct"`.

## Checks Run

- `air format .` clean.
- `Rscript --vanilla -e 'devtools::document()'` clean.
- `Rscript --vanilla -e 'devtools::test(filter = "phase0-api")'` returned
  103 pass / 0 fail / 0 warn / 0 skip.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean.
- `git diff --check` clean.
- `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'`
  returned 0 errors / 0 warnings / 0 notes.

## What Did Not Go Smoothly

No code issue. The only bookkeeping wrinkle was that the branch had been created
earlier but the local edits were sitting on `main`; they were moved onto
`codex/formula-status-single-step-bundle` before staging.

## Known Limitations

- No new fitting support.
- No new comparator support.
- No promotion of single-step construction beyond partial.

## Next Actions

1. Run remaining checks.
2. Bank as a narrow status/diagnostic PR.
3. Continue with the next bridge/result-surface hardening slice from refreshed
   main.

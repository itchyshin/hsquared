# Validation Status Helper

Date: 2026-06-13

Active lenses: Curie, Fisher, Pat, Rose, Grace.

Spawned subagents: none.

## Scope

Add a small exported `validation_status()` helper so users and developers can
inspect current validation atoms and planned comparator lanes from R. This is a
diagnostic table only. It does not run checks, fit models, or promote any
capability from planned or partial to covered.

## Skill

Used `validation-canon-review` before editing:

- read `docs/design/04-validation-canon.md`;
- read `docs/design/validation-debt-register.md`;
- kept estimator, model, and claim-boundary wording explicit.

## Implementation

Added:

- `R/validation-status.R`;
- exported `validation_status()`;
- `print.hs_validation_status()`;
- tests in `tests/testthat/test-phase0-api.R`;
- roxygen reference page and pkgdown reference-index entry.

Updated:

- README;
- model-status article;
- capability status;
- validation debt register;
- public claims register;
- NEWS;
- coordination board;
- check log.

## Validation

Local checks:

- `air format .`: completed.
- `Rscript -e "devtools::test(filter = 'phase0-api')"`: `56 pass`,
  `0 fail`, `0 warnings`, `0 skips`.
- `Rscript -e "devtools::document()"`: completed; wrote `NAMESPACE` and
  `validation_status.Rd`.
- `Rscript -e "devtools::test()"`: `295 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live bridge activated sibling `HSquared.jl`.
- `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`:
  articles rebuilt and `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors | 0 warnings | 0 notes`.
- `git diff --check`: clean.

Remote checks:

- Commit: `a52337a Add validation status helper`.
- GitHub Actions R-CMD-check `27462165978`: passed in 1m38s.
- GitHub Actions pkgdown `27462165981`: passed in 1m42s.
- GitHub Pages build/deploy `27462200373`: passed. The Pages run reported a
  Node.js 20 deprecation warning from GitHub's action stack, not from package
  code.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- validation status diagnostic helper;
- current validation atoms and planned comparator lanes;
- claim-boundary table.

Blocked wording:

- `validation_status()` runs validation checks;
- `validation_status()` means a capability is covered;
- general animal-model fitting is implemented;
- ASReml, BLUPF90, DMU, WOMBAT, genomic, QTL/eQTL, GLLVM, or GPU validation is
  covered.

## Next Work

1. Add a fitted Mrode animal-model output fixture after the Julia/R target is
   agreed.
2. Consider a future `run_validation_fixture()` only after fixtures need a
   public runner; keep status and execution separate for now.

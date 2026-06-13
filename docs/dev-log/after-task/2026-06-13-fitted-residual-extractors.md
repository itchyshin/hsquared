# Fitted And Residual Extractors

Date: 2026-06-13

Active lenses: Emmy, Pat, Fisher, Rose, Grace.

Spawned subagents: none.

## Scope

Add ordinary R `fitted()` and `residuals()` methods for `hsquared_fit` objects
that already contain normalized fitted-value predictions and stored response
values.

This is extractor ergonomics only. It does not add new model fitting,
variance-component estimation, production sparse fitting, or new validation
coverage.

## Skills

Used:

- `r-package-development`;
- `testing-r-packages`;
- `prose-style-review`;
- `after-task-audit`.

## Implementation

Added:

- `fitted.hsquared_fit()`;
- `residuals.hsquared_fit()`;
- tests for fitted values, residuals, missing response values, missing
  predictions, and response/fitted length mismatch.

Updated:

- NEWS;
- README;
- model-status article;
- v0.1 contract;
- engine contract;
- capability status;
- validation debt register;
- public claims register;
- coordination board;
- check log.

## Validation

Local checks:

- `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'fit-object')"`:
  documentation updated, formatting completed, `39 pass`, `0 fail`,
  `0 warnings`, `0 skips`.
- `Rscript -e "devtools::test()"`: `340 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live Julia bridge activated sibling `HSquared.jl`.
- `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`:
  articles rebuilt and `No problems found.`
- `Rscript -e "devtools::check()"`: first run had a namespace note for
  unqualified internal `predict()` and `fitted()` calls.
- After changing internal calls to `stats::predict()` and `stats::fitted()`:
  `air format . && Rscript -e "devtools::test(filter = 'fit-object')" && Rscript -e "devtools::check()"`
  returned focused tests `39 pass`, `0 fail`, `0 warnings`, `0 skips`, and
  `devtools::check()` `0 errors`, `0 warnings`, `0 notes`.
- `git diff --check`: clean.
- Overclaim scan:
  `rg -n 'fitted\\(\\).*general|residuals\\(\\).*general|residuals.*fit model|fitted.*fit model|general animal-model support|production sparse|ASReml parity|speedup|fast|faster' README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  Hits were planned, blocked, negated, or prior scan/report records.

Remote checks:

- GitHub Actions R-CMD-check `27463241417`: passed in 1m37s for commit
  `09f3135`.
- GitHub Actions pkgdown `27463241406`: passed for commit `09f3135`.
- GitHub Pages build/deploy `27463273446`: passed after pkgdown.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- `fitted()` and `residuals()` work for `hsquared_fit` objects containing the
  needed result and response fields.

Blocked wording:

- general model fitting works;
- residual diagnostics are validated;
- production sparse fitting works;
- comparator validation is covered.

## Next Work

1. Add residual diagnostics only after fitted examples and validation evidence
   exist.
2. Keep extractor wording tied to `hsquared_fit` objects, not default
   `hsquared()` calls.

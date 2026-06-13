# EBV, BLUP, And Accuracy Extractors

Date: 2026-06-13

Active lenses: Emmy, Falconer, Fisher, Pat, Rose, Grace.

Spawned subagents: none.

## Scope

Add applied-user extractor ergonomics for existing `hsquared_fit` objects:

- `EBV()` as an alias for `breeding_values()`;
- `BLUP()` as an alias for `breeding_values()`;
- `accuracy()` as square-root reliability when reliability estimates are
  available.

This is an API usability slice only. It does not add new model fitting,
reliability estimation, comparator validation, or production sparse inference.

## Skills

Used:

- `r-package-development`;
- `testing-r-packages`;
- `prose-style-review`;
- `after-task-audit`.

## Implementation

Added:

- `EBV()` S3 generic/default/`hsquared_fit` method;
- `BLUP()` S3 generic/default/`hsquared_fit` method;
- `accuracy()` S3 generic/default/`hsquared_fit` method;
- tests for aliases, derived accuracy, malformed reliability payloads, and
  out-of-range reliability values.

Updated:

- NAMESPACE;
- `breeding_values.Rd`;
- `reliability.Rd`;
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
  documentation updated, formatting completed, `48 pass`, `0 fail`,
  `0 warnings`, `0 skips`.
- `Rscript -e "devtools::test()"`: `349 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live Julia bridge activated sibling `HSquared.jl`.
- `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`:
  articles rebuilt and `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors`, `0 warnings`, `0 notes`.
- `git diff --check`: clean.
- Overclaim scan:
  `rg -n 'accuracy\\(\\).*validated|accuracy\\(\\).*general|EBV\\(\\).*general|BLUP\\(\\).*general|production accuracy|production sparse|general animal-model support|ASReml parity|speedup|fast|faster' README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  Hits were planned, blocked, negated, or prior scan/report records.

Remote checks:

- Pending until this slice is pushed.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- `EBV()` and `BLUP()` alias `breeding_values()` for `hsquared_fit` objects.
- `accuracy()` derives square-root reliability when reliability estimates are
  present and valid.

Blocked wording:

- accuracy is independently validated;
- reliability estimation is production-ready;
- general animal-model fitting works;
- comparator validation is covered.

## Next Work

1. Add examples after a stable fitted example exists.
2. Keep accuracy tied to reliability evidence and avoid independent validation
   claims until comparator checks exist.

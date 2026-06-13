# hs_data Environment-Key Diagnostics

Date: 2026-06-13

Active lenses: Emmy, Darwin, Pat, Rose, Grace.

Spawned subagents: none.

## Scope

Add environment/covariate metadata diagnostics to `hs_data()` without adding
environmental model terms or changing the R-to-Julia bridge.

This slice supports future multi-environment workflows by letting users supply
an `environment_id` key shared by phenotype records and an `environment` table.

## Skills

Used:

- `r-package-development`;
- `testing-r-packages`;
- `prose-style-review`;
- `after-task-audit`.

## Implementation

Added:

- `environment_id` argument to `hs_data()`;
- `hs_environment_spec` metadata for keyed environment tables;
- `summary(hs_data(...))$environment_status`;
- `data_status(...)$environment_status`;
- print support for environment-status diagnostics.

The environment-status table reports:

- environment rows;
- environment key;
- unique environment IDs in metadata;
- unique phenotype environment IDs;
- phenotype environment IDs with metadata;
- metadata-only environment IDs;
- phenotype environment IDs without metadata;
- duplicate environment IDs in the metadata table.

## Validation

Local checks:

- `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'hs-data')"`:
  documentation updated, formatting completed, `74 pass`, `0 fail`,
  `0 warnings`, `0 skips`.
- `Rscript -e "devtools::test()"`: `368 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live Julia bridge activated sibling `HSquared.jl`.
- `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`:
  articles rebuilt and `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors`, `0 warnings`, `0 notes`.
- `git diff --check`: clean.
- Overclaim scan:
  `rg -n "environment.*model|environment.*fit|multi-environment.*support|environment_id.*fit|environment_id.*model|genomic.*implemented|QTL.*implemented|eQTL.*implemented|GLLVM.*implemented|GPU.*implemented|supports genomic|supports QTL|supports eQTL|ASReml parity|speedup|fast|faster" README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  Hits were planned, blocked, negated, or prior scan/report records.

Remote checks:

- GitHub Actions R-CMD-check `27463896935`: passed in 1m37s.
- GitHub Actions pkgdown `27463896936`: passed in 1m34s.
- GitHub Pages build/deploy `27463935270`: passed; Node.js 20 deprecation
  warning is from the Pages action stack, not this package code.

Issue ledger:

- Issue #8 updated:
  <https://github.com/itchyshin/hsquared/issues/8#issuecomment-4698232188>.

## Rose Audit

Initial verdict: clean with limitations.

Allowed wording:

- `hs_data()` can check environment metadata coverage when `environment_id` is
  supplied.
- `summary()` and `data_status()` report environment-key diagnostics.

Blocked wording:

- environmental model terms are fitted;
- multi-environment animal models are supported;
- environment metadata is automatically joined into model matrices;
- genotype, QTL, eQTL, or GLLVM workflows are implemented.

## Tests Of The Tests

The focused tests cover:

- keyed environment metadata with unmatched phenotype and metadata keys;
- duplicate environment IDs in the metadata table;
- unkeyed environment tables that are present but not key-checked;
- invalid `environment_id` inputs and missing key columns.

## Coordination Notes

R-only slice. No Julia payload or engine API change is required.

## Known Limitations

- `environment_id` must use the same column name in `phenotypes` and
  `environment`.
- Environment metadata is not joined into model frames.
- Environmental random effects and multi-environment model terms remain
  planned.
- No file-backed environment metadata loading exists yet.

## Next Work

1. Consider separate phenotype/environment key names if users need
   `phenotype_environment_id` and `environment_id`.
2. Add environment-term formula grammar only when the model contract and Julia
   engine target are ready.

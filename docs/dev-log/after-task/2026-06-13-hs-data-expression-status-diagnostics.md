# hs_data Expression-Status Diagnostics

Date: 2026-06-13

Active lenses: Emmy, Jason, Pat, Rose, Grace.

Spawned subagents: none.

## Scope

Add expression component diagnostics to `hs_data()` without adding eQTL
fitting, omics models, automatic expression-feature joins, or bridge payload
changes.

This slice supports future eQTL and high-dimensional omics workflows by making
the current expression component shape visible to users and developers.

## Skills

Used:

- `hsquared-rehydrate`;
- `hsquared-team-dispatch`;
- `r-package-development`;
- `testing-r-packages`;
- `rose-pre-public-audit`;
- `after-task-audit`.

## Implementation

Added:

- `summary(hs_data(...))$expression_status`;
- `data_status(...)$expression_status`;
- print support for expression-status diagnostics.

The expression-status table reports:

- expression rows;
- expression IDs;
- expression feature count;
- named expression feature count;
- unnamed expression feature count;
- duplicate named expression feature count;
- expression component type.

## Validation

Local checks:

- `Rscript -e "devtools::document()"`: documentation updated; wrote
  `hs_data.Rd` and `data_status.Rd`.
- `air format . && Rscript -e "devtools::test(filter = 'hs-data')"`:
  formatting completed, `101 pass`, `0 fail`, `0 warnings`, `0 skips`.
- `Rscript -e "devtools::test()"`: `395 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live Julia bridge activated sibling `HSquared.jl`.
- `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`:
  articles rebuilt and `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors`, `0 warnings`, `0 notes`.
- `git diff --check`: clean.
- Overclaim scan:
  `rg -n "expression.*model|expression.*fit|expression_status.*fit|expression_status.*model|eQTL.*implemented|omics.*implemented|automatic.*expression|automatic.*annotation|genomic.*implemented|QTL.*implemented|GLLVM.*implemented|GPU.*implemented|supports eQTL|supports omics|supports QTL|ASReml parity|speedup|fast|faster" README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  Hits were planned, blocked, negated, prior scan/report records, or the
  intended new `without fitting eQTL or omics models` wording.

Remote checks:

- Pending until this slice is pushed.

## Rose Audit

Initial verdict: clean with limitations.

Allowed wording:

- `summary()` and `data_status()` report expression rows, expression IDs,
  feature counts, unnamed feature counts, duplicate feature counts, and
  expression component type.

Blocked wording:

- eQTL models are fitted;
- omics models are fitted;
- expression features are automatically joined into model matrices;
- marker, QTL, GWAS, GLLVM, or GPU workflows are implemented.

## Tests Of The Tests

The focused tests cover:

- data-frame expression inputs with an explicit ID column;
- named expression matrix columns with a duplicate feature ID;
- unnamed expression matrix columns;
- missing expression matrix feature names.

## Coordination Notes

R-only slice. No Julia payload or engine API change is required.

## Known Limitations

- `expression_status` reports in-memory matrix or data-frame shape only.
- It does not inspect file-backed arrays, chunked storage, PLINK/VCF data, or
  sparse expression matrices.
- It does not validate feature annotation; that remains under `annotation_id`.
- eQTL scans, omics models, and GLLVM-style high-dimensional models remain
  planned.

## Next Work

1. Consider a file-backed data-source descriptor after the in-memory data
   contract stabilizes.
2. Mirror the diagnostics in `HSquared.jl` only when the Julia data lane is
   ready and not colliding with current environment/annotation parity work.

# hs_data Annotation-Feature Diagnostics

Date: 2026-06-13

Active lenses: Emmy, Jason, Pat, Rose, Grace.

Spawned subagents: none.

## Scope

Add expression-feature annotation diagnostics to `hs_data()` without adding
eQTL fitting, omics models, or automatic model construction from annotation
metadata.

This slice supports future eQTL and multi-omics workflows by letting users
supply an `annotation_id` key in an `annotation` table and compare it with
expression feature columns.

## Skills

Used:

- `r-package-development`;
- `testing-r-packages`;
- `prose-style-review`;
- `after-task-audit`.

## Implementation

Added:

- `annotation_id` argument to `hs_data()`;
- `hs_annotation_spec` metadata for keyed annotation tables;
- `summary(hs_data(...))$annotation_status`;
- `data_status(...)$annotation_status`;
- print support for annotation-status diagnostics.

The annotation-status table reports:

- annotation rows;
- annotation key;
- unique annotation features;
- unique expression features;
- expression features with annotation metadata;
- annotation-only features;
- expression features without annotation metadata;
- duplicate annotation features in the annotation table.

## Validation

Local checks:

- `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'hs-data')"`:
  documentation updated, formatting completed, `94 pass`, `0 fail`,
  `0 warnings`, `0 skips`.
- `Rscript -e "devtools::test()"`: `388 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live Julia bridge activated sibling `HSquared.jl`.
- `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`:
  articles rebuilt and `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors`, `0 warnings`, `0 notes`.
- `git diff --check`: clean.
- Overclaim scan:
  `rg -n "annotation.*model|annotation.*fit|annotation_id.*fit|annotation_id.*model|eQTL.*implemented|omics.*implemented|expression.*model|expression.*fit|automatic.*annotation|genomic.*implemented|QTL.*implemented|GLLVM.*implemented|GPU.*implemented|supports eQTL|supports omics|supports QTL|ASReml parity|speedup|fast|faster" README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  Hits were planned, blocked, negated, or prior scan/report records.

Remote checks:

- Pending until this slice is pushed.

## Rose Audit

Initial verdict: clean with limitations.

Allowed wording:

- `hs_data()` can check expression-feature annotation coverage when
  `annotation_id` is supplied.
- `summary()` and `data_status()` report annotation-feature diagnostics.

Blocked wording:

- eQTL models are fitted;
- omics models are fitted;
- expression and annotation metadata are automatically joined into model
  matrices;
- marker, QTL, GWAS, GLLVM, or GPU workflows are implemented.

## Tests Of The Tests

The focused tests cover:

- keyed annotation metadata with unmatched expression and annotation features;
- duplicate annotation feature IDs;
- unkeyed annotation tables that are present but not key-checked;
- invalid `annotation_id` inputs and missing feature columns.

## Coordination Notes

R-only slice. No Julia payload or engine API change is required.

## Known Limitations

- `annotation_id` checks annotation rows against expression feature column
  names only.
- Annotation metadata is not joined into model frames.
- eQTL scans, omics models, and GLLVM-style high-dimensional models remain
  planned.
- No file-backed expression or annotation loading exists yet.

## Next Work

1. Consider feature-level storage diagnostics for very wide expression
   matrices.
2. Add file-backed expression/omics loading only after the data-contract API is
   stable.

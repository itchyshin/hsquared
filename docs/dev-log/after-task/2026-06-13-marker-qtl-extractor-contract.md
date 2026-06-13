# Marker/QTL/eQTL Extractor Contract

Date: 2026-06-13

Active lenses: Jason, Fisher, Pat, Rose, Grace.

Spawned subagents: none.

## Scope

Reserve user-facing marker, QTL, GWAS, and eQTL output extractor names while
keeping model fitting honestly planned. This is an R fitted-object contract
slice, not marker-scan, QTL, GWAS, eQTL, or genomic model support.

## Implementation

Added S3 generics and `hsquared_fit` methods for:

- `marker_effects()`;
- `marker_variance_explained()`;
- `qtl_table()`;
- `gwas_table()`;
- `eqtl_table()`;
- `lod_scores()`.

The `hsquared_fit` methods return the matching future result payload field.
The default methods error clearly that the current package reserves the
extractor names but does not fit marker-scan, QTL, GWAS, or eQTL models yet.

Updated:

- tests;
- roxygen docs and NAMESPACE;
- pkgdown reference index;
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

- `air format . && Rscript -e "devtools::test(filter = 'fit-object')"`:
  `32 pass`, `0 fail`, `0 warnings`, `0 skips`.
- `Rscript -e "devtools::document()"`: completed; wrote `NAMESPACE` and
  `marker_extractors.Rd`.
- `Rscript -e "devtools::test()"`: `306 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live bridge activated sibling `HSquared.jl`.
- `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`:
  articles rebuilt and `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors | 0 warnings | 0 notes`.
- `git diff --check`: clean.

Remote checks:

- Pending until this slice is pushed.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- reserved marker/QTL/eQTL extractor names;
- output-vocabulary placeholder;
- future `hsquared_fit` result fields.

Blocked wording:

- marker scanning is implemented;
- QTL, GWAS, or eQTL fitting is implemented;
- genomic models are supported;
- result tables can be generated from real marker models.

## Next Work

1. Add real result payload fields only after a marker/QTL/eQTL engine path
   exists.
2. Add plotting helpers later, after table structures are stable.

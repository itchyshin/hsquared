# Formula Grammar Roadmap Article

Date: 2026-06-13

Active lenses: Pat, Boole, Rose, Grace.

Spawned subagents: none.

## Scope

Add a pkgdown article that makes the formula language understandable to an
applied user while keeping current, partial, and planned support separate.

## Implementation

Added:

- `vignettes/articles/formula-grammar.Rmd`;
- a navbar link under Articles;
- an article-list entry in `_pkgdown.yml`;
- a NEWS entry.

The article covers:

- parsed v0.1 syntax;
- planned standard quantitative-genetic extensions;
- planned inheritance and relationship kernels;
- planned genomic and marker terms;
- planned multivariate and factor-analytic grammar;
- the current error rule for unsupported syntax.

## Validation

Local checks:

- `air format .`: completed.
- `git diff --check`: clean.
- `Rscript -e "pkgdown::check_pkgdown()"`: `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors | 0 warnings | 0 notes`.

Remote checks:

- Pending first push for this article slice.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- the v0.1 syntax is parsed and validates inputs;
- later syntax is planned or reserved;
- planned terms currently error as not implemented.

Blocked wording:

- `hsquared()` fits Phase 2+ models;
- genomic, QTL/eQTL, multivariate, or factor-analytic models are fitted;
- custom relationship or precision matrices are consumed by the engine.

## Next Work

1. Add small screenshots or rendered examples only after real fitted output
   exists.
2. Keep the formula article synchronized with Julia model-spec vocabulary.
3. Once Phase 1 fitting is real, add a worked animal-model vignette with
   validation evidence.

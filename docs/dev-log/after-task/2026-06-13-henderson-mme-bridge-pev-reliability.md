# Henderson MME Bridge PEV/Reliability Parity

Date: 2026-06-13

Active lenses: Hopper, Lovelace, Henderson, Fisher, Rose, Grace.

Spawned subagents: none.

## Scope

Let the supplied-variance Henderson MME bridge target attach dense
validation-path PEV and reliability fields when the local sibling `HSquared.jl`
checkout exposes applicable `prediction_error_variance()` and `reliability()`
methods for `HendersonMMEResult`.

This remains a tiny validation bridge target. It does not estimate variance
components, return a log-likelihood, run AI-REML, validate Mrode fitted outputs,
or claim production sparse reliability.

## Skills

Used:

- `bridge-contract-review`;
- `validation-canon-review`;
- `prose-style-review`;
- `after-task-audit`.

## Implementation

Added:

- an `applicable()`-guarded JuliaCall enrichment step for
  `target = "henderson_mme"`;
- optional PEV/reliability normalization in
  `hs_normalize_julia_henderson_mme_result()`;
- mocked normalizer coverage for optional `prediction_error_variance` and
  `reliability` fields;
- live bridge assertions that run when the local sibling Julia checkout
  actually returns those fields.

Updated:

- README;
- model-status article;
- v0.1 contract;
- engine contract;
- validation canon;
- capability status;
- validation debt register;
- public claims register;
- `validation_status()` wording;
- NEWS;
- coordination board;
- check log.

## Validation

Local checks:

- `air format . && Rscript -e "devtools::test(filter = 'julia-bridge|phase0-api')"`:
  `117 pass`, `0 fail`, `0 warnings`, `0 skips`; live Julia bridge activated
  sibling `HSquared.jl`.
- `Rscript -e "devtools::test()"`: `333 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live Julia bridge activated sibling `HSquared.jl`.
- `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`:
  articles rebuilt and `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors`, `0 warnings`, `0 notes`.
- `git diff --check`: clean.
- Overclaim scan:
  `rg -n 'henderson_mme.*estimate|Henderson MME.*estimate|supplied-variance.*log-likelihood|log-likelihood.*supplied-variance|production sparse reliability.*implemented|general animal-model support|AI-REML is implemented|Mrode fitted-output validation is covered|ASReml parity|fast|faster|speedup' README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  Hits were planned, blocked, negated, or prior scan/report records.

Remote checks:

- GitHub Actions R-CMD-check `27462976668`: passed in 1m29s for commit
  `1489185`.
- GitHub Actions pkgdown `27462976666`: passed for commit `1489185`.
- GitHub Pages build/deploy `27463009993`: passed after pkgdown.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- supplied-variance Henderson MME bridge target;
- optional dense validation-path PEV and reliability when Julia exposes
  applicable extractors;
- tiny local validation examples.

Blocked wording:

- variance components are estimated;
- log-likelihood or AIC is available for this target;
- AI-REML is implemented;
- production sparse reliability is implemented;
- Mrode fitted-output validation is covered;
- general animal-model support is implemented.

## Next Work

1. Keep this wording mirrored with the Julia twin's `HendersonMMEResult`
   extractor docs.
2. Add Mrode fitted-output validation before broadening public fitting claims.

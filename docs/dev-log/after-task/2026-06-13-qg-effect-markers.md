# Planned Standard QG And Inheritance Formula Markers

Date: 2026-06-13

Active lenses: Boole, Jason, Darwin, Emmy, Rose, Pat.

Spawned subagents: none.

## Scope

Reserve readable user-facing formula vocabulary for standard
quantitative-genetic extensions without claiming those models are implemented.

This covers:

- permanent and common-environment effects;
- maternal and paternal genetic/environmental effects;
- cytoplasmic and parent-of-origin/imprinting effects;
- dominance and epistasis relationship terms;
- custom relationship and precision terms.

## Scout Notes

Local sibling lessons:

- `gllvmTMB` keeps animal-relatedness keywords explicit and separates
  relationship matrices `A`/`Ainv` from sampling-variance `V`.
- `drmTMB` records structured-effect markers and status separately, which helps
  avoid fitted/planned confusion.
- `DRM.jl` uses `relmat()` and `animal()` as markers intercepted during formula
  parsing.
- `GLLVM.jl` performance notes support a coherent structured-precision grammar
  for later low-rank and factor-analytic work.

## Implementation

Added inert markers:

- `permanent()`;
- `common_env()`;
- `maternal_genetic()`;
- `maternal_env()`;
- `paternal_genetic()`;
- `paternal_env()`;
- `cytoplasmic()`;
- `imprinting()`;
- `dominance()`;
- `epistasis()`;
- `relmat()`;
- `precision()`.

Updated the parser so these markers fail before model-frame construction with
planned-not-implemented wording. This prevents planned Phase 2+ formula terms
from being evaluated as ordinary fixed effects or silently ignored.

Updated:

- tests;
- roxygen documentation and `NAMESPACE`;
- pkgdown reference index;
- README and NEWS;
- formula grammar;
- public claims register;
- capability status;
- validation debt;
- model-status article;
- coordination board and scout memo.

## Validation

Local checks:

- `air format .`: completed.
- `Rscript -e "devtools::document()"`: regenerated documentation;
  `man/qg_effect_markers.Rd` exists.
- `Rscript -e "devtools::test(filter = 'formula-animal')"`: `33 pass`,
  `0 fail`, `0 warnings`, `0 skips`.
- `Rscript -e "devtools::test()"`: `174 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live bridge activated sibling `HSquared.jl`.
- `git diff --check`: clean.
- `Rscript -e "pkgdown::check_pkgdown()"`: `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors | 0 warnings | 0 notes`.

Remote checks:

- R-CMD-check `27458665520`: passed on commit
  `14e5781 Add planned quantitative genetics markers`.
- pkgdown `27458665528`: passed on commit
  `14e5781 Add planned quantitative genetics markers`.
- GitHub Pages build and deployment `27458695360`: passed.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- the markers reserve planned formula vocabulary;
- the parser rejects these terms as planned, not implemented.

Blocked wording:

- permanent environment or common-environment models fit;
- maternal or paternal effects fit;
- dominance, epistasis, cytoplasmic inheritance, imprinting, or custom-kernel
  models fit;
- relationship or precision matrices are consumed by the engine.

## Tests Of The Tests

The tests check both sides of the guardrail:

- marker functions return invisibly when called as syntax helpers;
- the parser fails with planned-not-implemented errors before evaluating marker
  objects.

## Next Work

1. Ask the Julia twin to mirror these as planned model-spec vocabulary only.
2. Keep the next implementation slice on the v0.1 Gaussian animal model rather
   than jumping straight into Phase 2 fitting.
3. Add real model-spec objects for permanent/common-environment effects only
   after the Julia contract and validation fixtures exist.

## Coordination

The Julia twin should mirror these only as planned model-spec vocabulary until
the Julia engine has real relationship, inheritance, and result contracts.

# Supplied-Variance Henderson MME Validation Fixture

Date: 2026-06-13

Active lenses: Curie, Henderson, Fisher, Hopper, Rose, Grace.

Spawned subagents: none.

## Scope

Add an internal supplied-variance Henderson mixed-model-equation validation
fixture for issue #7. This validates a tiny MME solve and R-Julia agreement at
known variance components. It does not validate variance-component estimation,
AI-REML, a full Mrode fitted example, or production sparse fitting.

## Scout

Checked before editing:

- local `HSquared.jl/src/likelihood.jl`, confirming `henderson_mme()` solves
  fixed effects and animal-effect BLUPs/EBVs at supplied variance components;
- local `GLLVM.jl/CLAUDE.md`, reinforcing one-concern commits and
  verify-before-claim reporting;
- Henderson/Mrode anchors for the relationship inverse and mixed-model-equation
  validation ladder.

Persistent scout note:

- `docs/dev-log/scout/2026-06-13-henderson-mme-validation-scout.md`

## Implementation

Added:

- `hs_henderson_mme_validation_fixture()`;
- `hs_solve_henderson_mme_reference()`;
- R tests for expected `Ainv`, fixed effects, EBVs, fitted values, and h2;
- an optional live Julia bridge test against `HSquared.henderson_mme()`.

The fixture uses a five-animal pedigree with two founders, two full siblings,
and one progeny observed twice. The expected values are pinned from the
independent R MME solve and checked against Julia when the sibling checkout is
available.

## Validation

Local checks:

- `air format .`: completed.
- `Rscript -e "devtools::test(filter = 'validation-fixtures')"`: `19 pass`,
  `0 fail`, `0 warnings`, `0 skips`; live fixture activated sibling
  `HSquared.jl`.
- `Rscript -e "devtools::test()"`: `287 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live bridge activated sibling `HSquared.jl`.
- `Rscript -e "devtools::document()"`: completed.
- `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`:
  articles rebuilt and `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors | 0 warnings | 0 notes`.
- `git diff --check`: clean.

Remote checks:

- Commit: `ec2a9cc Add Henderson MME validation fixture`.
- GitHub Actions R-CMD-check `27461936435`: passed in 1m40s.
- GitHub Actions pkgdown `27461936446`: passed in 1m36s.
- GitHub Pages build/deploy `27461969071`: passed. The Pages run reported a
  Node.js 20 deprecation warning from GitHub's action stack, not from package
  code.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- supplied-variance Henderson MME validation fixture;
- R reference solve matches Julia `henderson_mme()` for fixed effects, EBVs,
  fitted values, and h2 on a tiny fixture.

Blocked wording:

- variance components are estimated;
- general animal-model fitting is implemented;
- Mrode fitted outputs are validated;
- AI-REML or production sparse fitting is validated;
- ASReml, BLUPF90, DMU, or WOMBAT parity is covered.

## Next Work

1. Extend issue #7 from supplied-variance MME to a fitted Mrode-style example
   with recorded estimator target and expected outputs.
2. Keep the Julia twin aligned on `henderson_mme()` result naming and fixture
   status.
3. Do not move any public capability from partial to covered until comparator
   evidence exists.

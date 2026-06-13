# Henderson MME Validation Scout

Date: 2026-06-13

Active lenses: Curie, Henderson, Fisher, Hopper, Rose, Grace.

Spawned subagents: none.

## Question

What should the next validation atom prove after pedigree `Ainv` ordering and
Mrode9 pedigree-inverse comparison?

## Sources Checked

- Local `HSquared.jl/src/likelihood.jl`: `henderson_mme()` solves Henderson's
  mixed-model equations at supplied positive variance components and explicitly
  does not optimize variance components.
- Local `GLLVM.jl/CLAUDE.md`: keep one concern per commit, verify before
  claiming, and use actual pass/fail evidence in reports.
- Henderson's direct inverse work anchors why the relationship precision
  matrix belongs in the equation system rather than as a dense relationship
  matrix inversion step.
- Mrode's animal-breeding-value text anchors the broader MME validation ladder,
  but this slice is not yet a fitted Mrode example.

## hsquared Action

Add an internal five-animal supplied-variance fixture with:

- two founders;
- two full-sibling animals;
- one progeny observed twice;
- fixed intercept and one covariate;
- expected `Ainv`;
- expected fixed effects, EBVs, fitted values, and h2.

The R test first solves the MME independently from the bridge payload, then, when
the sibling Julia package is available, compares the same quantities with
`HSquared.henderson_mme()`.

## Claim Wording Risk

Allowed:

- "supplied-variance Henderson MME validation fixture";
- "R reference solve matches Julia `henderson_mme()` for fixed effects, EBVs,
  fitted values, and h2 on a tiny fixture."

Blocked:

- "variance components are estimated";
- "general animal-model fitting is implemented";
- "Mrode fitted outputs are covered";
- "AI-REML or production sparse fitting is validated";
- "ASReml, BLUPF90, DMU, or WOMBAT parity is covered."

# animal + permanent environment vs ASReml — great tit development check

**2026-09-20. Development evidence only.** ASReml is licence-absent and is
**forbidden as a covered comparator leg**
(`docs/design/52-v07-exact-G-comparator-recipe.md:21`). Nothing here is a
validation claim, nothing here flips a capability row, and
[#138](https://github.com/itchyshin/hsquared/issues/138) stays open.

## Model

ASReml: `fixed = <trait> ~ year_f + round_f + exp_manip + female.age`,
`random = ~ vm(animal, Ainv) + ide(animal)`.

`hsquared`: the same fixed effects plus
`animal(1 | animal) + permanent(1 | animal)`, through
`hs_control(engine = "julia", engine_control = list(target = "repeatability", scale_method = "auto"))`.

`scale_method = "auto"` is **required**, not a tuning choice: the dense
estimator is capped at `nobs² + nanimals² ≤ max_dense_cells` (default 1e6) and
these problems need ~2.6e8 cells.

Pedigree prepared with `nadiv::prepPed()` and pruned to the analysis animals
plus all known ancestors, exactly as the notebook does.

## Results

### Clutch size — 11,856 records, 7,340 females, 10,937 pedigree rows

| component | hsquared | SE | ASReml |
| --- | --- | --- | --- |
| animal (V_A) | 0.59540 | 0.069573 | 0.595 |
| permanent (V_PE) | 0.52523 | 0.067677 | 0.525 |
| residual | 1.37276 | 0.028483 | — |

h² = 0.2388 ± 0.0269, repeatability = 0.4494, converged.

### Laying date — 11,642 records, 7,288 females, 10,914 pedigree rows

| component | hsquared | SE | ASReml |
| --- | --- | --- | --- |
| animal (V_A) | 6.2653 | 0.84325 | 6.27 |
| permanent (V_PE) | 3.0154 | 0.84902 | 3.02 |
| residual | 28.4227 | 0.55635 | — |

h² = 0.1662 ± 0.0218, repeatability = 0.2462, converged.

Both agree with ASReml to the precision the ASReml values were reported at.

## What this replaces

The earlier comparison fitted `animal(1 | animal)` ALONE in `hsquared` against
ASReml's `vm(animal) + ide(animal)`. That is not an estimation discrepancy, it
is two different models: with repeated records and no permanent-environment
term the additive variance absorbs V_PE, so `hsquared` reported a single
`animal = 1.110` ≈ 0.595 + 0.525, and h² was inflated to 0.4353 against the
0.2388 above. `hsquared` now warns when a repeated-measures design is fitted
without a `permanent()` term.

The `SE = NA` in the earlier table was also not an engine result: the notebook
hardcoded `SE = NA_real_` for the `hsquared` rows and never called
`variance_component_standard_errors()` / `heritability_standard_error()`. Both
are fixed in the notebook.

## What this is NOT

- Not a comparator gate, not covered-flip evidence, not a
  `validation_status()` row. ASReml cannot serve as a covered leg.
- One dataset, two traits, one machine, single run. No seeds, no replication,
  no pre-declaration, no MCSE.
- The standard errors are asymptotic and **not** coverage-calibrated; no
  interval coverage was assessed.
- Says nothing about agreement away from this design — no genomic, non-Gaussian,
  multivariate, or unbalanced-by-construction case was compared.

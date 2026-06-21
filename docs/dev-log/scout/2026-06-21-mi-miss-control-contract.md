# `mi()` / `miss_control()` grammar scout

## Question scouted

What should hsquared ratify for the planned model-based missing-data grammar
without activating missing-data fitting?

## Sources checked

- `drmTMB/R/missing-data.R`
- `drmTMB/vignettes/missing-data.Rmd`
- `gllvmTMB/R/missing-predictor.R`
- `gllvmTMB/R/parse-multi-formula.R`
- `gllvmTMB/R/fit-multi.R`
- `DRM.jl/src/gaussian_core.jl`
- `DRM.jl/src/sparse_aug_plsm.jl`
- `GLLVM.jl/src/families/laplace.jl`
- `docs/design/08-missing-data-plan.md`

## Relevant lesson

The R sisters converge on a simple surface:

- keep missing-data controls separate from execution controls;
- use `mi(x)` only for a bare modelled predictor at first;
- require `missing = miss_control(predictor = "model")` before accepting
  `mi()`;
- require `impute = list(x = x ~ ...)` to match the `mi(x)` variable;
- reject transformed or interacting `mi()` terms early;
- keep missing-response masking separate from missing-predictor integration.

The engine sisters provide patterns for response masks and Laplace/Fisher-scoring
loops, but hsquared's animal-model missing-response and pedigree-structured
missing-predictor paths are still new work. They cannot be claimed by borrowing
the sister-package names.

## hsquared action

Ratify the M0 planned grammar:

```r
missing = miss_control(response = "include")
mi(x)
missing = miss_control(predictor = "model")
impute = list(x = x ~ fixed + animal(1 | id, pedigree = ped))
```

Expose the planned surface in `formula_status()`, but do not export `mi()`,
`miss_control()`, `impute_model()`, or `imputed()` yet. Keep implementation
blocked on engine payload design, response-mask tests, and missing-predictor
identifiability review.

## Claim wording risk

Do not say hsquared handles missing data, performs imputation, supports FIML
missingness, estimates missing covariates, or supports REML with missing data.
The honest wording is: "planned grammar contract; no missing-data fitting
implementation yet."

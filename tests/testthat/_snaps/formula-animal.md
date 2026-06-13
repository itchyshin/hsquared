# formula parser rejects unsupported animal syntax

    Code
      hsquared:::hs_build_model_spec(y ~ animal(trait | id, pedigree = ped), data = dat,
      family = stats::gaussian(), REML = TRUE)
    Condition
      Error:
      ! Only random-intercept syntax `animal(1 | id, pedigree = ped)` is implemented. Animal slopes and trait terms are planned, not implemented.

---

    Code
      hsquared:::hs_build_model_spec(y ~ animal(1 | id, pedigree = ped, cov = us()),
      data = dat, family = stats::gaussian(), REML = TRUE)
    Condition
      Error:
      ! `animal()` argument `cov` is planned, not implemented in v0.1.

# formula parser validates pedigree and observed IDs

    Code
      hsquared:::hs_build_model_spec(y ~ animal(1 | id, pedigree = ped), data = dat,
      family = stats::gaussian(), REML = TRUE)
    Condition
      Error:
      ! `data` column `id` contains ID not present in `pedigree`: z.

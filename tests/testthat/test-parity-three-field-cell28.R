# Parity cell 28: the R three-field closed forms against the Julia producer
# (HSquared.jl test/a3_three_field.jl). Both sides use the same fixture
# (V_A = 0.4, intercept 0.3, V_RE = V_O = 0) and the same estimands:
#   h2_latent      = V_A / (V_A + V_RE + V_O)                (Eq 4)
#   h2_liability   = V_A / (V_A + V_RE + V_O + pi^2/3)       (Eq 24, logit)
#   h2_observation = V_A / (expm1(V) + exp(-(mu + V/2)))     (Eq 26, Poisson)
# The Julia values are produced live; the R values are computed independently
# here (the same closed forms the R normalizer enforces).

test_that("cell 28: Julia three-field payload equals the R closed forms [live]", {
  project <- hsquared:::hs_default_julia_project()
  hs_require_bridge("cell 28 three-field parity", project = project)

  hsquared:::hs_julia_setup(project)
  JuliaCall::julia_command(paste(
    "hsq_c28_fit(family; n_trials = nothing) = HSquared.NonGaussianFit(",
    "(sigma_a2 = 0.4,), -12.5, [0.3], [0.0, 0.0], [\"a\", \"b\"], true,",
    "family, :laplace, n_trials, nothing, false, nothing)"
  ))
  field <- function(fam, name, nt = "nothing") {
    JuliaCall::julia_eval(sprintf(
      "HSquared.nongaussian_three_field_payload(hsq_c28_fit(:%s; n_trials = %s)).%s",
      fam, nt, name
    ))
  }

  va <- 0.4
  mu <- 0.3
  expected_obs <- va / (expm1(va) + exp(-(mu + va / 2)))
  expected_liab <- va / (va + pi^2 / 3)

  # Poisson
  expect_equal(field("poisson", "h2_latent"), 1, tolerance = 1e-12)
  expect_equal(field("poisson", "h2_observation"), expected_obs, tolerance = 1e-12)

  # Bernoulli and scalar-trial Binomial
  for (spec in list(c("bernoulli", "nothing"), c("binomial", "3"))) {
    expect_equal(field(spec[1], "h2_latent", spec[2]), 1, tolerance = 1e-12)
    expect_equal(
      field(spec[1], "h2_liability", spec[2]), expected_liab,
      tolerance = 1e-12
    )
  }
})

# Cross-engine parity: hsquared vs HSquared.jl reference fixtures for the
# univariate Gaussian animal model on a small inbred pedigree (30 animals,
# 4 with F = 0.25).
#
# The fixture (fixtures/animal_model_engine_parity/) was written by HSquared.jl
# fitting the model directly, with no R and no bridge, at the engine commit
# pinned in expected_metadata.csv. Two checks use it:
#
# 1. Julia-free: rebuild A, the REML log-likelihood and the average-information
#    matrix in base R at the stored variance components, and confirm the
#    engine's logLik, REML optimum, GLS fixed effects and AI-based SEs.
# 2. Live (skip-guarded): fit the same model through hsquared() and confirm the
#    bridge returns the engine's h2, variance components, logLik and SEs.

hs_parity_engine_commit <- "8f58b13a616ef27a982bff4f2eff8f9558b39b86"

hs_parity_csv <- function(file) {
  utils::read.csv(
    testthat::test_path("fixtures", "animal_model_engine_parity", file),
    stringsAsFactors = FALSE,
    na.strings = ""
  )
}

hs_parity_meta <- function() {
  m <- hs_parity_csv("expected_metadata.csv")
  stats::setNames(m$value, m$key)
}

hs_parity_vc <- function(component, column = "estimate") {
  vc <- hs_parity_csv("expected_variance_components.csv")
  vc[[column]][vc$component == component]
}

# Tabular numerator relationship matrix; parents precede offspring in the file.
hs_parity_A <- function(ped) {
  n <- nrow(ped)
  s <- match(ped$sire, ped$id)
  d <- match(ped$dam, ped$id)
  A <- matrix(0, n, n, dimnames = list(ped$id, ped$id))
  for (i in seq_len(n)) {
    for (j in seq_len(i - 1L)) {
      A[i, j] <- A[j, i] <- 0.5 *
        ((if (is.na(s[i])) 0 else A[j, s[i]]) +
          (if (is.na(d[i])) 0 else A[j, d[i]]))
    }
    A[i, i] <- 1 +
      (if (is.na(s[i]) || is.na(d[i])) 0 else 0.5 * A[s[i], d[i]])
  }
  A
}

test_that("the engine-parity fixture pins the HSquared.jl commit and route", {
  meta <- hs_parity_meta()
  expect_identical(meta[["engine"]], "HSquared.jl")
  expect_identical(meta[["engine_commit"]], hs_parity_engine_commit)
  expect_identical(meta[["route"]], "fit_ai_reml")
  expect_identical(meta[["converged"]], "true")
  expect_identical(meta[["n_inbred"]], "4")
})

test_that("an R-side REML rebuild reproduces the HSquared.jl fixture", {
  ped <- hs_parity_csv("pedigree.csv")
  ph <- hs_parity_csv("phenotypes.csv")
  meta <- hs_parity_meta()
  A <- hs_parity_A(ped)[ph$id, ph$id]
  expect_equal(sum(diag(A) > 1), 4L)

  X <- stats::model.matrix(~sex, ph)
  y <- ph$y
  n <- length(y)
  theta <- c(hs_parity_vc("animal"), hs_parity_vc("residual"))

  reml_loglik <- function(th) {
    V <- th[[1]] * A + th[[2]] * diag(n)
    Vi <- solve(V)
    XVX <- crossprod(X, Vi %*% X)
    P <- Vi - Vi %*% X %*% solve(XVX, crossprod(X, Vi))
    -0.5 *
      ((n - ncol(X)) *
        log(2 * pi) +
        as.numeric(determinant(V)$modulus) +
        as.numeric(determinant(XVX)$modulus) +
        drop(crossprod(y, P %*% y)))
  }

  # logLik on the package scale (full REML, constants included).
  expect_equal(
    reml_loglik(theta),
    as.numeric(meta[["loglik"]]),
    tolerance = 1e-10
  )

  # The stored variance components are the REML optimum: central-difference
  # score is zero and nudging either component lowers the log-likelihood.
  h <- 1e-5
  score <- vapply(
    1:2,
    function(k) {
      e <- replace(c(0, 0), k, h)
      (reml_loglik(theta + e) - reml_loglik(theta - e)) / (2 * h)
    },
    numeric(1)
  )
  expect_lt(max(abs(score)), 1e-5)

  V <- theta[[1]] * A + theta[[2]] * diag(n)
  Vi <- solve(V)
  XVX <- crossprod(X, Vi %*% X)
  P <- Vi - Vi %*% X %*% solve(XVX, crossprod(X, Vi))

  # GLS fixed effects at the REML estimate.
  beta <- hs_parity_csv("expected_beta.csv")
  expect_equal(
    unname(drop(solve(XVX, crossprod(X, Vi %*% y)))),
    beta$estimate,
    tolerance = 1e-8
  )

  # h2 and its SE. The engine SEs are average-information SEs (AI matrix
  # 0.5 * y'P V_i P V_j P y), not observed- or expected-information SEs.
  expect_equal(
    as.numeric(meta[["h2"]]),
    theta[[1]] / sum(theta),
    tolerance = 1e-12
  )
  Py <- P %*% y
  dV <- list(A, diag(n))
  ai <- matrix(0, 2, 2)
  for (i in 1:2) {
    for (j in 1:2) {
      ai[i, j] <- 0.5 * drop(crossprod(Py, dV[[i]] %*% P %*% dV[[j]] %*% Py))
    }
  }
  vc_cov <- solve(ai)
  expect_equal(
    sqrt(diag(vc_cov)),
    c(hs_parity_vc("animal", "se"), hs_parity_vc("residual", "se")),
    tolerance = 1e-8
  )
  grad_h2 <- c(theta[[2]], -theta[[1]]) / sum(theta)^2
  expect_equal(
    sqrt(drop(crossprod(grad_h2, vc_cov %*% grad_h2))),
    as.numeric(meta[["h2_se"]]),
    tolerance = 1e-8
  )
})

test_that("hsquared() reproduces the HSquared.jl engine-parity fixture [live]", {
  hs_skip_live_julia()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for the live engine-parity fit."
  )

  ped <- hs_parity_csv("pedigree.csv")
  ph <- hs_parity_csv("phenotypes.csv")
  meta <- hs_parity_meta()

  fit <- hsquared(
    y ~ sex + animal(1 | id, pedigree = ped),
    data = ph,
    family = stats::gaussian(),
    REML = TRUE
  )

  fvc <- variance_components(fit)
  expect_equal(
    fvc$estimate[fvc$component == "animal"],
    hs_parity_vc("animal"),
    tolerance = 1e-6
  )
  expect_equal(
    fvc$estimate[fvc$component == "residual"],
    hs_parity_vc("residual"),
    tolerance = 1e-6
  )
  expect_equal(
    heritability(fit)$estimate,
    as.numeric(meta[["h2"]]),
    tolerance = 1e-6
  )
  expect_equal(
    as.numeric(stats::logLik(fit)),
    as.numeric(meta[["loglik"]]),
    tolerance = 1e-8
  )
  expect_equal(
    unname(stats::coef(fit)),
    hs_parity_csv("expected_beta.csv")$estimate,
    tolerance = 1e-6
  )

  vcse <- variance_component_standard_errors(fit)
  expect_equal(
    vcse$se[match(c("animal", "residual"), vcse$component)],
    c(hs_parity_vc("animal", "se"), hs_parity_vc("residual", "se")),
    tolerance = 1e-6
  )
  expect_equal(
    heritability_standard_error(fit)$se,
    as.numeric(meta[["h2_se"]]),
    tolerance = 1e-6
  )
})

# `hs_control(se_method = )`: which information matrix the asymptotic SEs use.
#
# Default "ai" (average information, what ASReml/WOMBAT/BLUPF90 report) and
# opt-in "observed" (finite-difference observed information). Both are checked
# against an INDEPENDENT dense R computation from the definitions:
#   AI  = 1/2 y'P Vi P Vj P y,   EXP = 1/2 tr(P Vi P Vj),   OBS = 2 AI - EXP.
# Background and the great tit / ASReml / MCMCglmm comparison:
# dev-test/se-investigation/RESULTS.md.

# ---- pure R: no Julia required -------------------------------------------

test_that("se_method defaults to ai and accepts observed", {
  expect_identical(hs_control()$se_method, "ai")
  expect_identical(hs_control(se_method = "observed")$se_method, "observed")
  expect_error(hs_control(se_method = "fisher"), "should be one of")
})

test_that("the Julia information keyword is built for the requested method", {
  expect_match(hsquared:::hs_julia_information_kw("ai"), "(information = :ai,)",
               fixed = TRUE)
  expect_match(hsquared:::hs_julia_information_kw("observed"),
               "(information = :observed,)", fixed = TRUE)
  expect_error(hsquared:::hs_julia_information_kw("expected"))
})

# ---- independent dense reference -----------------------------------------

hs_test_tabular_A <- function(ped) {
  n <- nrow(ped)
  A <- matrix(0, n, n)
  s <- match(ped$sire, ped$id)
  d <- match(ped$dam, ped$id)
  for (i in seq_len(n)) {
    for (j in seq_len(i - 1L)) {
      v <- 0.5 * ((if (!is.na(s[i])) A[j, s[i]] else 0) +
        (if (!is.na(d[i])) A[j, d[i]] else 0))
      A[i, j] <- A[j, i] <- v
    }
    A[i, i] <- 1 + if (!is.na(s[i]) && !is.na(d[i])) 0.5 * A[s[i], d[i]] else 0
  }
  dimnames(A) <- list(ped$id, ped$id)
  A
}

# SEs of the components and of the first component's ratio, from inverse AI and
# inverse (2 AI - EXP), with dV the derivative matrices dV/dtheta_k.
hs_test_dense_ses <- function(y, X, dV, theta) {
  V <- Reduce(`+`, Map(`*`, theta, dV))
  Vi <- solve(V)
  P <- Vi - Vi %*% X %*% solve(t(X) %*% Vi %*% X, t(X) %*% Vi)
  Py <- P %*% y
  k <- length(dV)
  AI <- EXP <- matrix(0, k, k)
  for (i in 1:k) for (j in 1:k) {
    AI[i, j] <- 0.5 * drop(t(dV[[i]] %*% Py) %*% P %*% (dV[[j]] %*% Py))
    EXP[i, j] <- 0.5 * sum(diag(P %*% dV[[i]] %*% P %*% dV[[j]]))
  }
  tot <- sum(theta)
  g <- c(tot - theta[1], rep(-theta[1], k - 1)) / tot^2
  ses <- function(C) c(sqrt(diag(C)), h2 = sqrt(drop(t(g) %*% C %*% g)))
  list(ai = ses(solve(AI)), observed = ses(solve(2 * AI - EXP)))
}

hs_test_fit_ses <- function(fit) {
  c(variance_component_standard_errors(fit)$se,
    h2 = heritability_standard_error(fit)$se)
}

# ---- live Julia ----------------------------------------------------------

test_that("univariate animal model: ai and observed match the dense reference", {
  hs_skip_live_julia()
  testthat::skip_if_not(hsquared:::hs_julia_bridge_available(),
                        "JuliaCall, Julia, and local HSquared.jl are required.")
  ped <- hs_sim_pedigree(n_founder = 40, n_per_gen = 80, n_gen = 2, seed = 7)
  dat <- hs_sim_genedrop_phenotypes(ped, sigma_a2 = 1, sigma_e2 = 1, seed = 7)
  f <- function(m) hsquared(y ~ animal(1 | id, pedigree = ped), data = dat,
                            control = hs_control(se_method = m))
  fit_ai <- f("ai")
  fit_ob <- f("observed")
  expect_identical(fit_ai$result$se_method, "ai")
  expect_identical(fit_ob$result$se_method, "observed")
  dg <- fit_diagnostics(fit_ob)
  expect_identical(dg$value[dg$metric == "se_method"], "observed")

  vc <- variance_components(fit_ai)$estimate
  A <- hs_test_tabular_A(ped)[dat$id, dat$id]
  ref <- hs_test_dense_ses(dat$y, matrix(1, nrow(dat), 1),
                           list(A, diag(nrow(dat))), vc)
  expect_equal(hs_test_fit_ses(fit_ai), unname(ref$ai), tolerance = 1e-6,
               ignore_attr = TRUE)
  expect_equal(hs_test_fit_ses(fit_ob), unname(ref$observed), tolerance = 2e-3,
               ignore_attr = TRUE)
  # the delta-method h2 interval follows the method too: observed SE is wider
  # here, so its interval is wider
  w <- function(fit) unname(diff(unlist(heritability_interval(fit)[c("lower", "upper")])))
  expect_equal(w(fit_ob) > w(fit_ai),
               hs_test_fit_ses(fit_ob)[["h2"]] > hs_test_fit_ses(fit_ai)[["h2"]])
})

test_that("sparse animal + permanent environment: ai and observed match the dense reference", {
  hs_skip_live_julia()
  testthat::skip_if_not(hsquared:::hs_julia_bridge_available(),
                        "JuliaCall, Julia, and local HSquared.jl are required.")
  ped <- hs_sim_pedigree(n_founder = 30, n_per_gen = 40, n_gen = 2, seed = 21)
  a <- hs_sim_genedrop_bv(ped, sigma_a2 = 1, seed = 21)
  set.seed(22)
  pe <- stats::setNames(stats::rnorm(nrow(ped), 0, sqrt(0.6)), ped$id)
  dat <- do.call(rbind, lapply(1:3, function(r) data.frame(
    id = ped$id, y = 2 + a[ped$id] + pe[ped$id] + stats::rnorm(nrow(ped), 0, sqrt(0.8)),
    stringsAsFactors = FALSE)))
  f <- function(m) hsquared(
    y ~ animal(1 | id, pedigree = ped) + permanent(1 | id), data = dat,
    control = hs_control(engine = "julia", se_method = m, engine_control = list(
      target = "repeatability", scale_method = "auto")))
  fit_ai <- suppressWarnings(f("ai"))
  fit_ob <- suppressWarnings(f("observed"))
  expect_identical(fit_ai$result$se_method, "ai")
  expect_identical(fit_ob$result$se_method, "observed")

  vc <- variance_components(fit_ai)$estimate
  A <- hs_test_tabular_A(ped)
  Z <- outer(dat$id, ped$id, `==`) * 1
  ref <- hs_test_dense_ses(dat$y, matrix(1, nrow(dat), 1),
                           list(Z %*% A %*% t(Z), Z %*% t(Z), diag(nrow(dat))), vc)
  expect_equal(hs_test_fit_ses(fit_ai), unname(ref$ai), tolerance = 1e-6,
               ignore_attr = TRUE)
  expect_equal(hs_test_fit_ses(fit_ob), unname(ref$observed), tolerance = 2e-3,
               ignore_attr = TRUE)
  expect_false(isTRUE(all.equal(hs_test_fit_ses(fit_ai), hs_test_fit_ses(fit_ob))))
})

test_that("genomic GREML honours se_method and records it", {
  hs_skip_live_julia()
  testthat::skip_if_not(hsquared:::hs_julia_bridge_available(),
                        "JuliaCall, Julia, and local HSquared.jl are required.")
  set.seed(31)
  n <- 300; m <- 400
  M <- matrix(stats::rbinom(n * m, 2, stats::runif(m, 0.1, 0.9)), n, m, byrow = TRUE)
  ids <- sprintf("g%03d", seq_len(n))
  rownames(M) <- ids
  W <- scale(M, scale = FALSE)
  y <- 3 + drop(W[, 1:40] %*% stats::rnorm(40, 0, 0.3)) + stats::rnorm(n)
  dat <- data.frame(id = ids, y = y)
  f <- function(m) hsquared(
    y ~ genomic(1 | id, markers = M), data = dat,
    control = hs_control(engine = "julia", se_method = m,
                         engine_control = list(target = "genomic")))
  fit_ai <- f("ai")
  fit_ob <- f("observed")
  expect_identical(fit_ai$result$se_method, "ai")
  expect_identical(fit_ob$result$se_method, "observed")
  expect_identical(variance_components(fit_ai), variance_components(fit_ob))
  se_ai <- heritability_standard_error(fit_ai)$se
  se_ob <- heritability_standard_error(fit_ob)$se
  expect_true(is.finite(se_ai) && is.finite(se_ob))
  expect_false(isTRUE(all.equal(se_ai, se_ob, tolerance = 1e-8)))
  # same estimand, so the two SEs are close, not different by orders
  expect_lt(abs(log(se_ob / se_ai)), log(1.5))
})

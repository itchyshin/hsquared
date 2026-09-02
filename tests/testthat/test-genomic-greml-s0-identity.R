# 0.7-S0 genomic GREML identity scaffolding (design-51). NOT a covered flip.

hs_s0_test_ginv <- function(ids) {
  n <- length(ids)
  G <- diag(n) * 1.0
  G[G == 0] <- 0.05
  G <- (G + t(G)) / 2
  Ginv <- solve(G)
  dimnames(Ginv) <- list(ids, ids)
  Ginv
}

test_that("N3: marker bridge payload freezes ridge = 0.01 (parser)", {
  ids <- paste0("g", 1:5)
  set.seed(4)
  M <- matrix(stats::rbinom(5 * 20, 2, 0.3), 5, 20)
  rownames(M) <- ids
  dat <- data.frame(y = c(1, 2, 3, 4, 5), id = ids)

  spec <- hsquared:::hs_build_model_spec(
    y ~ genomic(1 | id, markers = M),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)
  expect_equal(payload$ridge, 0.01)
  expect_equal(payload$relationship_provenance$ridge, 0.01)
  expect_equal(payload$relationship_provenance$relationship_scale, "K_lambda")
  expect_equal(payload$relationship_provenance$relationship_method, "vanraden1")
})

test_that("N1 scaffold: genomic() takes exactly one of Ginv or markers", {
  ids <- paste0("i", 1:5)
  set.seed(1)
  M <- matrix(sample(0:2, 5 * 12, replace = TRUE), nrow = 5, dimnames = list(ids, paste0("m", 1:12)))
  Ginv <- hs_s0_test_ginv(ids)
  dat <- data.frame(y = rnorm(5), id = ids, stringsAsFactors = FALSE)
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ genomic(1 | id, Ginv = Ginv, markers = M),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "exactly one of `Ginv` or `markers`"
  )
  spec_m <- hsquared:::hs_build_model_spec(
    y ~ genomic(1 | id, markers = M),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )
  expect_equal(spec_m$random$genomic$source, "markers")
  spec_q <- hsquared:::hs_build_model_spec(
    y ~ genomic(1 | id, Ginv = Ginv),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )
  expect_match(spec_q$bridge$target, "Ginv", fixed = TRUE)
})

test_that("N2: marker live fit labels genomic_variance_ratio (not pedigree h2) [live]", {
  hs_skip_live_julia()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for live marker GREML."
  )

  set.seed(20260902)
  na <- 10
  ids <- paste0("g", seq_len(na))
  M <- matrix(stats::rbinom(na * 40, 2, 0.3), na, 40)
  rownames(M) <- ids
  dat <- data.frame(
    y = 1 + stats::rnorm(na),
    id = ids,
    stringsAsFactors = FALSE
  )

  fit <- hsquared(
    y ~ genomic(1 | id, markers = M),
    data = dat,
    family = stats::gaussian(),
    control = hs_control(
      engine = "julia",
      engine_control = list(target = "genomic")
    )
  )
  ratio <- heritability(fit)
  expect_equal(ratio$component, "genomic_variance_ratio")
  expect_equal(ratio$relationship_source, "markers")
  expect_equal(ratio$ridge, 0.01)
  expect_false(identical(ratio$component, "h2"))
})

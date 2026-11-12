# Coverage lane for R/model-spec.R: the formula parser's refusal paths and its
# supplied-matrix validators. No Julia. Every refusal is checked for its
# condition class where the parser classes it, and for the message that names
# the offending syntax; accepted inputs are checked against an invariance
# (permutation of labels, equivalent spellings) rather than a bare "no error".

ped <- data.frame(
  id = letters[1:8],
  sire = c(NA, NA, NA, NA, "a", "a", "c", "c"),
  dam = c(NA, NA, NA, NA, "b", "b", "d", "d"),
  stringsAsFactors = FALSE
)
dat <- data.frame(
  y = c(1.2, 0.8, 2.1, 1.9),
  y2 = c(2.2, 1.8, 3.1, 0.9),
  id = c("e", "f", "g", "h"),
  dam = c("b", "b", "d", "d"),
  grp = c("n1", "n1", "n2", "n2"),
  age = c(1, 2, 3, 4),
  sex = c("m", "f", "m", "f"),
  stringsAsFactors = FALSE
)
Kmat <- diag(4)
dimnames(Kmat) <- list(dat$id, dat$id)
mrk <- matrix(
  c(0, 1, 2, 1, 0, 2, 1, 1, 0, 2, 1, 0, 1, 2, 0, 1, 2, 1, 0, 1, 2, 0, 1, 1),
  nrow = 8,
  dimnames = list(letters[1:8], c("m1", "m2", "m3"))
)
mf_group <- c(
  a = "base", b = "base", c = "base", d = "base",
  e = "", f = "", g = "", h = ""
)
mf_two <- c(
  a = "b1", b = "b2", c = "b1", d = "b2",
  e = "", f = "", g = "", h = ""
)
Gamma1 <- matrix(0.25, 1, 1, dimnames = list("base", "base"))
Gamma2 <- matrix(c(1, 0.2, 0.2, 1), 2, dimnames = list(c("b1", "b2"), c("b1", "b2")))

build <- function(formula, data = dat, family = stats::gaussian(), REML = TRUE) {
  hsquared:::hs_build_model_spec(formula, data, family, REML)
}

# A single_step() construction formula whose group/Gamma arguments are looked
# up by name in an environment holding the objects under test.
build_ss <- function(group, Gamma, group_expr = "mfg", gamma_expr = "gam") {
  env <- list2env(
    list(ped = ped, mrk = mrk, mfg = group, gam = Gamma),
    parent = globalenv()
  )
  txt <- sprintf(
    "y ~ single_step(1 | id, pedigree = ped, markers = mrk, group = %s, Gamma = %s)",
    group_expr,
    gamma_expr
  )
  build(stats::as.formula(txt, env = env))
}

expect_unsupported <- function(expr, fragment) {
  err <- expect_error(expr, class = "hsquared_unsupported_syntax")
  expect_match(conditionMessage(err), fragment, fixed = TRUE)
  invisible(err)
}

expect_refused <- function(expr, fragment) {
  err <- expect_error(expr)
  expect_match(conditionMessage(err), fragment, fixed = TRUE)
  invisible(err)
}

# ---- build entry --------------------------------------------------------------

test_that("a formula without an environment resolves names from the caller", {
  f <- y ~ animal(1 | id, pedigree = ped)
  with_env <- build(f)
  attr(f, ".Environment") <- NULL
  expect_null(environment(f))
  without_env <- build(f)
  expect_identical(without_env$random$animal$ids, with_env$random$animal$ids)
  expect_identical(without_env$random$animal$values, with_env$random$animal$values)
  expect_identical(without_env$bridge$target, with_env$bridge$target)
})

test_that("a formula with no primary effect names all five accepted primary terms", {
  err <- expect_unsupported(
    build(y ~ sex),
    "`formula` must contain exactly one primary term"
  )
  for (term in c("animal(1 | id, pedigree = ped)", "genomic(1 | id, Ginv = Ginv)",
                 "metafounder(1 | id, pedigree = ped, group = mf_group, Gamma = Gamma)",
                 "relmat(1 | id, K = K)", "precision(1 | id, Q = Q)")) {
    expect_match(conditionMessage(err), term, fixed = TRUE)
  }
})

test_that("REML must be a single TRUE or FALSE before anything else is looked at", {
  for (bad in list(NA, "yes", c(TRUE, FALSE), NULL, 1)) {
    expect_error(
      hsquared:::hs_validate_model_inputs(
        y ~ animal(1 | id, pedigree = ped),
        dat,
        stats::gaussian(),
        bad
      ),
      "`REML` must be `TRUE` or `FALSE`.",
      fixed = TRUE
    )
  }
})

test_that("hs_validate_fixed_design accepts an intercept-free empty design and rejects a duplicated column", {
  expect_true(hsquared:::hs_validate_fixed_design(matrix(0, 3, 0)))
  x <- cbind(a = c(1, 2, 3), b = c(1, 2, 3))
  expect_error(
    hsquared:::hs_validate_fixed_design(x),
    "rank deficient",
    fixed = TRUE
  )
  expect_true(hsquared:::hs_validate_fixed_design(cbind(a = c(1, 2, 3), b = c(1, 0, 1))))
})

# ---- opt-in combinations that are refused by name -----------------------------

test_that("bare (1 | group) effects combine only with an animal() pedigree primary", {
  expect_unsupported(
    build(y ~ genomic(1 | id, Ginv = Kmat) + (1 | grp)),
    "not `genomic()`"
  )
  expect_unsupported(
    build(y ~ animal(rr(age, order = 1) | id, pedigree = ped) + (1 | grp)),
    "does not (yet) combine with an `animal(rr(...) | id)` random-regression design"
  )
})

test_that("random regression is a single-effect univariate design", {
  expect_unsupported(
    build(y ~ animal(rr(age, order = 1) | id, pedigree = ped) + common_env(1 | grp)),
    "combining it with a second random effect"
  )
  expect_unsupported(
    build(cbind(y, y2) ~ animal(rr(age, order = 1) | id, pedigree = ped)),
    "Multivariate random regression"
  )
  expect_unsupported(
    build(cbind(y, y2) ~ genomic(1 | id, Ginv = Kmat)),
    "The multivariate path currently supports"
  )
})

test_that("a one-column cbind() is the univariate model, not a multivariate one", {
  uni <- build(cbind(y) ~ animal(1 | id, pedigree = ped))
  plain <- build(y ~ animal(1 | id, pedigree = ped))
  expect_false(isTRUE(uni$response$multivariate))
  expect_equal(as.numeric(uni$response$values), plain$response$values)
})

test_that("an unnamed matrix-column response gets trait1..traitK labels, a named one keeps its names", {
  unnamed <- dat
  unnamed$M <- cbind(c(1, 2, 3, 4), c(2, 3, 4, 5))
  spec <- build(cbind(M) ~ animal(1 | id, pedigree = ped), unnamed)
  expect_true(spec$response$multivariate)
  expect_identical(spec$response$trait_names, c("trait1", "trait2"))
  expect_identical(colnames(spec$response$values), c("trait1", "trait2"))
  expect_equal(unname(spec$response$values), unname(unnamed$M))

  mixed <- build(cbind(M, y) ~ animal(1 | id, pedigree = ped), unnamed)
  expect_identical(mixed$response$trait_names, c("trait1", "trait2", "trait3"))

  named <- dat
  named$M <- cbind(a = c(1, 2, 3, 4), b = c(2, 3, 4, 5))
  spec <- build(cbind(M) ~ animal(1 | id, pedigree = ped), named)
  expect_identical(spec$response$trait_names, c("a", "b"))
})

test_that("hs_family_label fills missing family and link slots with <unknown>", {
  blank <- stats::gaussian()
  blank$family <- ""
  blank$link <- NULL
  expect_identical(hsquared:::hs_family_label(blank), "<unknown>(<unknown>)")
  half <- stats::poisson()
  half$link <- NULL
  expect_identical(hsquared:::hs_family_label(half), "poisson(<unknown>)")
  expect_identical(hsquared:::hs_family_label(stats::binomial()), "binomial(logit)")
})

# ---- argument and grouping-variable guards ------------------------------------

test_that("animal() names a missing grouping column and every unsupported argument", {
  expect_refused(
    build(y ~ animal(1 | zz, pedigree = ped)),
    "`animal()` grouping variable `zz` was not found in `data`."
  )
  expect_refused(
    build(y ~ animal(1 | id, pedigree = ped, foo = 1)),
    "`animal()` argument `foo` is planned, not implemented in v0.1."
  )
  expect_refused(
    build(y ~ animal(1 | id, pedigree = ped, foo = 1, bar = 2)),
    "`animal()` arguments `foo`, `bar` are planned, not implemented in v0.1."
  )
  expect_unsupported(
    build(y ~ animal(1 | id, pedigree = ped, cov = "us")),
    "`animal()` argument `cov` is reserved, not parsed."
  )
})

test_that("rr() names every unsupported argument and validates its covariate", {
  expect_refused(
    build(y ~ animal(rr(age, order = 1, foo = 1, bar = 2) | id, pedigree = ped)),
    "`rr()` arguments `foo`, `bar` are planned, not implemented."
  )
  nonnum <- dat
  nonnum$age <- c("a", "b", "c", "d")
  expect_refused(
    build(y ~ animal(rr(age, order = 1) | id, pedigree = ped), nonnum),
    "`rr()` covariate `age` must be numeric."
  )
  for (bad in list(c(1, NA, 3, 4), c(1, Inf, 3, 4))) {
    bad_dat <- dat
    bad_dat$age <- bad
    expect_refused(
      build(y ~ animal(rr(age, order = 1) | id, pedigree = ped), bad_dat),
      "`rr()` covariate `age` must contain only finite, non-missing values."
    )
  }
  flat <- dat
  flat$age <- 3
  expect_refused(
    build(y ~ animal(rr(age, order = 1) | id, pedigree = ped), flat),
    "must vary (its observed range has zero width)"
  )
})

test_that("rr() standardises the covariate to [-1, 1] by its observed range", {
  spec <- build(y ~ animal(rr(age, order = 1) | id, pedigree = ped))
  rr <- spec$random$animal$random_regression
  expect_equal(rr$lower, 1)
  expect_equal(rr$upper, 4)
  expect_equal(rr$order, 1L)
  expect_equal(rr$values, c(1, 2, 3, 4))
})

test_that("a data id column may not hold missing, empty or zero ids", {
  for (bad in list(NA_character_, "", "0")) {
    bad_dat <- dat
    bad_dat$id[1] <- bad
    expect_refused(
      build(y ~ animal(1 | id, pedigree = ped), bad_dat),
      "`data` column `id` cannot contain missing, empty, or `0` IDs."
    )
  }
})

test_that("a pedigree with unconventional column names is read by position", {
  positional <- ped
  names(positional) <- c("x1", "x2", "x3")
  by_position <- build(y ~ animal(1 | id, pedigree = positional))
  by_name <- build(y ~ animal(1 | id, pedigree = ped))
  expect_identical(by_position$random$animal$ids, by_name$random$animal$ids)
  expect_equal(by_position$random$animal$values, by_name$random$animal$values)
})

test_that("metafounder() names a missing grouping column, an unnamed call and unsupported arguments", {
  expect_refused(
    build(y ~ metafounder(1 | zz, pedigree = ped, group = mf_group, Gamma = Gamma1)),
    "`metafounder()` grouping variable `zz` was not found in `data`."
  )
  expect_refused(
    build(y ~ metafounder(1 | id)),
    "`metafounder()` requires both `group` and `Gamma`"
  )
  expect_refused(
    build(y ~ metafounder(1 | id, pedigree = ped, group = mf_group, Gamma = Gamma1, foo = 1)),
    "`metafounder()` argument `foo` is planned, not implemented."
  )
  expect_refused(
    build(y ~ metafounder(1 | id, pedigree = ped, group = mf_group, Gamma = Gamma1, foo = 1, bar = 2)),
    "`metafounder()` arguments `foo`, `bar` are planned, not implemented."
  )
})

# ---- relmat() / precision() ----------------------------------------------------

test_that("relmat() names every argument-level mistake", {
  expect_refused(
    build(y ~ relmat(1 | zz, K = Kmat)),
    "`relmat()` grouping variable `zz` was not found in `data`."
  )
  expect_refused(
    build(y ~ relmat(age | id, K = Kmat)),
    "relmat slopes are planned, not implemented."
  )
  expect_refused(
    build(y ~ relmat(1 | id, K = Kmat, foo = 1)),
    "`relmat()` argument `foo` is planned, not implemented."
  )
  expect_refused(
    build(y ~ relmat(1 | id, K = Kmat, foo = 1, bar = 2)),
    "`relmat()` arguments `foo`, `bar` are planned, not implemented."
  )
  expect_refused(
    build(y ~ relmat(1 | id)),
    "`relmat()` requires a `K` argument (a relationship matrix with id row/column names)."
  )
  expect_refused(
    build(y ~ precision(1 | id)),
    "`precision()` requires a `Q` argument (a precision (inverse) matrix with id row/column names)."
  )
  expect_refused(
    build(y ~ relmat(1 | id, K = Kmat, Kinv = Kmat)),
    "`relmat()` takes exactly one of `K` or `Kinv` or `Q`."
  )
})

test_that("relmat() ids must all appear in the supplied matrix dimnames", {
  stranger <- dat
  stranger$id[1] <- "zz"
  expect_refused(
    build(y ~ relmat(1 | id, K = Kmat), stranger),
    "ID(s) not in the `K`: `zz`."
  )
})

test_that("relmat(K) is carried as K^-1 and a Matrix-class K gives the same spec as a base matrix", {
  K <- Kmat
  K[1, 2] <- K[2, 1] <- 0.3
  K_sparse <- Matrix::Matrix(K, sparse = TRUE)
  dense <- build(y ~ relmat(1 | id, K = K))
  sparse <- build(y ~ relmat(1 | id, K = K_sparse))
  expect_equal(dense$random$relmat$ginv, solve(K))
  expect_equal(sparse$random$relmat$ginv, dense$random$relmat$ginv)
  expect_identical(sparse$random$relmat$ids, dense$random$relmat$ids)
})

# ---- single_step() construction -----------------------------------------------

test_that("single_step() construction needs markers and refuses unknown genotyped ids", {
  expect_refused(
    build(y ~ single_step(1 | id, pedigree = ped)),
    "construction requires a `markers` matrix alongside `pedigree`"
  )
  stranger <- mrk
  rownames(stranger)[8] <- "zz"
  expect_refused(
    build(y ~ single_step(1 | id, pedigree = ped, markers = stranger)),
    "Genotyped id(s) not in the pedigree: `zz`."
  )
  expect_unsupported(
    build(y ~ single_step(age | id, pedigree = ped, markers = mrk)),
    "single_step slopes are planned, not implemented."
  )
  expect_refused(
    build(y ~ single_step(1 | zz, pedigree = ped, markers = mrk)),
    "`single_step()` grouping variable `zz` was not found in `data`."
  )
})

test_that("single_step() needs group and Gamma together and finite scalar tuning knobs", {
  env <- list2env(list(ped = ped, mrk = mrk, mfg = mf_group), parent = globalenv())
  expect_refused(
    build(stats::as.formula(
      "y ~ single_step(1 | id, pedigree = ped, markers = mrk, group = mfg)",
      env = env
    )),
    "requires both `group` and `Gamma` together"
  )
  for (bad in c("NA", "c(1, 2)", "Inf")) {
    expect_refused(
      build(stats::as.formula(
        sprintf("y ~ single_step(1 | id, pedigree = ped, markers = mrk, ridge = %s)", bad),
        env = env
      )),
      "`single_step()` `ridge` must be a single finite number."
    )
  }
})

test_that("metafounder group evaluation failures name the argument", {
  expect_refused(
    build_ss(mf_group, Gamma1, group_expr = "nonexistent_group_object"),
    "Could not evaluate `single_step()` metafounder `group = nonexistent_group_object`."
  )
  expect_refused(
    build_ss(mf_group, Gamma1, gamma_expr = "nonexistent_gamma_object"),
    "Could not evaluate `single_step()` `Gamma = nonexistent_gamma_object`."
  )
})

test_that("metafounder group labels are validated against the normalised pedigree", {
  expect_refused(
    build_ss(data.frame(a = 1), Gamma1),
    "metafounder `group` data frames must contain an `id` (or `animal`) column and a `group` column."
  )
  expect_refused(
    build_ss(matrix(mf_group, ncol = 1), Gamma1),
    "metafounder `group` must be a vector or data frame, not a matrix."
  )
  expect_refused(
    build_ss(unname(mf_group), Gamma1),
    "metafounder `group` must be named by pedigree IDs"
  )
  expect_refused(
    build_ss(c(mf_group, a = "base"), Gamma1),
    "metafounder `group` has duplicated id `a`."
  )
  expect_refused(
    build_ss(mf_group[-1L], Gamma1),
    "metafounder `group` is missing pedigree id(s): `a`."
  )
  expect_refused(
    build_ss(c(mf_group, zz = "base"), Gamma1),
    "metafounder `group` includes id(s) not in the normalized pedigree: `zz`."
  )
  no_labels <- stats::setNames(rep("", 8), letters[1:8])
  expect_refused(
    build_ss(no_labels, Gamma1),
    "must provide non-missing labels for animals with unknown parents. Missing label(s): `a`, `b`, `c`, `d`."
  )
})

test_that("a group data frame is the same input as the equivalent named vector", {
  as_vector <- build_ss(mf_group, Gamma1)
  as_frame <- build_ss(
    data.frame(id = names(mf_group), group = unname(mf_group)),
    Gamma1
  )
  expect_identical(as_frame$random$single_step$group_of, as_vector$random$single_step$group_of)
  expect_equal(as_frame$random$single_step$Gamma, as_vector$random$single_step$Gamma)
})

test_that("Gamma is validated as a labelled positive-semidefinite matrix", {
  expect_refused(build_ss(mf_group, matrix("a", 1, 1)), "`Gamma` must be a numeric matrix.")
  expect_refused(build_ss(mf_group, matrix(0.25, 1, 2)), "`Gamma` must be square.")
  expect_refused(build_ss(mf_group, matrix(Inf, 1, 1)), "`Gamma` must contain only finite values.")
  expect_refused(
    build_ss(mf_two, matrix(c(1, 0.1, 0.2, 1), 2, dimnames = dimnames(Gamma2))),
    "`Gamma` must be symmetric."
  )
  expect_refused(
    build_ss(mf_group, diag(2)),
    "`Gamma` must have one row/column per resolved metafounder group (1); got 2."
  )
  expect_refused(
    build_ss(mf_two, diag(2)),
    "`Gamma` must have row and column names when more than one metafounder group is resolved."
  )
  expect_refused(
    build_ss(mf_two, matrix(c(1, 0, 0, 1), 2, dimnames = list(c("b1", "b1"), c("b1", "b1")))),
    "`Gamma` group names must be unique."
  )
  expect_refused(
    build_ss(mf_two, matrix(c(1, 0, 0, 1), 2, dimnames = list(c("b1", "bX"), c("b1", "bX")))),
    "`Gamma` dimnames must match the resolved metafounder group labels."
  )
  expect_refused(
    build_ss(mf_two, matrix(c(1, 2, 2, 1), 2, dimnames = dimnames(Gamma2))),
    "`Gamma` must be positive semidefinite."
  )
})

test_that("a Gamma with permuted labels resolves to the same labelled matrix", {
  ordered <- build_ss(mf_two, Gamma2)
  permuted <- build_ss(mf_two, Gamma2[c("b2", "b1"), c("b2", "b1")])
  expect_equal(permuted$random$single_step$Gamma, ordered$random$single_step$Gamma)
  expect_equal(ordered$random$single_step$Gamma, unname(Gamma2))
})

# ---- supplied-matrix validators -------------------------------------------------

test_that("genomic Ginv is validated as a symmetric positive-definite labelled matrix", {
  ginv_spec <- function(x) build(y ~ genomic(1 | id, Ginv = x))
  expect_refused(
    build(y ~ genomic(1 | id, Ginv = nonexistent_ginv_object)),
    "Could not evaluate the `Ginv` argument (`nonexistent_ginv_object`)."
  )
  expect_refused(ginv_spec(matrix("a", 4, 4, dimnames = list(dat$id, dat$id))), "`Ginv` must be a numeric matrix.")
  expect_refused(ginv_spec(matrix(1, 4, 3, dimnames = list(dat$id, NULL))), "`Ginv` must be a nonempty square matrix.")
  expect_refused(ginv_spec(matrix(0, 0, 0)), "`Ginv` must be a nonempty square matrix.")
  na_g <- Kmat
  na_g[1, 1] <- NA
  expect_refused(ginv_spec(na_g), "`Ginv` must contain only finite, non-missing values.")
  expect_refused(ginv_spec(diag(4)), "`Ginv` must have unique, non-missing, nonempty row/column names")
  swapped <- Kmat
  colnames(swapped) <- rev(colnames(swapped))
  expect_refused(ginv_spec(swapped), "`Ginv` row and column names must match in order.")
  asym <- Kmat
  asym[1, 2] <- 0.5
  expect_refused(ginv_spec(asym), "`Ginv` must be symmetric.")
  indefinite <- Kmat
  indefinite[1, 1] <- -1
  expect_refused(ginv_spec(indefinite), "`Ginv` must be positive definite.")

  from_matrix <- ginv_spec(Matrix::Matrix(Kmat, sparse = TRUE))
  expect_equal(from_matrix$random$genomic$ginv, Kmat)
})

test_that("genomic markers are validated for class, shape, finiteness and variation", {
  marker_spec <- function(x) build(y ~ genomic(1 | id, markers = x))
  expect_refused(marker_spec(matrix("a", 8, 3)), "`markers` must be a numeric marker matrix.")
  expect_refused(marker_spec(matrix(0, 0, 0)), "`markers` must have at least one row and one marker column.")
  na_m <- mrk
  na_m[1, 1] <- NA
  expect_refused(marker_spec(na_m), "`markers` must contain only finite, non-missing dosages.")
  expect_refused(
    marker_spec(matrix(2, 8, 3, dimnames = list(letters[1:8], NULL))),
    "VanRaden denominator `k` must be positive"
  )
  dense <- marker_spec(mrk)
  sparse <- marker_spec(Matrix::Matrix(mrk, sparse = TRUE))
  expect_equal(sparse$random$genomic$markers, dense$random$genomic$markers)
})

# ---- planned markers and bare i.i.d. terms ---------------------------------------

test_that("every reserved effect marker names its nearest live path", {
  nearest <- c(
    maternal_env = "The live maternal sibling is `maternal_genetic(1 | dam)`",
    paternal_genetic = "The live genetic effect is `animal(1 | id, pedigree = ped)`.",
    paternal_env = "The live genetic effect is `animal(1 | id, pedigree = ped)`.",
    dominance = "does not implement dominance.",
    epistasis = "does not implement epistasis.",
    group = "The live grouping path is bare `(1 | group)`",
    unknown_parent_group = "The live grouping path is bare `(1 | group)`",
    cytoplasmic = "The live maternal genetic sibling is `maternal_genetic(1 | dam)`.",
    imprinting = "The live maternal genetic sibling is `maternal_genetic(1 | dam)`.",
    markers = "The live marker path is `genomic(1 | id, markers = )`",
    marker_scan = "The live marker path is `genomic(1 | id, markers = )`",
    qtl_scan = "The live marker path is `genomic(1 | id, markers = )`",
    inbreeding = "a reserved future *effect*, not a missing coefficient."
  )
  for (marker in names(nearest)) {
    formula <- stats::as.formula(
      sprintf("y ~ animal(1 | id, pedigree = ped) + %s(1 | id)", marker),
      env = environment()
    )
    err <- expect_error(build(formula), class = "hsquared_unsupported_syntax")
    expect_match(
      conditionMessage(err),
      sprintf("`%s()` is planned, not implemented.", marker),
      fixed = TRUE
    )
    expect_match(conditionMessage(err), nearest[[marker]], fixed = TRUE)
    expect_match(conditionMessage(err), "Run `formula_status()`", fixed = TRUE)
  }
  expect_identical(hsquared:::hs_planned_marker_nearest_path("not_a_marker"), "")
})

test_that("bare (1 | group) recognition accepts only the random-intercept form", {
  expect_true(hsquared:::hs_is_bare_iid_intercept(quote((1 | grp))))
  expect_false(hsquared:::hs_is_bare_iid_intercept(quote((age | grp))))
  expect_false(hsquared:::hs_is_bare_iid_intercept(quote(x + y)))
  expect_false(hsquared:::hs_is_bare_iid_intercept(quote(sex)))
})

test_that("parsing a bare (1 | group) term names its own failure modes", {
  expect_unsupported(
    hsquared:::hs_parse_bare_iid_call(quote((age | grp)), dat),
    "Only random-intercept syntax `(1 | group)` is accepted"
  )
  expect_refused(
    hsquared:::hs_parse_bare_iid_call(quote((1 | grp + age)), dat),
    "must be a bare column name."
  )
  expect_refused(
    build(y ~ animal(1 | id, pedigree = ped) + (1 | zz)),
    "The `(1 | zz)` grouping variable `zz` was not found in `data`."
  )
})

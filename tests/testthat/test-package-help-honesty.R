# Package-help honesty: ?hsquared-package must not keep Phase-0 "planned
# interface" or "fitting waits" language. Non-Gaussian is opt-in
# experimental, not planned. DESCRIPTION wording is pinned by
# test-hs-control-targets.R (hs_control sibling).

test_that("package Rd does not keep Phase-0 planned-interface or fitting-waits copy", {
  rd <- testthat::test_path("..", "..", "man", "hsquared-package.Rd")
  skip_if_not(
    file.exists(rd),
    "man/hsquared-package.Rd not present in the check copy"
  )
  text <- paste(readLines(rd, warn = FALSE), collapse = "\n")

  expect_no_match(text, "planned R-facing")
  expect_no_match(text, "waits for")
  expect_no_match(text, "Phase 0")
  expect_no_match(text, "Phase-0")
  expect_no_match(text, "non-Gaussian models are planned")
  expect_no_match(text, "non-Gaussian models remain planned")

  expect_match(text, "R-facing interface")
  expect_match(text, "non-Gaussian")
  expect_match(text, "opt-in")
  expect_match(text, "formula grammar stays planned")
  expect_no_match(text, "factor-analytic models remain planned")
})

test_that("twin-boundary Getting started link stays inside articles/", {
  article <- testthat::test_path(
    "..",
    "..",
    "vignettes",
    "articles",
    "twin-boundary.Rmd"
  )
  skip_if_not(file.exists(article), "twin-boundary article not present")
  text <- paste(readLines(article, warn = FALSE), collapse = "\n")
  expect_match(text, "[Getting started](hsquared.html)", fixed = TRUE)
  expect_no_match(text, "../hsquared.html", fixed = TRUE)
})

test_that("first-fit pages warn that Julia start and compile take about 30 s", {
  pages <- c(
    testthat::test_path("..", "..", "README.md"),
    testthat::test_path("..", "..", "vignettes", "hsquared.Rmd"),
    testthat::test_path(
      "..",
      "..",
      "vignettes",
      "articles",
      "gryphon-worked-example.Rmd"
    )
  )
  for (page in pages) {
    skip_if_not(file.exists(page), paste(basename(page), "not present"))
    text <- paste(readLines(page, warn = FALSE), collapse = "\n")
    expect_match(text, "first fit in a session", fixed = TRUE, info = page)
    expect_match(text, "30 s", fixed = TRUE, info = page)
    expect_match(text, "Julia starts and\\s+compiles", info = page)
    expect_match(text, "under a second", fixed = TRUE, info = page)
  }

  mv <- testthat::test_path(
    "..",
    "..",
    "vignettes",
    "articles",
    "multivariate.Rmd"
  )
  skip_if_not(file.exists(mv), "multivariate article not present")
  mv_text <- paste(readLines(mv, warn = FALSE), collapse = "\n")
  expect_match(mv_text, "first `cbind()` fit in a session", fixed = TRUE)
  expect_match(mv_text, "40 s", fixed = TRUE)
  expect_match(mv_text, "minutes", fixed = TRUE)
})

test_that("install docs tell the reader to Pkg.instantiate() the Julia checkout", {
  pages <- c(
    testthat::test_path("..", "..", "README.md"),
    testthat::test_path("..", "..", "vignettes", "hsquared.Rmd"),
    testthat::test_path(
      "..",
      "..",
      "vignettes",
      "articles",
      "fitting-models.Rmd"
    )
  )
  for (page in pages) {
    skip_if_not(file.exists(page), paste(basename(page), "not present"))
    text <- paste(readLines(page, warn = FALSE), collapse = "\n")
    expect_match(text, "Pkg.instantiate()", fixed = TRUE, info = page)
    expect_match(text, "git clone", fixed = TRUE, info = page)
  }
})

test_that("animal help lists accepted unknown-parent codes and phantom-parent fix", {
  rd <- testthat::test_path("..", "..", "man", "animal.Rd")
  skip_if_not(file.exists(rd), "man/animal.Rd not present")
  text <- paste(readLines(rd, warn = FALSE), collapse = "\n")
  expect_match(text, "NA", fixed = TRUE)
  expect_match(text, "\"0\"", fixed = TRUE)
  expect_match(text, "phantom", ignore.case = TRUE)
  expect_match(text, "founder rows", fixed = TRUE)
  expect_match(text, "-9", fixed = TRUE)

  grammar <- testthat::test_path(
    "..",
    "..",
    "vignettes",
    "articles",
    "formula-grammar.Rmd"
  )
  skip_if_not(file.exists(grammar), "formula-grammar article not present")
  grammar_text <- paste(readLines(grammar, warn = FALSE), collapse = "\n")
  expect_match(grammar_text, "Unknown parents", fixed = TRUE)
  expect_match(grammar_text, "founder", fixed = TRUE)
  expect_match(grammar_text, "missing_values", fixed = TRUE)
})

test_that("docs name Wald boundary limits and the 50:50 V_A LRT mixture", {
  pages <- c(
    heritability = testthat::test_path("..", "..", "man", "heritability.Rd"),
    heritability_interval = testthat::test_path(
      "..",
      "..",
      "man",
      "heritability_interval.Rd"
    ),
    variance_se = testthat::test_path(
      "..",
      "..",
      "man",
      "variance_component_standard_errors.Rd"
    ),
    inference = testthat::test_path("..", "..", "man", "inference_blocks.Rd"),
    limits = testthat::test_path(
      "..",
      "..",
      "vignettes",
      "articles",
      "current-limits.Rmd"
    ),
    gryphon = testthat::test_path(
      "..",
      "..",
      "vignettes",
      "articles",
      "gryphon-worked-example.Rmd"
    )
  )
  for (name in names(pages)) {
    skip_if_not(file.exists(pages[[name]]), paste(name, "not present"))
    text <- paste(readLines(pages[[name]], warn = FALSE), collapse = "\n")
    expect_match(text, "near 0", fixed = TRUE, info = name)
    expect_match(text, "50:50", fixed = TRUE, info = name)
    expect_match(text, "Self and Liang", fixed = TRUE, info = name)
    expect_match(text, "nested_lrt", fixed = TRUE, info = name)
    expect_no_match(text, "anova() now", fixed = TRUE, info = name)
  }
})

test_that("gryphon articles do not claim ancestral loops in the open pedigree", {
  pages <- c(
    testthat::test_path(
      "..",
      "..",
      "vignettes",
      "articles",
      "gryphon-worked-example.Rmd"
    ),
    testthat::test_path(
      "..",
      "..",
      "vignettes",
      "articles",
      "benchmark-comparators.Rmd"
    ),
    testthat::test_path(
      "..",
      "..",
      "vignettes",
      "articles",
      "validation-evidence.Rmd"
    )
  )
  for (page in pages) {
    skip_if_not(file.exists(page), paste(basename(page), "not present"))
    text <- paste(readLines(page, warn = FALSE), collapse = "\n")
    expect_no_match(text, "contains ancestral loops", fixed = TRUE, info = page)
    expect_no_match(text, "pathological", fixed = TRUE, info = page)
    expect_match(text, "no ancestral loops", fixed = TRUE, info = page)
    expect_match(text, "A_gryphon", fixed = TRUE, info = page)
  }
})

test_that("README and Getting started define covered, route, and interval labels", {
  pages <- c(
    testthat::test_path("..", "..", "README.md"),
    testthat::test_path("..", "..", "vignettes", "hsquared.Rmd")
  )
  for (page in pages) {
    skip_if_not(file.exists(page), paste(basename(page), "not present"))
    text <- paste(readLines(page, warn = FALSE), collapse = "\n")
    expect_match(text, "named model type", fixed = TRUE, info = page)
    expect_match(text, "validation status", fixed = TRUE, info = page)
    expect_match(text, "public_covered_count", fixed = TRUE, info = page)
    expect_match(text, "not a function", ignore.case = TRUE, info = page)
    expect_match(text, "directional-conservative", fixed = TRUE, info = page)
    expect_match(text, "nominal 95%", fixed = TRUE, info = page)
    expect_match(text, "**7**", fixed = TRUE, info = page)
  }
})

test_that("README and Getting started agree on install, Julia 1.10, and PATH", {
  pages <- c(
    testthat::test_path("..", "..", "README.md"),
    testthat::test_path("..", "..", "vignettes", "hsquared.Rmd")
  )
  for (page in pages) {
    skip_if_not(file.exists(page), paste(basename(page), "not present"))
    text <- paste(readLines(page, warn = FALSE), collapse = "\n")
    expect_match(
      text,
      'remotes::install_github("itchyshin/hsquared")',
      fixed = TRUE,
      info = page
    )
    expect_match(
      text,
      'pak::pak("itchyshin/hsquared")',
      fixed = TRUE,
      info = page
    )
    expect_match(text, "equivalent", fixed = TRUE, info = page)
    expect_match(text, "1.10", fixed = TRUE, info = page)
    expect_match(text, "PATH", fixed = TRUE, info = page)
    expect_match(text, "vignette", ignore.case = TRUE, info = page)
  }
})

test_that("non-Gaussian vignette does not call its marginal fit REML", {
  vignette <- testthat::test_path(
    "..",
    "..",
    "vignettes",
    "articles",
    "fitting-models.Rmd"
  )
  skip_if_not(
    file.exists(vignette),
    "source vignette not present in the check copy"
  )
  text <- paste(readLines(vignette, warn = FALSE), collapse = "\n")

  expect_no_match(text, "All fits are by REML", fixed = TRUE)
  expect_match(
    text,
    "does \\*\\*not\\*\\* make this non-Gaussian fit a REML fit"
  )
  expect_match(text, "Laplace marginal likelihood")
  expect_match(text, "flat measure", fixed = TRUE)
  expect_match(text, "REML-like", fixed = TRUE)
  expect_match(text, "not comparable with `glmer`", fixed = TRUE)
  expect_match(text, "Laplace-ML", fixed = TRUE)
})

test_that("nongaussian docs name the flat-integrated Laplace V_A estimator", {
  rd <- testthat::test_path("..", "..", "man", "hs_control.Rd")
  skip_if_not(file.exists(rd), "man/hs_control.Rd not present")
  text <- paste(readLines(rd, warn = FALSE), collapse = "\n")
  expect_match(text, "flat measure", fixed = TRUE)
  expect_match(text, "REML-like", fixed = TRUE)
  expect_match(text, "Laplace-ML", fixed = TRUE)
  expect_match(text, "glmer", fixed = TRUE)
  expect_match(text, "logLik", fixed = TRUE)

  diag_rd <- testthat::test_path("..", "..", "man", "fit_diagnostics.Rd")
  skip_if_not(file.exists(diag_rd), "man/fit_diagnostics.Rd not present")
  diag_text <- paste(readLines(diag_rd, warn = FALSE), collapse = "\n")
  expect_match(diag_text, "flat measure", fixed = TRUE)
  expect_match(diag_text, "not conventional", fixed = TRUE)
  expect_match(diag_text, "glmer", fixed = TRUE)
})

test_that("fitting-models aligns cbind and genomic GREML with covered wording", {
  vignette <- testthat::test_path(
    "..",
    "..",
    "vignettes",
    "articles",
    "fitting-models.Rmd"
  )
  skip_if_not(file.exists(vignette), "source vignette not present")
  text <- paste(readLines(vignette, warn = FALSE), collapse = "\n")

  expect_no_match(text, "capability itself stays `partial`", fixed = TRUE)
  expect_no_match(
    text,
    "so does the multivariate `cbind()` model even though",
    fixed = TRUE
  )
  expect_no_match(text, "two-effect leg, genomic, SNP-BLUP", fixed = TRUE)
  expect_match(text, "covered** on the default call", fixed = TRUE)
  expect_match(text, "**Genomic GREML** is covered", fixed = TRUE)
  expect_match(text, "explicit-target genomic GREML", fixed = TRUE)
  expect_match(text, "single-step) remain `partial`", fixed = TRUE)
})

test_that("function map names real extractors and R vs Julia gaps", {
  article <- testthat::test_path(
    "..",
    "..",
    "vignettes",
    "articles",
    "function-map-cheatsheet.Rmd"
  )
  skip_if_not(file.exists(article), "function-map article not present")
  text <- paste(readLines(article, warn = FALSE), collapse = "\n")

  expect_match(text, "accuracy(fit)", fixed = TRUE)
  expect_match(text, "?g_matrix_geometry", fixed = TRUE)
  expect_no_match(
    text,
    "marker_effects()`, `g_matrix_geometry()`.",
    fixed = TRUE
  )
  expect_match(text, "Julia only: `nested_lrt()", fixed = TRUE)
  expect_match(text, "additive_relationship()", fixed = TRUE)
  expect_match(text, "genomic_relationship_matrix()", fixed = TRUE)
  expect_match(text, "R function and Julia function", fixed = TRUE)
  expect_false(exists(
    "g_matrix_geometry",
    envir = asNamespace("hsquared"),
    inherits = FALSE
  ))
})

test_that("genomic help states the ridged residual shift", {
  rd <- testthat::test_path("..", "..", "man", "genomic_markers.Rd")
  skip_if_not(file.exists(rd), "man/genomic_markers.Rd not present")
  text <- paste(readLines(rd, warn = FALSE), collapse = "\n")

  expect_match(text, "G + 0.01 I", fixed = TRUE)
  expect_match(text, "0.01 * sigma_g2", fixed = TRUE)
  expect_match(text, "residual", fixed = TRUE)
  expect_match(text, "no \\\\code\\{ridge\\}")

  article <- testthat::test_path(
    "..",
    "..",
    "vignettes",
    "articles",
    "genomic-prediction.Rmd"
  )
  skip_if_not(file.exists(article), "genomic-prediction article not present")
  article_text <- paste(readLines(article, warn = FALSE), collapse = "\n")
  expect_match(article_text, "0.01 * sigma_g2", fixed = TRUE)
  expect_match(article_text, "no `ridge` argument", fixed = TRUE)
})

test_that("relmat docs name dimnames, singular MZ kernels, and the live target", {
  grammar <- testthat::test_path(
    "..",
    "..",
    "vignettes",
    "articles",
    "formula-grammar.Rmd"
  )
  skip_if_not(file.exists(grammar), "formula-grammar article not present")
  grammar_text <- paste(readLines(grammar, warn = FALSE), collapse = "\n")
  expect_no_match(grammar_text, "syntax reservation only", fixed = TRUE)
  expect_match(grammar_text, 'target = "relmat"', fixed = TRUE)
  expect_match(grammar_text, "positive definite", fixed = TRUE)
  expect_match(grammar_text, "row and column names", fixed = TRUE)

  article <- testthat::test_path(
    "..",
    "..",
    "vignettes",
    "articles",
    "inheritance-systems.Rmd"
  )
  skip_if_not(file.exists(article), "inheritance-systems article not present")
  article_text <- paste(readLines(article, warn = FALSE), collapse = "\n")
  expect_match(
    article_text,
    "Supplying your own relationship matrix",
    fixed = TRUE
  )
  expect_match(article_text, "Ginv", fixed = TRUE)
  expect_match(article_text, "1e-6 * diag", fixed = TRUE)
  expect_match(article_text, "monozygotic", ignore.case = TRUE)
  expect_match(article_text, "Va / (Va + Ve)", fixed = TRUE)
  expect_match(article_text, "ACE twin model", fixed = TRUE)
  expect_match(article_text, "not available from R", fixed = TRUE)

  rd <- testthat::test_path("..", "..", "man", "hs_control.Rd")
  skip_if_not(file.exists(rd), "man/hs_control.Rd not present")
  rd_text <- paste(readLines(rd, warn = FALSE), collapse = "\n")
  expect_match(rd_text, "positive definite", fixed = TRUE)
  expect_match(rd_text, "row and column names", fixed = TRUE)
  expect_match(rd_text, "1e-6", fixed = TRUE)
  expect_match(rd_text, "monozygotic", ignore.case = TRUE)
})

test_that("hs_control help names the 512-animal AI-REML boundary fallback", {
  rd <- testthat::test_path("..", "..", "man", "hs_control.Rd")
  skip_if_not(file.exists(rd), "man/hs_control.Rd not present")
  text <- paste(readLines(rd, warn = FALSE), collapse = "\n")

  expect_match(text, "512", fixed = TRUE)
  expect_match(text, "boundary_score_unresolved", fixed = TRUE)
  expect_match(text, "sparse_reml", fixed = TRUE)
  expect_match(text, "No dense-cell cap is not a size-free claim", fixed = TRUE)
  expect_match(text, "not a new covered claim", fixed = TRUE)
})

test_that("hs_control help names dense-route unit starts and rescale guidance", {
  rd <- testthat::test_path("..", "..", "man", "hs_control.Rd")
  skip_if_not(file.exists(rd), "man/hs_control.Rd not present")
  text <- paste(readLines(rd, warn = FALSE), collapse = "\n")

  expect_match(text, "Start values and limits", fixed = TRUE)
  expect_match(text, "unit start", fixed = TRUE)
  expect_match(text, "two_effect", fixed = TRUE)
  expect_match(text, "repeatability", fixed = TRUE)
  expect_match(text, "variance about 1", fixed = TRUE)
  expect_match(text, "scale_method", fixed = TRUE)
  expect_match(text, "equivariant", fixed = TRUE)
  expect_match(text, "converged", fixed = TRUE)
})

test_that("dense-limit docs state nobs^2 + nanimals^2, not n < 1000", {
  rd <- testthat::test_path("..", "..", "man", "validation_status.Rd")
  skip_if_not(file.exists(rd), "man/validation_status.Rd not present")
  text <- paste(readLines(rd, warn = FALSE), collapse = "\n")
  expect_match(text, "nobs^2 + nanimals^2", fixed = TRUE)
  expect_match(text, "1e6", fixed = TRUE)
  expect_match(text, "pedigree", ignore.case = TRUE)
  expect_no_match(text, "n <= 1000")
  expect_no_match(text, "n <~ 1000")

  article <- testthat::test_path(
    "..",
    "..",
    "vignettes",
    "articles",
    "current-limits.Rmd"
  )
  skip_if_not(file.exists(article), "current-limits.Rmd not present")
  article_text <- paste(readLines(article, warn = FALSE), collapse = "\n")
  expect_match(article_text, "nobs^2 + nanimals^2", fixed = TRUE)
  expect_match(article_text, "1e6", fixed = TRUE)
  expect_match(article_text, "pedigree", ignore.case = TRUE)
  expect_no_match(article_text, "n \u2272 1000")
  expect_no_match(article_text, "n <= 1000")
})

test_that("interval docs name average information versus finite-difference observed information", {
  article <- testthat::test_path(
    "..",
    "..",
    "vignettes",
    "articles",
    "current-limits.Rmd"
  )
  skip_if_not(file.exists(article), "current-limits.Rmd not present")
  article_text <- paste(readLines(article, warn = FALSE), collapse = "\n")
  expect_match(article_text, "Which information matrix?", fixed = TRUE)
  expect_match(article_text, "Average information", fixed = TRUE)
  expect_match(article_text, "Observed information", fixed = TRUE)
  expect_match(article_text, "fd_step = 1e-4", fixed = TRUE)
  expect_match(article_text, "same estimand", fixed = TRUE)

  pages <- c(
    heritability_interval = "heritability_interval.Rd",
    variance_component_standard_errors = "variance_component_standard_errors.Rd",
    repeatability_interval = "repeatability_interval.Rd",
    common_env_proportion_interval = "common_env_proportion_interval.Rd",
    covariance_standard_errors = "covariance_standard_errors.Rd"
  )
  for (rd_name in pages) {
    rd <- testthat::test_path("..", "..", "man", rd_name)
    skip_if_not(file.exists(rd), paste(rd_name, "not present"))
    text <- paste(readLines(rd, warn = FALSE), collapse = "\n")
    expect_match(text, "finite-difference", ignore.case = TRUE, info = rd_name)
    expect_match(text, "fd_step", fixed = TRUE, info = rd_name)
    expect_match(text, "current-limits.html", fixed = TRUE, info = rd_name)
  }

  uni <- paste(
    readLines(
      testthat::test_path(
        "..",
        "..",
        "man",
        "variance_component_standard_errors.Rd"
      ),
      warn = FALSE
    ),
    collapse = "\n"
  )
  expect_match(uni, "average-information", fixed = TRUE)
})

test_that("heritability help states default, repeatability, and multi-effect Vp", {
  rd <- testthat::test_path("..", "..", "man", "heritability.Rd")
  skip_if_not(file.exists(rd), "man/heritability.Rd not present")
  text <- paste(readLines(rd, warn = FALSE), collapse = "\n")

  expect_match(text, "What is h2 here", fixed = TRUE)
  expect_match(text, "Va + Ve", fixed = TRUE)
  expect_match(text, "Va + Vpe + Ve", fixed = TRUE)
  expect_match(text, "multi_effect", fixed = TRUE)
  expect_match(text, "Fixed-effect variance", fixed = TRUE)
  expect_match(text, "not in", fixed = TRUE)
  expect_match(text, "repeatability()", fixed = TRUE)

  rep_rd <- testthat::test_path("..", "..", "man", "repeatability.Rd")
  skip_if_not(file.exists(rep_rd), "man/repeatability.Rd not present")
  rep_text <- paste(readLines(rep_rd, warn = FALSE), collapse = "\n")
  expect_match(rep_text, "Va + Vpe + Ve", fixed = TRUE)
  expect_match(rep_text, "fixed-effect variance", ignore.case = TRUE)
})

test_that("heritability help names non-Gaussian scales and which row to report", {
  rd <- testthat::test_path("..", "..", "man", "heritability.Rd")
  skip_if_not(file.exists(rd), "man/heritability.Rd not present")
  text <- paste(readLines(rd, warn = FALSE), collapse = "\n")

  expect_match(text, "Non-Gaussian responses", fixed = TRUE)
  expect_match(text, "h2_liability", fixed = TRUE)
  expect_match(text, "pi^2/3", fixed = TRUE)
  expect_match(text, "report", ignore.case = TRUE)
  expect_match(text, "ln(1 + 1/lambda)", fixed = TRUE)
  expect_match(text, "probit", ignore.case = TRUE)
  expect_match(text, "is not\\s+available in R")
  expect_match(text, "de Villemereuil", fixed = TRUE)
  expect_match(text, "Eq 4", fixed = TRUE)
  expect_match(text, "Eq 24", fixed = TRUE)
  expect_match(text, "V_link", fixed = TRUE)
  expect_match(text, "not the latent residual", fixed = TRUE)
})

test_that("cbind help names the dense validation-scale cell cap", {
  rd <- testthat::test_path("..", "..", "man", "multivariate_extractors.Rd")
  skip_if_not(file.exists(rd), "man/multivariate_extractors.Rd not present")
  text <- paste(readLines(rd, warn = FALSE), collapse = "\n")
  expect_match(text, "max_dense_cells", fixed = TRUE)
  expect_match(text, "nobs^2 + nanimals^2", fixed = TRUE)
  expect_match(text, "few hundred animals", fixed = TRUE)
  expect_no_match(text, "fits on the default path", fixed = TRUE)

  ev <- testthat::test_path("..", "..", "man", "g_matrix_geometry.Rd")
  skip_if_not(file.exists(ev), "man/g_matrix_geometry.Rd not present")
  ev_text <- paste(readLines(ev, warn = FALSE), collapse = "\n")
  expect_match(ev_text, "max_dense_cells", fixed = TRUE)
  expect_no_match(ev_text, "fits on the default path", fixed = TRUE)

  vignette <- testthat::test_path(
    "..",
    "..",
    "vignettes",
    "articles",
    "fitting-models.Rmd"
  )
  skip_if_not(file.exists(vignette), "fitting-models article not present")
  vtext <- paste(readLines(vignette, warn = FALSE), collapse = "\n")
  expect_match(vtext, "max_dense_cells", fixed = TRUE)
  expect_match(vtext, "few hundred animals", fixed = TRUE)

  expect_error(
    genetic_covariance(list()),
    "max_dense_cells",
    fixed = TRUE
  )
})

test_that("fitting-models later examples define their data and validate", {
  vignette <- testthat::test_path(
    "..",
    "..",
    "vignettes",
    "articles",
    "fitting-models.Rmd"
  )
  skip_if_not(file.exists(vignette), "source vignette not present")
  text <- paste(readLines(vignette, warn = FALSE), collapse = "\n")
  expect_match(text, "repeated_dat <-", fixed = TRUE)
  expect_match(text, "ce_dat <-", fixed = TRUE)
  expect_match(text, "mat_dat <-", fixed = TRUE)
  expect_match(text, "Ginv <-", fixed = TRUE)
  expect_match(text, "M <-", fixed = TRUE)
  expect_match(text, "mv_dat$length", fixed = TRUE)
  expect_match(text, "bin_dat <-", fixed = TRUE)

  ped <- data.frame(
    id = c("s1", "s2", "d1", "d2", "o1", "o2", "o3", "o4"),
    sire = c(NA, NA, NA, NA, "s1", "s1", "s2", "s2"),
    dam = c(NA, NA, NA, NA, "d1", "d2", "d1", "d2")
  )
  dat <- data.frame(
    id = ped$id,
    sex = c("m", "m", "f", "f", "m", "f", "m", "f"),
    age = c(4, 5, 4, 5, 1, 1, 1, 1),
    weight = c(72, 75, 65, 68, 31, 33, 35, 30)
  )
  v <- hs_control(engine = "validate")

  repeated_dat <- data.frame(
    id = rep(dat$id, each = 2),
    y = rep(dat$weight, each = 2) + c(-0.5, 0.5)
  )
  expect_no_error(hsquared(
    y ~ animal(1 | id, pedigree = ped) + permanent(1 | id),
    data = repeated_dat,
    control = v
  ))

  ce_dat <- data.frame(
    id = dat$id,
    y = dat$weight,
    litter = c("l1", "l1", "l2", "l2", "l1", "l2", "l1", "l2")
  )
  expect_no_error(hsquared(
    y ~ animal(1 | id, pedigree = ped) + common_env(1 | litter),
    data = ce_dat,
    control = v
  ))

  mat_dat <- data.frame(
    id = c("o1", "o2", "o3", "o4"),
    y = c(31, 33, 35, 30),
    dam = c("d1", "d2", "d1", "d2")
  )
  expect_no_error(hsquared(
    y ~ animal(1 | id, pedigree = ped) + maternal_genetic(1 | dam),
    data = mat_dat,
    control = v
  ))

  g_dat <- data.frame(id = dat$id, y = dat$weight)
  Ginv <- diag(nrow(g_dat))
  dimnames(Ginv) <- list(g_dat$id, g_dat$id)
  expect_no_error(hsquared(
    y ~ genomic(1 | id, Ginv = Ginv),
    data = g_dat,
    control = v
  ))

  snp_dat <- data.frame(id = dat$id, y = dat$weight)
  set.seed(1)
  M <- matrix(
    sample(0:2, nrow(snp_dat) * 4, replace = TRUE),
    nrow = nrow(snp_dat)
  )
  rownames(M) <- snp_dat$id
  expect_no_error(hsquared(
    y ~ genomic(1 | id, markers = M),
    data = snp_dat,
    control = v
  ))

  mv_dat <- dat
  mv_dat$length <- c(120, 122, 118, 119, 80, 81, 83, 79)
  expect_no_error(hsquared(
    cbind(weight, length) ~ sex + age + animal(1 | id, pedigree = ped),
    data = mv_dat,
    control = v
  ))
})

test_that("hsquared#270: interval and SE pages name warn-and-return, not omission", {
  hi <- testthat::test_path("..", "..", "man", "heritability_interval.Rd")
  se <- testthat::test_path(
    "..",
    "..",
    "man",
    "variance_component_standard_errors.Rd"
  )
  h2 <- testthat::test_path("..", "..", "man", "heritability.Rd")
  skip_if_not(file.exists(hi), "man/heritability_interval.Rd not present")
  skip_if_not(
    file.exists(se),
    "man/variance_component_standard_errors.Rd not present"
  )
  skip_if_not(file.exists(h2), "man/heritability.Rd not present")

  hi_text <- paste(readLines(hi, warn = FALSE), collapse = "\n")
  se_text <- paste(readLines(se, warn = FALSE), collapse = "\n")
  h2_text <- paste(readLines(h2, warn = FALSE), collapse = "\n")

  expect_no_match(hi_text, "the estimate is interior to")
  expect_match(hi_text, "must not be reported", fixed = TRUE)
  expect_match(hi_text, "warns", ignore.case = TRUE)
  expect_match(hi_text, "summary()", fixed = TRUE)
  expect_match(hi_text, "printed SE/CI block", fixed = TRUE)

  expect_no_match(se_text, "fields are omitted")
  expect_match(se_text, "must not be reported", fixed = TRUE)
  expect_match(se_text, "warn", ignore.case = TRUE)
  expect_match(se_text, "summary()", fixed = TRUE)

  expect_match(h2_text, "heritability_interval()", fixed = TRUE)
  expect_match(h2_text, "summary()", fixed = TRUE)
  expect_match(h2_text, "printed SE/CI block", fixed = TRUE)
})

test_that("random-regression help tells users to rescale the response", {
  rd <- testthat::test_path(
    "..",
    "..",
    "man",
    "random_regression_extractors.Rd"
  )
  skip_if_not(
    file.exists(rd),
    "man/random_regression_extractors.Rd not present"
  )
  rd_text <- paste(readLines(rd, warn = FALSE), collapse = "\n")
  expect_match(rd_text, "unit variance", fixed = TRUE)
  expect_match(rd_text, "converged = TRUE", fixed = TRUE)
  expect_match(rd_text, "REML optimum", fixed = TRUE)

  article <- testthat::test_path(
    "..",
    "..",
    "vignettes",
    "articles",
    "current-limits.Rmd"
  )
  skip_if_not(file.exists(article), "current-limits article not present")
  article_text <- paste(readLines(article, warn = FALSE), collapse = "\n")
  expect_match(article_text, "Rescale the response to about unit", fixed = TRUE)
  expect_match(article_text, "random_regression", fixed = TRUE)
})

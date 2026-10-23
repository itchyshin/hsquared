# hsquared#288: user-facing help, warnings, and articles must cite
# repo-only design/dev-log/sim paths with a GitHub URL, using the
# repo that actually contains the file.

hs_r_blob <- function(path) {
  paste0("https://github.com/itchyshin/hsquared/blob/main/", path)
}

hs_jl_blob <- function(path) {
  paste0("https://github.com/itchyshin/HSquared.jl/blob/main/", path)
}

hs_read_pkg <- function(...) {
  path <- testthat::test_path("..", "..", ...)
  skip_if_not(file.exists(path), paste(c(...), collapse = "/"))
  paste(readLines(path, warn = FALSE), collapse = "\n")
}

test_that("validation_status help cites ledger files by GitHub URL", {
  text <- hs_read_pkg("man", "validation_status.Rd")
  expect_match(
    text,
    hs_r_blob("docs/design/capability-status.md"),
    fixed = TRUE
  )
  expect_match(
    text,
    hs_r_blob("docs/design/45-bridge-production-fences-DRAFT.md"),
    fixed = TRUE
  )
  expect_match(
    text,
    "https://github.com/itchyshin/hsquared/tree/main/docs/dev-log/comparator-runs/",
    fixed = TRUE
  )
})

test_that("repeated-records warning and formula_status cite the MV PE note by URL", {
  ped <- data.frame(
    id = c("a", "b", "c", "d", "e"),
    sire = c(NA, NA, NA, "a", "a"),
    dam = c(NA, NA, NA, "b", "c"),
    stringsAsFactors = FALSE
  )
  set.seed(5)
  dat <- data.frame(
    id = rep(c("a", "b", "c", "d", "e"), each = 3),
    t1 = stats::rnorm(15),
    t2 = stats::rnorm(15),
    stringsAsFactors = FALSE
  )
  w <- tryCatch(
    hsquared(
      cbind(t1, t2) ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = hs_control(engine = "validate")
    ),
    warning = conditionMessage
  )
  note <- hs_r_blob("docs/design/57-mv-pe-cbind-permanent-237.md")
  expect_match(w, note, fixed = TRUE)

  fs <- formula_status()
  row <- fs[fs$term == "permanent(1 | id)", ]
  expect_equal(nrow(row), 1L)
  expect_match(row$current_behavior, note, fixed = TRUE)
})

test_that("genome-wide calibration metadata cites the Julia REBUILD gate by URL", {
  src <- hs_read_pkg("R", "gwas.R")
  expect_match(
    src,
    hs_jl_blob("sim/phase5_qtl_rebuild_production_gate.jl"),
    fixed = TRUE
  )
  expect_no_match(src, "(sim/phase5_qtl_rebuild_production_gate.jl)", fixed = TRUE)
})

test_that("user-facing articles cite repo-only design/dev-log/sim paths by URL", {
  articles <- list(
    list(
      file = c("vignettes", "articles", "current-limits.Rmd"),
      url = hs_r_blob("docs/design/capability-status.md")
    ),
    list(
      file = c("vignettes", "articles", "genomics-gpu-roadmap.Rmd"),
      url = hs_r_blob("docs/design/07-genomics-qtl-gpu-plan.md")
    ),
    list(
      file = c("vignettes", "articles", "benchmark-comparators.Rmd"),
      url = hs_r_blob("docs/design/01-v0.1-contract.md")
    ),
    list(
      file = c("vignettes", "articles", "rr-comparator.Rmd"),
      url = hs_jl_blob("docs/design/22-rr-convention-lock.md")
    ),
    list(
      file = c("vignettes", "articles", "two-effect-comparator.Rmd"),
      url = hs_jl_blob(
        "docs/dev-log/recovery-checkpoints/2026-06-30-v3-two-effect-blupf90-comparator.md"
      )
    ),
    list(
      file = c("vignettes", "articles", "multi-effect-comparator.Rmd"),
      url = hs_r_blob("sim/phase2_multi_effect_live_parity.R")
    )
  )

  for (article in articles) {
    text <- do.call(hs_read_pkg, as.list(article$file))
    expect_match(text, article$url, fixed = TRUE, info = article$file[[3L]])
  }
})

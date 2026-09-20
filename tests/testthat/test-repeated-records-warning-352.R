# Repeated records with no permanent-environment term (HSquared.jl#352 item 3).
#
# With >1 record per individual and only the additive effect in the model,
# sigma^2_a absorbs the permanent-environment variance: nothing else can explain
# why repeated records on the same individual resemble each other. On the great
# tit data this returned a single animal = 1.110 where ASReml's
# vm(animal) + ide(animal) was 0.595 + 0.525. It was silent.
#
# The issue asked the R side to REFUSE. It warns instead: refusing would reject
# models legitimately specified this way, and the warning names the now-reachable
# alternative, which a refusal at the time the issue was filed could not.

hs_rr_ped <- function() {
  data.frame(
    id = c("a", "b", "c", "d", "e"),
    sire = c(NA, NA, NA, "a", "a"),
    dam = c(NA, NA, NA, "b", "c"),
    stringsAsFactors = FALSE
  )
}

test_that("repeated records with no permanent() term warn about absorbed V_PE", {
  set.seed(1)
  dat <- data.frame(
    id = rep(c("a", "b", "c", "d", "e"), each = 3),
    y = stats::rnorm(15),
    stringsAsFactors = FALSE
  )
  expect_warning(
    hsquared(
      y ~ animal(1 | id, pedigree = hs_rr_ped()),
      data = dat,
      control = hs_control(engine = "validate")
    ),
    "15 records for 5 individuals"
  )
  # The warning must name the fix, not just the problem.
  w <- tryCatch(
    hsquared(
      y ~ animal(1 | id, pedigree = hs_rr_ped()),
      data = dat,
      control = hs_control(engine = "validate")
    ),
    warning = conditionMessage
  )
  expect_match(w, "permanent(1 | ...)", fixed = TRUE)
  expect_match(w, "repeatability", fixed = TRUE)
  expect_match(w, "scale_method", fixed = TRUE)
  expect_match(w, "ABSORB", fixed = TRUE)
})

test_that("one record per individual does not warn", {
  set.seed(2)
  dat <- data.frame(
    id = c("a", "b", "c", "d", "e"),
    y = stats::rnorm(5),
    stringsAsFactors = FALSE
  )
  expect_no_warning(
    hsquared(
      y ~ animal(1 | id, pedigree = hs_rr_ped()),
      data = dat,
      control = hs_control(engine = "validate")
    )
  )
})

test_that("repeated records WITH permanent() do not warn", {
  set.seed(3)
  dat <- data.frame(
    id = rep(c("a", "b", "c", "d", "e"), each = 3),
    y = stats::rnorm(15),
    stringsAsFactors = FALSE
  )
  expect_no_warning(
    hsquared(
      y ~ animal(1 | id, pedigree = hs_rr_ped()) + permanent(1 | id),
      data = dat,
      control = hs_control(engine = "validate")
    )
  )
})

test_that("the warning is suppressible for a deliberate single-effect model", {
  set.seed(4)
  dat <- data.frame(
    id = rep(c("a", "b", "c", "d", "e"), each = 3),
    y = stats::rnorm(15),
    stringsAsFactors = FALSE
  )
  expect_no_warning(suppressWarnings(
    hsquared(
      y ~ animal(1 | id, pedigree = hs_rr_ped()),
      data = dat,
      control = hs_control(engine = "validate")
    )
  ))
})

test_that("formula_status() points repeated-measures users at the right route", {
  fs <- formula_status()
  row <- fs[fs$term == "permanent(1 | id)", ]
  expect_equal(nrow(row), 1L)
  # Discoverability was the other half of the failure: the target existed and
  # was still missed, so the status row must name the model AND the scale lever.
  expect_match(row$current_behavior, "REPEATED-MEASURES", fixed = TRUE)
  expect_match(row$current_behavior, "scale_method", fixed = TRUE)
  expect_match(row$current_behavior, "ABSORB", fixed = TRUE)
})

test_that("a multivariate response is not told to add a term it cannot accept", {
  # hsquared#212's defect class: naming a lever the target does not accept. The
  # multivariate route admits a single random-intercept animal effect and
  # nothing else, so the univariate `permanent()` recipe would be rejected if a
  # reader followed it. The absorption is still real and still reported.
  ped <- hs_rr_ped()
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
  expect_match(w, "15 records for 5 individuals", fixed = TRUE)
  expect_match(w, "ABSORB", fixed = TRUE)
  expect_match(w, "cannot carry a `permanent()` term", fixed = TRUE)
  # It must NOT hand out the univariate call.
  expect_false(grepl("target = \"repeatability\"", w, fixed = TRUE))
  expect_false(grepl("scale_method", w, fixed = TRUE))
})

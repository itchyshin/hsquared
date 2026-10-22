# Table-driven guard tests for the formula-term parsers in R/model-spec.R.
# Each row is a malformed term and a fragment of the message it must raise, so
# a reworded or dropped guard fails here instead of silently changing the
# error an applied user sees. Branches already asserted in test-maternal.R
# (`no extra arguments`, `dams must be`) are not repeated.

guard_ped <- data.frame(
  id = c("a", "b", "c", "d", "e"),
  sire = c(NA, NA, NA, "a", "a"),
  dam = c(NA, NA, NA, "b", "c")
)
guard_dat <- data.frame(
  y = c(1, 2, 3, 4),
  id = c("b", "c", "d", "e"),
  g = c("g1", "g1", "g2", "g2"),
  mum = c("a", "a", "b", "c"),
  z = c(0.1, 0.4, 0.2, 0.9),
  age = c(1, 2, 3, 4)
)
guard_k <- diag(4)
dimnames(guard_k) <- list(guard_dat$id, guard_dat$id)

expect_guard <- function(formula, fragment) {
  expect_error(
    hsquared:::hs_build_model_spec(
      formula,
      data = guard_dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    fragment,
    fixed = TRUE
  )
}

test_that("animal() rejects malformed random-effect terms with a named message", {
  cases <- list(
    list(
      y ~ animal(formula = 1 | id, pedigree = guard_ped),
      "Write the random-effect"
    ),
    list(
      y ~ animal(pedigree = guard_ped),
      "must have one random-effect expression"
    ),
    list(
      y ~ animal(1 | id, guard_ped),
      "must have one random-effect expression"
    ),
    list(
      y ~ animal(id, pedigree = guard_ped),
      "argument must be a random-effect"
    ),
    list(
      y ~ animal(1 | f(id), pedigree = guard_ped),
      "must be a bare column name"
    ),
    list(
      y ~ animal(1 | id + z, pedigree = guard_ped),
      "must be a bare column name"
    ),
    list(
      y ~ animal(1 + z | id, pedigree = guard_ped),
      "are implemented inside `animal()`"
    )
  )
  for (case in cases) {
    expect_guard(case[[1L]], case[[2L]])
  }
})

test_that("rr() on the animal left-hand side must name one bare covariate", {
  cases <- list(
    list(
      y ~ animal(rr(order = 2) | id, pedigree = guard_ped),
      "must name exactly one covariate"
    ),
    list(
      y ~ animal(rr(age, z, order = 2) | id, pedigree = guard_ped),
      "must name exactly one covariate"
    ),
    list(
      y ~ animal(rr(f(age), order = 2) | id, pedigree = guard_ped),
      "covariate must be a bare column name"
    )
  )
  for (case in cases) {
    expect_guard(case[[1L]], case[[2L]])
  }
})

test_that("metafounder() rejects malformed random-effect terms", {
  gamma <- matrix(1, 1, 1)
  cases <- list(
    list(
      y ~ metafounder(formula = 1 | id, pedigree = guard_ped, Gamma = gamma),
      "Write the random-effect"
    ),
    list(
      y ~ metafounder(pedigree = guard_ped, Gamma = gamma),
      "must have one random-effect expression"
    ),
    list(
      y ~ metafounder(id, pedigree = guard_ped, Gamma = gamma),
      "argument must be a random-effect"
    ),
    list(
      y ~ metafounder(z | id, pedigree = guard_ped, Gamma = gamma),
      "Only random-intercept syntax"
    ),
    list(
      y ~ metafounder(1 | f(id), pedigree = guard_ped, Gamma = gamma),
      "must be a bare column name"
    )
  )
  for (case in cases) {
    expect_guard(case[[1L]], case[[2L]])
  }
})

test_that("common_env() rejects malformed terms and extra arguments", {
  base <- quote(animal(1 | id, pedigree = guard_ped))
  cases <- list(
    list(
      bquote(y ~ .(base) + common_env(pedigree = guard_ped)),
      "must have one random-effect expression"
    ),
    list(
      bquote(y ~ .(base) + common_env(g)),
      "must be a random-effect expression"
    ),
    list(
      bquote(y ~ .(base) + common_env(z | g)),
      "Only random-intercept syntax"
    ),
    list(
      bquote(y ~ .(base) + common_env(1 | f(g))),
      "must be a bare column name"
    ),
    list(
      bquote(y ~ .(base) + common_env(1 | g, extra = 1)),
      "takes no extra arguments in the v0.1"
    )
  )
  for (case in cases) {
    expect_guard(eval(case[[1L]]), case[[2L]])
  }
})

test_that("maternal_genetic() rejects malformed terms", {
  base <- quote(animal(1 | id, pedigree = guard_ped))
  cases <- list(
    list(
      bquote(y ~ .(base) + maternal_genetic(pedigree = guard_ped)),
      "must have one random-effect expression"
    ),
    list(
      bquote(y ~ .(base) + maternal_genetic(mum)),
      "must be a random-effect expression"
    ),
    list(
      bquote(y ~ .(base) + maternal_genetic(z | mum)),
      "Only random-intercept syntax"
    ),
    list(
      bquote(y ~ .(base) + maternal_genetic(1 | f(mum))),
      "must be a bare column name"
    ),
    list(
      bquote(y ~ .(base) + maternal_genetic(1 | nodam)),
      "was not found in `data`"
    )
  )
  for (case in cases) {
    expect_guard(eval(case[[1L]]), case[[2L]])
  }
})

test_that("permanent() rejects malformed terms and a mismatched group", {
  base <- quote(animal(1 | id, pedigree = guard_ped))
  cases <- list(
    list(
      bquote(y ~ .(base) + permanent(pedigree = guard_ped)),
      "must have one random-effect expression"
    ),
    list(
      bquote(y ~ .(base) + permanent(id)),
      "must be a random-effect expression"
    ),
    list(
      bquote(y ~ .(base) + permanent(z | id)),
      "Only random-intercept syntax"
    ),
    list(
      bquote(y ~ .(base) + permanent(1 | f(id))),
      "must be a bare column name"
    ),
    list(
      bquote(y ~ .(base) + permanent(1 | id, extra = 1)),
      "takes no extra arguments"
    ),
    list(
      bquote(y ~ .(base) + permanent(1 | g)),
      "must use the same grouping variable"
    )
  )
  for (case in cases) {
    expect_guard(eval(case[[1L]]), case[[2L]])
  }
})

test_that("relmat() and precision() reject malformed random-effect terms", {
  cases <- list(
    list(
      y ~ relmat(id, K = guard_k),
      "argument must be a random-effect"
    ),
    list(
      y ~ relmat(K = guard_k),
      "must have one random-effect expression"
    ),
    list(
      y ~ relmat(z | id, K = guard_k),
      "Only random-intercept syntax"
    ),
    list(
      y ~ relmat(1 | f(id), K = guard_k),
      "The grouping variable in"
    ),
    list(
      y ~ precision(1 | f(id), Q = guard_k),
      "The grouping variable in"
    )
  )
  for (case in cases) {
    expect_guard(case[[1L]], case[[2L]])
  }
})

test_that("genomic() and single_step() reject malformed random-effect terms", {
  cases <- list(
    list(y ~ genomic(Ginv = guard_k), "must have one random-effect expression"),
    list(y ~ genomic(id, Ginv = guard_k), "argument must be a random-effect"),
    list(y ~ genomic(z | id, Ginv = guard_k), "Only random-intercept syntax"),
    list(y ~ genomic(1 | f(id), Ginv = guard_k), "must be a bare column name"),
    list(
      y ~ single_step(Hinv = guard_k),
      "must have one random-effect expression"
    ),
    list(
      y ~ single_step(1 | f(id), Hinv = guard_k),
      "must be a bare column name"
    )
  )
  for (case in cases) {
    expect_guard(case[[1L]], case[[2L]])
  }
})

test_that("a bare random effect rejects a non-symbol grouping", {
  expect_guard(
    y ~ animal(1 | id, pedigree = guard_ped) + (1 | f(g)),
    "bare `(1 | group)` random effect must be a bare column name"
  )
})

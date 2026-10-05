#' Random-regression formula marker
#'
#' `r lifecycle::badge("experimental")`
#'
#' `rr()` is the opt-in random-regression (reaction-norm) left-hand side of an
#' [animal()] term. Write
#' `animal(rr(age, order = 2) | id, pedigree = ped)` and fit with
#' `control = hs_control(engine = "julia", engine_control = list(target = "random_regression"))`.
#' Calling `rr()` on its own is a syntax marker and returns `NULL`.
#'
#' `order` is the number of normalized-Legendre coefficients, not the
#' polynomial degree. `order = 2` is a linear reaction norm: intercept +
#' slope, so `K_g` is 2 x 2. A user who wants a quadratic Legendre polynomial
#' (three coefficients) writes `order = 3`. The default is `order = 2`. The
#' path is covered at `k = 2`; `k >= 3` stays experimental.
#'
#' The engine maps the covariate to `[-1, 1]` over the *fitted* data range
#' (the observed min and max). `K_g` is estimated in that standardized
#' basis (`phi_n(t) = sqrt((2n+1)/2) P_n(t)`). A comparison with another
#' program must rebuild the same mapping and the same normalized Legendre
#' family; otherwise the coefficient covariances are not the same estimand.
#'
#' `order` must be a literal positive integer in the formula. A name such as
#' `ord <- 2L; rr(age, order = ord)` is not evaluated by the parser.
#'
#' @param covariate A bare column name for a numeric within-individual
#'   covariate (repeated records), for example `age` or `dim`.
#' @param order Number of normalized-Legendre coefficients. Default `2`
#'   (intercept + slope). Must be a literal positive integer.
#' @param ... Reserved for future syntax such as `type =`.
#'
#' @return `NULL`, invisibly. The call is interpreted by [hsquared()] when it
#'   appears inside `animal(rr(...) | id, ...)`.
#'
#' @seealso [animal()], [hs_control()], [rr_covariance()]
#' @examples
#' # n = 4 animals x 3 ages is a syntax demo, not a number for a paper.
#' ped <- data.frame(
#'   id = c("sire", "dam", "off1", "off2"),
#'   sire = c(NA, NA, "sire", "sire"),
#'   dam = c(NA, NA, "dam", "dam")
#' )
#' dat <- data.frame(
#'   id = rep(c("off1", "off2"), each = 3),
#'   age = rep(c(1, 3, 5), 2),
#'   weight = c(38, 40, 41, 36, 37, 39)
#' )
#' model_spec(
#'   weight ~ animal(rr(age, order = 2) | id, pedigree = ped),
#'   data = dat
#' )
#' @export
rr <- function(covariate, order = 2, ...) {
  invisible(NULL)
}

# Block unsupported likelihood-inference helpers

These methods intentionally fail with explicit scope messages. v0.1
reports point estimates, likelihood summaries for converged fits, and
diagnostics, but validated standard errors, confidence intervals,
profile likelihoods, and likelihood-ratio tests are deferred until they
have validation evidence.

## Usage

``` r
# S3 method for class 'hsquared_fit'
confint(object, parm, level = 0.95, ...)

# S3 method for class 'hsquared_fit'
vcov(object, ...)

# S3 method for class 'hsquared_fit'
profile(fitted, ...)

# S3 method for class 'hsquared_fit'
anova(object, ...)
```

## Arguments

- object:

  An `hsquared_fit` object.

- parm, level:

  Included for compatibility with
  [`stats::confint()`](https://rdrr.io/r/stats/confint.html).

- ...:

  Reserved for future arguments.

- fitted:

  An `hsquared_fit` object for
  [`stats::profile()`](https://rdrr.io/r/stats/profile.html).

## Value

These functions always error.

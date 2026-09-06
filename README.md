# hsquared

<!-- ONE hex only: pkgdown uses man/figures/logo.* in the page header (drmTMB pattern).
     Do not also put a hex in this title or in a hero block — that made three. -->
<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/itchyshin/hsquared/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/itchyshin/hsquared/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

<p class="hs-kicker">R interface · Julia engine · a twin, not a port</p>

<p class="hs-question">How much is genetic?</p>

<p class="hs-pitch">Formula first. The engine estimates heritability, variance
components, and breeding values on the routes that are
<strong>covered</strong>. Experimental 0.8.0 — not production, not CRAN,
and 0.9 is not released.</p>

<p class="hs-cta">
<a class="hs-btn hs-btn-primary" href="articles/hsquared.html">Getting started</a>
<a class="hs-btn" href="articles/current-limits.html">Can I fit and report this?</a>
<a class="hs-btn" href="articles/model-status.html">What is covered today?</a>
</p>

> **Warning — experimental 0.8.0.** Not production / not CRAN / 0.9 is not
> released. `public_covered_count` is **7**. Fitting needs a local Julia and an
> `HSquared.jl` checkout — R alone parses and validates but does not fit.
> Julia engine-covered ≠ R-public covered. Report point estimates only for
> **covered** routes. Intervals are experimental and **not coverage-calibrated**.
> See [Can I fit and report this?](articles/current-limits.html).

## Start here

| If you want to… | Read this |
| --- | --- |
| check a formula without installing Julia | [Getting started](articles/hsquared.html) (`engine = "validate"`) |
| decide whether a number may go in a paper | [Can I fit and report this?](articles/current-limits.html) |
| see the seven covered routes | [Model status](articles/model-status.html) |
| set up the Julia engine | [Installation](#installation) |
| look up a function | [Reference](reference/index.html) |

## Quick start — no Julia required

This four-animal pedigree is a syntax demo, not a number for a paper.

```r
library(hsquared)

ped <- data.frame(
  id   = c("sire", "dam", "off1", "off2"),
  sire = c(NA, NA, "sire", "sire"),
  dam  = c(NA, NA, "dam", "dam")
)
dat <- data.frame(
  id     = c("sire", "dam", "off1", "off2"),
  sex    = c("m", "f", "m", "f"),
  weight = c(42, 38, 40, 37)
)

hsquared(
  weight ~ sex + animal(1 | id, pedigree = ped),
  data = dat,
  engine = "validate"
)
```

## Fitting — requires the Julia engine

With a local Julia, `JuliaCall`, and an `HSquared.jl` checkout (see
[Installation](#installation)):

```r
fit <- hsquared(
  weight ~ sex + animal(1 | id, pedigree = ped),
  data = dat
)
summary(fit)
```

Report only what [Can I fit and report this?](articles/current-limits.html)
allows for the route you ran.

## Installation

```r
# install.packages("remotes")
remotes::install_github("itchyshin/hsquared")
```

Fitting also needs Julia, `JuliaCall`, and a local `HSquared.jl` tree.
`HSquared` is not in the Julia General registry — do not use
`Pkg.add("HSquared")` by name.

```r
install.packages("JuliaCall")
```

Clone or point at your `HSquared.jl` checkout per the getting-started guide.

## Twin

`hsquared` is the applied R interface.
[HSquared.jl](https://itchyshin.github.io/HSquared.jl/) is the sparse engine.
A twin, not a port.

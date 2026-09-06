# hsquared <a href="https://itchyshin.github.io/hsquared/"><img src="man/figures/logo.png" align="right" height="138" alt="hsquared hex logo (PROPOSAL)" /></a>

<!-- HEX: PROPOSAL pending Shinichi pick (BRAIN-NOTES 2026-09-06). Not a settled brand. -->
<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/itchyshin/hsquared/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/itchyshin/hsquared/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

<div class="hs-banner" role="status">
<p><strong>Warning — experimental 0.8.0.</strong> Not production / not CRAN /
0.9 is not released. The version number tracks <em>covered</em> capability,
not surface area; the first CRAN release is not this bump.
<code>public_covered_count</code> is <strong>7</strong>.
<strong>Fitting requires a local Julia and an <code>HSquared.jl</code>
checkout</strong> — R alone parses and validates a model but does not fit
it. Julia engine-covered evidence is <strong>not</strong> R-public covered:
factor-analytic G stays <strong>planned</strong> on the R formula;
single-step stays <strong>opt-in partial</strong> (not default-route). The
Julia twin's General registration
(<a href="https://github.com/JuliaRegistries/General/pull/166969">PR #166969</a>)
is deferred pending collaborator review; do not use
<code>Pkg.add("HSquared")</code> by name. What you may report is listed on
<a href="https://itchyshin.github.io/hsquared/articles/current-limits.html">Can I fit and report this?</a>
— not in <code>validation_status()</code>. Report point estimates only for
<strong>covered</strong> routes. Standard errors and intervals are
experimental and <strong>not coverage-calibrated</strong>.</p>
</div>

`hsquared` is the R interface for a Julia-backed quantitative-genetic
modelling system. The first question is simple:

<blockquote class="hs-question">
<p>How much is genetic?</p>
</blockquote>

The default path is the univariate Gaussian animal model. The R package
owns the formula, the summaries, and the extractors. `HSquared.jl` owns
the engine — a twin, not a port.

## Start here

| If you want to… | Read this |
| --- | --- |
| check a formula without installing Julia | [Getting started](https://itchyshin.github.io/hsquared/articles/hsquared.html) (`engine = "validate"`) |
| decide whether a number may go in a paper | [Can I fit and report this?](https://itchyshin.github.io/hsquared/articles/current-limits.html) |
| see the seven covered routes | [Model status](https://itchyshin.github.io/hsquared/articles/model-status.html) |
| set up the Julia engine | [Installation](#installation) |
| look up a function | [Reference](https://itchyshin.github.io/hsquared/reference/) |

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
  control = hs_control(engine = "validate")
)

model_spec(
  weight ~ sex + animal(1 | id, pedigree = ped),
  data = dat
)
```

`engine = "validate"` confirms the formula and data. `model_spec()` shows
the parsed design and the engine target — without fitting.

## Fitting — requires the Julia engine

With a local Julia, `JuliaCall`, and an `HSquared.jl` checkout (see
[Engine setup](#engine-setup)), the same call *attempts* a fit. This is
not a silent fallback.

**n = 4 is still a syntax demo.** This tiny pedigree often fails to
converge. You may see `converged: FALSE` and a near-zero heritability.
That is not h² = 0, and it is not a number for a paper. Check
`fit_diagnostics(fit)` first. The successful first path on this page is
`engine = "validate"` above.

```r
fit <- hsquared(
  weight ~ sex + animal(1 | id, pedigree = ped),
  data = dat
)

fit_diagnostics(fit)
heritability(fit)          # warns if the fit did not converge
variance_components(fit)
breeding_values(fit)
```

Without the engine, this call errors with install guidance rather than
silently degrading.

## What is covered (count 7)

Covered means a pre-declared recovery gate passed and an external
same-estimand comparator agrees. Point estimates are reportable inside
the stated scope. Several of these are **validation-scale** and still
carry the experimental 0.8.0 label. `public_covered_count` is **7**.

- Univariate Gaussian animal model on the default call
  (`y ~ fixed + animal(1 | id, pedigree = ped)`, REML)
- Common-environment two-effect
- Arbitrary-N independent multi-effect
- Random regression, **k = 2 only**
- Direct–maternal correlated 2×2 G (`heritability()` returns the
  labelled Willham triple, not a bare scalar)
- Unstructured multivariate **t = 2** via `cbind()` (k ≥ 3 and diagonal
  stay out)
- Genomic GREML on the ordinary
  `hsquared(y ~ genomic(1 | id, markers = M))` / `Ginv = Q` call
  (single-step and SNP-BLUP stay out)

What you may report is listed on
[Can I fit and report this?](https://itchyshin.github.io/hsquared/articles/current-limits.html).
`validation_status()` is a developer evidence table, not that list.
Evidence for the default univariate path is on
[Validation evidence](https://itchyshin.github.io/hsquared/articles/validation-evidence.html).

**Partial / opt-in** — code runs; the evidence chain has a named hole:
repeatability / permanent environment, the maternal-genetic two-effect
leg, SNP-BLUP, and single-step, all through
`hs_control(engine = "julia")` with an explicit target. Julia
engine-covered rows (for example `V2-SSHINV` / `V4-FA`) do **not** flip
R coverage.

**Planned / reserved** — parses, then aborts as planned: factor-analytic
G (`cov = fa(K)` is not an activated R formula), paternal effects,
dominance, epistasis, cytoplasmic inheritance, imprinting, and
marker / QTL scans as a public report path.

### Uncertainty

Experimental asymptotic REML standard errors and confidence intervals
are surfaced when a local engine provides them, clearly labelled
experimental and **not coverage-calibrated**. Validated SEs/CIs and
`confint()` / `vcov()` are deliberately out of scope rather than shipped
uncalibrated.

## Installation

```r
# install.packages("pak")
pak::pak("itchyshin/hsquared")
```

That installs the R package only. Fitting also needs a local
[Julia](https://julialang.org/),
[`JuliaCall`](https://cran.r-project.org/package=JuliaCall), and a local
[`HSquared.jl`](https://github.com/itchyshin/HSquared.jl) checkout.
`HSquared` is not in the Julia General registry — do not use
`Pkg.add("HSquared")` by name.

### Engine setup

```r
install.packages("JuliaCall")
```

```sh
git clone https://github.com/itchyshin/HSquared.jl
```

```r
Sys.setenv(HSQUARED_JULIA_PROJECT = "/path/to/HSquared.jl")
```

Until the engine is available, `control = hs_control(engine = "validate")`
parses and validates without fitting.

## Twin

```text
hsquared       R package: applied-user interface
HSquared.jl    Julia package: sparse quantitative-genetic engine
```

Engine docs: <https://itchyshin.github.io/HSquared.jl/>

## Development

```r
devtools::check()
```

The project operating system lives in `AGENTS.md`, `ROADMAP.md`,
`docs/design/`, `docs/dev-log/`, and `.agents/skills/`. Repository state
is authoritative.

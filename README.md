# hsquared

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/itchyshin/hsquared/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/itchyshin/hsquared/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`hsquared` is the R interface for an open, Julia-backed quantitative-genetic
modelling system. The R package owns the applied-user surface — formula syntax,
data validation, summaries, extractors, examples — and the
[`HSquared.jl`](https://github.com/itchyshin/HSquared.jl) engine does the
computation.

> [!WARNING]
> **Experimental 0.6.0 — not production / not CRAN.** The version number tracks
> *covered* capability, not surface area; the first CRAN release is not this bump. `public_covered_count` is **6**. **Fitting requires a local Julia
> and an `HSquared.jl` checkout** — R alone parses and validates a model but
> does not fit it. The Julia twin's General registration
> ([PR #166969](https://github.com/JuliaRegistries/General/pull/166969)) is
> deferred pending collaborator review; do not use `Pkg.add("HSquared")` by
> name. What you
> may report is listed on
> [Can I fit and report this?](https://itchyshin.github.io/hsquared/articles/current-limits.html)
> — not in `validation_status()`. Report point estimates only for **covered**
> routes. Standard errors and intervals are experimental and **not coverage-calibrated**.

## Quick start — no Julia required

This four-animal pedigree is a syntax demo, not a number for a paper. You can
check that the model is expressible before installing an engine:

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

`hsquared(..., engine = "validate")` confirms the formula and data.
`model_spec()` shows the parsed design and the engine target that *would* be
called — without fitting anything.

## Fitting — requires the Julia engine

With a local Julia, `JuliaCall`, and an `HSquared.jl` checkout (see
[Engine setup](#engine-setup)), the same call *attempts* a fit. This block
needs the engine; it is not a silent fallback.

**n = 4 is still a syntax demo.** This tiny pedigree often fails to
converge. You may see `converged: FALSE` and a near-zero heritability.
That is not h² = 0, and it is not a number for a paper. Check
`fit_diagnostics(fit)` first. `heritability()` warns when the fit did
not converge. The successful first path on this page is
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

The R side builds the response, design matrices, and normalized pedigree; the
engine builds `Ainv`, estimates the variance components by average-information
REML, and returns an `hsquared_fit` object. Without the engine, this call errors
with install guidance rather than silently degrading.

## What is covered, and what is not

What you may report is listed on
[Can I fit and report this?](https://itchyshin.github.io/hsquared/articles/current-limits.html).
`validation_status()` is a developer evidence table of validation atoms; it is
not the user-facing list of covered routes.

**Covered** — pre-declared recovery gate passed *and* an external same-estimand
comparator agrees. Point estimates are reportable within the stated scope:

- the **univariate Gaussian animal model** on the default call
  (`y ~ fixed + animal(1 | id, pedigree = ped)`, REML);
- **t = 2 unstructured multivariate** via a `cbind()` response on the ordinary
  `hsquared()` call (G10; validation-scale; experimental label retained;
  k≥3 and diagonal stay out);
- **common-environment two-effect** and its **arbitrary-N** independent-effect
  generalization;
- **random regression, k = 2** (k = 2 only);
- the **direct–maternal correlated 2×2 G** model, whose `heritability()` returns
  the labelled Willham triple rather than a bare scalar.

Several of these are covered at validation scale and are listed on that limits
page; some do not yet have their own `validation_status()` row.
`public_covered_count` is **6**.

Evidence for the default univariate path: known-truth DGP recovery (near-unbiased variance
components over a replicated study), the published gryphon REML estimate
(Wilson et al. 2010) within the maintainer-signed-off comparator band, and
agreement with `sommer`. Engine-recovery results are validated locally through
the R-to-Julia bridge; public CI exercises the equivalent pure-R REML reference
and skip-guards the live-engine tests, since there is no Julia in CI.

**Experimental** — the code runs and is bridge-verified, but the evidence chain
has a named hole. Exploratory use, or report beside your own comparator:
repeatability / permanent environment, the maternal-genetic two-effect leg,
genomic (GREML or SNP-BLUP), and single-step effects, all reached through
`hs_control(engine = "julia")` with an explicit target.

**Reserved syntax only** — parses, then aborts as planned, not implemented:
paternal effects, dominance, epistasis, cytoplasmic inheritance, imprinting,
custom relationship or precision matrices, and marker/QTL scans. Use
`formula_status()` to see the parsed, reserved, and planned grammar.
Output names such as `qtl_table()`, `gwas_table()`, `eqtl_table()`,
`marker_variance_explained()`, and `lod_scores()` are reserved for future fitted
marker/QTL/eQTL results; `marker_effects()` is live for the opt-in SNP-BLUP path.

### Uncertainty

Experimental asymptotic REML standard errors and confidence intervals are
surfaced when a local engine provides them, clearly labelled experimental and not
coverage-calibrated. Validated SEs/CIs and `confint()`/`vcov()` are deliberately
out of scope rather than shipped uncalibrated.

## Installation

```r
# install.packages("pak")
pak::pak("itchyshin/hsquared")
```

That installs the R package only. Fitting additionally needs a local
[Julia](https://julialang.org/), the
[`JuliaCall`](https://cran.r-project.org/package=JuliaCall) R package, and a
local `HSquared.jl` checkout.

### Engine setup

`HSquared.jl` is a from-source Julia checkout, not a package-managed dependency:

1. Install [Julia](https://julialang.org/downloads/) and the bridge R package:

   ```r
   install.packages("JuliaCall")
   ```

2. Clone the engine:

   ```sh
   git clone https://github.com/itchyshin/HSquared.jl
   ```

3. Tell `hsquared` where the checkout lives, in one of two ways:

   ```r
   # (a) for the session, or persistently via .Renviron
   Sys.setenv(HSQUARED_JULIA_PROJECT = "/path/to/HSquared.jl")

   # (b) per call, same ped/dat as the quick start
   fit <- hsquared(
     weight ~ sex + animal(1 | id, pedigree = ped),
     data = dat,
     control = hs_control(
       engine_control = list(julia_project = "/path/to/HSquared.jl")
     )
   )
   ```

Until the engine is available, `control = hs_control(engine = "validate")`
parses and validates the model without fitting.

## Data bundles

`hs_data()` records phenotype, pedigree, genotype, expression, marker,
annotation, and environment inputs for integrated workflows:

```r
bundle <- hs_data(phenotypes = dat, pedigree = ped)
summary(bundle)
data_status(bundle)

spec <- model_spec(y ~ sex + age + animal(1 | id), data = bundle)
```

The animal-model parser uses the bundle pedigree by default, so `animal(1 | id)`
is equivalent to spelling `animal(1 | id, pedigree = pedigree)` when
`data = bundle`.

`summary(bundle)` and `data_status(bundle)` report pedigree coverage, founder and
parent-link counts, marker-map size and coordinate range, genotype marker-column
counts and missing values, expression row/feature counts and annotation coverage,
and environment-key coverage. When both `genotypes` and `markers` are supplied,
genotype marker column names must match marker-map IDs exactly.

These are **metadata validation only**. Genomic, QTL/eQTL, omics, and
environment-effect models are separate routes with their own status — see the
limits page.

## Documentation

| Page | Question it answers |
|---|---|
| [Getting started](https://itchyshin.github.io/hsquared/articles/hsquared.html) | How do I fit my first model? |
| [Can I fit and report this?](https://itchyshin.github.io/hsquared/articles/current-limits.html) | May I put this number in a paper? |
| [Function map](https://itchyshin.github.io/hsquared/articles/function-map-cheatsheet.html) | Which function do I call now? |
| [Validation evidence](https://itchyshin.github.io/hsquared/articles/validation-evidence.html) | What is the evidence behind each row? |

The interface rule is deliberately simple: easy, easy, easy. Applied users are
gold; the package should make the common quantitative-genetic model feel obvious
before it exposes specialist machinery.

## Development

```r
devtools::check()
```

The project operating system lives in `AGENTS.md`, `ROADMAP.md`,
`docs/design/`, `docs/dev-log/`, and `.agents/skills/`. Repository state is
authoritative; chat memory only points agents toward the right files.

# Genomic prediction

This article shows the current opt-in genomic prediction surface in
`hsquared`. It is for users who already have a genomic relationship
inverse, a marker matrix, or a single-step relationship inverse and want
to understand which path is live today.

The current genomic paths are experimental, REML-only unless stated
otherwise, and Julia-backed. They are not the default
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
fit. They require
`control = hs_control(engine = "julia", engine_control = list(...))`, a
local Julia, `JuliaCall`, and a sibling `HSquared.jl` checkout.

## Three current paths

The current R surface has three distinct genomic paths.

| Path | Formula term | Target | Variances |
|----|----|----|----|
| GBLUP / genomic GREML from a supplied inverse | `genomic(1 | id, Ginv = Ginv)` | `target = "genomic"` | estimated by the Julia AI-REML path |
| GBLUP / genomic GREML from raw markers | `genomic(1 | id, markers = M)` | `target = "genomic"` | estimated after the engine builds and regularizes G |
| SNP-BLUP / RR-BLUP marker effects | `genomic(1 | id, markers = M)` | `target = "snp_blup"` | supplied by the user, or REML-estimated when omitted |

There is also a single-step surface:

| Path | Formula term | Target | Variances |
|----|----|----|----|
| supplied-H inverse single-step | `single_step(1 | id, Hinv = Hinv)` | `target = "single_step"` | estimated by the Julia AI-REML path |

Building `Hinv` from a pedigree and genomic relationship is planned.
APY, low-rank marker solvers, weighted genomic relationships, and
Bayesian marker models are also planned. A post-fit,
relatedness-corrected marker scan is now available experimentally via
`gwas(fit, markers)` (see *Post-fit marker scan* below) — its p-values
are **not** genome-wide calibrated; QTL/eQTL scans remain planned.

## Supplied Ginv

Use this path when you already have a genomic relationship inverse whose
row and column names match the IDs in the phenotype data.

``` r

fit_g <- hsquared(
  y ~ batch + genomic(1 | id, Ginv = Ginv),
  data = pheno,
  family = gaussian(),
  REML = TRUE,
  control = hs_control(
    engine = "julia",
    engine_control = list(target = "genomic")
  )
)

variance_components(fit_g)
heritability(fit_g)
breeding_values(fit_g)
fit_diagnostics(fit_g)
```

Read the random effect as a genomic breeding value: $`\mathbf g \sim
N(0, \mathbf G \sigma_g^2)`$, with `Ginv` supplied on the inverse scale.

The parser checks that every observed ID is present in the `Ginv`
dimnames. The current path estimates the genomic and residual variance
components by the Julia AI-REML engine. It is still partial because
broad comparator parity and production-scale genomic validation are not
complete.

## Marker-built G

Use this path when you have an individual-by-marker dosage matrix `M`,
with rownames matching the phenotype IDs.

``` r

fit_marker_g <- hsquared(
  y ~ batch + genomic(1 | id, markers = M),
  data = pheno,
  family = gaussian(),
  REML = TRUE,
  control = hs_control(
    engine = "julia",
    engine_control = list(target = "genomic")
  )
)

variance_components(fit_marker_g)
heritability(fit_marker_g)
breeding_values(fit_marker_g)
```

The engine centers the marker matrix, builds a genomic relationship
matrix, and uses a regularized inverse for the REML fit. This is
convenient for small and validation-scale examples. It is not yet a
production genotype pipeline: PLINK/VCF readers, imputation hooks,
scaling/blending choices, APY, and large on-disk marker workflows remain
future work.

## SNP-BLUP marker effects

Use this path for per-marker effects. Supply `variance_components` when
you want the effects at variance components you already trust (for
example from a prior genomic GREML fit) — a supplied-variance solve.
Omit `variance_components` to have
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
estimate `sigma_g2`/`sigma_e2` by REML from the markers
(`fit_snp_blup_reml`); the example below shows the supplied-variance
form.

``` r

fit_snp <- hsquared(
  y ~ batch + genomic(1 | id, markers = M),
  data = pheno,
  family = gaussian(),
  REML = TRUE,
  control = hs_control(
    engine = "julia",
    engine_control = list(
      target = "snp_blup",
      variance_components = c(sigma_g2 = 1.0, sigma_e2 = 2.0)
    )
  )
)

marker_effects(fit_snp)
marker_variance_explained(fit_snp)
breeding_values(fit_snp)
heritability(fit_snp)
fit_diagnostics(fit_snp)
```

`marker_effects(fit_snp)` returns one effect per marker column. The
genomic breeding values are the marker-derived predictions for each
genotyped individual. `marker_variance_explained(fit_snp)` returns a
descriptive table with each marker’s fitted contribution, computed as
effect squared times the centered marker variance and normalized across
markers. Treat it as a summary of the fitted SNP-BLUP, not as a
marker-scan p-value, QTL signal, or causal decomposition under linkage
disequilibrium. When you supply `sigma_g2`/`sigma_e2` the fitted object
records `variance_components_source = "supplied"`; if you omit them,
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
estimates the variances by REML and records
`variance_components_source = "estimated_snp_blup_reml"`.

## Supplied Hinv single-step

Use this path only when you already have a single-step inverse
relationship matrix `Hinv` with dimnames matching the phenotype IDs.

``` r

fit_h <- hsquared(
  y ~ batch + single_step(1 | id, Hinv = Hinv),
  data = pheno,
  family = gaussian(),
  REML = TRUE,
  control = hs_control(
    engine = "julia",
    engine_control = list(target = "single_step")
  )
)

variance_components(fit_h)
heritability(fit_h)
breeding_values(fit_h)
```

This is not yet automatic single-step HBLUP construction. The package
does not currently build `Hinv` from pedigree and genotype inputs. That
construction is planned as a separate validated relationship-matrix
slice.

## Output checklist

For the current genomic paths, start with:

``` r

fit_diagnostics(fit_g)
variance_components(fit_g)
heritability(fit_g)
breeding_values(fit_g)
```

For SNP-BLUP, also use:

``` r

marker_effects(fit_snp)
marker_variance_explained(fit_snp)
```

## Post-fit marker scan (experimental)

`gwas(fit, markers)` runs a dense, supplied-variance,
**relatedness-corrected** mixed-model (GLS) Wald marker scan on a fitted
Gaussian animal model, reusing the fit’s estimated variance components
and pedigree relationship. Markers are one row per animal (in the fit’s
pedigree order), one column per marker.

``` r

fit <- hsquared(y ~ x + animal(1 | id, pedigree = ped), data = dat)
scan <- gwas(fit, markers) # markers: animals x markers
scan # effect, se, z, chisq, p_value, bonferroni_p, bh_qvalue, lod
```

The p-values are **not genome-wide calibrated**: they are nominal Wald
p-values plus Bonferroni/Benjamini-Hochberg over the supplied markers
only, with no realistic-LD/design calibration, no permutation, and no
leave-one-chromosome-out (LOCO). Do not report genome-wide significance
from them.

The tabular
[`gwas_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
/
[`qtl_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
/
[`eqtl_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
output names stay reserved for a planned map-annotated scan API:

``` r

qtl_table(fit_g)    # reserved (planned map-annotated API)
gwas_table(fit_g)   # reserved
eqtl_table(fit_g)   # reserved
```

## Current evidence boundary

The current genomic and single-step rows are `partial`.

Covered in the R lane:

- parser and payload checks for supplied `Ginv`, marker matrices,
  supplied `Hinv`, and SNP-BLUP variance inputs;
- skip-guarded live bridge tests for genomic GREML, marker-built G,
  supplied `Hinv`, and SNP-BLUP when Julia and the sibling engine are
  available;
- extractor checks for variance components, genomic heritability,
  genomic breeding values, marker effects, and provenance diagnostics.

Still planned:

- production relationship-matrix construction and scaling/blending
  controls;
- building `Hinv` from pedigree plus genotype data;
- APY and low-rank large-marker workflows;
- PLINK/VCF/BCF readers and on-disk marker storage;
- genomic comparator parity with sommer, BLUPF90-family tools, JWAS, or
  other agreed benchmarks;
- marker scans, QTL, GWAS, and eQTL;
- uncertainty intervals and reliability for production genomic
  predictions.

## Background anchors

The current syntax follows standard genomic prediction ideas:
marker-based prediction of total genetic value, genomic relationship
matrices for GBLUP, and single-step blending of pedigree and genomic
information. Useful anchors are [Meuwissen, Hayes and Goddard
(2001)](https://pubmed.ncbi.nlm.nih.gov/11290733/), [VanRaden
(2008)](https://pubmed.ncbi.nlm.nih.gov/18946147/), and [Aguilar,
Misztal, Johnson, Legarra, Tsuruta and Lawlor
(2010)](https://pubmed.ncbi.nlm.nih.gov/20105546/).

For `hsquared`, those papers motivate the roadmap. The current package
exposes small, opt-in genomic building blocks and keeps broad production
genomic claims behind explicit validation gates.

See also:

- [Fitting
  models](https://itchyshin.github.io/hsquared/articles/fitting-models.md)
- [Genomics, QTL, and CPU/GPU
  roadmap](https://itchyshin.github.io/hsquared/articles/genomics-gpu-roadmap.md)
- [Model
  status](https://itchyshin.github.io/hsquared/articles/model-status.md)

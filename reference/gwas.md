# Post-fit relatedness-corrected marker scan (GWAS)

`gwas()` runs a dense, supplied-variance, relatedness-corrected
mixed-model (GLS) Wald marker scan on a fitted Gaussian animal model,
reusing the fit's estimated variance components `(σ²a, σ²e)` and
pedigree relationship. It is an experimental, validation-scale screen
that surfaces the Julia-owned `HSquared.mixed_model_marker_scan()`.

## Usage

``` r
gwas(object, markers, marker_ids = NULL, ...)
```

## Arguments

- object:

  A fitted Gaussian animal model (`hsquared_fit` from the default
  pedigree path); its variance components and pedigree relationship are
  reused so the scan is conditioned on the same covariance the model was
  fit under.

- markers:

  A numeric matrix of marker dosages with one row per animal in the
  fit's pedigree (in pedigree order) and one column per marker.

- marker_ids:

  Optional marker names; defaults to the `markers` column names, then to
  sequential ids.

- ...:

  Unused.

## Value

An `hs_gwas` data frame with one row per marker: `marker`, `effect`,
`se`, `z`, `chisq`, `p_value`, `bonferroni_p`, `bh_qvalue`, `lod`. Its
[`print()`](https://rdrr.io/r/base/print.html) method restates the
uncalibrated-significance caveat.

## Details

**The p-values are NOT genome-wide calibrated.** They are
marker-by-marker Wald (nominal) p-values plus deterministic Bonferroni
and Benjamini-Hochberg adjustments over the *supplied* marker set only.
There is no realistic-LD / study-design calibration, no permutation, and
no external comparator (the calibration gate is `HSquared.jl#48`). A
leave-one-group-out (LOCO) scan is available engine-side
(`HSquared.loco_mixed_model_marker_scan()`); this R `gwas()` wrapper
does **not** yet surface it (R LOCO surfacing is in progress), so the
scan it runs applies one whole-pedigree relationship correction across
all markers. Do not report genome-wide significance from these values.

# Post-fit relatedness-corrected marker scan (GWAS)

`gwas()` runs a dense, supplied-variance, relatedness-corrected
mixed-model (GLS) Wald marker scan on a fitted Gaussian animal model,
reusing the fit's estimated variance components `(σ²a, σ²e)` and
pedigree relationship. It is an experimental, validation-scale screen
that surfaces the Julia-owned `HSquared.mixed_model_marker_scan()`.

## Usage

``` r
gwas(
  object,
  markers,
  marker_ids = NULL,
  method = c("mixed", "single", "loco"),
  marker_groups = NULL,
  genome_wide = FALSE,
  n_permutations = 1000L,
  seed = 1L,
  ...
)
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

- method:

  `"mixed"` (default) for the relatedness-corrected mixed-model (GLS)
  scan with one whole-pedigree relationship correction across all
  markers; `"single"` for the relatedness-**un**corrected single-marker
  (OLS) scan (a naive screen useful mainly as a contrast — it is more
  inflated by relatedness than the mixed scan); or `"loco"` for a
  leave-one-group-out scan with a per-group **genomic** relationship
  correction (requires `marker_groups`). The LOCO scan reuses the
  pedigree fit's variance components while correcting with a genomic
  relationship (a scale mismatch), so it is validation-scale and
  uncalibrated like the others.

- marker_groups:

  Required for `method = "loco"` (and only then): a vector with one
  group label per marker column (for example a chromosome label).
  Markers in a group are tested with a genomic relationship built from
  all **other** groups. Needs at least two distinct, non-missing labels.

- genome_wide:

  Logical; if `TRUE` (requires `method = "single"`), add a
  genome-wide-calibrated `genome_wide_p` column via the exact
  per-dataset add-one permutation rule (see Details). Defaults to
  `FALSE` (nominal p-values only).

- n_permutations:

  Number of permutations for the genome-wide null when
  `genome_wide = TRUE` (default 1000). The add-one floor is
  `1/(n_permutations+1)`.

- seed:

  Integer RNG seed for the genome-wide permutation null (default 1), so
  the `genome_wide_p` column is reproducible for a given Julia version.

- ...:

  Unused.

## Value

An `hs_gwas` data frame with one row per marker: `marker`, `effect`,
`se`, `z`, `chisq`, `p_value`, `bonferroni_p`, `bh_qvalue`, `lod` (and,
when `genome_wide = TRUE`, `genome_wide_p`), carrying a `scan_method`
attribute (and, when `genome_wide = TRUE`, a `calibration` attribute).
Its [`print()`](https://rdrr.io/r/base/print.html) method restates the
uncalibrated-significance caveat for the nominal columns (and, for
`method = "single"`, the absence of any relatedness correction; for
`method = "loco"`, the genomic-vs-pedigree scale mismatch).

## Details

**The default `p_value`/`bonferroni_p`/`bh_qvalue` columns are NOT
genome-wide calibrated.** They are marker-by-marker Wald (nominal)
p-values plus deterministic Bonferroni and Benjamini-Hochberg
adjustments over the *supplied* marker set only. Do not report
genome-wide significance from those columns.

**Genome-wide calibration** is available via `genome_wide = TRUE` (which
requires `method = "single"`, the validated fixed-effect scope). It adds
a `genome_wide_p` column: the exact per-dataset add-one permutation
p-value (the marker is declared genome-wide significant when
`genome_wide_p <= alpha`, `alpha = 0.05`). For each analysis the
permutation null is rebuilt from the analysed phenotype (`y` permuted
conditional on `X`, re-scanned `n_permutations` times), and the
genome-wide p is `(1 + #{null max >= observed})/(n_permutations + 1)`.
This is the HSquared.jl `genome_wide_marker_scan` engine call, whose
family-wise type-I control is validated at validation and production
scale (the per-dataset add-one REBUILD gate; the anti-conservative
`(1-alpha)` quantile rule is NOT used). The result carries a
`calibration` attribute (method `permutation_addone`,
`empirical_type1 = NA` because the per-dataset rule's validity is by
construction and externally validated, named in `validation_reference`).
SCOPE: fixed-effect / intercept-only; the relatedness-corrected
mixed-model genome-wide null is NOT yet calibrated, so
`genome_wide = TRUE` is rejected for `method = "mixed"`/`"loco"`.

A leave-one-group-out (LOCO) scan is available with `method = "loco"`
and a `marker_groups` argument: when a marker is tested, the genomic
relationship correction is built from the markers **not** in that
marker's group (e.g. its chromosome), so the marker's own signal does
not leak into the background relationship. The LOCO relationship is
**genomic** (VanRaden) while the reused variance components are
**pedigree**-estimated — a scale mismatch that keeps this
validation-scale (see `method`).

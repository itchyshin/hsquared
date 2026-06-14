# Extract planned marker, QTL, GWAS, and eQTL results

These extractor names cover genomic, QTL, GWAS, and eQTL fitted results.
They return values only when an `hsquared_fit` object contains the
corresponding result field. `marker_effects()` is populated by the
opt-in SNP-BLUP path (`target = "snp_blup"`); the remaining names are
reserved for future results. The current package does not fit
marker-scan, QTL, GWAS, or eQTL models.

## Usage

``` r
marker_effects(object, ...)

marker_variance_explained(object, ...)

qtl_table(object, ...)

gwas_table(object, ...)

eqtl_table(object, ...)

lod_scores(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

The requested marker or scan result for `hsquared_fit` objects that
contain the corresponding field.

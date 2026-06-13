# Extract planned marker, QTL, GWAS, and eQTL results

These extractor names are reserved for future genomic, QTL, GWAS, and
eQTL fitted results. They return values only when an `hsquared_fit`
object contains the corresponding result field. The current package does
not fit marker-scan, QTL, GWAS, or eQTL models.

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

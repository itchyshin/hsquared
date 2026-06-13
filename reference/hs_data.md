# Create an hsquared data container

`hs_data()` collects phenotype, pedigree, genotype, marker, expression,
annotation, and environment inputs into one checked container. It is a
lightweight data-contract object for future genomic, QTL/eQTL, and
multi-omics workflows. It does not fit models.

## Usage

``` r
hs_data(
  phenotypes,
  pedigree = NULL,
  genotypes = NULL,
  markers = NULL,
  expression = NULL,
  annotation = NULL,
  environment = NULL,
  id = "id"
)
```

## Arguments

- phenotypes:

  A data frame of phenotypic records.

- pedigree:

  Optional pedigree data frame.

- genotypes:

  Optional genotype matrix or data frame.

- markers:

  Optional marker map data frame.

- expression:

  Optional expression matrix or data frame.

- annotation:

  Optional annotation data frame.

- environment:

  Optional environment/covariate data frame.

- id:

  Name of the individual ID column in `phenotypes`.

## Value

An `hs_data` object.

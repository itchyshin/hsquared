# Create an hsquared data container

`hs_data()` collects phenotype, pedigree, genotype, marker, expression,
annotation, and environment inputs into one checked container. It is a
lightweight data-contract object for future genomic, QTL/eQTL, and
multi-omics workflows. It does not fit models. The v0.1 parser can use
an `hs_data` object directly as `data`, reading model variables from
`phenotypes` and making named components such as `pedigree` available to
formula terms.

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
  environment_id = NULL,
  id = "id"
)
```

## Arguments

- phenotypes:

  A data frame of phenotypic records.

- pedigree:

  Optional pedigree data frame.

- genotypes:

  Optional genotype matrix or data frame. Matrix row names or data-frame
  ID values identify individuals. When `markers` is supplied, genotype
  marker column names must match marker-map IDs exactly.

- markers:

  Optional marker map data frame. When supplied, it must contain marker
  ID, chromosome, and position columns. Recognized aliases include
  `marker`, `snp`, or `id`; `chromosome`, `chr`, or `chrom`; and
  `position`, `pos`, `bp`, or `base_pair`.

- expression:

  Optional expression matrix or data frame.

- annotation:

  Optional annotation data frame.

- environment:

  Optional environment/covariate data frame.

- environment_id:

  Optional column name used to match `environment` rows to phenotype
  records. When supplied, the column must exist in both `phenotypes` and
  `environment`.

- id:

  Name of the individual ID column in `phenotypes`.

## Value

An `hs_data` object.

## Details

`summary(hs_data(...))` reports ID overlap diagnostics, pedigree
diagnostics, and, when genotype or marker components are supplied,
marker-map and genotype-column alignment diagnostics. When
`environment_id` is supplied, it also reports environment metadata
coverage diagnostics.

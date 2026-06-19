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
  annotation_id = NULL,
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

- annotation_id:

  Optional column name used to match `annotation` rows to expression
  feature columns. When supplied, the column must exist in `annotation`.

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
diagnostics, and, when expression, genotype, or marker components are
supplied, expression-feature, genotype-column, marker-map, and
genotype-marker alignment diagnostics. When `annotation_id` is supplied,
it reports expression-feature annotation coverage diagnostics. When
`environment_id` is supplied, it also reports environment metadata
coverage diagnostics.

## Examples

``` r
ped <- data.frame(
  id = c("a", "b", "c", "d"),
  sire = c(NA, NA, "a", "a"),
  dam = c(NA, NA, "b", "c")
)
dat <- data.frame(
  y = c(1, 2, 3),
  sex = c("f", "m", "f"),
  id = c("a", "c", "d")
)
bundle <- hs_data(phenotypes = dat, pedigree = ped)
bundle
#> <hs_data>
#>   phenotypes: 3 rows
#>   phenotype IDs: 3
#>   pedigree IDs: 4
summary(bundle)
#> <summary_hs_data>
#>   components: phenotypes, pedigree
#>   phenotype IDs: 3
#>   ID overlap:
#>                         metric count
#>                  phenotype_ids     3
#>                   pedigree_ids     4
#>                   genotype_ids     0
#>                 expression_ids     0
#>    phenotypes_without_pedigree     0
#>   phenotypes_without_genotypes     3
#>   genotypes_without_phenotypes     0
#>  phenotypes_without_expression     3
#>  expression_without_phenotypes     0
#>   pedigree status:
#>                       metric count
#>                pedigree_rows     4
#>                 pedigree_ids     4
#>  phenotype_ids_with_pedigree     3
#>            pedigree_only_ids     1
#>                     founders     2
#>                  nonfounders     2
#>             known_sire_links     2
#>              known_dam_links     2
#>     missing_known_parent_ids     0
#>       duplicate_pedigree_ids     0
#>             self_parent_rows     0
#>       same_known_parent_rows     0
```

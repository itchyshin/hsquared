# Inspect hsquared data-container status

`data_status()` gives a direct user-facing view of the checks stored in
an
[`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
object. It reports component presence, ID overlap diagnostics, pedigree
diagnostics, expression-feature diagnostics, genotype-column
diagnostics, and marker-map/genotype-marker alignment diagnostics when
those inputs are supplied. When `annotation_id` is supplied, it reports
expression-feature annotation coverage diagnostics. When
`environment_id` is supplied, it also reports environment metadata
coverage diagnostics. It does not fit models, build genomic relationship
matrices, add eQTL terms, or add environment-effect terms.

## Usage

``` r
data_status(data)
```

## Arguments

- data:

  An
  [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  object.

## Value

An `"hs_data_status"` object.

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
data_status(bundle)
#> <hs_data_status>
#>   components: phenotypes, pedigree
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
#>   expression status: not available
#>   genotype status: not available
#>   marker status: not available
#>   annotation status: not available
#>   environment status: not available
```

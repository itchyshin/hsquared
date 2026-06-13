# Inspect validation evidence status

`validation_status()` reports the current validation atoms and planned
comparator lanes for `hsquared`. It is a status table only: it does not
run validation checks, fit models, or promote any capability to working
status.

## Usage

``` r
validation_status()
```

## Value

A data frame of validation status records with class
`"hs_validation_status"`.

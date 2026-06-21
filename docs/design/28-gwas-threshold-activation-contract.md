# GWAS Threshold Activation Contract

This note defines what must be true before `hsquared` turns the current
experimental `gwas(fit, markers)` p-values into user-facing genome-wide
significance thresholds.

Current status:

- `gwas()` is live for mixed, single-marker, and LOCO scans.
- Output p-values are nominal Wald p-values, with Bonferroni and BH summaries
  computed over the supplied marker panel.
- HSquared.jl PR #134 banked a fixed-marker-panel type-I smoke harness. That
  is validation infrastructure, not an R threshold.
- HSquared.jl PR #143 (`07a3c63`) added the missing Julia
  `V5-MARKER-THRESHOLD` validation-status/source-doc row while keeping the
  threshold evidence gate open; this is status hygiene, not an R threshold.
- R must not call any line, cutoff, q-value, or table column genome-wide
  calibrated until the gates below are met.

## Activation Surface

The first activated threshold should be opt-in and explicit. A future API may
look like:

```r
scan <- gwas(fit, markers, calibration = "permutation")
gwas_table(scan)
autoplot(scan, threshold = "calibrated")
```

The exact spelling can change, but the result object must carry enough metadata
that users and plots can distinguish:

- nominal Wald p-values;
- deterministic multiplicity summaries over the supplied markers;
- empirical or simulation-backed thresholds;
- the marker panel, LD structure, and relationship correction used for
  calibration;
- whether the threshold applies to mixed, single-marker, LOCO, or another scan
  method.

## Required Result Fields

Before activation, a calibrated scan result needs at least:

- `marker`, `effect`, `se`, `z`, `chisq`, `p_value`, and `lod`;
- marker map fields when available: chromosome, position, and marker ID;
- `scan_method` with values such as `mixed`, `single`, or `loco`;
- `calibration_method`, for example `none`, `permutation`, or
  `fixed_panel_simulation`;
- `calibration_seed` or seed list;
- `n_permutations` or simulation replicate count;
- `alpha`;
- the calibrated cutoff on the reported p-value or LOD scale;
- the estimated empirical type-I error at the declared alpha;
- dropped-marker and convergence diagnostics;
- a flag saying whether the calibration used a fixed or regenerated marker
  panel;
- a provenance string naming the engine function and package version.

`autoplot.hs_gwas()` may draw a calibrated line only when these fields are
present and internally consistent. Otherwise the current Bonferroni line stays
visual only.

## Validation Gates

Activation requires all of the following.

1. A deterministic contract test proving the R result object refuses calibrated
   threshold metadata when required fields are missing or contradictory.
2. A Julia-side fixed-panel smoke that is reproducible from recorded seeds and
   produces type-I error near the declared alpha.
3. A realistic-LD or real-marker-panel calibration run that exercises a marker
   panel closer to applied use than the fixed-panel smoke.
4. A same-result comparison against an accepted scan tool or independent
   implementation for at least one small fixture, such as PLINK, GenABEL,
   GEMMA, GCTA, sommer-derived scan code, or another reviewed tool with the
   same fitted background model and test statistic.
5. A negative-control check showing no inflated genome-wide call rate under a
   null phenotype for the chosen default threshold.
6. A positive-control check where a planted marker or region is recoverable
   under the declared scan method.
7. Fisher/Curie signoff on the acceptance band, seed count, marker-panel
   assumptions, and whether the result is a smoke, validation-scale claim, or
   production claim.

The comparator must match the estimand. A Bayesian/MCMC agreement probe or a
different mixed-model background may be useful context, but it is not
same-result threshold validation by itself.

## R Boundary

Until these gates are met, R behavior remains:

- `gwas()` returns nominal/Bonferroni/BH summaries only;
- `print.hs_gwas()` and `autoplot.hs_gwas()` must keep the uncalibrated
  significance wording;
- `gwas_table(scan)` may expose the current uncalibrated `hs_gwas` rows, but
  calibrated/map-annotated fit-level `gwas_table()` output remains reserved;
- QTL and eQTL thresholds remain planned separately;
- `validation_status()` and capability rows stay partial.

## First Follow-Up Slice

The first implementation slice after this contract should not activate
thresholds. It should add a validator for optional threshold metadata on an
`hs_gwas` object and tests that reject incomplete calibration payloads. Only
after that should R consume a real engine calibration payload.

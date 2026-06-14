# SNP-BLUP Marker Variance Share Scout

Date: 2026-06-14

## Question

What should `marker_variance_explained()` mean for the current opt-in
SNP-BLUP/RR-BLUP path in `hsquared`?

## Sources Checked

- Local `HSquared.jl/src/genomic.jl`: `centered_markers()` defines
  `W = M - 2p`, `k = 2 * sum(p * (1 - p))`, and `fit_snp_blup()` fits marker
  effects with per-marker variance `sigma_g2 / k`.
- Local `HSquared.jl/docs/src/genomic-models.md`: documents the
  SNP-BLUP/GBLUP equivalence and says marker effects are deliberately not
  breeding values.
- Local `HSquared.jl/docs/dev-log/after-task/2026-06-13-snp-blup.md`: records
  the twin-side implementation and supplied-variance boundary.
- Local `gllvmTMB` covariance/explained-variance docs: useful wording pattern
  for "explained share" as an interpretation of an already-fitted latent or
  random-effect object, not a discovery statistic.
- VanRaden (2008), "Efficient Methods to Compute Genomic Predictions",
  Journal of Dairy Science, DOI: https://doi.org/10.3168/jds.2007-0980.
- Meuwissen, Hayes, and Goddard (2001), "Prediction of Total Genetic Value
  Using Genome-Wide Dense Marker Maps", Genetics, DOI:
  https://doi.org/10.1093/genetics/157.4.1819.

## Lesson

The current R path already has enough information to report a descriptive
marker contribution table for SNP-BLUP:

```text
contribution_j = alpha_j^2 * Var(W_j)
proportion_j   = contribution_j / sum(contribution)
```

where `alpha_j` is the fitted SNP-BLUP marker effect and `W_j` is the centered
marker dosage column used by the supplied-variance fit. This is useful because
it lets users inspect which fitted marker effects contribute most to the fitted
marker-score variation.

This is not a marker scan, p-value, LOD score, QTL interval, fine-mapping
result, or causal variance decomposition under linkage disequilibrium. Marker
columns can be correlated, so per-column shares should be read as descriptive
model-output summaries only.

## hsquared Action

- Populate `marker_variance_explained()` for opt-in SNP-BLUP fits.
- Use the record-level marker design and the allele frequencies returned by the
  Julia fit when available, so the centering matches the fitted marker effects.
- Keep `qtl_table()`, `gwas_table()`, `eqtl_table()`, and `lod_scores()` as
  reserved output vocabulary until scan engines exist.

## Claim Risk

Allowed wording:

```text
`marker_variance_explained()` reports descriptive fitted-marker shares for the
opt-in supplied-variance SNP-BLUP path.
```

Blocked wording:

```text
`marker_variance_explained()` identifies QTL, computes GWAS p-values, explains
causal marker variance, validates marker importance, or provides production
genomic prediction.
```

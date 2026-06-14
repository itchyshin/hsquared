# QTL, GWAS, and eQTL status

This article is a status page for marker scans, QTL, GWAS, and eQTL in
`hsquared`.

The short version:

- [`marker_effects()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  is live only for the opt-in SNP-BLUP path.
- [`marker_scan()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md),
  [`qtl_scan()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md),
  [`qtl_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
  [`gwas_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
  [`eqtl_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
  and
  [`lod_scores()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  are reserved vocabulary.
- No marker-scan, QTL, GWAS, or eQTL model is fitted today.

The goal is to make the future syntax visible without making users
wonder whether a scan engine is already hidden somewhere.

## What works today

For marker-level output, the current fitted path is SNP-BLUP at supplied
variance components:

``` r

fit_snp <- hsquared(
  y ~ batch + genomic(1 | id, markers = M),
  data = pheno,
  family = gaussian(),
  REML = TRUE,
  control = hs_control(
    engine = "julia",
    engine_control = list(
      target = "snp_blup",
      variance_components = c(sigma_g2 = 1.0, sigma_e2 = 2.0)
    )
  )
)

marker_effects(fit_snp)
breeding_values(fit_snp)
```

This is a supplied-variance marker-effect solve. It does not scan
markers for association, estimate p-values, compute LOD scores, or
identify QTL intervals.

Data diagnostics are also live:

``` r

bundle <- hs_data(
  phenotypes = pheno,
  genotypes = M,
  markers = marker_map,
  expression = expr
)

data_status(bundle)
formula_status()
validation_status()
```

Use these helpers before a scan exists. They catch ID, genotype,
marker-map, and expression-component problems that would otherwise
become hard-to-debug scan errors later.

## Reserved output vocabulary

These names are already part of the fitted-object contract:

``` r

marker_effects(fit)
marker_variance_explained(fit)
qtl_table(fit)
gwas_table(fit)
eqtl_table(fit)
lod_scores(fit)
```

Only
[`marker_effects()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
has a live producer today, and only for SNP-BLUP. The other extractors
return values only if a future engine target has produced the matching
result field.

## Planned GWAS path

The intended single-marker GWAS grammar is:

``` r

fit_gwas <- hsquared(
  y ~ sex + age +
    genomic(1 | id, Ginv = Ginv) +
    marker_scan(M, map = marker_map, leave_one_chr_out = TRUE),
  data = pheno,
  genotypes = M,
  family = gaussian()
)

gwas_table(fit_gwas)
```

This does not fit yet. Before this surface can be promoted, the engine
needs a scan target that records at least:

- marker ID, chromosome, and position;
- allele coding and tested effect;
- test statistic, p-value, and multiple-testing metadata;
- relationship correction used for the background model;
- whether LOCO or another proximal-contamination guard was used;
- convergence and dropped-marker diagnostics.

The user-facing claim should be “mixed-model marker scan” only after
those fields are produced, tested, and documented.

## Planned QTL path

For experimental crosses and line designs, QTL scans usually need more
than a raw marker matrix. The planned interval-style surface is:

``` r

fit_qtl <- hsquared(
  y ~ sex + age +
    animal(1 | id, pedigree = ped) +
    qtl_scan(position, genotype_probs = probs),
  data = pheno,
  family = gaussian()
)

qtl_table(fit_qtl)
lod_scores(fit_qtl)
```

This does not fit yet. The first credible QTL slice should carry
explicit cross or family metadata, genotype probabilities, a map, the
scan grid, and permutation or otherwise declared thresholds. Until then,
users should use specialist QTL packages for real QTL scans and use
`hsquared` for the current animal, genomic, and data-integration pieces.

## Planned eQTL path

eQTL analysis is a scale problem as much as a syntax problem. A small
cis-eQTL surface might eventually look like this:

``` r

fit_eqtl <- hsquared(
  expression ~ batch + sex +
    marker_scan(M, map = marker_map, window = "cis") +
    genomic(1 | id, Ginv = Ginv),
  data = expr_long,
  genotypes = M,
  family = gaussian()
)

eqtl_table(fit_eqtl)
```

A wide expression-matrix version is later still:

``` r

fit_eqtl_wide <- hsquared(
  expr_matrix ~ batch + sex +
    marker_scan(M, map = marker_map) +
    sample_factors(K = 5) +
    genomic(1 | id, Ginv = Ginv),
  data = expr_data,
  genotypes = M,
  family = gaussian()
)
```

Neither form fits today. The future eQTL layer needs chunked
marker-by-trait evaluation, cis/trans windows, sample-factor or batch
correction, multiple-testing accounting, missing-expression handling,
and a result table that can be written without keeping every test in
memory.

## Scale caveats

Scan outputs can become large very quickly:

- GWAS: many individuals by hundreds of thousands to millions of
  markers;
- QTL interval scans: many positions by traits or environments;
- eQTL: markers by genes, transcripts, tissues, or other molecular
  traits.

For `hsquared`, a credible scan engine must therefore be able to stream
or chunk work, avoid unnecessary dense copies, and record enough
provenance to re-run a hit. GPU acceleration may become useful for dense
marker and response-matrix operations, but CPU correctness and result
agreement come first.

## Validation gates

The first scan implementation should stay `partial` until these gates
exist:

- tiny deterministic marker tests where the known marker wins;
- null tests with calibrated false-positive behaviour at unit-test
  scale;
- ID and marker-map mismatch tests;
- one same-estimand comparison with a specialist tool for QTL or GWAS;
- a result-table schema that is stable enough for downstream plotting;
- explicit wording for missing genotypes, dropped markers, and failed
  tests.

For eQTL, add:

- a tiny cis/trans fixture;
- chunking tests over marker and expression blocks;
- multiple-testing metadata;
- a memory-use report for at least a laptop-scale example.

## Background anchors

The planned QTL grammar is anchored in interval and high-dimensional QTL
mapping; useful references include [Lander and Botstein
(1989)](https://pubmed.ncbi.nlm.nih.gov/2563713/) and [Broman et
al. (2019)](https://pubmed.ncbi.nlm.nih.gov/30591514/).

The planned GWAS path is a mixed-model scan with relatedness correction,
closer in spirit to EMMAX and GEMMA than to a simple uncorrected marker
regression; see [Kang et
al. (2010)](https://pubmed.ncbi.nlm.nih.gov/20208533/) and [Zhou and
Stephens (2012)](https://pubmed.ncbi.nlm.nih.gov/22706312/).

The planned eQTL path is motivated by the scale and structure of
expression genetics, where cis/trans windows, batch correction, and many
response traits matter; see the [GTEx Consortium atlas
(2020)](https://pmc.ncbi.nlm.nih.gov/articles/PMC7737656/).

For now, those papers motivate the roadmap. They are not evidence that
`hsquared` currently runs QTL, GWAS, or eQTL scans.

See also:

- [Genomic
  prediction](https://itchyshin.github.io/hsquared/articles/genomic-prediction.md)
- [Genomics, QTL, and CPU/GPU
  roadmap](https://itchyshin.github.io/hsquared/articles/genomics-gpu-roadmap.md)
- [Model
  status](https://itchyshin.github.io/hsquared/articles/model-status.md)

# QTL/GWAS/eQTL Extension Boundary

Date: 2026-06-14

## Decision

Keep `hsquared` as the easy modelling interface and status ledger for genomic,
marker, QTL, GWAS, and eQTL concepts. Put heavy scan execution and large-result
infrastructure into optional future extensions unless a first scan target is
small, dependency-light, and fully validated in the core package.

Proposed future extension names:

```text
hsquaredQTL      R-side scan workflows, result tables, plots, reports
HSquaredQTL.jl   Julia-side scan kernels, chunking, accelerator experiments
```

This is a boundary decision, not an implementation claim. Neither extension
exists yet.

## Core `hsquared` owns

The core R package should keep:

- simple user-facing formula vocabulary:
  - `genomic(1 | id, Ginv = Ginv)`;
  - `genomic(1 | id, markers = M)`;
  - `single_step(1 | id, Hinv = Hinv)`;
  - reserved `marker_scan()` and `qtl_scan()` terms;
- `hs_data()` metadata diagnostics for phenotype, pedigree, genotype, marker
  map, expression, annotation, and environment inputs;
- compact fitted-object extractor names:
  - `marker_effects()`;
  - `marker_variance_explained()`;
  - `gwas_table(scan)` for an already-computed `hs_gwas`;
  - `lod_scores(scan)` for an already-computed `hs_gwas`;
  - future fit-level `qtl_table()`;
  - future fit-level `gwas_table()`;
  - `eqtl_table()`;
  - map-annotated `lod_scores()`;
- status helpers and claim boundaries:
  - `formula_status()`;
  - `validation_status()`;
  - `data_status()`;
- small validation fixtures and result-shape tests for any scan output the
  engine eventually produces;
- links to extension packages once they exist.

The core package may eventually include a tiny Gaussian single-marker scan if
all of these are true:

- no heavy dependency is required;
- result schema is stable;
- a deterministic test can prove the known marker wins;
- a null test guards false-positive behaviour at unit-test scale;
- one specialist-tool comparison exists for the same estimand;
- Rose can describe the claim without using production-scale language.

## Future `hsquaredQTL` owns

The R extension should own workflows that would crowd or slow the core package:

- PLINK/VCF/BCF/BGEN and large dosage ingestion;
- Arrow/Parquet/HDF5/Zarr-backed scan datasets;
- chunked marker-by-trait orchestration;
- cis/trans window management for eQTL;
- marker/QTL/GWAS/eQTL plotting:
  - Manhattan plots;
  - QQ plots;
  - LOD curves;
  - regional plots;
- permutation, FDR, and genome-wide threshold workflows;
- fine-mapping and credible-set workflows;
- high-volume report writing;
- external-tool import/export for R/qtl2, GEMMA, PLINK, JWAS, BLUPF90-family
  tools, ASReml runs, and other agreed comparators.

The extension should depend on the core package, not the reverse.

## Future `HSquaredQTL.jl` owns

The Julia extension should own computations that are too large or specialized
for `HSquared.jl` core:

- streaming marker scans over dense or sparse marker blocks;
- LOCO and other proximal-contamination guards;
- mixed-model score/Wald/LRT scan kernels;
- matrix-free repeated solves;
- response-matrix scan primitives for eQTL and multi-omics;
- CPU/GPU benchmark harnesses for scan workloads;
- accelerator-specific kernels after CPU agreement is established.

`HSquared.jl` core should still provide the generic relationship, mixed-model,
and result-object abstractions that the extension calls.

## Routing rule

Use the core package for model language:

```r
hsquared(
  y ~ covariates + genomic(1 | id, Ginv = Ginv),
  data = pheno,
  family = gaussian()
)
```

Use the extension for scan execution once it exists:

```r
# planned future shape, not implemented
scan <- hsquaredQTL::scan_markers(
  y ~ covariates + genomic(1 | id, Ginv = Ginv),
  data = pheno,
  genotypes = M,
  map = marker_map,
  mode = "gwas"
)
```

If a formula term such as `marker_scan()` is later supported in the core
modelling interface, it should dispatch to a validated engine target or to an
installed extension explicitly. It must not silently fall back to an unvalidated
scan path.

## Result schema before syntax expansion

Any scan-producing target should return a table with at least:

- result type: `qtl`, `gwas`, or `eqtl`;
- marker or position ID;
- chromosome and position;
- tested effect and allele/genotype coding;
- estimate, standard error when validated, test statistic, p-value or LOD;
- background relationship model used;
- LOCO/proximal-contamination status when relevant;
- multiple-testing metadata;
- dropped-marker and convergence diagnostics;
- software versions and seed/provenance fields for reproducibility.

Plotting functions should consume this table. They should not depend on hidden
engine internals.

## Public-claim rule

Public docs may say:

- "QTL/GWAS/eQTL vocabulary is reserved";
- "`marker_effects()` is live for opt-in SNP-BLUP";
- "post-fit `gwas()` and `gwas_table(scan)` / `lod_scores(scan)` are
  experimental and uncalibrated";
- "formula-level scan support, calibrated thresholds, and map-annotated tables
  are planned";
- "large-scan execution is extension-bound."

Public docs must not say:

- "GWAS is supported";
- "QTL mapping is implemented";
- "eQTL analysis works";
- "GPU-accelerated scans are available";
- "hsquared replaces R/qtl2, GEMMA, JWAS, PLINK, or ASReml for scans."

Those claims require code, tests, comparator evidence, documentation, and a
Rose audit.

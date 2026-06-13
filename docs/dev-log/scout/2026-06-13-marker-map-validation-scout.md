# Scout: Marker-Map Validation Boundary

Date: 2026-06-13
Question: what should the first `hs_data()` marker-map check validate without
claiming genomic or QTL/eQTL modelling support?

## Sources Checked

- `quantgen-scout` local package map.
- Local `GLLVM.jl` docs, especially the structured-dependence note that treats
  genomic relationship matrices as external inputs from marker tools.
- Local `drmTMB`, `gllvmTMB`, `DRM.jl`, and `GLLVM.jl` searches for marker-map
  vocabulary and user-facing status patterns.

## Lesson

For this slice, marker maps should be treated as metadata. The useful first
gate is not allele parsing or marker scanning; it is checking that marker IDs,
chromosomes, and positions are present and internally usable. This follows the
sister-project pattern of accepting structured metadata early while keeping
model-fitting claims behind explicit evidence.

## hsquared Action

- Validate marker maps supplied to `hs_data()` for marker ID, chromosome, and
  non-negative numeric position columns.
- Store normalized marker IDs, chromosomes, positions, and column indices in a
  private `hs_marker_map_spec`.
- Keep genotype parsing, PLINK/VCF ingestion, marker imputation, GWAS/QTL scans,
  and genomic relationship construction planned.

## Claim Risk

Do not say marker maps imply genomic fitting. Allowed wording: marker metadata
validation only.

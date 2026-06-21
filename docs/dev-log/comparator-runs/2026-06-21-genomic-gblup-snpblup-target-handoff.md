# Genomic GBLUP / SNP-BLUP target handoff packet

Date: 2026-06-21

## Purpose

Record the R-lane handoff for the Julia-native genomic GBLUP / SNP-BLUP target
fixture added by HSquared.jl PR #140.

This packet is not comparator evidence. It is the run protocol for obtaining
external same-estimand comparator evidence.

## Capability Gate

- R issue family: `itchyshin/hsquared#7` / `itchyshin/hsquared#9`
- Julia gate: `itchyshin/HSquared.jl#49`
- Julia source: HSquared.jl `008ea4d`
- Current status: genomic/SNP-BLUP rows remain `partial`.

## Fixture

Use the committed Julia target fixture:

```text
HSquared.jl/test/fixtures/genomic_gblup_snpblup_target/
```

Files:

- `phenotypes.csv`
- `markers.csv`
- `allele_frequencies.csv`
- `expected_genomic_relationship.csv`
- `expected_genomic_precision.csv`
- `expected_beta.csv`
- `expected_gebv.csv`
- `expected_marker_effects.csv`
- `expected_metadata.csv`
- `generate.jl`

Fixture summary from `expected_metadata.csv`:

- `sigma_g2 = 2`
- `sigma_e2 = 1`
- VanRaden method 1 with supplied allele frequencies
- 4 individuals and 6 markers
- GBLUP/SNP-BLUP maximum absolute GEBV route difference:
  `1.1102230246251565e-15`

## Required Comparator Run

An accepted comparator report must record:

- tool or package name and version;
- exact HSquared.jl commit and fixture checksum or copied fixture path;
- input translation details, including marker centering and VanRaden scaling;
- supplied variance components and whether the comparator can fix or only
  estimate them;
- fixed-effect estimate;
- GEBVs aligned to `g1`-`g4`;
- marker effects aligned to `m1`-`m6` when the comparator exposes marker effects;
- convergence status and warnings;
- maximum absolute deviations from the stored targets.

Candidate comparator routes include AGHmatrix, rrBLUP, sommer, BGLR/JWAS, or a
BLUPF90-family route, but only if the report demonstrates the same estimand and
scale. A rerun of HSquared.jl itself does not count as external comparator
evidence.

## Local Tool Availability

Local R package probe on this host:

| Package | Result |
| --- | --- |
| `AGHmatrix` | MISSING |
| `rrBLUP` | MISSING |
| `sommer` | 4.4.3 |
| `BGLR` | MISSING |

`sommer` being installed is not automatically sufficient. A future `sommer`
run must show the same supplied-variance, VanRaden-method-1 target and report
the scale mapping before it can be considered comparator evidence.

## Initial Review Bands

These are review bands, not automatic promotion:

| Quantity | Proposed acceptance band |
| --- | --- |
| fixed-effect intercept | absolute difference <= `1e-6` |
| GEBVs | max absolute difference <= `1e-6` after confirmed scale mapping |
| marker effects | max absolute difference <= `1e-6` when exposed |
| relationship matrix `G` | max absolute difference <= `1e-10` |
| convergence | no unreviewed warning or boundary/singularity issue |

If the comparator estimates rather than fixes variance components, Fisher and
Curie must record a separate estimand decision before any status claim changes.

## Claim Boundary

This records target availability only. It does not add AGHmatrix, rrBLUP,
sommer, JWAS, BGLR, BLUPF90, or other external comparator evidence. It does not
activate new R genomic syntax, sparse/APY scaling, weighted/standardized marker
priors, Bayesian marker priors, or a covered-status promotion.

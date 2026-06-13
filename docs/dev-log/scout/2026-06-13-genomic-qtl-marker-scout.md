# Genomic/QTL Marker Scout

Date: 2026-06-13

Active lenses: Jason, Boole, Rose.

## Local Packages Checked

- `gllvmTMB`
- `DRM.jl`

## Useful Patterns

- `gllvmTMB` uses formula-marker families such as animal/phylogenetic keywords
  to preserve readable user syntax while routing implementation through parser
  and engine contracts.
- `DRM.jl` keeps the R-facing bridge boundary explicit: formula strings,
  families, structured terms, and flattened results are handled as a contract,
  not as implicit side effects.

## Decision For hsquared

Add `genomic()`, `single_step()`, `markers()`, `marker_scan()`, and `qtl_scan()`
only as inert syntax markers. The parser must reject them as planned, not
implemented until Julia and R have a real data, relationship, and result
contract.

## Claim Boundary

This scout supports API vocabulary only. It does not support any public claim
that genomic prediction, marker scans, QTL/eQTL analysis, or single-step models
are implemented.

# LOCO marker-scan bridge — R-wiring build-spec

Status: **IMPLEMENTED**, 2026-06-20 (R lane / Ada, Hopper, Henderson, Fisher;
adversarially reviewed by Boole/Hopper/Fisher/Curie/Rose; live-verified). The
engine contract is **proven and live-probed** (§1, §6); the open dimensional
question raised in handoff-8 is **resolved** by the probe (§3). The R wiring
(`method = "loco"` + `marker_groups`) has landed with pure-R guards and a live
parity test. This doc is kept as the as-built contract.

## 0. Why

`gwas()` already surfaces two engine marker scans: the relatedness-corrected
mixed-model scan (`method = "mixed"`, one whole-pedigree relationship correction
across all markers) and the relatedness-**un**corrected single-marker scan
(`method = "single"`). Both reuse a fitted pedigree animal model's variance
components. The missing third option is **leave-one-group-out (LOCO)**: when a
marker on chromosome *c* is tested, the relationship correction is built from the
markers **not** on *c*, so a marker's own signal does not leak into the
relationship that is supposed to control for background polygenic structure
(proximal contamination). LOCO is the standard guard in genomic GWAS.

The engine ships LOCO; R does not yet surface it. The target API adds a `method`
value plus a `marker_groups` argument:

```r
fit <- hsquared(y ~ animal(1 | id, pedigree = ped), data = dat)
g <- gwas(fit, markers = M, marker_groups = chrom, method = "loco")
```

## 1. Engine contract (PROVEN — do not re-derive)

`HSquared.jl/src/genomic.jl`:

- `loco_relationship_precisions(markers, marker_groups; allele_frequencies = nothing, ridge = 0.01)`
  → `Dict{String, Matrix{Float64}}`. For each group label it **drops that group's
  markers**, builds a VanRaden `G` from the rest
  (`genomic_relationship_matrix`), and returns its regularized dense inverse
  (`genomic_relationship_inverse`). Requires ≥2 distinct non-empty groups.
- `loco_mixed_model_marker_scan(y, X, Z, relationship_precisions, marker_groups, markers, sigma_a2, sigma_e2; allele_frequencies = nothing, marker_ids = nothing)`
  → the same `NamedTuple` shape as `mixed_model_marker_scan`, **plus**
  `marker_groups` and `relationship_groups`. It selects the matching precision per
  marker, forms the dense GLS covariance
  `V = σ²a · Z · inv(precision) · Zᵀ + σ²e · I`, and runs the marker-by-marker
  Wald scan.

Both are **engine-internal, dense, supplied-variance, validation-scale**. They do
not estimate variance components, choose public LOCO defaults, calibrate
p-values, or run sparse production scans.

## 2. The dimensional crux (RESOLVED by the live probe, §6)

The precision matrix enters the **`Ainv` slot** of the scan's GLS covariance.
`_mixed_marker_scan_cache` guards `size(Z, 2) == size(precision, 1)`, so each
precision must be **(n_animals × n_animals)**. Therefore:

| Quantity | Level | What R passes |
| --- | --- | --- |
| precisions input | **animal** | `markers` (already validated: one row per pedigree animal, in pedigree order) |
| scan `markers` | **record** | `Z %*% markers` (the same record-level matrix the `mixed` scan already builds) |
| `marker_groups` | per **marker column** | length `ncol(markers)`, ≥2 distinct, no empty labels |
| `σ²a, σ²e` | scalar (supplied) | reused from the pedigree fit, unchanged |

This is the resolution of the handoff-8 open question: the precisions are built
from **animal-level** markers (`markers`), while the scan tests **record-level**
markers (`Z %*% markers`). Both come from the single validated `markers` matrix —
no new alignment step is needed.

## 3. The variance-scale caveat (the one real scientific decision)

`gwas(method = "loco")` **reuses the pedigree fit's σ²a/σ²e** (matching the
existing `method = "mixed"`/`"single"` contract — `gwas()` "reuses the fit's
estimated variance components") but the per-chromosome relationship is now
**genomic** (VanRaden G), whose scale (`2Σp(1−p)`) differs from the pedigree A
scale (`1 + F`). The engine LOCO scan takes a **single** supplied `σ²a/σ²e`, so
per-group re-estimation is not in the contract; re-estimating genomic variance
components (GREML) would require a genomic fit and change the `gwas(fit, …)`
contract — out of scope for this slice.

Decision: surface LOCO at validation scale, reusing the pedigree-estimated
variance components, with an **explicit print/`@return` caveat** that the variance
components are pedigree-estimated while the LOCO relationship is genomic (a scale
mismatch), the p-values remain **uncalibrated**, and proper genomic-VC LOCO is
future work. HSquared.jl PR #134 later banked a fixed-panel calibration smoke
harness, but that does not activate R significance thresholds or turn this into
a production GWAS.

## 4. R wiring (R lane only — `R/gwas.R`, `R/autoplot.R`)

1. `gwas()` generic + methods gain `marker_groups = NULL` and `method` enum
   `c("mixed", "single", "loco")`.
2. New validator `hs_gwas_marker_groups(marker_groups, markers, method)`:
   - `method == "loco"` ⇒ `marker_groups` required; coerce to character; length
     must equal `ncol(markers)`; no `NA`/empty labels; ≥2 distinct groups (fail
     fast in R with a named error before the bridge).
   - `method != "loco"` ⇒ `marker_groups` must be `NULL` (error otherwise — it is
     only meaningful for LOCO; no silent ignore).
3. In `gwas.hsquared_fit`, the `loco` branch assigns the **animal-level**
   `markers` (for precisions) and the **record-level** `markers_rec` (for the
   scan), the groups, and the reused σ²a/σ²e, then issues:
   ```julia
   hsq_prec = HSquared.loco_relationship_precisions(hsq_markers_animal, hsq_groups);
   hsq_scan = HSquared.loco_mixed_model_marker_scan(
       hsq_y, hsq_X, hsq_Z, hsq_prec, hsq_groups, hsq_markers, hsq_sigma_a2, hsq_sigma_e2;
       marker_ids = hsq_marker_ids);
   ```
   The result Dict marshalling is unchanged (the LOCO result is a superset of the
   mixed shape), so `hs_normalize_gwas_result(raw, method = "loco")` is reused.
4. `print.hs_gwas` gains a `loco` branch: "per-chromosome (LOCO) genomic
   relationship correction; variance components reused from the pedigree fit
   (genomic-vs-pedigree scale mismatch); NOT genome-wide calibrated".
5. `autoplot()` Manhattan/QQ method note recognises `scan_method == "loco"`.

## 5. Honesty / capability status

- `docs/design/capability-status.md` marker-scan row: note LOCO now surfaced at
  `partial (R)`, validation-scale, uncalibrated, pedigree-VC caveat.
- `NEWS.md`: a `gwas(method = "loco", marker_groups = …)` bullet.
- No `covered` promotion (calibration gate `#48` is twin-side and open).

## 6. Tests

Pure-R (no engine):
- normalizer carries `scan_method = "loco"`; `print()` shows the LOCO + scale
  caveat strings.
- `hs_gwas_marker_groups` guards: missing groups under loco; groups supplied
  under non-loco; wrong length; empty/NA labels; <2 distinct groups.

Live (skip-guarded, one process):
- **Probed 2026-06-20** (`/tmp/loco_probe.R`): `loco_relationship_precisions`
  returns (n_animals × n_animals) precisions; the LOCO scan runs; a chr1 marker
  matches a single `mixed_model_marker_scan` using the chr1 precision to
  **max|diff| = 0.0**; chr2 markers differ; LOCO differs from the whole-G scan.
- Landed tests mirror the probe through the R `gwas()` wrapper: `method = "loco"`
  p-values match a direct engine `loco_mixed_model_marker_scan`, match the
  per-group chr1/chr2 precision scans (both directions), and differ from
  `method = "mixed"` (whole-pedigree) and `method = "single"`.
- **Non-square-`Z` regression** (the crux made testable): a square `Z` (one record
  per animal) makes animal-level and record-level markers identical, so a
  markers/markers_rec swap would pass undetected. A repeated-records fit (110
  records / 80 animals, interior σ²a) asserts the scan runs, parity vs a direct
  engine LOCO scan built from animal-level precisions + record-level scan markers,
  and `expect_error` on the wrong wiring (record-level markers → precisions, which
  the engine `size(Z,2)==size(precision,1)` guard rejects).

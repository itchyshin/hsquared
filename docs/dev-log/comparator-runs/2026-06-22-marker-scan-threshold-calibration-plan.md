# Marker-scan threshold calibration plan

Date: 2026-06-22

Reporter: Fisher (inference reviewer)

Related issue: `itchyshin/hsquared#23`

Related twin gates: `itchyshin/HSquared.jl#48`, coordination `#61`

Related design docs:

- `docs/design/28-gwas-threshold-activation-contract.md` (activation contract;
  this plan operationalizes its Validation Gates, it does not restate them);
- the marker/QTL rows in `docs/design/capability-status.md`.

## Purpose

Define the concrete experimental route that would move the post-fit
`gwas(fit, markers)` marker scan from uncalibrated nominal/Bonferroni/BH
p-values toward a *calibrated* genome-wide significance threshold. Three
calibration legs are specified: (1) permutation-based per-scan thresholds,
(2) realistic-LD simulation calibration, and (3) external PLINK/GEMMA/GCTA(-style)
comparator alignment.

This is a **plan only**. It is not calibration evidence and not a
genome-wide-significance claim. No threshold is activated by this document.

The activation contract (doc 28) lists *what must be true* before a threshold
turns on. This plan lists *how each gate would be exercised*, *what the null and
the acceptance bands are*, and *what verdict each leg must clear*. It is the
methods layer beneath the contract's gate list.

## Current state & gaps

### What `gwas()` does now

`gwas()` (see `R/gwas.R`) runs an experimental post-fit, single-marker test on a
fitted **default univariate Gaussian pedigree animal model**
(`hsquared(y ~ ... + animal(1 | id, pedigree = ped))`). It reuses the fit's
estimated additive/residual variance components `(σ²a, σ²e)` and the fit's
relationship, and offers three methods:

- `method = "mixed"` (default): a generalized-least-squares (GLS) Wald test per
  marker, with one whole-pedigree relationship correction (`Ainv`) reused across
  all markers at the fitted `(σ²a, σ²e)`;
- `method = "single"`: a relatedness-**uncorrected** single-marker OLS contrast
  (no `Z`/`Ainv`/`σ²a`);
- `method = "loco"` (requires `marker_groups`): a leave-one-group-out scan whose
  per-group relationship correction is built from the *other* groups' markers.

The result is an `hs_gwas` table carrying `marker`, `effect`, `se`, `z`,
`chisq`, `p_value`, `bonferroni_p`, `bh_qvalue`, `lod`. `gwas_table(scan)` and
`lod_scores(scan)` are thin views of an already-computed `hs_gwas`; they are not
map-annotated result tables. `autoplot(scan, ...)` draws an uncalibrated
Manhattan plus a QQ panel with a `lambda_GC` genomic-inflation diagnostic.

### Why the thresholds are not calibrated

The reported quantities are honest *marker-by-marker* statistics, but nothing in
the pipeline ties any cutoff to a genome-wide false-positive rate:

- the `p_value` column is the **nominal** Wald p-value for a single marker — it
  carries no information about how many effectively-independent tests the panel
  represents;
- `bonferroni_p` and `bh_qvalue` are **deterministic** multiplicity arithmetic
  over the *supplied* marker count. Bonferroni assumes independent tests and is
  conservative under LD; BH controls FDR under its own assumptions, not the
  genome-wide FWER a breeder reads off a Manhattan line. Neither is anchored to
  the realized correlation structure of the panel;
- the scan is **dense / validation-scale**, exercised on tiny fixtures, not on a
  panel with realistic marker density or LD decay;
- there is no empirical null. No permutation distribution, no realistic-LD
  simulation, and no external comparator has been run. The Julia lane banked a
  *fixed-marker-panel* type-I smoke harness (HSquared.jl PR #134) and a
  `V5-MARKER-THRESHOLD` status row (PR #143), but these are infrastructure and
  status hygiene, not an R threshold.

Consequently the `gwas()` docs, `print.hs_gwas()`, and `autoplot.hs_gwas()` must
keep the **NOT genome-wide calibrated** wording, and the capability/QTL rows stay
`partial`.

### The LOCO scale mismatch

`method = "loco"` is additionally caveated. Its per-chromosome relationship
correction is **genomic** (a VanRaden matrix built from the held-out markers),
but the variance components it reuses are **pedigree**-estimated from the
original animal-model fit. The additive variance `σ²a` estimated against a
pedigree relationship is not on the same scale as a genomic relationship matrix
(different base population, different diagonal/scaling convention). The LOCO test
statistic is therefore computed with a mismatched `(σ²a, σ²e)` and stays
validation-scale even relative to the mixed scan. Any LOCO threshold work must
either (a) re-estimate variance components against the genomic background per
fold, or (b) restrict the first calibrated threshold to `method = "mixed"` on the
pedigree scale and treat LOCO calibration as a separate, later gate. This plan
treats `method = "mixed"` as the primary calibration target and flags LOCO as
out of scope for the first activation.

## Calibration approach 1 — permutation

**Idea.** Build an empirical null for the *whole-scan* test statistic by
permuting phenotypes under the null hypothesis of no marker association while
preserving the relatedness / fixed-effect structure, then read the genome-wide
threshold off the null distribution of the **per-scan maximum statistic**.

**Permutation scheme (preserve relatedness, break only the marker link).**
A naive shuffle of raw `y` destroys the polygenic covariance and inflates the
null. The defensible scheme for a mixed-model scan is to permute on the
*decorrelated* scale:

1. fit the null model `y ~ fixed + animal(1 | id, pedigree = ped)` once;
2. form rotated residuals under the fitted `(σ²a, σ²e)` (a whitening transform
   `V^{-1/2}`, or equivalently permute polygenic-adjusted residuals), so that
   permuted draws share the fitted mean structure and covariance;
3. for each permutation `b = 1..B`: reassign the decorrelated residuals to
   individuals, back-transform, and re-run the *same* marker scan
   (`method = "mixed"`) holding the marker matrix and `Ainv` fixed;
4. record `T_b = max_j statistic_j` over all markers in permutation `b`
   (max over the `z²`/`chisq` or, equivalently, the min over `p_value`).

A simpler, transparent first cut permutes individual labels of the
polygenic-adjusted residual vector; the rotated-residual scheme above is the
target once the whitening transform is validated against the engine.

**FWER and FDR control.**

- **FWER (genome-wide significance line).** The `1 - α` quantile of the
  max-statistic null `{T_1, ..., T_B}` is the calibrated cutoff. A marker is
  genome-wide significant at level `α` if its observed statistic exceeds that
  quantile. This is the permutation analogue of the line a breeder reads off a
  Manhattan plot and it automatically accounts for the panel's effective number
  of independent tests under its realized LD.
- **FDR (optional).** A permutation-calibrated FDR can be obtained by comparing
  the observed ordered p-values to the per-rank null p-value distribution across
  permutations (an empirical-null analogue of BH). FDR is a secondary deliverable;
  the primary activation target is the FWER line.

**Compute cost.** Cost is `B` full mixed-model scans. Useful FWER tail resolution
at `α = 0.05` needs `B ≈ 2,000-10,000`; `α = 0.01` or smaller needs more. Each
permutation re-solves a GLS scan over all markers, so cost scales with
`B × n_markers × (cost of one decorrelated marker test)`. This is the leg most
likely to need the Julia engine to vectorize the per-permutation scan and to
reuse the factorization of `V` (or `Ainv`) across permutations. Seeds and `B`
must be recorded in the result object (`calibration_seed`, `n_permutations`)
exactly as doc 28's Required Result Fields demand.

**What this leg cannot do alone.** Permutation calibrates the *null* for the
tested statistic on the *given* panel; it does not establish power, and it does
not by itself prove the statistic is correctly specified (a mis-scaled `V`, e.g.
the LOCO mismatch above, would be permuted consistently and the inflation would
hide). Approaches 2 and 3 cover those gaps.

## Approach 2 — realistic-LD simulation

**Idea.** Permutation gives an empirical null on one panel; simulation tells us
whether the *threshold rule* controls type-I error and retains power across panels
with realistic linkage disequilibrium. This is the leg that turns "uncalibrated"
into "calibrated under a stated LD regime".

**Data-generating process.**

- simulate genotypes with **realistic LD** (e.g. a coalescent/haplotype model or
  a Markov chain along the chromosome with a target LD-decay curve), spanning a
  range of marker densities and minor-allele-frequency spectra;
- simulate phenotypes under the fitted animal-model covariance:
  - **null scenario:** polygenic background only, *no* marker effect, to measure
    empirical type-I error;
  - **spiked-QTL scenario:** one (or a few) markers assigned a known effect size
    on top of the polygenic background, to measure power;
- vary `n`, marker density, LD strength, `h²`, and QTL effect size across a grid
  so the calibrated claim is bounded to a studied region, not asserted globally.

**What is measured.**

- **empirical type-I error** at each nominal `α` (0.05, 0.01, and at least one
  genome-wide-scale `α`): the realized genome-wide false-positive *call rate*
  under the null scenario, for the chosen threshold rule (permutation line and/or
  a simulation-calibrated cutoff);
- **power**: the recovery rate of the spiked marker / region under the declared
  scan method across the effect-size grid.

**What counts as calibrated.** A threshold rule is "calibrated under realistic
LD" only if, across the studied grid, the empirical type-I error sits inside a
pre-registered acceptance band around the declared `α` (band and Monte Carlo
standard error fixed *before* the run, signed off by Fisher/Curie), and the
positive-control power is non-trivial at plausible effect sizes. A rule that
controls type-I only at `α = 0.05` but inflates at genome-wide `α` is **not**
calibrated for the genome-wide claim. The negative-control (null, no inflated
call rate) and positive-control (planted region recoverable) gates from doc 28
are the pass/fail summaries of this leg.

## Approach 3 — external comparator alignment

**Idea.** Independent, accepted tools provide a same-result cross-check that the
`hs_gwas` statistic and ranking are not idiosyncratic. This is doc 28's gate 4.

**Alignment targets** (matched to the same fitted background model and test
statistic as far as each tool allows):

- **PLINK** `--assoc` (no relatedness correction; aligns to `method = "single"`)
  and `--mlma` (mixed-linear-model association; aligns to `method = "mixed"`);
- **GEMMA** `-lmm` (univariate linear mixed model with a supplied relatedness
  matrix; aligns to `method = "mixed"`);
- **GCTA** `--mlma` / `--mlma-loco` (MLM and leave-one-chromosome-out; the LOCO
  variant is the natural comparator for `method = "loco"` *once* the LOCO scale
  mismatch above is resolved).

**What to compare.**

- **−log10 p ranking.** Rank concordance of markers between `hs_gwas` and the
  comparator (e.g. Spearman correlation of −log10 p, plus agreement on the
  ordering of the top markers). Exact p-value equality is not expected across
  tools with different variance-component estimators; *ranking and top-hit
  structure* are the contract.
- **λ_GC genomic inflation.** The genomic inflation factor (median χ² over its
  null expectation; the same `lambda_GC` the QQ panel already reports) should be
  comparable between `hs_gwas` and the comparator and near 1 under a null/clean
  scenario. A divergent λ_GC is a red flag that the background correction differs.
- **Top-hit concordance.** For a spiked fixture, whether `hs_gwas` and the
  comparator both place the planted marker/region among the top hits, and whether
  the genome-wide call sets agree.

**Boundary.** A comparator with a *different estimand* (a Bayesian/MCMC scan, or a
different mixed-model background) is useful context but is **not** same-result
threshold validation by itself (doc 28). The comparator must share the background
model, relationship correction, test statistic, and p-value scale to count.

## Acceptance criteria for activating a threshold

A calibrated `gwas()` threshold may be activated in R only when **all** of the
following hold (this is the operational reading of doc 28's gates 1-7):

1. **Result-object guard (gate 1).** A deterministic R contract test proves an
   `hs_gwas` object refuses calibrated-threshold metadata when the required
   fields (doc 28's `calibration_method`, `calibration_seed`/seed list,
   `n_permutations`/replicate count, `alpha`, the calibrated cutoff, the estimated
   empirical type-I error, the fixed-vs-regenerated-panel flag, provenance) are
   missing or contradictory. This is the first follow-up slice and it activates
   **no** threshold.
2. **Reproducible null (gates 2-3, Approach 1 + 2).** A permutation and/or
   fixed-panel null is reproducible from recorded seeds, *and* a realistic-LD
   calibration run shows **signed-off empirical type-I error inside the
   pre-registered band at every claimed nominal `α`** (not only at `α = 0.05`).
3. **Negative + positive controls (gates 5-6).** Under a null phenotype the
   default threshold shows no inflated genome-wide call rate; under a spiked
   phenotype the planted marker/region is recoverable at the declared method.
4. **External concordance (gate 4, Approach 3).** For at least one small fixture
   with a matched background model and statistic, an accepted tool (PLINK
   `--mlma` / GEMMA `-lmm` / GCTA `--mlma`) agrees on −log10 p ranking, shows a
   comparable λ_GC, and concords on the top hit(s).
5. **Scale integrity.** The activated threshold is restricted to the method whose
   variance-component scale is internally consistent. `method = "mixed"` on the
   pedigree scale is the first candidate; `method = "loco"` is **excluded** until
   the genomic-vs-pedigree variance-component mismatch is resolved (re-estimated
   per fold against the genomic background).
6. **Sign-off (gate 7).** Fisher *and* Curie sign off on the acceptance band,
   seed/replicate count, marker-panel and LD assumptions, and whether the result
   is a smoke, a validation-scale claim, or a production claim. Rose records a
   clean audit or explicit blockers.

Until every item passes, R returns nominal/Bonferroni/BH summaries only and all
"genome-wide" wording stays off.

## Required tools + blocker

The three legs need, at minimum: an LD-aware genotype simulator (coalescent or
Markov-chain), a permutation harness able to reuse the `V`/`Ainv` factorization
across replicates (Julia-side for cost), and at least one accepted external scan
executable for the alignment leg.

**Local blocker (recorded 2026-06-21, still current).** This host **lacks**
PLINK / PLINK2 / GEMMA / GCTA / BOLT-LMM / SAIGE-style executables and the
GenABEL / qvalue / rrBLUP / GAPIT / SNPRelate / GWASTools / SKAT / BGLR /
AGHmatrix R packages. Only `sommer` 4.4.5 is present (the 2026-06-21
report's `4.4.3` is now stale on this host), and `sommer` is not
automatically a scan comparator (it would have to demonstrate the same background
model, statistic, marker panel, p-value scale, and threshold estimand first). See
`docs/dev-log/comparator-runs/2026-06-21-marker-scan-tool-availability.md`.
Therefore Approach 3, and any executable-backed part of Approaches 1-2, **cannot
run on this machine today.** R significance thresholds remain **INACTIVE**.

## Report / evidence location + verdict

- **Permutation / simulation evidence**, when produced, belongs in
  `data-raw/` study scripts (per the recovery-study precedent) with a summary in
  this `docs/dev-log/comparator-runs/` directory.
- **External comparator runs** must use
  `docs/dev-log/comparator-runs/TEMPLATE.md` and record tool name/version, host
  class, fixture checksum / generation script, exact command, model/estimand
  match, convergence, the matched-scale results table, and a Rose/Fisher/Curie
  verdict (per `comparator-runs/README.md`).
- **Result-object metadata** must satisfy doc 28's Required Result Fields before
  `autoplot.hs_gwas()` may draw a calibrated line.

**Fisher verdict:** Plan accepted as the methods layer beneath the doc 28 gates.
The permutation scheme must permute on the decorrelated (whitened) scale, not raw
`y`; the type-I band must be pre-registered and checked at genome-wide `α`, not
only `α = 0.05`; LOCO is correctly excluded from the first activation on the
scale-mismatch ground. No threshold is activated by this document.

**Jason verdict (pending):** comparator targets (PLINK `--mlma`, GEMMA `-lmm`,
GCTA `--mlma`/`--mlma-loco`) match the standard landscape for relatedness-aware
single-marker scans; confirm at run time that the chosen tool's variance-component
estimator and relationship matrix are documented so the estimand match is
auditable.

**Rose verdict (pending):** to be recorded when a calibration leg is actually
run. This is a plan; it changes no public claim and promotes no capability.

## Claim boundary

This is a **plan only**. It does not calibrate any threshold, does not activate a
genome-wide-significance claim, and does not add PLINK / GEMMA / GCTA / SAIGE /
GenABEL / qvalue / rrBLUP / BGLR / sommer-derived or any other external scan
evidence. `gwas()` today remains dense/validation-scale and uncalibrated; its
p-values stay nominal with deterministic Bonferroni/BH summaries; the LOCO scale
mismatch (genomic relationship with pedigree-estimated variance components)
stands. R significance thresholds remain **INACTIVE**. There is no QTL/eQTL
workflow, no map-annotated result table, no permutation-validated cutoff, no
realistic-LD calibration, no external comparator, and no capability promotion.
R issue #23 and HSquared.jl #48/#61 remain open / partial.

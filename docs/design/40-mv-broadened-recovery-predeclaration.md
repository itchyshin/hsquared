# 40 — Multivariate broadened-recovery pre-declaration (MV-5)

> **Status: PRE-REGISTRATION — PROPOSAL awaiting maintainer compute-go.** This is
> the pre-declared gate for the broadened multivariate recovery campaign (MV-5 in
> `docs/design/36-phase3-6-execution-plan.md`). Per the no-post-hoc-relaxation rule
> (2026-06-14 / 2026-06-22 precedent; `docs/design/34-interval-recovery-pre-registration.md`),
> the design and the PASS gate are fixed **before any run**, committed at a SHA,
> and the numbers are not moved after seeing results. **Nothing runs until the
> maintainer approves the Totoro compute and this pre-declaration is committed.**

## Purpose

Strengthen the evidence scope of the 0.6 multivariate covered flip. Today's
covered-candidate recovery is **bi-trait at a single (G0, R0) truth point**
(`data-raw/multivariate-recovery-study.R`, 100-rep cold-start); the per-seed
Frobenius diagnostic fails ~25/48. This campaign broadens to **genuine
multi-trait across multiple truth points**, so the flip covers "multi-trait
animal model," not "bi-trait at one point." It does **not** by itself flip
anything — it feeds the flip scope (MV-7); the flip still needs the in-suite
sommer full-unstructured gate (MV-1), the executed BLUPF90 leg citation (MV-2),
the derived-estimand identity tests (MV-3), the Boole grammar freeze
(`docs/design/38`), Darwin sign-off, and a Rose audit.

## ADEMP pre-declaration

**Aims.** Estimate the bias and Monte-Carlo SE of the multivariate REML estimator
across trait dimension and truth point, to license a covered claim scoped to
multi-trait recovery.

**Data-generating mechanism.**
- Trait dimension **t = 3** (extends the current t = 2).
- **Two pre-specified positive-definite (G0, R0) truth points**, chosen to span a
  low and a high genetic-correlation regime (exact matrices fixed in the committed
  driver, not chosen after seeing results).
- Pedigree animal-model design including a **full-sib structure** (the current
  study is half-sib-weighted); dense, validation-scale (n ≤ ~1000).
- Cold-start optimisation (no truth warm-start), mirroring the existing harness.

**Estimands.** All **6 unique G0 elements** (3 variances + 3 covariances) and **6
R0 elements** as the component targets; the **3 pairwise genetic correlations
r_g** and **3 per-trait h²** as derived targets.

**Methods.** `HSquared.fit_multivariate_reml` driven through the read-only R→Julia
bridge by an extended `data-raw/multivariate-recovery-study.R` (t = 3). No edits
to `HSquared.jl` (twin-discipline; engine fit only).

**Performance measures and PASS gate (fixed now).**
- **Component gate (the flip-relevant one):** every **interior** (non-boundary)
  G0 and R0 element satisfies **|bias| ≤ 2·MCSE** at the pre-declared seed count,
  in **both** truth points.
- **Derived targets** (r_g, per-trait h²) are checked by the within-package
  **identity test** (they equal their defining function of the covered
  components), per the Standard-Tier Covered-Flip Gate — **not** separately
  bias-gated.
- **Per-seed Frobenius is a diagnostic, NOT the gate.** The aggregate
  element-wise bias/MCSE gate is the covered criterion; a per-seed Frobenius
  pass-rate is reported for transparency but does not set the threshold (stating
  this explicitly forecloses the trap of reading the ~25/48 per-seed Frobenius as
  a failed recovery).
- **Convergence** rate reported; non-converged fits excluded from the bias/MCSE
  computation with their count disclosed (never silently dropped).

**Seeds (tiered, pre-declared).**
- **Screen tier: 48 seeds per cell** (t = 3 × 2 truth points = 2 cells) — the
  pre-declared screen gate above.
- **Confirm tier: 500 seeds** on any cell that passes the screen, mirroring the
  C1 / supplied-K screen→confirm pattern (`docs/dev-log/recovery-checkpoints/2026-07-10-coverage-recovery-results.md`).
  A screen fail is **banked negative** and does not trigger a re-seeded rescue
  (the R4 discipline).

## Compute plan

- **Host: Totoro** (`snakagaw@totoro.biology.ualberta.ca`, 384-core, no queue).
- `OPENBLAS_NUM_THREADS=1`; parallelism capped at **≤ 96 cores** (lab-shared
  etiquette).
- Wall-clock bound is ~12.6 s/rep (not core count); 48 seeds × 2 cells is a short
  screen, the 500-seed confirm the longer leg — parallelise across seeds.
- DRAC (SLURM array, `fir`) is the fallback / confirm-tier host if Totoro is busy.

## Integrity conditions (non-negotiable)

1. This file is committed at a **SHA before any run**; results land separately in
   `docs/dev-log/recovery-checkpoints/` and cite this SHA.
2. **No post-hoc threshold relaxation.** The |bias| ≤ 2·MCSE gate stands as
   written; a marginal fail is banked negative (as repeatability was, 2026-07-10).
3. **Interior cells only** for the gate; boundary/near-singular G0 cells are
   reported but excluded from the pass criterion.
4. **Twin-discipline:** engine fit via the read-only bridge; no `HSquared.jl`
   edit; an engine-side pass is not by itself the R covered flip.

## Runs only after

The maintainer approves the Totoro compute **and** this pre-declaration is
committed. — PROPOSAL (MV-5).

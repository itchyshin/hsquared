# 2026-07-10 — coverage & recovery evidence results (governed by doc 34)

**Status: EVIDENCE BANKED. Screening/characterization tier. Nothing promoted — `public_covered_count` stays 5.**

Results of the four campaigns pre-registered in `docs/design/34-interval-recovery-pre-registration.md`.
All ran on DRAC `fir` (`def-snakagaw_cpu`), verified by real Julia exit code + the driver's own
machine-readable GATE lines (SLURM `COMPLETED` alone is not trusted). Raw TSVs live on DRAC
`/project` under `HSquared.jl/sim/drac/results/`; drivers on twin branch
`sim/2026-07-10-coverage-recovery-drivers`.

Every driver was ADEMP-reviewed → adversarially re-verified → locally smoked → cluster-smoked
before its full run. The gate caught a real defect in each (coverage mislabeling; vacuous-PASS
gate holes; a `@printf` literal-format load bug caught only by the local smoke).

---

## C1 — univariate interval coverage (job 47925485; 2000 reps/cell, bootstrap arm ON)

Pooled per doc 34 §12 (Σcovered / Σ`interval_success` across 20 tasks). Claim levels adjudicated
at the **interpretable interior cells** (small design q=120, h²∈{0.3,0.5,0.7}, 0.95 level) per §4
worst-cell rule:

| Estimand | delta / Wald | profile | bootstrap |
|---|---|---|---|
| **h²** | directional-conservative | directional-conservative | directional-conservative |
| **σ²a** | **experimental-only** (0.897 at h²=0.5, under-covers) | directional-conservative | directional-conservative |

- **h² intervals over-cover (conservative) across all three legs** — never under-cover.
- **The σ²a Wald/delta interval genuinely under-covers** (0.897 < 0.90 at h²=0.5), while **profile
  stays calibrated** (0.947/0.956 at h²=0.5/0.7) — this measures, at 2000 reps, exactly why the
  shipped variance-component interval is profile-only.
- Caveats (§2/§8): the **tiny** design (q=36) is NON-INTERPRETABLE at this tier (bootstrap/profile
  shed intervals, Σ`interval_success` < 1800); **h²=0.1 is a boundary cell** (characterization); the
  **0.90 nominal level is descriptive-only** (not promotable).
- **Earns:** the shipped h² interval and the profile σ²a interval qualify for the
  **directional-conservative** claim level — an honest upgrade from the placeholder "experimental"
  the 0.1 honesty pass shipped. Touches the Uncertainty Scope → **maintainer ratification after a
  Rose audit** (not a `public_covered_count` move).

## C8 — multivariate REML recovery re-seed (job 47925486; 500 seeds/cell, 16 cells)

- **500/500 convergence on every cell**, including the extreme `rg_095` boundary and cold starts.
- **`base_inside` PASSES** (within 2·MCSE) → **no R9 covered-regression**.
- **14/16 pass. The only two failures are `rg_090_rec1` and `rg_095_rec1`.**
- Sharp characterization of the #268 signal: the mild **downward additive-genetic (co)variance bias
  appears only at single-record × extreme-rg (≥0.90)**. `rg_high_rec1` (rg=0.70, 1 record) passes;
  `rg_090`/`rg_095` at rec3 pass; the rg_high records ladder (rec1/2/4/6) all pass. Adding records
  fixes it even at rg=0.95. Characterization only — nothing promoted (V4-MV-REML already covered at
  validation scale; this broadens the DGP evidence and documents the boundary caveat).

## supplied-K / Q escape-hatch — 48-seed recovery SCREEN (job 47928724)

- **All 3 cells PASS, 48/48 converged:** `arbK` (arbitrary well-conditioned K, scope=new),
  `identity` (K=I reduction, scope=inside), `pedA` (K=A_ped reduction, scope=inside) — each with all
  of σ²k, σ²e, h²k within 2·MCSE. → **COVERED-ELIGIBLE (screening only)**.
- **Owes before any covered move (§11):** a 2000-rep CONFIRM tier; the `sommer vsr(id, Gu=K)`
  same-estimand comparator (R-lane, not yet run); a Rose audit; **the maintainer's escape-hatch
  IN/OUT decision (queue #5)**; and the per-move G10.

## repeatability (permanent-environment) — 48-seed recovery SCREEN (job 47928725)

- **Interior `wellpowered` cell (q=800, 4 records/ind) PASSES on the gated estimand `t`**
  (bias +0.0009, essentially unbiased, 48/48 converged). Ladder rungs at records≥2 pass
  (`ladder_rec2/rec3`, `split_small_n`). → **t COVERED-ELIGIBLE at the interior (screening only)**.
- The two characterization "fails" are as pre-declared, **not** claim-killers: `ladder_rec1`
  (records=1 identifiability floor — σ²pe/t not point-identified at 1 record) and `null_pe0`
  (σ²pe=0 boundary, a −0.010 small-bias trip at tiny 48-seed MCSE). The identifiability ladder
  behaves exactly as designed (t recoverable at records≥2, degrades at records=1).
- The **σ²a/σ²pe split (and h²) stay characterized-only / experimental-only** per doc 34 — their
  MCSE is large; the split is not gated at any validation scale.
- **Owes:** a 2000-rep CONFIRM tier (needs a seed-array driver — the well-powered n=3200 dense fit
  is ~90 min for 48 seeds, so the confirm must parallelize seeds across array tasks like C1); the
  `sommer` animal + `ide(id)` comparator; Rose; and the per-move G10.

---

## Maintainer-gated items now teed up

1. **C1 claim-level upgrade** to directional-conservative (h² all legs; profile σ²a) — Uncertainty
   Scope change, after Rose.
2. **supplied-K flip** — clean screen; needs the escape-hatch IN/OUT call (#5) + 2000-rep confirm +
   Rose + G10.
3. **repeatability flip** — clean interior screen on `t`; needs 2000-rep confirm + Rose + G10.

## Provenance

DRAC `fir` jobs: **47925485** (C1, 20×100), **47925486** (C8, 16 cells ×500), **47928724**
(supplied-K, 3×48), **47928725** (repeatability, 6×48). Drivers + sbatch: twin
`sim/2026-07-10-coverage-recovery-drivers`. Pre-registration: `docs/design/34`. Raw per-cell/per-task
TSVs on DRAC `/project` (`sim/drac/results/{c1_rerun_boot199,w1_v5,supplied_k,rr_repeat}/`) — copy to
a committed location before the 60-day `/scratch` policy is relevant (they are on `/project`, not
`/scratch`).

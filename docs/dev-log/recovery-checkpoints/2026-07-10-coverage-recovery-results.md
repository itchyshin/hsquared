# 2026-07-10 — coverage & recovery evidence results (governed by doc 34)

**Status: EVIDENCE BANKED through the 2000-rep CONFIRM tier. supplied-K recovery CLEAN at confirm; repeatability `t` a banked NEGATIVE at confirm (marginal fail, gate not moved per R4). Nothing promoted — `public_covered_count` stays 5.**

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
  of σ²k, σ²e, h²k within 2·MCSE. → screen PASS.
- **2000-rep CONFIRM (job 48022362): CLEAN** — all 3 cells converged **2000/2000**, all PASS
  |bias|≤2·MCSE. The arbitrary-K recovery holds at the stricter confirm-tier MCSE; the
  recovery-confirm gate is CLOSED for supplied-K.
- **Still owes before any covered move (§11):** the `sommer vsr(id, Gu=K)` same-estimand
  comparator (R-lane, not yet run); an n-ladder + a genuine σ²k=0 null (beyond the K=I reduction);
  the R-surface wiring (`relmat()`/`precision()`); a Rose audit; **the maintainer's escape-hatch
  IN/OUT decision (queue #5)**; and the per-move G10.

## repeatability (permanent-environment) — 48-seed recovery SCREEN (job 47928725)

- **48-seed SCREEN:** interior `wellpowered` passed on `t` (bias +0.0009, 48/48); ladder rungs at
  records≥2 passed (`ladder_rec2/rec3`, `split_small_n`).
- **2000-rep CONFIRM (jobs 48024165 + 48040475 resume): MARGINAL FAIL — this supersedes the screen.**
  Converged **1999/2000** (rate 0.9995); `t` bias **−0.00120**, MCSE 0.00057, **|bias|/MCSE = 2.10 > 2.0**
  → **gate_pass=false**. Per doc 34 §5 this is a **banked NEGATIVE at the confirm tier**: repeatability
  does **NOT** flip; `t` stays **experimental/partial**. The absolute bias is tiny (−0.23% of true
  t=0.516) — a small finite-sample **downward point-bias** resolvable only at the 2000-rep tier,
  negligible for applied use. **Not an engine defect** — supplied-K components recover cleanly at the
  same tier, favouring finite-sample **ratio-nonlinearity** (delta-method/Jensen curvature of a bounded
  variance ratio with a weakly-identified pe). Per **R4 (§9) the gate is NOT moved and NO higher-rep /
  re-seeded rescue is scheduled**; mechanism confirmation is a non-blocking twin-lane follow-up (out of 0.2.0).
- The two characterization "fails" are as pre-declared, **not** claim-killers: `ladder_rec1`
  (records=1 identifiability floor — σ²pe/t not point-identified at 1 record) and `null_pe0`
  (σ²pe=0 boundary, a −0.010 small-bias trip at tiny 48-seed MCSE). The identifiability ladder
  behaves exactly as designed (t recoverable at records≥2, degrades at records=1).
- The **σ²a/σ²pe split (and h²) stay characterized-only / experimental-only** per doc 34 — their
  MCSE is large; the split is not gated at any validation scale.
- **Confirm DONE (marginal fail, above): NO flip.** The `sommer` comparator is now moot for a flip;
  repeatability stays experimental with the point-bias caveat. The interval-coverage tier for a
  shipped `repeatability_interval` is a separate, still-open question (not settled by this recovery leg).

---

## Maintainer-gated items now teed up

1. **C1 claim-level upgrade** to directional-conservative (h² all legs; profile σ²a; Wald σ²a stays a
   demoted experimental probe) — Uncertainty-Scope change, after Rose. **No count move (stays 5).**
2. **supplied-K flip (5→6)** — recovery **confirm CLEAN**; still needs the escape-hatch IN/OUT call
   (#5) + the `sommer` comparator + n-ladder/null + R-surface wiring (`relmat()`/`precision()`) + Rose + G10.
3. **repeatability — NOT a flip.** The 2000-rep confirm marginally failed (banked negative, §5); `t`
   stays experimental with the ~0.2% point-bias caveat; **gate not moved (R4)**.

## Provenance

DRAC `fir` jobs — screens: **47925485** (C1, 20×100), **47925486** (C8, 16 cells ×500), **47928724**
(supplied-K, 3×48), **47928725** (repeatability, 6×48). Confirm tier: **48022362** (supplied-K,
3×2000, CLEAN), **48024165**+**48040475** resume (repeatability wellpowered, 40×50 seed-array → 2000,
MARGINAL FAIL). Drivers + sbatch (incl. `phase3_repeatability_confirm.sbatch`): twin
`sim/2026-07-10-coverage-recovery-drivers`. Pre-registration: `docs/design/34`. Raw per-cell/per-task
TSVs on DRAC `/project` (`sim/drac/results/{c1_rerun_boot199,w1_v5,supplied_k,rr_repeat}/`) — copy to
a committed location before the 60-day `/scratch` policy is relevant (they are on `/project`, not
`/scratch`).

# 42 — FA calibration-failure diagnosis (S1)

> **Status: DIAGNOSIS (read-only), 2026-07-11.** The S1 step of the 0.8
> factor-analytic pillar (`docs/design/36-phase3-6-execution-plan.md`): *diagnose
> the FA/low-rank calibration failure before spending compute.* Produced by two
> independent engine reads (Gauss diagnosis + Karpinski adversarial cross-check).
> The engine fix is **Julia-lane** (`HSquared.jl`); this doc is the R-lane
> diagnosis + recommendation and supersedes the start-sensitivity premise of
> `docs/design/20-factor-analytic-em-initializer.md` §2.

## Headline

**The FA calibration failure is NOT optimizer start-sensitivity, so the doc-20 EM
warm-start is very likely the wrong fix.** Do **not** launch a Totoro warm-start
campaign yet. Run one cheap discriminating test first.

## The decisive refutation of start-sensitivity

The FA calibration sim **already warm-starts at a near-oracle point** —
`initial = (0.7·Λ_true, 1.3·ψ_true, 1.2·R_true)`
(`HSquared.jl/sim/phase4b_structured_covariance_recovery.jl:135-137`, truth at
`:106-109`). The recorded **8/10** FA recovery
(`HSquared.jl/src/validation_status.jl:344`) therefore happens **despite starting
in the truth neighbourhood**. A data-driven Rubin–Thayer EM start (doc-20) is
generically *worse* than `0.7·Λ_true`, so it cannot rescue seeds that already
fail from near-truth. This single fact undercuts doc-20 §2.

## What it actually is (reconciled)

Both reads converge: the failures are a mix of **(i) information-limited sampling
variability** against a tight relative-Frobenius threshold (thin design: q=60
animals / 6 sire families / n=360; the true `G23 = −0.19` is the smallest,
sign-fragile covariance driving `λ₁² = G12·G13/G23`), and **(ii) at least one
genuine Heywood / improper-solution boundary excursion** (the catastrophic
rel-G≈0.578 seed). It is:

- **NOT rotation non-identifiability** — the design is `t=3, K=1` (no rotation
  freedom; `K(K−1)/2 = 0`), and the recovery metric is on `G0 = ΛΛ' + Ψ`, which is
  rotation-invariant (`evolvability.jl:11-17`). Rotation cannot cause a
  G0-recovery failure. (doc-29's rotation-flatness note is a red herring here.)
- **NOT Ainv conditioning** — clean non-inbred half-sib pedigree, F=0.
- **Structurally boundary-prone by construction** — `t=3, K=1` is
  **Ledermann-saturated** (6 free params = 6 distinct `G0` entries, df=0), so an
  improper solution (some `ψ_i` pinned to 0) is a **positive-probability data
  event** fixed by the DGP + sample size, not by the optimizer. ~20% improper at
  this design is unremarkable.
- **Silently converging at the boundary** — `ψ = exp(param)`
  (`multivariate.jl:561-565`), so the Heywood boundary is at `param → −∞`;
  NelderMead (`:854`) satisfies its simplex tolerance while a `ψ_k → 0`, and
  `ΛΛ'+diag(ψ)` stays PD for any `ψ>0` (`:326`), so `_mv_build_Vchol` never throws
  (`:670-677`) and the Inf-guard (`:815-824`) never fires. **All-converged-yet-
  mis-recovered is the boundary signature**; G+R joint failures are
  genetic/residual aliasing as `ψ_k` collapses.

## The one test to run first (cheap; discriminates optimizer/boundary vs sampling)

For each failing seed, compute the **fitted REML loglik vs the loglik at the TRUE
parameters**, read jointly with **min(ψ̂)** and cond(G0):
- fitted loglik **≥** truth loglik with `ψ̂_k → 0` ⇒ **Heywood/boundary** (the
  optimizer found an equal-or-better improper optimum) — a warm-start cannot help;
- fitted loglik **<** truth loglik ⇒ a genuine optimizer miss (then, and only
  then, is a better start/optimizer relevant);
- both losses small vs the threshold ⇒ **sampling variability vs a too-tight
  threshold** — the fix is threshold justification, not estimation.

This needs only a per-seed re-evaluation (not a campaign); the per-seed
`(loglik, min ψ̂, rel_g)` were never logged, so the attribution is currently
inferred.

## Recommended fix direction (Julia-lane, pending the test)

1. **Heywood boundary handling** — bound `ψ` away from 0 or add a small proper-
   solution penalty/prior; report `min ψ̂` and a `heywood` flag per fit.
2. **Add the Ledermann-bound guard** — `_validate_genetic_structure`
   (`multivariate.jl:536-547`) only checks `1 ≤ rank ≤ t`, not `(t−K)² ≥ t+K`, so
   it silently accepts under-identified `K>1` combos (t=3,K=2 has 8 params > 6
   entries). Add the guard **before any K>1 calibration** — no warm-start can fix
   a non-injective `(Λ,ψ) → G0` map.
3. **Gate downstream evolvability on cond(G0)** — `conditional_evolvability`/
   `autonomy` invert G (`evolvability.jl:99-131`) and blow up near a Heywood/
   low-rank G.
4. **Threshold check** — quantify whether the 0.45 relative-Frobenius gate is
   attainable at this thin design under correct estimation before treating any
   near-miss as a defect.
5. **If fa resists but low-rank passes**, ship low-rank covered and hold fa
   partial — do **not** relax the fa threshold (execution-plan non-negotiable 4).

## Why this matters

Following doc-20 as written (build an EM warm-start, then run a Totoro multi-start
campaign) would likely **spend compute on the wrong fix** — the sim already starts
near truth. The dense REML core forms and Choleskys an N×N V every negloglik eval
(`multivariate.jl:670-677`), so a multi-start campaign multiplies cost without
changing the boundary. Run the discriminating test, then choose the fix.

## Open items

Per-seed telemetry (`loglik`, `min ψ̂`, min-eig(G0), cond(V)) is unrecorded;
the failing 10-seed set (harness default seed `20260614`, `sim:208`) must be
reproduced; the low-rank 9/10 (1 R-only failure) is a different boundary
(`G0=ΛΛ'` singular by construction) and is weaker evidence — out of scope for the
FA question. A gradient/AI-REML vs NelderMead A/B on identical seeds would confirm
whether NelderMead contributes false-convergence.

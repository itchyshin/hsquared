# 2026-09-03 — 0.8 twin pointer (Julia S2 FROZEN · no R flip)

Julia lane `cursor/08-fa-20260903` (draft [HSquared.jl #292](https://github.com/itchyshin/HSquared.jl/pull/292))
froze the S2 FA recovery gate at **`eff57e3d`**.

- Gate DGP: `t=4 K=1`, `ledermann_slack=4`
- Pass: converged + `rel_g ≤ 0.45` + `rel_r ≤ 0.25` + **`min(ψ̂) ≥ 1e-4`** + slack `> 0`
- Old G/R gates accept collapsed uniqueness (S1: 5/8 "passes" still Heywood)
- Driver: `HSquared.jl` `sim/v08_fa_s2_prereg.jl` (blob `370cf697`)
- Decision: `HSquared.jl` `docs/dev-log/decisions/2026-09-03-v08-s2-fa-recovery-gate-prereg.md`
- S4 seeds `20260914:20260923` predeclared, **not run**
- S3 = uniqueness bound / Ledermann guard, **not** EM warm-start

S1 classify remains closed at Julia `80e91d75` / `5f07d026`. R pointer for S1
is `d9c5314`.

**Not an R covered flip.** `factor-analytic G` stays **planned**. Count stays
**7**. Experimental **0.7.0**. No `cov = fa(K)`. No Rose CLEAN.

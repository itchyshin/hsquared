# 2026-09-03 — 0.8 twin pointer (Julia S1 CLOSED · no R flip)

Julia lane `cursor/08-fa-20260903` (draft [HSquared.jl #292](https://github.com/itchyshin/HSquared.jl/pull/292))
finished the predeclared design-42 S1 classify on Totoro (Julia 1.10.0, 1 core).

## Contrast (`d3-contrast`, 3 seeds)

| seed | class | Δℓ (fit−truth) | min(ψ̂) | heywood_flag |
|---|---|---:|---:|---|
| 20260616 | heywood_boundary | +7.51 | 2.52e-7 | true |
| 20260619 | heywood_boundary | +10.52 | 1.47e-7 | true |
| 20260614 | ok_recovery | +7.31 | 5.37e-8 | true |

Zero `optimizer_miss`. Both banked FA fails are Heywood. The pass seed still
collapses uniqueness (driver ranks G/R gates ahead of `min(ψ̂)`).

## Panel (`d3-panel`, 10 seeds)

CLASS_COUNTS: `ok_recovery` 8 · `heywood_boundary` 2 (same two fails) ·
`optimizer_miss` 0. `heywood_flag=true` on 7/10, including 5 of 8
`ok_recovery`. `ledermann_slack=0` on all ten.

Authoritative Julia records:

- `HSquared.jl` `docs/dev-log/recovery-checkpoints/2026-09-03-v08-s1-d3-contrast.md`
- `HSquared.jl` `docs/dev-log/recovery-checkpoints/2026-09-03-v08-s1-d3-panel.md`
- `HSquared.jl` `docs/dev-log/decisions/2026-09-03-v08-s1-fa-diagnose-predeclare.md`
- `HSquared.jl` `sim/v08_fa_s1_diagnose.jl`

**Not an R covered flip.** `factor-analytic G` stays **planned**. Single-step
stays **partial / opt-in**. Count stays **7**. Version stays experimental
**0.7.0**. No `cov = fa(K)` freeze. No Rose CLEAN (not requested, not written).
G5 default-genomic PRs #157/#291 are a different lane — do not merge into
this branch.

S2 prereg outline lives in scratch only
(`~/local-scratch/h2-08-S2-prereg-outline-2026-09-03.md`). No campaign.

# 2026-09-02 — 0.7-S0b Totoro exact-G estimated-VC one-shot — PASS

**Gate: PASS** · primary sommer PASS · secondary rrBLUP PASS  
**Not a covered flip.** `public_covered_count` stays **6**.  
Scratch twin: `~/local-scratch/h2-07-totoro-exactG-2026-09-02.md`.

## Commands / job

| Field | Value |
|---|---|
| Named job | `0.7-S0b-exactG-20260902` |
| Host | Totoro |
| PID | **1498082** |
| Wall | **11 s** (2026-09-03T00:02:58Z–00:03:09Z) |
| Julia | 1.10.10 · engine SHA `0e2af700` (then on `cursor/07-greml-20260902`) |
| Recipe | `docs/design/52-v07-exact-G-comparator-recipe.md` (Fisher tols frozen **before** run) |
| Packet copy | `~/local-scratch/h2-07-exactG-packet/` |

## Predeclared tols (Fisher)

rel VC ≤ 0.02; \(\lvert\Delta r_G\rvert\) ≤ 0.02; shared \(K_\lambda = G + 0.01 I\); seed **202609022**.

## Outcome

| Leg | rel Δ σ²_g | rel Δ σ²_e | \|Δ r_G\| | Verdict |
|---|---|---|---|---|
| sommer 4.4.6 | 2.12e-4 | 1.14e-4 | 7.61e-5 | **PASS** |
| rrBLUP 4.6.3 | 1.24e-7 | 6.62e-8 | 4.44e-8 | **PASS** |

No post-hoc widen. Discharges design-41 §3 #2 (comparator). Does **not** by
itself discharge §3 #1 (see design-53 SUPERSEDE) or authorize a covered flip.

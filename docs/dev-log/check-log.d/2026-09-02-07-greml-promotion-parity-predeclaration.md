# 2026-09-02 — 0.7 G5: R↔engine genomic promotion parity — TOLERANCE RECORD

**Arc:** 0.7 GREML gap-clear G5 (Rose preflip §2.7 / §4 G5).  
**Lane:** R (`hsquared`) + Julia twin catch-up (#8).  
**Branch:** `cursor/07-greml-20260902`.

**Honesty:** Unlike A26 (new predeclaration *before* a new measure), the
promotion fixture and live identity gate **already exist** on tip with
committed tolerances. This shard **records** those predeclared tolerances and
the DP-10-style CI caveat for Rose visibility. It does **not** invent a new
run or widen tols.

## Fixture / legs

| Leg | What | Predeclared tol (already in test) |
|---|---|---|
| R live marker vs exact supplied-Q | `tests/testthat/test-genomic.R` “explicit marker and exact supplied-Q routes agree [live]” | VC / \(r_G\) / fixef / EBV `tolerance = 1e-8`; precision fingerprint exact |
| R frozen activation fixture | same file “frozen activation fixture matches base R and both public routes [live]” | fixture-pinned construction + both routes |
| Julia S0 identity | `test/test_genomic_greml_s0_identity.jl` marker vs supplied-Q | `Q` `atol = 1e-10`; heritability `1e-12`; EBV max abs `1e-10` |

Promotion claim scope: **opt-in** `target = "genomic"` on the declared
\(K_\lambda\) kernel — not default activation.

## CI caveat (same posture as DP-10 / A26)

Live `R-CMD-check.yaml` provisions **no** Julia. With the bridge unavailable,
live genomic parity legs **skip** rather than fail. A green Julia-free CI check
does **not** imply these legs ran. Tier-1 Julia-provisioned parity CI remains
optional / not enabled (stub `if: false` unchanged). Local live PASS is the
Rose-visible discharge for this gap, matching owner-accepted 0.6 DP-10 C
posture.

## Fence

Recording this parity does **not** authorize the covered flip by itself.
Count stays **6**. Results / re-measure pointer:
`docs/dev-log/check-log.d/2026-09-02-07-greml-promotion-parity.md`.

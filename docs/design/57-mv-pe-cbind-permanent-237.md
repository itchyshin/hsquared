# Multivariate + permanent-environment (hsquared #237)

Status: **honest fence** (2026-09-24 overnight T1). No fit path. No covered flip.
Version stays **0.9.0**. `public_covered_count` stays **7**.

## Verdict

`cbind(...)` + `permanent(1 | id)` must not silently absorb PE into `G0`. The
engine does **not** yet fit the multi-trait repeatability model

```text
Y = XB + Z u_a + Z u_pe + E
u_a ~ N(0, G0 ⊗ A),   u_pe ~ N(0, P0 ⊗ I)
```

so R keeps a **named reject** with closest live paths, plus a repeated-records
warning on animal-only `cbind()` that does not hand out a call the MV route
would refuse (hsquared#212 class).

## Engine inventory (read 2026-09-24, `origin/main` @ coverage bank)

| Surface | Scope | MV+PE? |
| --- | --- | --- |
| `fit_multivariate_reml` | one RE block; `V = Z(A⊗G0)Z' + R` | no |
| `fit_repeatability_reml` | univariate `σ_a²`, `σ_pe²`, `σ_e²` | no |
| `fit_multi_effect_reml` | `y::AbstractVector` only | no |
| payload-v2 | MV requires exactly one RE block | rejects Y + ≥2 blocks |

Closest live paths today:

1. Univariate repeatability: drop `cbind`, use
   `control = hs_control(engine = "julia", engine_control = list(target = "repeatability"))`
   with `animal(...) + permanent(1 | id)`.
2. Multivariate without PE: keep `cbind(...) ~ fixed + animal(1 | id, pedigree = ped)`
   and drop `permanent()` (G0 may absorb PE when records repeat; the fit warns).

## R surfaces that close the honesty debt

| Surface | Contract |
| --- | --- |
| Spec fence | `hs_abort_unsupported_syntax` names `#237`, both closest paths, count-7 fence (`R/model-spec.R`; parity-09 SG1) |
| Repeated-records warning | MV animal-only warns ABSORB + `#237` + univariate repeatability / MV-without-PE; never suggests `permanent()` on `cbind` (`R/conditions.R`) |
| Tests | `test-engine-julia-unsupported-parity.R` (SG1); `test-repeated-records-warning-352.R` (MV branch) |
| Status | this note; capability-status / validation-debt rows; parity-09 D3 |

## What a future fit would need (DEFER)

1. Julia: dense MV REML with second Kronecker PE (`P0`), t=1 identity to
   `fit_repeatability_reml`, and P0→0 reduction to current MV.
2. Bridge: payload-v2 dispatch for `Y` + pedigree + iid/permanent blocks.
3. R: lift the `cbind`+`permanent` fence; keep experimental / opt-in.
4. Evidence before any status move: known-truth `G0` **and** `P0`, plus a
   same-estimand comparator. Univariate repeatability stays `partial`.

Until that chain exists: **no** R-public MV+PE claim, **no** count change.

## Pointers

- Issue: https://github.com/itchyshin/hsquared/issues/237
- Parity-09 D3 / SG1: `docs/design/55-r-julia-engine-julia-parity-09.md`,
  `docs/design/56-r-julia-parity-09-error-audit.md`
- Twin: HSquared.jl `docs/design/12-bridge-compatibility.md` (parity-09)

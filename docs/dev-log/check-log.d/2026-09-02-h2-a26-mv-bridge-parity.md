# 2026-09-02 — A26: R↔engine multivariate parity at the k=2 fixture — RESULTS

**Arc:** A26 (Rose A25 blocker 1). **Lane:** R (`hsquared`), Hopper lens.
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Branch:** `claude/lane-h2-twin-20260901`. **Not pushed.**

Tolerances were predeclared and committed in `0ec917f`
(`2026-09-02-h2-a26-mv-bridge-parity-predeclaration.md`) **before** any parity
run. Nothing below was used to choose a tolerance.

## Fixture — shared, not asymmetric

All eight data/target CSVs of `phase4_multitrait_parity` are **byte-identical**
across lanes (md5 measured); only `README.md` differs (the R copy carries the
R-lane comparator protocol). No new fixture was created. 80 records ×
20 animals × 2 traits; local Mac only, no Totoro/DRAC.

## Results — every predeclared leg PASSES

Test file: `tests/testthat/test-multivariate-engine-parity.R` (`37843d8`).

### Tier B1 — start-matched R↔engine determinism (declared `atol = 1e-8`)

Bridge fit given the engine's own data-scaled start (`0.5 · phenotypic
variance`), against the serialized target:

| Quantity | max abs delta | Declared |
|---|---|---|
| `G0` | **1.72e-14** | 1e-8 |
| `R0` | **8.47e-15** | 1e-8 |
| `h²` | **2.89e-14** | 1e-8 |
| `beta` | **4.44e-15** | 1e-8 |
| EBVs (all 20 × 2) | **1.90e-14** | 1e-8 |
| `loglik` | **8.53e-14** | 1e-8 |
| `r_g` | **0** to printed precision (0.277124187186) | 1e-8 |

Agreement at round-off, six orders inside the declared bound. Two things follow.
First, the R bridge marshals `Y`, `X`, sparse-CSC `Z`, the pedigree, and the id
vector **exactly** — no transpose, no column re-order, no `NA`→`NaN` slip.
Second, it establishes what the fixture's generation recipe was (the engine
default start), which was not written down anywhere: reproducing a target to
1e-14 from an independent entry point is stronger evidence than agreeing with a
same-session re-run.

### Tier B2 — the bridge's OWN default start (declared 5e-4 / 5e-3 / 1e-3)

`hs_validate_multivariate_initial(NULL, t)` sends `I₂`, never the engine's
data-scaled default, so this is what the shipped default path actually recovers:

| Quantity | max abs delta | Declared |
|---|---|---|
| `G0` | **1.96e-05** | 5e-4 |
| `R0` | **2.32e-06** | 5e-4 |
| `h²` | **5.60e-06** | 5e-4 |
| `beta` | **3.53e-07** | 5e-4 |
| EBVs | **6.15e-06** | 5e-3 |
| `loglik` | **1.68e-10** | 1e-3 |
| `r_g` | 0.277103777 vs 0.277124187 (Δ **2.04e-05**) | 5e-4 |

Inside every declared bound, with 25× headroom on the tightest. The `initial`
divergence costs ~2e-5 on `G0` — real, measured, and far from binding.

### Tier B3 — pedigree-permutation invariance (declared `atol = 1e-6`)

| Pedigree row order | `G0` | `R0` | EBVs (ID-matched) |
|---|---|---|---|
| original (already sorted) | 1.72e-14 | 8.47e-15 | 1.90e-14 |
| **reversed** | 1.72e-14 | 8.47e-15 | 1.57e-14 |
| **random-shuffled** (seed 26) | 1.72e-14 | 8.47e-15 | 1.61e-14 |

This is the leg the fixture alone cannot supply. The R emitter builds `Z`
columns over R's `hs_topological_pedigree` order; Julia rebuilds `Ainv` over its
own `normalize_pedigree` order. Both are DFS post-order (sire subtree, dam
subtree, emit), so they agreed **by parallel implementation and by no test** —
and the fixture pedigree is already topologically sorted, so it could not
discriminate. Permuting forces a genuine re-sort on both sides (verified: the
emitted order really changes, `f1,f2,f3,…` → `f3,f6,a6,f1,…`) and the estimates
are invariant to round-off. The `Z`↔`Ainv` alignment contract is now pinned.

### Mutation check — the legs bite

A leg that cannot fail is not evidence, so each was confronted with a defect the
bridge could plausibly have (baseline `max|dG0|` = 1.72e-14):

| Injected defect | `max|dG0|` | `max|dEBV|` |
|---|---|---|
| `Z` columns permuted (`Z`↔`Ainv` misalignment) | **6.78e-01** | 1.77e+00 |
| `Y` trait columns swapped | **3.33e-01** | 1.31e+00 |
| pedigree rows reversed, `Z` untouched | **4.49e-01** | 1.99e+00 |
| `x` covariate dropped from `X` | **5.76e-02** | 2.14e-01 |

All four violate the declared tolerance by 3–13 orders of magnitude.

## Commands and outcomes

| Command | Result |
|---|---|
| `test_file("test-multivariate-engine-parity.R")`, live bridge, `NOT_CRAN=true` | **PASS 44 / FAIL 0 / SKIP 0** |
| same file, CRAN lane (no `NOT_CRAN`, no project) | **PASS 6 / FAIL 0 / SKIP 2** — Tier A still runs; live legs skip |
| `test_file("test-bridge-dashboard-contracts.R")` | **PASS 35 / FAIL 0** |
| `python3 tools/validate-bridge-dashboard.py` | `bridge_dashboard_ok schema_rows=11 parity_smoke_rows=13 boundary_rows=11` |
| `test_file("test-diagonal-multivariate.R")` live | PASS 26 / FAIL 0 |
| `test_file("test-multivariate-fence-contract.R")` | PASS 16 / FAIL 0 |
| `test_file("test-mrode-multivariate-anchor.R")` | PASS 6 / FAIL 0 |
| `air format tests/testthat/test-multivariate-engine-parity.R` | clean |

## Finding — PRE-EXISTING segfault blocks the "in CI" half of blocker 1

`devtools::test()`-style runs of the live multivariate suite **crash**, and it is
not this arc's change. Isolated:

- `test-multivariate.R` **alone**, `NOT_CRAN=true` with a live bridge →
  **segmentation fault 11**.
- Narrowed to the single test *"JuliaCall sends multivariate response NA cells
  as NaN"*.
- Minimal repro, no `hsquared` fitting code: `julia_assign` an R matrix
  containing `NA`, then `julia_eval` an expression referencing it. The assign
  succeeds; the eval segfaults inside Rcpp precious-preserve
  (`_JuliaCall_juliacall_docall`). JuliaCall 0.17.6, R 4.6.0, Julia 1.10.0.
- Verified **pre-existing**: reproduces with `test-multivariate-engine-parity.R`
  removed from the directory. Bare `julia_eval` of `Int64`/`Float64`/`sum(...)`
  scalars is fine, so it is the assign-then-eval interaction, not the return
  type.
- The A26b entry recorded this file as green under `NOT_CRAN=true`; that run
  reported **2 live-Julia skips**, i.e. the bridge was not configured, so the
  live legs were never exercised. Not a lapse — an unmeasured premise.

Consequence, stated precisely: the A26 parity legs pass **per file**; a
whole-suite live run cannot currently be demonstrated clean. Not fixed here —
it is a toolchain defect in another file's lane and fixing it would widen this
commit. **Handed to Grace.**

## Finding — dashboard had no row for the route MV-4 actually wired

`v02_multivariate` records `julia_dispatch = fit_payload_v2:multivariate` with
boundary "Parser throws without G0/R0". That describes the **payload_v2
supplied-covariance MME block**, which has no R route (consistent with Rose's
F5). The default `cbind()` auto-route calls
`hs_fit_julia_multivariate_payload` → `HSquared.fit_multivariate_reml` directly.
So the route carrying the promotion claim had **no schema row and no parity
row**. The existing row was left alone (it is accurate for its own path) and a
new `v02_multivariate_reml` row added beside it, `r_bridge_status = partial`.

## Fence — A26 does NOT authorize the covered flip

One of nine acceptance criteria is discharged. Still open: **A27** (Darwin
sign-off on the genetic covariance/correlation as the recovered quantity, plus
the locked `r_g` / per-trait `h²` citation), **MV-5 disposition**, **A29** Rose
pre-flip audit, owner **G10**, **DP-1** (neither branch pushed, so nothing here
is CI-verified), and the F3 Julia Documenter page regeneration.

- R multivariate stays **partial**. No status flipped in any commit.
- `public_covered_count` stays **5**.
- Parity is **point-estimate at ONE k=2 fixture**; `k ≥ 3` and
  `genetic_structure = "diagonal"` stay experimental; no interval-coverage claim.
- No push, no G10, no Registrator, no version bump, no Totoro/DRAC.

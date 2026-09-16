# 2026-09-02 — A26: R↔engine multivariate parity — TOLERANCE PREDECLARATION

**Arc:** A26 (R↔engine element-wise multivariate parity, k = 2 promotion fixture).
**Lane:** R (`hsquared`), Hopper (bridge/translator lens).
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Branch:** `claude/lane-h2-twin-20260901`. **Not pushed.**

**This file is written and committed BEFORE the parity comparison is run.**
The A25 Rose audit (blocker 1) requires the tolerance to be declared first, so
this entry carries no results. Results land in a separate
`2026-09-02-h2-a26-mv-bridge-parity.md` entry.

## Why this arc exists — what the existing tests do NOT do

Measured on both lanes at this branch, the k = 2 fixture
(`phase4_multitrait_parity`) is consumed twice, and **neither consumer crosses
the bridge**:

| Lane | Consumer | What it actually asserts |
|---|---|---|
| Julia | `test/runtests.jl` "Phase 4 shared multi-trait parity fixture" | `multivariate_mme(Y, X, Z, Ainv, G0, R0)` — the **supplied-covariance MME at the stored covariances**. Never calls `fit_multivariate_reml`; never re-runs the optimizer. |
| R | `test-multivariate.R` "R consumes the shared Phase 4 … fixture" | Injects the `expected_*.csv` values into a **hand-built `raw` list**, then checks the R normalizer/extractors surface them. **Executes no Julia code at all.** |

So the serialized target is pinned from both sides *by construction*, and the
R↔engine path between them is asserted nowhere. That is exactly Rose's blocker 1
("Does not exist"), and it is confirmed, not inferred.

**Fixture is genuinely shared — no twin asymmetry.** All eight data/target CSVs
are byte-identical across lanes (md5, measured); only `README.md` differs
(R copy carries the R-lane comparator protocol). No new fixture is created.

## Two bridge divergences found while designing this (pre-run, static reading)

Recorded here because they are the reason the tolerance is tiered, not because
the parity run has produced them.

1. **`initial` default diverges between the two entry points.**
   `fit_multivariate_reml` with no `initial` starts at
   `G0 = R0 = Diagonal(0.5 · phenotypic variance)` (`src/multivariate.jl`,
   data-scaled). The R bridge **never reaches that default**:
   `hs_validate_multivariate_initial(NULL, t)` returns `list(G0 = I, R0 = I)`
   and `hs_fit_julia_multivariate_payload` always assigns it. On this fixture the
   engine default would be `diag(0.43, 0.18)`-ish against the bridge's
   `diag(1, 1)`. Same estimator, **different starting simplex**.
2. **The optimizer is derivative-free.** `optimize(negloglik, params0,
   NelderMead(), …)`. Nelder-Mead converges on the objective, not the parameter
   vector; near a flat REML optimum the parameters can sit further from the
   target than the loglik does. A parameter-scale tolerance borrowed from a
   Newton-type fit would be wrong here.

Consequence: a single tolerance cannot serve. Start-matched agreement should be
near-deterministic; start-mismatched agreement is an optimizer property.

## Predeclared legs and tolerances

`Y`, `X`, `Z`, `Ainv`, `ids` are built by the R payload emitter and sent over
`JuliaCall`; `Ainv` is rebuilt inside Julia from the transmitted pedigree.

### Tier A — structural, EXACT (no tolerance)

Any failure here is a bridge defect, not a numeric disagreement.

- `payload$ids` order == `expected_ebv.csv` animal order (the Julia
  `normalize_pedigree(...).ids` order, pinned by the Julia testset's
  `@test ebv_ids == ped.ids`).
- `payload$X` == `[1 x]`, `payload$Y` == the two trait columns, `payload$Z`
  == the record→animal incidence built over `payload$ids`, all element-wise.
- Returned trait order == `c("trait1", "trait2")`; `dimnames` on `G0`/`R0`.
- `converged == TRUE`; EBV long format has `2 · q` rows; `nobs == 2 · n`.
- Engine-returned `breeding_ids` == `payload$ids` (not merely set-equal).

### Tier B1 — start-matched R↔engine determinism, `atol = 1e-8`

R bridge fit vs a **native Julia fit on the same fixture, read from CSV inside
Julia**, both given the same `initial`. This is the leg that actually confronts
marshalling: a transposed matrix, a mis-ordered `Z` column, a broken sparse-CSC
hand-off, or an `NA`→`NaN` slip cannot survive it. Nelder-Mead is deterministic
and unseeded, so start-matched runs on identical inputs should agree to
round-off. Applies element-wise to `G0`, `R0`, `r_g`, `r_e`, `h²`, `beta`,
EBVs, `loglik`.

### Tier B2 — R bridge vs the SERIALIZED fixture target

Declared **before** measurement, on the reasoning above (derivative-free
optimizer, start mismatch of item 1):

| Quantity | Declared `atol` |
|---|---|
| `G0`, `R0` element-wise | `5e-4` |
| `h²` per trait | `5e-4` |
| `r_g`, `r_e` | `5e-4` |
| `beta` element-wise | `5e-4` |
| EBVs element-wise | `5e-3` |
| `loglik` | `1e-3` |

Basis: the same order as the in-repo `sommer` external-comparator leg
(`5e-4` VC / `5e-3` EBV in `test-multivariate.R`), which is the only existing
precedent for comparing two independent optimizer runs of this estimand on this
fixture. The Julia lane's `5e-6` is **not** the precedent — it pins a
supplied-covariance MME with no optimizer re-run.

### Tier B3 — pedigree-permutation invariance, `atol = 1e-6`

The R emitter builds `Z` columns over R's `hs_topological_pedigree` order; Julia
rebuilds `Ainv` over its own `normalize_pedigree` order. Both are DFS post-order
(sire subtree, dam subtree, emit) so they agree **by parallel implementation**,
verified by no test. The fixture pedigree is already topologically sorted, so it
cannot discriminate. This leg refits on a **row-permuted** pedigree (same
animals, same parents) and requires the estimates to be invariant and the EBVs
to match after ID-matching. A `Z`↔`Ainv` misalignment shows up here and nowhere
else in the suite.

## Escalation rule — binding

If a leg lands outside its declared tolerance, that is **recorded as a finding
with the measured deltas**. The tolerance is **not** widened to accommodate it,
and no leg is dropped after seeing its result. If Tier B2 misses because of the
`initial` divergence, the fix under consideration is the bridge default, not the
tolerance.

## Fence — restated because this arc is a flip precondition

Passing A26 **does not authorize the R multivariate `covered` flip.** It
discharges one of the nine acceptance criteria. Still open: A27 (Darwin sign-off
on the genetic covariance/correlation as the recovered quantity, plus the locked
`r_g` / `h²` citation), MV-5 disposition, A29 Rose pre-flip audit, owner G10, and
DP-1 (neither branch pushed, so nothing here is CI-verified).

- R multivariate stays **partial**.
- `public_covered_count` stays **5**.
- No push, no G10, no Registrator, no version bump, no Totoro/DRAC.
  Fixture is 80 records × 20 animals × 2 traits — local Mac only.

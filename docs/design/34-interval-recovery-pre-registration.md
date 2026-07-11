# 34 — Interval & recovery pre-registration (honesty anchor, committed BEFORE any sbatch)

Date: 2026-07-10 · Lane: coordinator (R-repo `docs/design/`), governing both lanes ·
Status: **PREDECLARATION — no run yet.**

This file is the hard launch gate for the coverage / recovery evidence campaigns that
follow. The claim-level rule, the ±2·MC-SE bands, the cell grids, the seed streams, the
interpretability floor, and the aggregation rule below are **fixed BEFORE any `sbatch`**
(R4 discipline; the 2026-06-14 calibration-failure rule — no post-hoc threshold
relaxation). Every campaign produces **triage or characterization evidence until a
calibrated gate clears**; nothing moves to `covered` and `public_covered_count` does not
change without a real Rose audit and the maintainer's per-move **G10** sign-off (G10 is
non-delegable).

Placement rationale (see §14): the claim-level rule is a **coordinator-lane / public-claims
artifact** (the R repo owns the v0.1 Uncertainty Scope and every claim level), so the
governing rule lives here; the operational grids/seeds/`sbatch` for each campaign live in
the twin's `HSquared.jl/docs/dev-log/recovery-checkpoints/` and **cite this doc by number**.

---

## 1. Purpose

Bind, in advance, the mapping from measured evidence to the public claim we are allowed to
make, for the shipped animal-model interval and recovery machinery. Two distinct kinds of
evidence are governed by one shared discipline:

- **Coverage evidence** (interval legs) → an **interval claim level**
  (`point` / `directional-conservative` / `experimental-only`).
- **Recovery evidence** (point-estimate / EBV bias legs) → **covered-eligibility**
  (`covered-eligible` / `banked-negative`).

The anchor exists so that when the `.out` files and TSVs come back, the decision is a lookup,
not a negotiation.

---

## 2. Vocabulary (fixed definitions)

- **Claim level.** The three interval claim levels of the v0.1 Uncertainty Scope
  (`docs/design/01-v0.1-contract.md`, as amended 2026-07-09):
  - **`point`** — the surface may report a point estimate *and* an interval presented as
    calibrated (nominal coverage supported by evidence).
  - **`directional-conservative`** — an interval may be shown but only as a *conservative /
    directional* statement (it does not under-cover; it may be wider than nominal). It must
    not be presented as exactly calibrated.
  - **`experimental-only`** — no interval on any user-facing surface; point estimate only,
    behind an opt-in / experimental label. (Rendered as `experimental` in the v0.1 contract
    prose; `experimental-only` is the tier label used by this rule.)
- **Estimand.** A single targeted quantity: `h2`, `sigma_a2`, a variance-ratio (two-effect),
  the repeatability `t`, a genetic correlation `r_g` (on the Fisher-z scale where an interval
  is formed), a G/R (co)variance entry, or an EBV accuracy. **A derived estimand is its own
  estimand** (see §4, no-inheritance).
- **Leg.** A method that produces the interval or estimate for a given estimand. C1 interval
  legs are **{delta, profile, bootstrap}**, mapping to the shipped labels
  `*_delta_z`, `*_profile_chisq`, `*_bootstrap_percentile`. C8 / supplied-K / repeatability
  use the **recovery** leg (a REML point fit whose bias is measured across seeds).
- **Cell.** One point of the pre-declared grid: (design × estimand × level × leg) for
  coverage; (design × truth-cell × leg) for recovery.
- **Interior vs boundary cell.** *Boundary* cells sit on or adjacent to a parameter-space
  edge (§8); all others are *interior*. Claim levels are set from **interior** cells;
  boundary cells inform caveats only.
- **Interpretable cell.** A coverage cell is *interpretable* only if
  `interval_success ≥ 0.9 · reps`. The coverage **denominator is `interval_success`, NOT
  `reps`** (the harness contract from the W1 predeclaration). A cell with
  `interval_success < 0.9 · reps` is reported **NON-INTERPRETABLE** and is excluded from tier
  assignment — it can never promote a claim.

---

## 3. The decision rule — VERBATIM (as committed)

Reproduced exactly as pre-declared, before any elaboration:

```
INTERVAL PRE-REGISTRATION DECISION RULE (committed BEFORE any sbatch;
no post-hoc relaxation), PER ESTIMAND (derived coverage does NOT inherit
from components):

  measured coverage within 0.95 +/- 2*MC-SE   supports 'point' or 'directional-conservative'
  [0.90, 0.94)                                 => 'directional-conservative' only
  < 0.90                                       => 'experimental-only'

~2000 reps/cell justified by coverage MC-SE ~= sqrt(0.95*0.05/2000) ~= +/- 0.0049.

Boundary cells: h2 -> 0 (univariate); |r_am| in {0.9, 0.95} + null (multivariate).

Legs: {delta, profile, bootstrap} for C1; recovery for C8.
```

The rule is authoritative as written. §4–§5 **operationalize** it without weakening it: every
elaboration below is either a definition or a *stricter* completion (over-coverage never
promotes; ties resolve downward).

---

## 4. Precise operationalization — coverage legs

Let `Ĉ` be the empirical coverage in an interpretable interior cell, computed on the realized
denominator `m_eff = interval_success`, and let `SE = sqrt(Ĉ·(1 − Ĉ) / m_eff)` be its Monte
Carlo standard error (the design anchor `sqrt(0.95·0.05/2000) ≈ 0.0049` in §6 is the *target*
SE at nominal coverage and full success; the *realized* SE uses `Ĉ` and `m_eff`). Define the
point-calibration band `B = [0.95 − 2·SE, 0.95 + 2·SE]` (≈ `[0.9403, 0.9597]` at the anchor).

**Per-cell eligibility (exhaustive; edges resolve to the lower/safer tier):**

| Measured `Ĉ` | Interval interpretation | Cell-eligible tier |
| --- | --- | --- |
| `Ĉ ∈ B` (calibrated) | coverage ≈ nominal | **`point`** (or, if chosen, the safer `directional-conservative`) |
| `Ĉ > 0.95 + 2·SE` (over-covers) | conservative / wider than nominal, never under-covers | **`directional-conservative`** — *never* `point` (not calibrated) and *never* `experimental-only` (it is honest, not anti-conservative) |
| `Ĉ ∈ [0.90, 0.95 − 2·SE)` (mild under-cover) | below band but ≥ 0.90 | **`directional-conservative` only** |
| `Ĉ < 0.90` (under-covers) | materially anti-conservative | **`experimental-only`** |

Notes that make this unambiguous:

- The verbatim threshold **`0.94`** is the rounded rendering of the lower band edge
  `0.95 − 2·SE ≈ 0.9403` at 2000 reps. The two are treated as identical; the boundary point
  itself resolves **downward** (a cell exactly at `0.90` or at a band edge takes the lower
  tier).
- **Over-coverage is added explicitly** because it is the empirically dominant regime for
  these shipped intervals at small `n` (the 2026-07-03 coverage study found `:delta` at
  `n=36` hitting 1.000). The verbatim rule's first branch covers the two-sided band; this row
  states the stricter completion so no over-covering cell is ever mistaken for `point`.
- **Per estimand, no inheritance (the load-bearing clause).** Coverage for a *derived*
  estimand is measured on the derived estimand's **own** interval and never inherited from its
  components. `h2 = sigma_a2 / (sigma_a2 + sigma_e2)` does **not** inherit `sigma_a2`'s tier;
  `r_g` does **not** inherit the tiers of `G[1,1]`, `G[2,2]`; the repeatability `t` does **not**
  inherit `sigma_a2`'s. Each derived estimand has its own row in every legs × cells grid.

**Aggregation to a leg×estimand claim level (pre-committed).** The claim level published for a
`(leg, estimand)` pair is the **worst (lowest) cell-eligible tier across its interpretable
interior cells** — a claim is only as strong as its weakest interior cell. Boundary cells (§8)
and non-interpretable cells do not enter this minimum; they generate caveats. Precedence, low
to high: `experimental-only` < `directional-conservative` < `point`.

**Nominal-level scope (0.95 promotable; 0.90 descriptive-only).** The claim-level rule of
§3–§4 is defined for the **0.95-nominal** intervals — the level the shipped surfaces report.
The harness also emits **0.90-nominal** intervals; these are **descriptive probes** (like the
t-/Satterthwaite probes of §7) and are **never** promotable to a claim level, whatever their
measured coverage. A perfectly-calibrated 90% interval covers at ~0.90 and must **not** be run
through the 0.95 band (which would falsely demote it). A 0.90-level claim, if ever wanted,
requires its own pre-registered band `0.90 ± 2·MC-SE` in a new predeclaration.

**Conditional coverage (disclosure).** Because the denominator is `interval_success` (§2), the
reported coverage is **coverage conditional on the interval being formed**. Where interval
formation fails non-randomly — e.g. the delta arm throwing as `σ²a → 0` at the `h2 → 0`
boundary — this conditioning biases the cell **upward** relative to unconditional coverage.
Every cell therefore reports its **per-cell exclusion/failure rate** alongside `Ĉ`, and the
boundary cells (§8) are read as *conditional* coverage, never as unconditional.

---

## 5. Precise operationalization — recovery legs (C8, supplied-K, repeatability)

Recovery legs measure a **point estimate**, not an interval, so they do not map onto the
interval claim levels; they map onto **covered-eligibility**. The same ±2·MC-SE discipline
applies with the target shifted from `0.95` (coverage) to `0` (bias):

- For each pre-declared parameter `θ` in a cell, compute across the `m` converged seeds:
  `bias = mean(θ̂ − θ_true)` and `MC-SE = sd(θ̂) / sqrt(m)`.
- **Cell passes** iff **every** pre-declared parameter satisfies `|bias| ≤ 2·MC-SE`
  (the C8 harness's `aggregate_within_2mcse` gate). Any EBV-accuracy floor
  (`≥ 0.85`) is a **reported** floor, not the discriminator.
- A passing interior cell → **`covered-eligible`** for that leg×cell. A failing interior cell
  → **`banked-negative`** (a recorded, reusable negative: seeds, versions, bias, MC-SE
  committed), not a threshold to be re-tuned.
- **Covered-claim regression rule (R9).** A cell that lies **inside an already-`covered`
  scope** (e.g. C8's `base_inside`) that **fails** its gate is a **STOP-and-ask covered-claim
  regression**, not a banked negative. Do not proceed to any promotion; narrow the covered
  row's scope or revisit the promotion with the maintainer.

Recovery legs never produce an *interval* claim level. Where a shipped surface reports an
interval built on top of a recovery-gated point estimate, that interval's tier is set by a
**coverage** leg (§4), measured separately.

---

## 6. MC-SE justification — why ~2000 reps/cell

**Coverage (binomial proportion).** Empirical coverage at nominal `p = 0.95` is a proportion;
its Monte Carlo SE is `sqrt(p(1 − p)/m)`. At `m = 2000`:

```
MC-SE = sqrt(0.95 * 0.05 / 2000) = sqrt(2.375e-5) = 0.004873  ≈  ±0.0049
2 * MC-SE ≈ 0.0097  ≈  ±1.0 percentage point
```

So the point-calibration band is roughly `0.95 ± 1.0pp`, i.e. `[0.940, 0.960]` — tight enough
that a genuinely nominal method is separated from a `[0.90, 0.94)` mildly-under-covering method
with a ~5·MC-SE margin, and from `< 0.90` by ~10·MC-SE. Fewer reps widen the band and blur
these tiers (500 reps → MC-SE ≈ 0.0097, ~2pp; the earlier 46853279 study's resolution). 2000
reps is the smallest round count that makes the ±0.0049 band operational.

**Realized denominator.** The band is computed on `m_eff = interval_success`, not on `reps`.
Non-convergence or boundary clamping shrinks `m_eff` and *widens* the realized SE; the §2
interpretability floor (`interval_success ≥ 0.9·reps`) bounds that inflation to
`≤ sqrt(1/0.9) ≈ 1.05×` before a cell is declared NON-INTERPRETABLE.

**Recovery (bias).** For recovery legs the relevant MC-SE is `sd(θ̂)/sqrt(m)`, which is
**parameter- and design-specific**, not `sqrt(0.95·0.05/m)`. A 2000-rep confirm tightens the
bias band ~`sqrt(2000/50) ≈ 6.3×` versus a 50-seed triage — which is exactly why 48–50-seed
recovery runs are **screening only** (direction, not magnitude) and a **2000-rep** run is
required before a recovery leg can inform a `covered` promotion (§11).

---

## 7. Per-estimand legs (the grid skeleton)

| Campaign | Estimand(s) | Legs | Gate type | Rule |
| --- | --- | --- | --- | --- |
| **C1** univariate | `h2`, `sigma_a2` | delta (`*_delta_z`), profile (`*_profile_chisq`), bootstrap (`*_bootstrap_percentile`) | coverage | §4 |
| **C1-ext** (new driver, §10) | two-effect variance-ratio, repeatability `t`, `r_g` (Fisher-z) | delta, profile, bootstrap | coverage | §4, per-estimand |
| **C8** multivariate | `G[1,1]`, `G[1,2]`, `G[2,2]`, `R[1,1]`, `R[1,2]`, `R[2,2]`, EBV accuracy | recovery | recovery | §5 |
| **supplied-K** | the variance components / ratio under a user-supplied `K` (and `Q`) | recovery | recovery | §5 |
| **repeatability** | `t` (gated); `h2 = sigma_a2/total` split (characterized-only) | recovery | recovery | §5 + §10 pre-commitment |

The t-/Satterthwaite-df columns emitted by the C1 harness
(`*_delta_t_*_probe`, `*_satterthwaite_chisq_probe`) are **PROBES**: descriptive diagnostics,
**never** a covered claim, whatever their measured coverage. The shipped variance-component
interval ships `:profile`-only precisely because the Wald/`_delta_z` probe under-covers.

---

## 8. Boundary cells (characterization, never promotion)

Boundary cells sit where the estimator is known to be least reliable (v0.1 contract:
"Boundary regimes `h2 → 0` or `h2 → 1`, low-information designs"). They are run and reported
**separately** and **never** enter the §4 aggregation minimum or a §5 promotion; a boundary
cell that fails is a documented caveat on the claim's edge, not a claim-killer and not a
claim-maker.

- **Univariate (C1): `h2 → 0`.** The smallest grid point (e.g. `h2 = 0.05`, plus the existing
  `h2 = 0.1`). At the lower boundary the additive variance pins at the `(0, ∞)` edge, REML
  clamps, and intervals truncate at 0 — coverage becomes irregular by construction. Reported as
  boundary characterization of the shipped intervals near `h2 = 0`.
- **Multivariate (C8): `|r_am| ∈ {0.9, 0.95}` + null (`r = 0`).** Genetic-correlation boundary
  cells extending the current grid (which stops at `rg_high = 0.70`). Two hard constraints,
  pre-committed:
  1. The existing `cond(G0) > 1e6` **reject guard stays on** (the near-singular-G vacuous-pass
     trap). A boundary cell rejected by the guard is recorded **"not evaluable at this design"**
     — neither a pass nor a fail. Construct the `{0.9, 0.95}` cells with diagonals chosen to
     keep `cond(G0)` under the guard where possible; where `0.95` cannot, it is reported as
     not-evaluable, not silently dropped.
  2. The known C8 signal — a **mild downward bias in the additive genetic (co)variance `G`**,
     sharpest for **single-record designs at extreme `r_g`** (job 47889484: `rg_low_rec1`,
     `rg_high_rec1` failed at 50 seeds; `R0` well-recovered everywhere) — is the *expected*
     boundary behavior these cells characterize, not a new discovery to be gated as covered.

---

## 9. No post-hoc relaxation (the anchor's teeth)

Frozen at this commit, before any `sbatch`:

- the three claim-level thresholds and the ±2·MC-SE band construction (§3, §4);
- the recovery `|bias| ≤ 2·MC-SE` per-parameter gate and the R9 regression rule (§5);
- the coverage denominator (`interval_success`) and the interpretability floor
  (`≥ 0.9·reps`) (§2);
- the interior/boundary partition and the boundary cell definitions (§8);
- the leg × estimand × cell grids, the design list, the `h2` / `r_g` grids, and the
  independent per-task master-seed streams;
- the aggregation-to-tier rule (worst interior interpretable cell) (§4).

After results are seen it is **forbidden** to: widen the band; move a threshold; reclassify a
failing **interior** cell as **boundary** to rescue a claim; drop or down-weight a failing
interpretable interior cell; switch the aggregation from *worst-cell* to mean/median;
re-baseline the coverage denominator to `reps`; or relabel a PROBE column as a shipped leg.
Any genuinely warranted change is a **new pre-registration** (a new `docs/design/NN` doc or a
new dated twin predeclaration that supersedes the relevant section here) run on **fresh
seeds** — never an edit to a gate evaluated against already-observed data. Narrowing scope
**before** launch (as the W1 predeclaration did: medium-design + large `n_boot` deferred) is
permitted and is *not* relaxation; it must be timestamped *pre-launch, no results seen*.

**Pre-launch clarifications (2026-07-10, no results seen).** Three adjudication points were
folded in from the adversarial ADEMP driver review **before any `sbatch`**: the nominal-level
scope (0.95 promotable, 0.90 descriptive-only; §4), the conditional-coverage disclosure with a
per-cell exclusion rate (§4), and the exact pooling recipe (§12). Each **tightens** adjudication
or adds a required disclosure; none widens a band, moves a threshold, or relaxes a gate.

---

## 10. Campaigns this pre-registration governs

All four inherit §2–§9. Operational grids/seeds/`sbatch` for each live in the twin
recovery-checkpoints and **must cite this doc**.

### C1 — univariate small-sample interval coverage (re-run)
- **Kind:** coverage → interval claim level (§4). **Legs:** delta, profile, bootstrap.
  **Estimands:** `h2`, `sigma_a2` (each its own tier).
- **DGP / grid:** half-sib designs `tiny:4:8:24` (q=36), `small:8:16:96` (q=120), optionally
  `medium:16:32:192` (q=240); `h2 ∈ {0.1, 0.3, 0.5, 0.7}` interior at unit total variance;
  **boundary** `h2 → 0` cell per §8; levels `{0.90, 0.95}`; AI-REML Gaussian animal model.
  Harness `sim/phase1_small_sample_interval_calibration.jl` (bootstrap drawn once per replicate,
  both levels off the shared draw set).
- **Seeds:** independent per-task master seeds → **~2000 interpretable reps/cell** target
  (§6). Bootstrap `n_boot` right-sized after the 1-task smoke (`seff`); the bootstrap arm's
  feasibility governs whether `medium` and larger `n_boot` are in-scope this run (W1 lesson:
  bootstrap at q=240 was infeasible → tiny+small first).
- **Prior context:** bootstrap job **47870067**; delta/profile job **46853279**
  (500 reps → over-coverage at small `n`, `:profile` better-calibrated). This run lifts those
  to the 2000-rep calibrated tier and adds the bootstrap leg at 2000 reps.

### C1-ext — new-family coverage legs (governed, staged after C1)
- **Kind:** coverage (§4), per-estimand. **Estimands:** two-effect variance-ratio,
  repeatability `t`, `r_g` on the Fisher-z scale.
- **Driver discipline (gotcha):** adding method labels to the committed C1 harness
  **invalidates `--resume`** against the committed detail TSV. Therefore implement as a
  **NEW driver + NEW TSV** (proposed name `sim/phase1_interval_coverage_ext.jl` writing
  `sim/drac/results/…_ext_<jobid>.tsv`), **not** an in-place edit of
  `phase1_small_sample_interval_calibration.jl`. This keeps the C1 detail TSV `--resume`-safe.

### C8 — multivariate REML recovery (re-seed)
- **Kind:** recovery → covered-eligibility (§5). **Parameters:** `G[1,1] G[1,2] G[2,2]
  R[1,1] R[1,2] R[2,2]` + EBV accuracy floor. **Gate:** `aggregate_within_2mcse`.
- **Grid:** the 8 pre-declared cells in `sim/drac/phase4_v4_cells.tsv`
  (`base_inside` = covered scope, tagged `inside`, under R9; the rest `new`) **plus** the §8
  boundary cells `|r_am| ∈ {0.9, 0.95}` and null. Harness
  `sim/phase4_multivariate_reml_recovery.jl`, cold-start, iterations 5000.
- **Boundary-cell driver discipline (gotcha):** appending boundary rows to the committed
  `phase4_v4_cells.tsv` **changes the cell set and invalidates `--resume`** against the
  committed C8 TSV. Add boundary cells as a **NEW cells file** (proposed
  `sim/drac/phase4_v4_boundary_cells.tsv`) run as a **separate array**, leaving the 8-cell
  file and its `--resume` history intact.
- **Seeds:** the confirm tier is **2000 reps/cell**; the prior 50-seed run (job **47889484**,
  5/8 within band) is **triage** (direction only). Re-run of the committed 8 cells at the
  2000-rep tier + the boundary array.
- **R9 is armed:** a `base_inside` failure is STOP-and-ask, not a banked negative.

### supplied-K / Q escape-hatch — 48-seed recovery gate (pending)
- **Kind:** recovery → covered-eligibility (§5), **screening tier** (48 seeds). Gates the
  user-supplied relationship/kernel matrix `K` (and marker `Q`) path.
- **Status:** the "supplied-K/Q escape hatch IN/OUT" decision is on the maintainer's G10 queue
  (2026-07-09 handover). This pre-registration governs the gate's evaluation **if** the hatch
  is admitted; it does **not** decide admission. 48 seeds are screening; a clean screen
  schedules a 2000-rep confirm before any `covered` claim.

### repeatability — 48-seed recovery gate (pending)
- **Kind:** recovery → covered-eligibility (§5), **screening tier** (48 seeds).
  Estimator `fit_repeatability_reml`.
- **Pre-committed identifiability stance (from 2026-06-18):** the repeatability `t =
  (σ²a+σ²pe)/total` is the identifiable summary and is the **gated** estimand; the
  `σ²a`-vs-`σ²pe` **split (`h2`) is weakly identified even at n≈1575** and is declared
  **characterized-only / `experimental-only`** — it is **not** gated as `point` at any
  validation scale here, and a 48-seed screen that happens to look good does **not** overturn
  that stance (it would need a much deeper multi-generation pedigree + external comparator,
  out of lane). This is the honest pre-commitment: we pre-declare *not* to claim the split.

---

## 11. Screening tier vs calibrated tier

| Tier | Reps/seeds | What it establishes | What it can do |
| --- | --- | --- | --- |
| **Screening / triage** | 48–50 | direction of a bias / gross mis-calibration | flag a boundary; schedule a confirm; bank a negative — **cannot** set a claim level or promote |
| **Calibrated / confirm** | ~2000 | claim-level tier (§4) or covered-eligibility magnitude (§5) | feed a Rose audit + G10; a `covered` move needs this tier |

A `public_covered_count` move or an interval claim-level assignment requires the **calibrated
tier** for the governing leg × estimand, plus a real Rose audit and the maintainer's G10. No
screening result, however clean, is sufficient on its own.

---

## 12. Run discipline (R4 + verified programme gotchas)

- **DRAC arrays only**, never login-node compute. Default cluster **fir**, `def-snakagaw_cpu`.
  `module load julia/1.10.10`. **Pin `OPENBLAS_NUM_THREADS=1`.** Depot + checkout on
  `/project`, never `/scratch` (60-day purge; the W1 outputs were nearly lost to it).
- **SLURM `COMPLETED` ≠ Julia succeeded.** A script whose last `echo` exits 0 reports
  `COMPLETED` even on a Julia error. Verification is **read the `.out` exit status *and* parse
  the committed TSV / machine-readable `GATE` line** — the authoritative gate is the printed
  AGGREGATE block, never the SLURM state and never a per-seed Frobenius exit.
- **`--resume` invalidation.** Changing method labels or cell definitions invalidates
  `--resume` against a committed TSV. Extensions ship as **NEW drivers + NEW TSVs** (C1-ext,
  C8 boundary cells; §10), never in-place mutations of the committed harnesses or TSVs.
- **Pooling to the calibrated tier (exact recipe; the per-task footgun).** The full ~2000-rep
  coverage per `(estimand, leg, design, h2, level)` is obtained by **summing raw counts** across
  the per-task **SUMMARY** TSVs: `coverage = Σ covered / Σ interval_success`,
  `MC-SE = sqrt(coverage·(1 − coverage) / Σ interval_success)`. **Never** average per-task
  coverage or MC-SE (that yields the ~100-rep MC-SE and a band ~4.5× too wide). **Never** re-feed
  the concatenated per-task **DETAIL** TSVs through the harness reader — its dedup key excludes
  seed/task, so `rep 1..100` repeated across 20 tasks collapses to ~100 reps; if detail must be
  pooled, key on the `seed` column (2000 distinct), never `rep`.
- **Smoke first.** One-task smoke, `seff` to right-size `--time`/`--mem`/`n_boot`, then the
  full array. Foreign untracked files are never staged.
- **Twin lane scope.** New drivers are proposed as **full new files under `sim/`** (the granted
  lane exception); `src/` and `validation_status.jl` are **not** touched by this work.

---

## 13. What a pass / fail means

- **C1 pass** = an honest per-estimand, per-leg coverage table mapped through §4. The expected
  headline (from the 500-rep precursor) is conservative over-coverage at small `n` →
  `directional-conservative` for the shipped intervals, converging toward `point` as `n` grows,
  with `:profile` reaching the band before `:delta`. It promotes nothing by itself; the
  t/df-probe path stays blocked.
- **C8 pass** on the `new` cells with **no `base_inside` regression** = the broader-DGP recovery
  evidence for the multivariate finish, to be assembled with a Rose audit + G10. The boundary
  array characterizes the genetic-(co)variance downward-bias edge (single record × extreme
  `r_g`) as a documented caveat.
- **supplied-K / repeatability screens** either clear cleanly → schedule a 2000-rep confirm, or
  flag a boundary → banked negative. The repeatability `h2` split is pre-declared
  `experimental-only` regardless.
- **Any fail** is a recorded, reusable negative (seeds / versions / bias / MC-SE committed).
  Neither outcome changes a default or a public claim without Rose + G10.

---

## 14. Placement recommendation (this doc's own path)

**Recommended:** this governing anchor lives in the **R coordinator lane** as
`docs/design/34-interval-recovery-pre-registration.md` (next free number after `33-…`), and the
**per-campaign operational ADEMP predeclarations** (grids, seeds, cells, `sbatch`) live in the
twin `HSquared.jl/docs/dev-log/recovery-checkpoints/` and **cite doc-34 by number**.

Rationale:
1. The claim-level rule (`point` / `directional-conservative` / `experimental-only`) is a
   **public-claims / Uncertainty-Scope artifact**, and the R repo owns public claims and the
   v0.1 contract — the durable honesty anchor belongs where the claim vocabulary is defined.
2. It is **cross-lane**: it governs both a univariate (C1) and multivariate (C8) campaign plus
   two engine-side gates; a single twin per-campaign predeclaration cannot be the shared source
   of truth for all four.
3. It respects the twin lane restriction: authoring here needs no edit to protected twin files;
   the twin side only gains **new `sim/` drivers** (proposed, not mutated) and short
   predeclarations that reference this doc.
4. It matches the established house pattern — the twin's `recovery-checkpoints/` already hold
   per-`sbatch` ADEMP predeclarations (W1, direct-maternal, rr-k2, v5-qtl…); this doc gives
   them a single upstream rule to inherit instead of restating the decision rule each time.

**Alternative (second-best):** a twin-only `sim/` predeclaration. Rejected as the *primary*
home because it would place the public claim-level rule in the engine lane, splitting the
source of truth for claim levels away from the v0.1 contract and forcing every future campaign
to re-derive the rule. The twin predeclarations remain — as *operational* children of this doc,
not as the governing rule.

---

## 15. Provenance

- Claim-level vocabulary: `docs/design/01-v0.1-contract.md` Uncertainty Scope (amended
  2026-07-09); `docs/dev-log/handover/2026-07-09-claude-handover.md`.
- C1 harness / labels / denominator: `HSquared.jl/sim/phase1_small_sample_interval_calibration.jl`;
  W1 ADEMP predeclaration `…/recovery-checkpoints/2026-06-29-w1-drac-ademp-predeclaration.md`;
  500-rep coverage study `…/2026-07-03-interval-coverage.md` (job 46853279); bootstrap job
  47870067.
- C8 harness / cells / gate: `HSquared.jl/sim/phase4_multivariate_reml_recovery.jl`,
  `sim/drac/phase4_v4_cells.tsv`, `sim/drac/phase4_v4_recovery.sbatch`; breadth checkpoint
  `…/2026-07-09-c8-mv-recovery-breadth.md` (job 47889484, 5/8 at 50 seeds).
- Repeatability identifiability: `…/2026-06-18-phase3-repeatability-h2-identifiability.md`
  (t gateable; `h2` split not reliably recoverable even at n≈1575).
- supplied-K / Q escape hatch: maintainer G10 queue, 2026-07-09 handover.
- Discipline: R4 no-post-hoc-relaxation (2026-06-14 calibration-failure rule); R9 covered-claim
  regression rule; G10 per-move maintainer sign-off (non-delegable).

**Status on commit: PREDECLARATION. No `sbatch` has run against these gates. Land this doc
first; then smoke; then launch.**
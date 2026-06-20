# START HERE — session handoff 5 (2026-06-20 s4, ultracode validation+contract sweep)

Resume rule: **live repo state wins over this doc.** Run `hsquared-rehydrate` (or
`git status --short --branch`, `git diff`, then read the coordination board +
latest `check-log` entry + this file). Then continue.

## Inherit (carry forward)

- **Goal (`/goal`):** "finish what's in your plan and goal, look at the widget,
  turn the many parts of the plan into action. There's a lot to do — work
  autonomously until the context gets very full." Keep driving the package toward
  completion; keep the mission-control widget current.
- **Mission control widget:** gitignored at `.mission-control/status.json`
  (served by `.mission-control/serve.py`). Refresh it as you go (Python: load
  JSON, update `in_flight`/`activity`/`next_up`/`twin_bridge`/`status_line`,
  write back, validate). It is current as of this handoff.
- **User directive:** "ultracode all Julia stuff left + the R-Julia bridge — keep
  communicating with your Julia twin." Drive order: **Julia unlocks → bridge →
  docs/validation.** Ultracode is on (use Workflows; adversarially verify).

## The key unlock (do not lose)

Live bridge — Julia is off-PATH at `~/.juliaup/bin/julia` (1.10):
```sh
PATH="$HOME/.juliaup/bin:$PATH" \
HSQUARED_JULIA_PROJECT="/Users/z3437171/Dropbox/Github Local/HSquared.jl" \
NOT_CRAN=true Rscript -e 'devtools::load_all(); testthat::test_file("tests/testthat/test-<x>.R")'
```
`hs_julia_bridge_available()` gates on `Sys.which("julia")`, so the PATH export is
mandatory. JuliaCall can segfault on teardown — run heavy live work one process
per file, and SAVE results to disk before the process ends (a nonzero exit after
the result prints is the teardown, not a failure).

## What landed this session (s4) — all on `main`, pushed `ad6584f..2ac078d`, CI green

| Commit | What |
| --- | --- |
| `94e94d3` | **Multivariate t=2 validation evidence** (twin's #1 handoff #10/#49). `data-raw/multivariate-recovery-study.R` (bug-fixed: missing `control = hs_control(engine="julia")` wrapper silently NULL'd every fit) → **100-rep COLD-start** live recovery, 100/100 converged, all 9 targets within bias ± 2·MCSE (no detectable bias), EBV acc 0.79/0.74. `data-raw/multivariate-comparator-study.R` (new) → **full-unstructured** `sommer` comparator vs the twin `phase4_multitrait_parity` target, agreement ≤ 8e-5 (recovers off-diag R0[2,1] the in-suite diagonal `mmes` check can't). capability-status + validation-debt-register + NEWS reconciled. **V4-MV-REML kept partial** (promotion twin-gated). |
| `47d46e1` | **Metafounder `Gamma=` reservation** — `metafounder()` marker now declares `Gamma = NULL` (+ @param); marker stays planned-not-implemented. |
| `a9c81d4` | Dev-log: board + check-log + after-task (`2026-06-20-multivariate-validation-metafounder.md`). |
| `2ac078d` | CI evidence record. |

Adversarially verified by a 4-lens Workflow (`wf_8bad14cd-fba`): both comparator
lenses **sound** (the correctness agent re-ran the study and reproduced every
number; confirmed the 113.7 loglik offset, A symmetry, and the `mmes`
unstructured-residual error). Metafounder lenses minor_issues — all should-fix
items applied to the #61 post + the code.

## Twin coordination — #61 (check for replies first)

- **Posted the MV evidence** (versions + tolerances) → issuecomment-4758935657.
- **Posted the metafounder Q1–Q4 contract** → issuecomment-4758935789: dedicated
  `metafounder(1|id, pedigree=ped, Gamma=Γ)`; MF/UPG distinct; dense `m×m` Γ +
  per-animal `group_of` (per-unknown-parent-slot groups deferred + flagged);
  **combined `(m+n)` inverse** is the fit payload; leading `m` rows are random
  metafounder **solutions** (not means) → new `metafounder_effects()`; Γ=εI→0
  reduction. **Awaiting the twin's `:metafounder` payload shape** to build the unpack.
- The R-side metafounder mirrored issue was **not** created (auto-mode classifier
  denied issue creation — not explicitly requested). The contract is on #61; the
  maintainer can open the R-side mirror, or approve issue creation next session.
- Twin is on `julia/session-closeout-v7` (handover v7); `main @ 06506e7` = PCG
  matrix-free MME (#85). Her open R-lane asks: metafounder Q1–Q4 (✅ answered),
  the MV comparator (✅ done), #43/#21 selinv merge-guard (already done s3),
  #45/#23 scan unpack, #2/#6 fitted-Mrode confrontation, #44/#18 HELD (non-Gaussian
  parser waits for her method note).

## Next backlog (ranked, unblocked first)

1. **Single-step H⁻¹ CONSTRUCTION bridge** (bridge activation; top unblocked item).
   The engine is shipped/exported:
   `fit_single_step_reml(y, X, Z, Ainv, A, G, genotyped_rows; tau, omega,
   blend_weight, ridge, initial, target, ids)` and `single_step_inverse(Ainv, A,
   G, genotyped_rows; …)` (`HSquared.jl/src/genomic.jl:2127,2163`). The R bridge
   currently only takes a **supplied** `Hinv` (`single_step(1|id, Hinv=Hinv)`).
   **To activate:** grammar `single_step(1 | id, pedigree = ped, markers = M)` (or
   `G = G`) where markers/G cover the **genotyped subset**; the R side builds
   `A`/`Ainv` from the full pedigree, computes `genotyped_rows` (indices of the
   genotyped IDs in pedigree order), and sends `y, X, Z, Ainv, A, G,
   genotyped_rows` to a new `target = "single_step_construct"`.
   **Fiddly bits:** (a) the data model must express markers/G for a *subset* of
   the pedigreed animals (the current genomic path assumes all id are genotyped);
   (b) `genotyped_rows` + G row-order alignment to pedigree order.
   **Correctness anchor (de-risks it):** when `G = A₂₂` (genomic == pedigree among
   genotyped), single-step reduces EXACTLY to the pedigree animal model — so a
   live test `single_step(G=A₂₂) == plain animal()` fit is the parity check.
2. **CPU batched marker-scan prototype** (Julia, R-lane-assigned; gates GPU, #48).
   Batch all-marker Wald stats off one mixed-model solve vs the per-marker loop;
   the design pass measured ~30× CPU. Standalone Julia, deliver to twin #48/#51.
3. **AI-REML convergence hardening** (Julia prototype): the `fit_ai_reml` PosDef
   try/catch gap noted s3 (`likelihood.jl:381`); σ²ₐ→0 cancellation lead.

**Twin-blocked (do NOT start):** FA/low-rank covariance (#42), calibrated GWAS
thresholds (#48), GPU ext/wiring, production sparse fitting, correlated
direct-maternal.

## Discipline

Per-slice: implement → adversarially verify (Workflow) → live-verify if
engine-coupled → `air format` + `document/test/check_pkgdown/check` → check-log →
board row → after-task → Rose audit → commit (plain imperative, no
Co-Authored-By) → push → record CI → post to twin #61. Honesty gate: only
`covered` is "working"; everything new is experimental/partial; carry the
engine's caveats; no public claim without live evidence + the experimental fence.

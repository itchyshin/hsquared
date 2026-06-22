# Codex hand-off: engine + comparator slices (13–18 of the 20-slice plan)

Date: 2026-06-22 · From: Claude (R lane) · To: Codex (engine/live toolchain) ·
Lane: coordination.

The 2026-06-22 20-slice plan split into 14 Claude-runnable slices (banked as the
stacked PRs #99/#100/#102/#103 on #98) and **6 slices that require live
Julia/R execution or comparator binaries** — these are routed to Codex here. The
R-lane artifacts each slice needs (contracts, runbooks, plans) are already banked;
this packet points each engine/comparator slice at its prepared inputs.

**Boundary.** Nothing here is executed or promoted. Every slice below needs
implementation/tests/validation + a Rose audit before any capability/validation/
public-claim row moves. Local host lacks the comparator binaries (BLUPF90-family,
ASReml, DMU, WOMBAT, PLINK/GEMMA/GCTA) and several R packages (AGHmatrix, rrBLUP,
BGLR) — the binary-dependent slices need a capable host.

## Slice 13 — Engine PEV/reliability via `:selinv` on `result_payload(AnimalModelFit)`
- **Lane:** Codex-Julia (engine). R already consumes the fields.
- **What:** route the live `AnimalModelFit` `result_payload` PEV/reliability via
  `method = :selinv` (currently `:dense` on that path). R surfaces them already.
- **Twin issue:** `HSquared.jl#6`. **Gate:** engine test + green twin row; R fires
  immediately.

## Slice 14 — Execute the 2nd same-estimand multivariate REML comparator
- **Lane:** Codex + binaries (blocked locally — needs a capable host).
- **What:** run ASReml-R / DMU / WOMBAT (or BLUPF90-family) on the
  `phase4_multitrait_parity` fixture and record a reviewed run report. This is the
  single biggest V4-MV-REML promotion blocker.
- **Prepared inputs:** `docs/dev-log/comparator-runs/2026-06-22-multivariate-second-comparator-runbook.md`
  (ASReml/DMU/WOMBAT) and the existing
  `2026-06-21-blupf90-multivariate-executable-handoff.md` (BLUPF90). Both pin the
  targets, scale mapping, and acceptance bands.
- **Twin/R issues:** `HSquared.jl#49`/`#41`, `hsquared#10`. **Gate:** one accepted
  run + Rose/Fisher/Curie verdict.

## Slice 15 — Widen `multivariate_result_payload` for `:lowrank`/`:factor_analytic`
- **Lane:** Codex-Julia (engine). **Now unblocked** by PR A.
- **What:** widen the payload to accept structured fits and emit the eigenbasis +
  invariants + invariant-only SEs (never raw loadings), per the now-ratified
  contract.
- **Prepared input:** `docs/design/29-structured-covariance-eigenbasis-bridge-contract.md`
  (the R ack the Julia FA decision was holding for). **Twin/R:** `HSquared.jl#42`,
  `hsquared#22`. **Gate:** engine widening + R bridge tests; then R #22 fires.

## Slice 16 — Build the fitted Mrode Ch.3/4 native target fixture
- **Lane:** Codex-Julia (engine), R consumes the fixture.
- **What:** a Julia-native fitted animal-model target (Mrode Ch.3/4) the R suite
  can reproduce — moves V1-MRODE-FIT toward Julia-native covered.
- **Twin/R:** `HSquared.jl#46`, `hsquared#7`. **Gate:** fixture + R parity test.

## Slice 17 — Post-fit marker-scan entry point `(fit, markers)`
- **Lane:** Codex-Julia (engine) + R glue.
- **What:** an engine entry point routing `(fit, markers)` to
  `mixed_model_marker_scan` (today the fit carries `Ainv = NULL` and no scan fn
  consumes a fit). Then R `gwas()` can run on the production path.
- **Prepared input:** the threshold-calibration plan
  `docs/dev-log/comparator-runs/2026-06-22-marker-scan-threshold-calibration-plan.md`
  (the calibration is a *later* gate; this slice is the entry point only).
- **Twin/R:** `HSquared.jl#48`, `hsquared#23`. **Gate:** engine entry point +
  R wiring tests; thresholds stay inactive.

## Slice 18 — Implement per-record varying-trial Binomial R activation
- **Lane:** R build is Claude-draftable, but **activation needs a live round-trip
  (Codex)** — so the finishing step is Codex's.
- **What:** per the plan, flip the equal-totals guard (`R/model-spec.R:437-446`)
  to a per-record `n_trials` vector build, make the family-symbol mapper
  vector-safe (`R/julia-bridge.R:443`), marshal the vector
  (`R/julia-bridge.R:543-544`), and verify with a live `fit_laplace_reml(...;
  n_trials = <vector>)` round-trip.
- **Prepared input:** `docs/design/31-nongaussian-per-record-trials-activation-plan.md`
  (file:line-precise, with the silent-Bernoulli landmine flagged). **Twin:**
  `HSquared.jl#44`. **Gate:** live round-trip green + pure-R tests; non-Gaussian
  stays partial (no heritability).

## Also flagged for Codex (out-of-scope items surfaced during PRs A–C)
- Julia `validation_status()` V4-MV-REML / V4-FA rows still list SEs/LRT as
  "missing"; the R extractors already ship — refresh the twin rows
  (`HSquared.jl#41`/#47).
- Latent R-code items needing live tests (do not fix without a round-trip): the
  possibly over-parameterized `idv(record):us(trait)` residual in
  `inst/comparator-scripts/asreml/multivariate-animal.R`; a λ_GC-implies-
  calibration wording risk in `R/gwas.R`/autoplot.
- The HSquared.jl #61 ledger refresh is drafted at
  `docs/dev-log/coordination/2026-06-22-jl61-cross-lane-ledger-refresh-draft.md`
  (post on the Julia side at the maintainer's discretion).

## Boundary
No execution, no promotion, no issue-state change here. This is a routing packet;
each slice carries its own gates and Rose audit before any claim moves.

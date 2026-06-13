# v0.1 default-fit flip (engine = "fit")

Date: 2026-06-13

Active lenses: Ada, Shannon, Boole, Fisher, Rose, Pat, Hopper (perspectives).
Spawned subagents: yes — a 5-agent adversarial honesty audit workflow
(`wetqf4t9i`, lenses rose-overclaim / twin-consistency / mlreml-honesty /
pat-coherence + adversarial blocker verification). An earlier 5-agent review
(`wz4clipba`) seeded the must-fix list.

Current lane: R (hsquared). No twin edits — the Julia twin is driven by a
separate live session.

## Goal and context

Under the standing finish-directive, flip the default `hsquared()` control from
validate-and-stop to a real fit of the v0.1 univariate Gaussian animal model,
and make every living public surface honest about that change.

The v0.1 promotion predicate (in `01-v0.1-contract.md`) was met and the
maintainer signed off the gate decisions (2026-06-13): gryphon anchor, sommer
comparator band, and DGP-recovery thresholds. The Julia twin declares the
matching gates on its `v01-gate-validation-status` branch (V1-AI-REML covered,
V1-MRODE-FIT / V1-COMPARATORS covered_external, V1-SPARSE-REML-OPT partial).

### Coordination history (important)

An earlier pass in this session edited the twin's `validation_status.jl` /
`runtests.jl` believing the twin idle. The twin session was in fact live (on
`phase4-multivariate-mme`) and had already done its v0.1 validation flip on its
own `v01-gate-validation-status` branch. The stray twin edits were surfaced to
the maintainer, who chose: **"You merge twin; I fix+push R"** — the twin
session/maintainer merges `v01-gate-validation-status` into Julia `main` and
discards the stray edits; this R lane fixes the review findings and pushes the R
flip **referencing the merged twin state**. This report records the R-lane half.
No twin files were touched by this slice.

## What changed

Engine / API:

- `R/hs_control.R` — default `engine = "fit"` (was `"validate"`); reworded the
  `ai_reml` target doc (now the validated default estimator, not "experimental
  opt-in"); kept `sparse_reml` experimental.
- `R/hsquared.R` — the `"fit"` branch fits via `fit_ai_reml` through the bridge
  and otherwise errors with install guidance. **ML rejection:** `REML = FALSE`
  is rejected on the `"fit"` path and on the `engine = "julia"` estimation
  targets (`fit_animal_model`, `sparse_reml`, `ai_reml`), exempting the
  supplied-variance `henderson_mme`. Reworded the `validate` terminal message
  and the `@param REML` doc (REML-only; `REML = FALSE` not implemented).
- `R/julia-bridge.R` — the two REML-only optimizers stamp `method = "REML"`
  (what they compute) instead of echoing the requested method, so a fit object
  can never be mislabeled.

Status declarations / claims:

- `R/validation-status.R` — promoted the default AI-REML fit, the gryphon
  published-REML anchor, and the known-truth DGP recovery rows to `covered`;
  de-gated their claim boundaries; fixed the gryphon "exactly" wording to
  "within the signed-off band"; kept `sparse_reml` partial.
- `R/formula-status.R` — the v0.1 `animal()` terms are `fitted (v0.1 default)`.
- `R/hsquared-package.R`, `DESCRIPTION`, `README.md`, `vignettes/hsquared.Rmd`,
  `vignettes/articles/{model-status,mission-control}.Rmd` — rewritten to the
  fits-by-default reality; ML-rejection and Julia-requirement stated; the
  gryphon "exact" overclaim replaced by the signed-off band (machine precision
  reserved for engine-vs-pure-R).
- `docs/design/{00-vision,01-v0.1-contract,06-public-claims-register,
  capability-status,validation-debt-register}.md` — predicate marked SATISFIED;
  claims promoted to covered-for-v0.1; "exact" overclaims corrected; the
  contradictory present-tense "default-fit flip additionally requires
  production-readiness" restated in past tense with scoped acceptance.

Tests:

- `tests/testthat/test-phase0-api.R` — `engine == "fit"` default; a new test
  that the fit path rejects `REML = FALSE`; validation_status row promotions.
- `tests/testthat/test-julia-bridge.R` — a new default-fit test; a new test that
  the `engine = "julia"` estimation path rejects `REML = FALSE`; the opt-in
  smoke test now uses `REML = TRUE`.
- `tests/testthat/{test-bridge-payload,test-hs-data}.R` — `engine = "validate"`
  and the new fit-target / validate messages.

## Adversarial audit (`wetqf4t9i`)

Three lenses returned clean. The mlreml-honesty lens found one **confirmed
blocker** (adversarially verified by reading the source + the twin engine): the
`engine = "julia"` default target `fit_animal_model` still routed `REML = FALSE`
to the genuine ML optimizer and returned an `"ML"`-labeled fit, contradicting
the new "ML is not implemented" claims. Fixed by the `engine = "julia"` ML guard
above + a regression test; the should-fix `@param REML` wording was also fixed.

## Checks

- `air format .` clean; `devtools::document()`.
- Full `testthat` suite with juliaup on PATH + `NOT_CRAN` + `sommer` + `enhancer`
  (live default fit, gryphon recovery, DGP, sommer comparator all run):
  **0 failures, 0 warnings, 0 skipped**.
- `rcmdcheck(--as-cran)`: **0 errors, 0 warnings, 1 NOTE** (benign new-submission).
- Both pkgdown articles render.

## Boundary

v0.1 fits the univariate Gaussian animal model by **REML only** (ML rejected),
single record per animal, requires the Julia engine. Recovery against the
published gryphon numbers is band-level, not bit-exact. Multivariate, genomic,
factor-analytic, and non-Gaussian models remain planned. Engine
production-readiness (large/real pedigrees) and the engine half of boundary
stability remain post-v0.1 hardening (twin work).

## Push gate (open)

The R flip is committed locally but **not pushed**. Per the maintainer's chosen
path, the push waits until the twin's `v01-gate-validation-status` lands on Julia
`main` (currently at `94e695b`; the gate flip is still branch-only). Once it
lands, push the R flip and append remote CI evidence to the check-log.

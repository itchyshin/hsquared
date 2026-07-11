# After-Task: MV-4 — multivariate cbind() auto-route (0.6)

**Date:** 2026-07-11 · **Lane:** R · **Owner:** Boole / Emmy / Hopper / Rose

## Task goal

Implement the ratified doc-38 multivariate grammar freeze (MV-4): make a
`cbind(...)` Gaussian response auto-route to the multivariate REML fitter on the
default `engine = "fit"` path, dropping the opt-in `target = "multivariate"`
requirement — the first code slice of the 0.6 milestone. **Implementation only:
no covered flip.**

## Active lenses and spawned agents

- Lenses: Boole (frozen grammar / dispatch predicate, doc 38), Emmy (dispatch
  structure), Hopper (bridge payload reuse), Rose (no-overclaim boundary).
- Spawned subagents: none (focused slice; ultracode off).
- Current lane: R.

## Files created or changed

- `R/hsquared.R` — removed the default-path multivariate abort; branched the fit
  dispatch to `hs_fit_julia_multivariate_payload`; added the §H2 auto-select
  (`engine = "julia"` + multivariate + no explicit target → `"multivariate"`);
  reworded the residual opt-in guard.
- `tests/testthat/test-multivariate.R` — replaced the two stale abort assertions
  with auto-route verification (validate-based target check + bridge-gated
  no-old-abort check).
- `docs/dev-log/check-log.md`, this report, coordination board.

## Checks run and exact outcomes

- `air format R/hsquared.R tests/testthat/test-multivariate.R` — delta confined
  to the edited regions (hsquared.R was already air-conformant; no pre-existing
  reformatting dragged in).
- `devtools::test(filter = "multivariate")` — clean; 3 skips (live JuliaCall /
  sommer comparator, expected).
- Full `devtools::test()` — **exit 0, 0 failures**; live-Julia/comparator skips
  only.
- Boundary grep — no other test depended on the removed multivariate abort
  messages.

## Public claim audit

- **No promotion.** `validation_status()` / capability-status / public-claims
  unchanged; multivariate stays `partial`/experimental; the lifecycle badge is
  unchanged; `public_covered_count` unaffected. The auto-route removes opt-in
  friction; it does not assert coverage. The 0.6 `partial → covered` flip
  (component external same-estimand comparator + `h2_T`/`r_g` identity tests +
  Darwin biology sign-off + Rose audit) is a separate gate event (doc 38 §F).

## Tests of the tests

- The `engine = "validate"` assertion is Julia-free and deterministic (confirms
  the multivariate target is selected without a bridge). The bridge-gated
  negative assertion (old aborts no longer fire) exercises the actual dispatch
  path when Julia is absent; when Julia is present the live smoke tests cover the
  real fit. Together they distinguish "grammar targets MV" from "dispatch reaches
  the MV fitter."

## Coordination notes

- Implements the doc-38 freeze ratified 2026-07-11 (Boole + maintainer). Doc 38 is
  in PR #131; this code slice is a separate branch/PR against `main`; no file
  overlap (PR #131 touches docs/design + decisions/ROADMAP only).
- Twin-discipline held: engine fit via the read-only bridge; no `HSquared.jl`
  edit; the engine `V4-MV-REML` covered status does not confer the R flip.

## What did not go smoothly

- Nothing blocking. The `air format` pre-existing-non-conformance hazard did not
  bite here (hsquared.R was already conformant), unlike the earlier
  extractors.R/gwas.R case.

## Known limitations

- The auto-route makes an **experimental** capability the default-path behavior
  ahead of its covered flip; this is intended per doc 38 §E (the auto-route is
  API-stable at 0.6, but the covered numeric claim is the separate gate). Status
  surfaces keep it labelled experimental until the flip.
- Covered numeric claim is scoped to `k = 2`; `k ≥ 3` is
  parseable-and-fittable-but-experimental (doc 38 §H1).

## Next actions

1. The 0.6 covered-flip evidence: MV-1 (in-suite full-unstructured sommer gate),
   MV-2 (cite the executed BLUPF90 leg), MV-3 (`r_g`/`h2` identity tests), MV-5
   (broadened recovery, doc 40, maintainer compute-go), Darwin sign-off, Rose.
2. Merge order: doc-38 ratification (PR #131) and this implementation both land
   before the flip.

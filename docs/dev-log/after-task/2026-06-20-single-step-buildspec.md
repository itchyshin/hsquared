# After-task — closed #93 loop + single-step R-wiring build-spec (2026-06-20 s5)

## Goal

(1) Close the cross-lane #93 plot-data contract loop now that R consumes all four
landed preparers. (2) De-risk the ranked #3 (single-step H⁻¹ construction bridge),
a "focused fresh-context build", with a precise R-wiring build-spec grounded in a
live engine probe — so the next session executes rather than designs.

## Shipped

- **#93 completion comment** (`issuecomment-4760095710`): the four-preparer
  consumption table + live parity guards (24/24), the per-question status (Q1
  rename-robust, Q3b raw+annotate confirmed, Q4 status flags enforced, Q6 RR parity
  landed), and the open asks back to the twin (§6 naming map, the `value` rename).
- **`docs/design/25-single-step-construction-bridge.md`** — the build-spec:
  proven engine contract, parser grammar, the `genotyped_rows` alignment rule (the
  crux), payload contract, exact bridge command sequence, live tests (reduction +
  partial-genotyped + alignment guards + knobs), honesty/status, risk register.
- Board + check-log updated.

## Honesty

- Docs + coordination only — **no R package code changed** (no capability claim).
  The spec is `planned`; the capability-status row flips to `partial (R)` only when
  the build lands + the reduction test is green (twin-gated past `partial`).
- The spec is **evidence-backed**, not speculative: the central command sequence and
  the G=A₂₂ reduction were live-confirmed this session (max|ΔVC| = 0.0), and the
  engine function names were verified exported.

## Verification

- LIVE probe (engine, juliaup): a 5-animal pedigree → `additive_relationship`→A,
  `G = A[g,g]` all-genotyped, `fit_single_step_reml(y,X,Z,Ainv,A,G,g)` ==
  `fit_ai_reml(animal_model_spec(...))` → **max|ΔVC| = 0.0**.
- Exports verified: `single_step_inverse`, `fit_single_step_reml`,
  `genomic_relationship_matrix`, `additive_relationship` (corrected from the
  initial `numerator_relationship` guess against the real `src/HSquared.jl`).
- No R checks needed (markdown design note + an issue comment).

## Cross-lane

- #93 loop closed from the R side; ball is with the twin for the §6 naming-map
  confirm + the optional `value` rename. The build-spec targets her exported
  `single_step_inverse`/`fit_single_step_reml`.

## Next

1. **Execute `docs/design/25`** — the single-step construction bridge build
   (parser → payload → bridge → live reduction test). Mechanical now.
2. LOCO / single-marker `gwas()` (#4).

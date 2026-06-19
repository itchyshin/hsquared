# 23 — External-comparator policy

Consolidates the scattered comparator practice into one reference: which external packages gate
which capability, the same-estimand rules, the tolerance bands, and what `covered` requires. This
is policy/design, not a capability claim. The live source of truth for status is
`validation_status()`; this doc explains the *rules behind* the rows.

## Principles

1. **Same estimand, same model, same data.** A comparator only counts if it estimates the *same*
   quantity by the *same* method on the *same* design — e.g. REML variance components for the
   identical animal model on the identical records and relationship matrix. Cross-method or
   cross-model "agreement" is not evidence.
2. **Two-sided agreement vs one-sided floor.** A *two-sided* comparator (both fitters should land
   on the same optimum within a band) is real agreement. A *one-sided floor* (our fit must be at
   least as good by a shared objective) only rules out our optimiser being worse — it is weaker and
   must never be described as "agreement".
3. **Honesty gate.** A comparator is *evidence behind* a capability row, not a separately `covered`
   capability. Only a `validation_status()` row may be called `covered`, and only when its gate is
   met. Comparators that "skip when absent" (Suggests not installed) must skip, never silently pass.
4. **CI vs local.** Pure-R reference + external-R-package comparators run in public CI (given
   Suggests); the live Julia engine legs are skip-guarded and run only locally. State which is which
   wherever a number is shown.

## Comparator → capability map

| Comparator | Kind | Gates / supports | Where |
| --- | --- | --- | --- |
| **`nadiv`** | two-sided (A⁻¹ construction) | pedigree numerator-relationship inverse vs `nadiv::makeAinv()` at 1e-10 (twin `V1-AINV-MRODE9`) | engine + R fixtures |
| **`sommer`** | two-sided (REML VC + h²) | gryphon published-REML agreement within the signed-off band (twin `V1-COMPARATORS`; R "external published-REML recovery" row, `covered`) | `test-validation-fixtures.R` |
| **`pedigreemm`** | **one-sided floor only** | hsquared REML logLik ≥ pedigreemm's on a *replicated* design (it cannot fit the saturated one-record Mrode design; its optimiser lands off-optimum on pedigree models) | `test-validation-fixtures.R` |
| **`enhancer`** | data source | ships the gryphon `DT_gryphon` / `A_gryphon` teaching dataset for the published anchor | fixtures |
| **`sommer` (multivariate)** | partial two-sided | diagonal-residual multivariate target: G0, diag(R0), per-trait h² within `5e-4`; does NOT validate off-diagonal R0 | `test-multivariate.R` |
| **ASReml-R / BLUPF90** | manual, future | dry-run-safe comparator-script templates only; no committed run evidence | `inst/comparator-scripts/` |
| **MCMCglmm / DMU / WOMBAT** | future | not yet wired; reserved for promotion of partial rows | — |

## Tolerance bands (maintainer-signed-off, 2026-06-13)

From `docs/design/01-v0.1-contract.md` (Gate decisions):

- **Gryphon univariate (sommer):** variance components within ~1–2% relative; `h²` within
  ~0.01–0.02 absolute; EBV correlation > 0.999 (rank correlation 1.0). The implemented atom asserts
  the variance-component + `h²` portion (`expect_equal(tolerance = 0.02)`, relative; the `h²`-vs-
  `sommer` check is an absolute `0.02` bound). The EBV-correlation criterion is a target verified on
  the engine side.
- **pedigreemm floor:** `logLik(hsquared) ≥ logLik(pedigreemm) − 1e-6`. A floor, not a band.
- **Multivariate (sommer, diagonal residual):** `5e-4` on G0, diag(R0), and diagonal-target h².
- **Known-truth DGP (not a comparator, the recovery study):** ≥ 100 replicates, fixed seed; `0`
  inside bias ± 2·MCSE for σ²a, σ²e, h² (|relative h² bias| ≤ 0.05 backstop); mean cor(EBV, true BV)
  ≥ 0.5 at h² = 0.4.

## What `covered` requires

A capability row moves from `partial`/`planned` to `covered` only when:

1. the estimand and model are pinned (no ambiguity about what is fitted);
2. a **two-sided** external comparator (or a published anchor) agrees within the signed-off band,
   OR a known-truth recovery study meets the DGP thresholds — a one-sided floor alone never
   suffices;
3. the evidence is committed and CI-runnable (or, for engine-only legs, reproduced locally with the
   skip-guard documented);
4. the public claim matches the row, and Rose records a clean audit.

Multivariate (`V4-MULTIVARIATE` / `V4-MV-REML`), factor-analytic (`V4-FA`), genomic
(`V2-*`), and the standard-QG REML rows (`V3-*-REML`) remain `partial` precisely because they lack a
*passing* two-sided comparator or known-truth recovery; the harness exists, the gate does not yet
pass. See `docs/dev-log/issue-map.md` for the open gates.

## See also

- `docs/design/01-v0.1-contract.md` — the signed-off gate decisions + promotion predicate.
- `docs/design/12-multivariate-comparator-plan.md` — the multivariate comparator ladder.
- `vignettes/articles/validation-evidence.html` + `vignettes/articles/benchmark-comparators.html`
  — the narrative + the executed benchmark.
- `validation_status()` — the live per-row source of truth.

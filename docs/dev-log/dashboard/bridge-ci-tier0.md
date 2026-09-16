# Bridge CI Tier 0 — fixture-first contracts (no live Julia)

**Slice:** H² B4 A16 phase 1  
**Plan source:** `~/local-scratch/h2-b4-bridge-plan.md` § A16 — Tier 0  
**CI surface:** default `R-CMD-check` (no Julia, no `JuliaCall`)

Tier 0 is the **always-on** bridge evidence leg on GitHub Actions. Live bridge
parity (Tier 1) stays skip-guarded until an optional Julia job exists; see
`.github/workflows/bridge-ci-tier0.NOTES.md`.

## Tier 0 test classes

| Class | testthat file | Dashboard smoke_id / boundary |
| --- | --- | --- |
| Emitter contract (payload v2) | `tests/testthat/test-bridge-payload-v2.R` | `smoke_payload_v2_emitter` |
| Emitter contract (v0.1 fields) | `tests/testthat/test-bridge-payload.R` | `smoke_bridge_payload_v01` |
| Normalizer (Julia-free) | `tests/testthat/test-julia-bridge.R` | `default_ai_reml_boundary` (live rows skip) |
| Fixture pins (Julia-free legs) | `tests/testthat/test-validation-fixtures.R` | `smoke_gryphon_r_reference` |
| Dashboard + validator | `tests/testthat/test-bridge-dashboard-contracts.R` | all TSV ledgers |
| Tier 0 registry contract | `tests/testthat/test-bridge-ci-tier0-contracts.R` | `tier0_ci_contract_boundary` |

## Tier 0 parity smoke rows (`julia_path = none`)

These rows in `bridge-parity-smoke-status.tsv` must keep `test_status = covered`
so CI exercises bridge **emitter / fixture** contracts without a Julia runtime:

- `smoke_payload_v2_emitter`
- `smoke_bridge_payload_v01`
- `smoke_gryphon_r_reference`

## Serialized payload stability (optional Tier 0)

`tests/fixtures/emit_payload_v2_fixtures.R` serializes fixtures a/b/c for the
Julia twin (`HSquared.jl/test/fixtures/payload_v2/`). Tier 0 asserts in-memory
payload fingerprints in `test-bridge-ci-tier0-contracts.R`; committed JSON
checksums are optional follow-up.

## Tier 1 (not enabled)

Optional `bridge-parity` workflow stub documents the future job (Julia +
`JuliaCall`, filtered `test-julia-bridge.R` / `test-engine-julia-smoke.R`).
Not wired in phase 1.

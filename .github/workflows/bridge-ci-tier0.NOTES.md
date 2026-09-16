# Bridge CI tiers (A16)

Authoritative tier tables: `docs/dev-log/dashboard/bridge-ci-tier0.md`  
Recon plan: `~/local-scratch/h2-b4-bridge-plan.md` § A16

## Tier 0 — default `R-CMD-check` (active)

GitHub Actions workflow: `.github/workflows/R-CMD-check.yaml`

Runs the full `testthat` suite. Bridge **live** legs skip when Julia is absent;
Tier 0 contract tests must pass on every PR:

| Filter (maintainer) | Role |
| --- | --- |
| `bridge-ci-tier0-contracts` | Tier 0 registry + payload fingerprints |
| `bridge-dashboard-contracts` | Dashboard TSV schema + validator |
| `bridge-payload-v2` | Payload v2 emitter (Julia-free) |
| `bridge-payload` | v0.1 emitter fields (Julia-free) |

Normalizer + fixture pins live in `test-julia-bridge.R` and
`test-validation-fixtures.R` (mixed skip-guarded and Julia-free tests).

## Tier 1 — optional Julia parity job (stub only)

File: `.github/workflows/bridge-parity-tier1.stub.yaml`  
Status: **not enabled** (`workflow_dispatch` stub; job `if: false`)

When enabled (Grace lens), install Julia + `JuliaCall`, checkout sibling
`HSquared.jl`, run filtered live smokes and `emit_payload_v2_fixtures.R` →
Julia `test_payload_v2_parity.jl`. Budget ≤ 15 min.

## Tier 2 — maintainer / Totoro

Full `devtools::test()` with Julia available; row-specific parity per
`bridge-parity-smoke-status.tsv` tolerances.

## Tier 1 (2026-09-02)

`bridge-parity-tier1.yaml` is `workflow_dispatch` only and sets `HSQUARED_REQUIRE_BRIDGE=true`. Do **not** flip `bridge-parity-tier1.stub.yaml` `if: false`. Owner DP-10 still decides whether this becomes standing evidence for criterion 8.

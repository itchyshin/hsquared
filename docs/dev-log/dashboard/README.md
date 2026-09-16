# hsquared bridge dashboard (A14 phase 1)

Row-specific ledgers for the R↔Julia bridge contract. Pattern donor:
`drmTMB/docs/dev-log/dashboard/bridge-*.tsv`.

These tables are **source truth for claim boundaries**, not generated views.
The payload-v2 schema remains FREEZE-READY in
`HSquared.jl/docs/design/21-payload-v2-multiblock-schema.md` until the mirrored
ledger handshake is RATIFIED (Julia #5/#6 ↔ R #5).

## Files

| TSV | Role |
| --- | --- |
| `bridge-payload-schema.tsv` | Per-route payload fields and bridge status |
| `bridge-parity-smoke-status.tsv` | Row-specific parity smoke + tolerances |
| `bridge-boundary.tsv` | smoke_status / bridge_status / boundary_doc_status / claim_boundary per target |

## Status columns in `bridge-boundary.tsv`

Three columns end in `_status` and they answer three different questions. They
use deliberately disjoint vocabularies so that no reader — and no generated
view — can scan one column and come away with the other's claim.

| Column | Question it answers | Allowed values |
| --- | --- | --- |
| `smoke_status` | Does a smoke test exercise this target, and under what guard? | `live_skip_guarded`, `emitter_only`, `no_smoke`, `calibrated_point_parity` |
| `bridge_status` | Is the R↔Julia bridge for this target a covered surface? | `covered`, `experimental`, `partial`, `planned`, `intentional_error`, `unsupported`, `not_applicable` |
| `boundary_doc_status` | Is the boundary itself written down, with resolvable evidence? | `documented`, `partial`, `planned` |

`boundary_doc_status = documented` is **not** a coverage claim. It says only that
this row states its limits and points at evidence that exists. A row can be
`no_smoke` / `experimental` / `documented` at once — `gryphon_live_vignette` is
exactly that, and it is consistent: there is no smoke, the bridge is
experimental, and the boundary is fully written down.

`bridge_status` never increments `public_covered_count` on its own (B1 F2), and
`tools/validate-bridge-dashboard.py` rejects `bridge_status = covered` on a
`no_smoke` row.

This column was renamed from a bare `status` on 2026-09-01 (B4 barrier condition
C3): `status = covered` on a `no_smoke` row read as a covered bridge surface.

## Validate

```sh
python3 tools/validate-bridge-dashboard.py
```

## Tier 0 CI (A16 — no live Julia)

Fixture-first bridge contracts run in default `R-CMD-check`. See
`bridge-ci-tier0.md` and `.github/workflows/bridge-ci-tier0.NOTES.md`
(plan: `~/local-scratch/h2-b4-bridge-plan.md` § A16 Tier 0).

```r
devtools::test(filter = "bridge-ci-tier0-contracts")
```

## Contract tests

```r
devtools::test(filter = "bridge-dashboard-contracts")
```

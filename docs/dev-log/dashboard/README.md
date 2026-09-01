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
| `bridge-boundary.tsv` | smoke_status / parity_required / claim_boundary per target |

## Validate

```sh
python3 tools/validate-bridge-dashboard.py
```

## Contract tests

```r
devtools::test(filter = "bridge-dashboard-contracts")
```

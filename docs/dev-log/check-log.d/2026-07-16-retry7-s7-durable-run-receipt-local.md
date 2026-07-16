# Retry-7 S7 durable synthetic-run receipt — local gate (2026-07-16)

The S7 remote rehearsal passed but could not clear because its retained log did
not bind the timeout configuration. The synthetic lifecycle now writes a
create-once, sidecar-protected `synthetic_run_receipt.tsv` before materializing
either stage. It records the deployed R/Julia roots and heads, the resolved
timeout executable, the validated 1..3600-second bound, `TERM`, 15-second kill
grace, and the exact wrapper arguments. The same frozen configuration is passed
to every worker in both D0F and D1.

Local evidence from this source state:

- synthetic worker self-test: PASS, including receipt contents and sidecar;
- focused launcher test: PASS;
- full `devtools::test()`: PASS with existing documented skips only;
- synthetic lifecycle sidecar: PASS
  (`290b21370f52104d244d5a1770cf75052fa892a6e0c5208e67d9175f0fdb2285`);
- Julia `Pkg.test()`, Documenter build, and preamble cap: PASS;
- `git diff --check`: PASS.

This source change invalidates all prior exact-head CI and review receipts.
The passed remote lifecycle remains historical synthetic evidence only; a fresh
clean/dirty Totoro control and lifecycle with the new receipt are required.
No official preseal or RNG is authorized by this record.

# Retry-7 S7 preseal gate — blocked checkpoint

## State

**Supersession (2026-07-16):** the attempted canonical writer exposed a stale
`v07_genomic_recovery_v3.R.sha256` sidecar. Commit `01ad843` repairs that byte
binding. This is a tool-byte change, so every prior exact-head S7 and Sol
clearance is invalidated; rerun the exact-head local/CI/rehearsal/review chain
before any new preseal decision. No preseal was written.

The exact-head S7 synthetic packet is complete and pushed in R commit
`a8a9ecba00f87630b4de446f32af7859f6273da4`; its code source remains
`f77acc072c6d917fb86855fb49dfd8f222c3d7ce`, with Julia
`976814393043d3a4af5ce343d8ac4b05c43eac41`.

The fresh Totoro rehearsal PASS, receipt hashes, clean/dirty deployment controls,
and Batch A/B CLEAN reviews are recorded in
`docs/dev-log/check-log.d/2026-07-16-retry7-s7-f77-totoro-synthetic-rehearsal.md`.

## Hard stop

The required explicitly routed Sol preseal/chronology verifier was launched
read-only as `gpt-5.6-sol` with ultra effort. It completed its scoped code reads
but entered repeated empty waits, emitted neither a final verdict nor a result
file, and was terminated. Therefore **preseal is not cleared**.

Do not treat S7 PASS, review receipts, or this checkpoint as authority to:

- write a canonical preseal;
- materialize bootstrap data or consume any phenotype seed;
- run an official fit, D0F/D1-D4 compute, or the 576-fit campaign;
- change default routing, public coverage, merge, or release.

## Resume

Start a new enforced Sol read-only job with a concise preseal/chronology brief.
It must return a durable `CLEAR_PRESEAL` or `BLOCKED` verdict before any preseal
command is considered. Read the S7 rehearsal record and Batch A/B TSV receipts
first; preserve the protected Retry-5 drafts and quarantined Julia scaffold.

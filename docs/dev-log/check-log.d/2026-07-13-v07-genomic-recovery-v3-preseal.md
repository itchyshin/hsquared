# Check log — v0.7 genomic recovery-v3 pure preseal layer

Date: 2026-07-13

## Scope

Prospectively freeze and mutation-test the D0F/D1 evidence contract without
creating an official marker panel, phenotype, fit, corpus, or adjudication
receipt. Public activation remains held and `public_covered_count` remains 5.

## Frozen design

- D0F uses 24 fixed D0 panels per design and eight fresh phenotypes per panel:
  576 fits total, plus a deterministic 10,000-replicate two-level bootstrap.
- D1 uses 12 interior cells and 48 seeds per cell: 576 fits total.
- The canonical 36-cell table SHA-256 is
  `9a41a7dee379f273bccdbb0bd03523c08566662bfdab401ac99be3f904c4a6bd`.
- The 39-key preseal binds the exact D0 receipt and the exact diagnostics pair
  `r/d0_packet_diagnostics_base_r.tsv` at
  `7c1cbc165df90e844bd4fdc7fc6ffb6dcbb8343c0d5ca9e7a588e4ca6d48c370`.
- The evidence dependency is acyclic: preseal -> official corpus -> corpus lock
  -> independent recomputation -> schema-bound adjudication receipt.

## Exact source hashes before commit

- doc 49: `c1885ccb8a50dedbea2b43ababcfc3ed5fdbae98867b0ca47afe45497cc888d2`
- R preseal tool: `fbb9928acb4176b7780cc0a3ae625984cf82833b988adcfc43f315be30be30da`
- R focused test: `cd4710d6be38f49e9b072f69c64898c726a2ca3d9a1a6d831331a0527ab2986e`
- Julia replay tool: `efab8a5a6d99a6253620eca417c4d7ab73c9626ec9a9f6efe2fd9417d38aa88e`

## Checks

- R absolute-path preseal selftest: PASS.
- Focused R preseal suite: PASS with no failures, warnings, or skips.
- Full R package suite: 2,276 pass, 0 fail, 0 warn, 68 expected skips.
- Focused recovery-v2 suite after immutable-object test repair: PASS.
- Julia replay selftest with BLAS and Julia threads set to one: PASS.
- Full Julia `Pkg.test()`: PASS.
- Shared D1 parity: 36 rows x 56 fields, typed exact/`1e-10`, canonical R
  fixture SHA-256
  `945ab4576b534420688190f6649d83cc476d3dfb0e4b6e56b35af1b1d5cb8087`.
- Shared D0F parity: 3 rows x 38 fields, typed exact/`1e-10`, canonical R
  fixture SHA-256
  `1ee7c9c2cb42c940ef55bb003fa5c02f811201a1002713e39365d10237529795`.
- `git diff --check`: PASS in both twins.
- Totoro D0 root and receipt rechecked live; receipt hash remains
  `190b6546fab8caeec24683c4f7bee8063ada671c220852c9372e5db194b2886a`.

## Tests of the tests

Mutations went red for extra/missing/symlink/FIFO/special/empty tree members;
noncanonical/nested roots; forged sidecars and deployed Git blobs; unrelated
dirty worktree files; deleted implementation surfaces; wrong live host/runtime,
RNG, BLAS, Julia threads, and worker cap; forged D0 root/receipt/diagnostics;
receipt commit drift; malformed unsuccessful attempts; retained-marker drift;
0/1 successful fits; zero/nonfinite information; source/replay provenance;
all D1 and D0F parity fields; replay-versus-official performance sourcing; and
truth/ridge versus marker-ratio tolerance.

## Independent verdicts

- Fisher/Curie preregistration review: CLEAN.
- Hopper final pure-preseal audit: CLEAN, no residual P0/P1.
- Grace R pure-preseal audit: CLEAN.
- Grace Julia final bounded audit: CLEAN after explicit residual-variance
  canonicalization and actual committed-table validation.

## Boundary

This is a pure preseal layer. It contains no official DGP/fitting driver and no
operational adjudicator. Non-selftest R execution, postrun R admission, and
Julia final admission all fail closed. The next slice must implement and review
the official R driver, independent base-R recomputer, schema-bound adjudicator,
and process launcher before any D0F/D1 preseal or phenotype can exist.

# check-log — 2026-09-01 R-lane S5 manifest refresh (twin of Rose JL-1)

**Arc:** pre-push remediation of Rose finding JL-1, R-lane tail
**Lane:** `claude/lane-h2-twin-20260901` @ `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Julia twin:** `HSquared.jl` `69280b70` +
`docs/dev-log/check-log.d/2026-09-01-h2-twin-matfree-ledger-home.md`

## Why the R lane was touched at all

The JL-1 repair is a Julia-lane job and was done there. One R-lane surface names
the same S5 arc, so it was checked, and it was wrong in two ways.

`docs/design/real-data-validation-manifest.toml`, arc `s5_matfree_tail_recovery`:

1. `claim_boundary` read **"FROZEN NOT RUN; q=25,000; requires maintainer
   compute-go."** S5 ran on 2026-09-01 and PASSED. An R-lane design surface was
   asserting NOT RUN about the campaign's largest piece of evidence.
2. `julia_surface` pointed at `sim/f6_matfree_recovery.jl` — the small opt-in
   n=400 Monte-Carlo recovery driver, not the S5 gate. The gate is
   `sim/phase_s5_matfree_tail_recovery_gate.jl` (confirmed present in the Julia
   worktree).

`tolerance` also said only "FROZEN predeclaration; owner threshold sign-off
required", which no longer tells a reader what was actually pre-declared.

## Change

One arc entry updated. `tolerance` now carries the four pre-declared bounds;
`claim_boundary` carries the measured result and its limits; `julia_surface`
points at the gate that ran.

The new `claim_boundary` deliberately states four fences: recovery-to-truth holds
for the frozen gate fixture **at q = 25,000 and nowhere else**; the honest A1
margin is **~3.5x across the two realizations measured, not ~30x** from the
1.10.10 draw alone; `public_covered_count` stays **5** with G10 S3 UNSIGNED and
S6/S7 open; and there is **no R surface**, because `fit_matrix_free_reml` is not
wired to the bridge.

It also names the engine ledger row `V1-MATFREE-REML`, which — as of the Julia
twin commit — exists, so this pointer resolves.

## Commands

```sh
julia -e 'using TOML; TOML.parsefile(".../real-data-validation-manifest.toml")'
# TOML parses OK; arcs: 17
# julia_surface: sim/phase_s5_matfree_tail_recovery_gate.jl
# claim_boundary head: RUN AND PASSED 2026-09-01, q=25,000, 48 seeds, Julia 1.10.10 on Totoro
```

The only R consumer of this file is `tests/testthat/helper-realdata-manifest.R`,
which checks the file ships in the build tarball; it does not assert on this
arc's fields, so no test needed updating.

## Claim boundary

Documentation accuracy only. No R code, no `validation_status()` row, no
capability change. The R ledger is untouched: R `validation_status()` covered
count and the Julia `public_covered_count` (**5**) are both unmoved. Nothing here
promotes the matrix-free path, which remains unwired to the R bridge (S7 OPEN).

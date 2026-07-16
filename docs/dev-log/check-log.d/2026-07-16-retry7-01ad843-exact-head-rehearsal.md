# Retry-7 exact-head rehearsal after recovery-v3 sidecar repair

**Date:** 2026-07-16  
**Scope:** restarted pre-RNG admission evidence after the recovery-v3 driver
sidecar repair. No official phenotype or bootstrap seed was materialized or
consumed.

## Exact heads and byte binding

- R source: `01ad843c8a2968b9180188f70bf9955cf433908c`
- Julia replay: `976814393043d3a4af5ce343d8ac4b05c43eac41`
- Recovery-v3 driver SHA-256:
  `35fb2630e5f706694111e65aa5544ff9e37469bbe987f76541785ade90080543`
- Totoro clean root:
  `/home/snakagaw/hsq_work/retry7-s7-sidecar-01ad843-97681439`

The deployed R clone, Julia clone, and driver sidecar matched these values
before the lifecycle was launched.

## Local and CI checks

- `Rscript --vanilla -e 'devtools::test()'`: **2,991 pass, 0 fail, 0 warn**;
  69 environment-gated skips.
- `julia --project=. -e 'using Pkg; Pkg.test()'`: **passed**.
- `julia --project=docs docs/make.jl`: completed through the local Vitepress
  build; existing docstring/asset/audit warnings remain non-fatal.
- `bash tools/preamble_cap.sh`: **CAP OK**.
- Built-source `R CMD check --no-manual` with non-forced Suggests: no errors;
  the existing `vignettes/hsquared.Rmd` / absent `inst/doc` condition produced
  two warnings, and unavailable `pedigreemm` was INFO only.
- Exact-source GitHub R-CMD-check run
  [`29537291400`](https://github.com/itchyshin/hsquared/actions/runs/29537291400):
  **success**.

## Fresh Totoro synthetic rehearsal

The clean deployment check passed. The full synthetic D0F-to-D1 lifecycle then
passed with receipt-bound workers (`timeout=900`, `TERM`, 15-second kill
grace): `recovery-v3 synthetic lifecycle: PASS`.

- Synthetic run receipt:
  `cbc0e3d72f6b7e4073839527eefce0aa4f93071cfc8bb68de5edb356d32f5717`
- D0F adjudication (`COMPLETE`):
  `ee7e644a6c33cd54a9c14ea2f10eda642623d5bc1e3c3f83dd4eb48fb9129fff`
- D1 adjudication (`ELIGIBLE=12`):
  `c04d3ae44f4f64931041df3b503447b0357f747bd674af1063de3d9b3a4f6a06`
- D0F R/Julia matching summary (3 rows):
  `525cc51b368e0ecb8dd51309e74a030a2af39aab66ae29561aed2f166a028ac7`
- D1 R/Julia matching summary (36 rows):
  `332a455abb764fa7fecb5fc99865fb9683f48423c7eb31bb1dd7b04843184c02`
- D0F route lineage (9 rows):
  `b1784b86ad2620b9d1c73bec30ac3cf740bfb94dc5e24ea5b4aa98081e65398a`
- D1 route lineage (36 rows):
  `50deaeb430e22425ee0dfe16a23d8527407bbfbe2b990ec205e58a54b8c526cd`

All five synthetic post-run reviewers were `CLEAN` for both D0F and D1.

## Dirty-deployment control

An independent sibling root ending `-dirty` received only a sentinel. Its
`deployment-check` exited 1 with `deployed implementation worktree is dirty`.
It did not modify the clean root or lifecycle workspace.

## Boundary

This is restarted rehearsal evidence only. It does not preseal a canonical
root, spend either Retry-7 seed, materialize bootstrap data, draw a phenotype,
or authorize the 576-fit campaign. Fresh independent review batches and the
enforced Sol decision remain required before any preseal action.

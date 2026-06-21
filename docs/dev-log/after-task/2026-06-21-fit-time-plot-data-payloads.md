# After-task report - 2026-06-21 fit-time plot-data payloads (#93/A3)

Active lenses: Ada, Shannon, Hopper, Florence, Curie, Rose, Grace, Pat.
Spawned subagents: none.
Current lane: R.

## Summary

The A3/#93 R-lane slice is locally complete. The bridge now attaches available
engine `*_plot_data` payloads at fit time for standard animal-model,
multivariate, and random-regression fits, while keeping the existing R-side
recompute fallback for missing payloads and random-regression custom grids.

No `HSquared.jl` files were edited.

## Changed

- Added Julia-call attach helpers for standard, multivariate, and
  random-regression plot-data payloads in `R/julia-bridge.R`.
- Added R normalizers for the attached payloads before they reach
  `autoplot()`.
- Kept `autoplot()` grid semantics: random-regression plot payloads are reused
  only for the default 25-point bridge grid; custom `at`/`n` requests recompute
  from `K_g`.
- Replaced the deprecated horizontal forest-plot errorbar call with the
  supported ggplot2 orientation API.
- Updated plotting tests and live bridge probes for attached payloads.
- Updated `NEWS.md`, `docs/design/24-plotting-standard.md`, and
  `docs/design/capability-status.md` without widening capability claims.

## Verification

- `air format .` - passed.
- `Rscript --vanilla -e 'devtools::test(filter = "autoplot")'` - 126 passed,
  0 failed, 0 warnings, 0 skipped.
- Live `test-plot-data-parity.R` with the sibling Julia project - 35 passed,
  0 failed, 0 warnings, 0 skipped.
- Live `test-random-regression.R` with the sibling Julia project - 93 passed,
  0 failed, 0 warnings, 0 skipped.
- Non-live `test-multivariate.R` with the Julia project unset - 61 passed,
  0 failed, 0 warnings, 3 skipped.
- Targeted live multivariate bridge probe - passed and printed
  `multivariate_plot_payload_probe_ok`.
- Full live `test-multivariate.R` with the Julia project set - local JuliaCall
  setup segfault after 40 pure R passes. This is a verifier limitation in this
  local process, not a failed assertion in the new payload path; the targeted
  live multivariate probe covers the new attachment behavior.
- `Rscript --vanilla -e 'devtools::document()'` - passed.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` - clean.
- `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'` -
  Status OK, 0 errors, 0 warnings, 0 notes.

The first `rcmdcheck()` run without `_R_CHECK_FORCE_SUGGESTS_=false` reported
1 ERROR because local optional suggested packages `enhancer`, `nadiv`, and
`pedigreemm` were absent.

## Rose/Hopper boundary

This is a bridge and plotting-payload ergonomics slice. It does not claim new
statistical validation, comparator parity, marker/non-Gaussian plotting,
PEV/reliability plotting, structured covariance support, or production
multivariate coverage.

## Coordination answers

1. **A3/#93 bankability:** ready for a narrow branch/PR from the local evidence
   above. It is not yet staged or committed in this thread.
2. **R-lane blockers for #10/#41/#49 multivariate validation promotion:**
   current evidence is Julia internal recovery plus one reproduced external
   `sommer` fixture leg; this remains partial. Promotion still needs a broader
   and explicitly declared recovery gate, a published/Mrode-style target, and
   another independent comparator leg such as ASReml, BLUPF90/AIREMLF90,
   JWAS/equivalent, or another accepted same-estimand tool.
3. **Exact local comparator/tool availability:** `sommer` 4.4.3 and
   `MCMCglmm` 2.36 are installed. `nadiv`, `asreml`, `pedigreemm`, and
   `enhancer` are not installed. No `blupf90`, `airemlf90`, `remlf90`,
   `renumf90`, or `gibbsf90` executable is currently on `PATH`. R-side
   comparator skeletons exist under `inst/comparator-scripts/asreml/` and
   `inst/comparator-scripts/blupf90/`, but they are not executed evidence.
4. **Preferred next cross-lane priority:** after banking A3 and the Julia
   comparator-evidence slice, I would put external validation first for
   #10/#41/#49, then run the clean-branch bridge activation sweep. The next
   science contract should be Candidate A, metafounder R bridge plus
   single-step `H^Gamma`, before Candidate B structured FA/lowrank eigenbasis.
   Candidate A is more directly user-facing and aligns with the existing
   single-step/metafounder engine direction, but it must stay contract-first:
   R syntax, payload shape, ID/order/Gamma semantics, tests, and Rose boundary
   before any capability claim. Candidate B should wait until rotation,
   eigenbasis/loadings, and validation-language conventions are pinned.

# After-task — Next-big-4 slice 7 (#34): multivariate recovery harness (2026-06-19)

## Task goal

Program-2 workstream #3 (multivariate → covered): the R-side known-truth recovery harness for the
2-trait multivariate REML estimator — the harness the twin/maintainer runs (with a local engine)
to move `V4-MULTIVARIATE` / `V4-MV-REML` from `partial` toward `covered`.

## Files changed

- `data-raw/multivariate-recovery-study.R` — new ADEMP-structured study (build-ignored, like the
  univariate `dgp-recovery-study.R`): clean generational pedigree, simulate B = U'Zg L_G' (Cov =
  G0⊗A) + E = Ze L_R' (Cov = R0⊗I), fit via `target = "multivariate"`, recover G0/R0/rg/per-trait
  h². Truth G0=[[1,0.3],[0.3,0.8]], R0=[[1,-0.1],[-0.1,1.2]] → h²=c(0.5,0.4), rg=0.335.
- `docs/dev-log/issue-map.md`, `coordination-board.md` — #34 recorded.

## What is verified vs pending (honesty)

- **Verified now (pure R, no engine):** the DGP runs and is statistically correct — over 200
  replicates the empirical phenotypic covariance ≈ `[[1.97,0.19],[0.19,1.99]]` vs the true
  `G0+R0 = [[2,0.2],[0.2,2]]`, confirming `Cov(B)=G0⊗A`, `Cov(E)=R0⊗I`.
- **Pending (engine-gated, NOT claimed):** the recovery numbers (bias ± 2·MCSE per G0/R0 element,
  rg, h²; convergence rate). The `RECORDED RESULT` block is explicitly left PENDING — no recovery
  numbers are fabricated. Run with a local Julia + `HSquared.jl` (`HSQUARED_RUN_MV_RECOVERY=true`),
  then record, mirroring the univariate study's recorded block.

## Checks

- `data-raw/` is `.Rbuildignore`'d, so the script does not affect `devtools::test()` /
  `devtools::check()` (prior 849/0/0/27 + check 0/0/0 hold). DGP portion executed + validated in R.

## Public claim audit (Rose lens)

- No capability promoted. The harness produces the *evidence* needed for promotion; it does not
  itself promote. `V4-MULTIVARIATE` / `V4-MV-REML` stay `partial` until the recovery run + the twin
  gate (HSquared.jl#41). No recovery numbers claimed.

## Next actions

- Twin/maintainer: run the harness with an engine + record the recovery block; then (with a passing
  result + comparator) promote the multivariate rows. The R side of workstream #3 (#26 SEs + #34
  harness) is complete.
- Remaining program-2 work is now twin-gated: #4 factor-analytic (HSquared.jl#37/#42), the
  non-Gaussian / scan frontier, and the multivariate recovery run itself.

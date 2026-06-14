# Next 50 Slices

This is the practical runway after the opt-in multivariate R bridge. It is not a
claim that all items are implemented. Each slice should end with tests,
check-log evidence, an after-task report, and an updated claim boundary.

## Current Status

- R multivariate bridge slice: done on `hsquared` main (`835e8c2`), with local
  package checks and remote R-CMD-check/pkgdown/Pages green.
- R structured multivariate error ergonomics: done on `hsquared` main
  (`6a4fdf4`), with remote R-CMD-check/pkgdown/Pages green.
- R multivariate fitting article: done on `hsquared` main (`43d83aa`), with
  remote R-CMD-check/pkgdown/Pages green.
- R multivariate extractor documentation examples: done on `hsquared` main
  (`21161a5`), with remote R-CMD-check/pkgdown/Pages green.
- R shared deterministic multivariate fixture consumption: done on `hsquared`
  main (`61a7ca3`); R now carries the same Phase 4 fixture files and checks
  payload ordering plus normalized G/R/h2/fixed-effect/EBV/logLik extractor
  shape against the serialized Julia REML target. Remote R-CMD-check/pkgdown/
  Pages are green.
- V4 issue-ledger cleanup: done in this slice. R reported fixture consumption
  back to bridge issue #6, validation issue #7, and extractor issue #5; issue
  #7 now carries `status:partial` instead of stale `status:planned`.
- Multivariate comparator planning: recorded in the comparator-plan slice. The first
  feasible optional comparator is `sommer` on the shared fixture with diagonal
  residuals; ASReml-R and BLUPF90/AIREMLF90 remain manual gates until installed
  or licensed evidence exists. No validation row is promoted.
- Multivariate optional `sommer` comparator: added in the optional-comparator
  slice for G0, diag(R0), and diagonal-target h2 on the shared Phase 4 fixture.
  This is a partial external check only; it does not validate full residual
  covariance.
- Manual ASReml/BLUPF90 comparator skeletons: added in the manual-gate slice
  under `inst/comparator-scripts/`, with dry-run checks and a `docs/dev-log/
  comparator-runs/` provenance folder. They are templates/manual gates only, not
  run evidence.
- Dedicated multivariate validation issue ledger: opened as
  `hsquared#10` and cross-linked from validation canon issue #7. Status remains
  `partial`.
- Julia twin report: Phase 4B slices 1-8 are done; the next real Julia bite is
  the opt-in structured covariance recovery harness.
- R lane next safe bite: keep eating the R-safe documentation/comparator runway
  while Julia owns structured covariance and recovery hardening.

## Programme Board

| # | Lane | Slice | Gate before widening claims |
| --- | --- | --- | --- |
| 1 | coordinator | Close orphaned Julia PRs whose commits are already on `HSquared.jl` main. | GitHub issue/PR ledger clean. |
| 2 | Julia | Delete merged Phase 4 multivariate branches. | Main contains the commits and CI is green. |
| 3 | Julia | Sync hand-maintained Julia validation-status docs to live V4 rows. | Julia docs and `validation_status()` agree. |
| 4 | Julia | Add `_cov_to_chol_params` / `_chol_params_to_cov` roundtrip tests for `t >= 3`. | Parameter-order regression test green. |
| 5 | Julia | Reject rank-deficient multivariate `X` inside the engine too. | Engine and R guards agree. |
| 6 | Julia | Document and test the dense `inv(Ainv)` conditioning caveat. | Failure mode is visible, not silent. |
| 7 | Julia | Harden `genetic_correlation()` for invalid user-supplied covariance matrices. | PSD/PD guard tests green. |
| 8 | Julia | Commit deterministic `t >= 2` known-truth multivariate recovery fixture. | Recovery thresholds signed off by Fisher/Curie. |
| 9 | R | Promote multivariate evidence wording only as far as the twin recovery fixture allows. | `validation_status()` remains honest. |
| 10 | R/docs | Add a short multivariate fitting vignette with `cbind()` and missing trait cells. | Pkgdown clean; no production wording. |
| 11 | R | Improve `animal(trait | id, cov = ...)` errors to point users to the current `cbind()` path. | Boole/Pat wording review. |
| 12 | Julia | Add `multivariate_mme()` examples to Documenter. | Documenter green. |
| 13 | R | Add examples for `genetic_covariance()` / `genetic_correlation()` in extractor docs. | R examples stay non-running or skip-safe. |
| 14 | coordinator | Open/update GitHub issues linking V4 partial gates to R issue ledger. | done: R follow-up comments posted to #6/#7/#5; #7 labelled `status:partial`. |
| 15 | Julia | Surface structured multivariate `genetic_structure = :diagonal` through stable engine tests. | Twin gate stays partial until recovery. |
| 16 | R | Design R control syntax for diagonal multivariate G, without default exposure. | Formula/API signoff. |
| 17 | Julia | Stabilize low-rank multivariate REML tests and diagnostics. | PSD and logLik checks green. |
| 18 | R | Design `cov = lowrank(K)` grammar against the Julia structure. | Roadmap-only until engine gate. |
| 19 | Julia | Stabilize factor-analytic `G = Lambda Lambda' + Psi` engine output names. | Loadings/uniqueness extraction tests green. |
| 20 | R | Add reserved extractor names for loadings, uniqueness, latent breeding values, and eigen-G. | Placeholders do not imply fitting. |
| 21 | R/docs | Add a G-matrix interpretation vignette for breeders/ecologists. | Pat/Darwin/Kirkpatrick review. |
| 22 | Julia | Add multivariate external-comparator fixtures where feasible (`sommer`, ASReml if available). | Comparator policy accepted. |
| 23 | R | Add comparator-status rows for multivariate only after evidence exists. | partial: `sommer` diagonal-residual evidence added to the existing multivariate row; dedicated issue #10 tracks full same-estimand, ASReml/BLUPF90, and recovery gates before any covered row. |
| 24 | R | Add `G_matrix()` as an alias or wrapper only if it improves user clarity. | Avoid duplicate confusing extractors. |
| 25 | Julia | Implement genomic relationship scaling/blending options. | G/GINV tests against known formulas. |
| 26 | R | Expose marker-to-G controls with simple names and safe defaults. | Jason/Hopper review. |
| 27 | Julia | Add single-step `Hinv` construction from A and G. | Tiny and Mrode-style H checks. |
| 28 | R | Expose `single_step(..., pedigree = ped, genotypes = ...)` only after Hinv is engine-covered. | No supplied-Hinv confusion. |
| 29 | Julia | Add APY approximation prototype. | Numerical agreement and memory benchmarks. |
| 30 | R/docs | Add genomic prediction vignette: GBLUP, SNP-BLUP, supplied variances, and boundaries. | No JWAS/ASReml replacement claim. |
| 31 | Julia | Add marker-effect REML or AI-REML variance estimation for SNP-BLUP. | Supplied-variance status can move only after recovery. |
| 32 | R | Add `marker_variance_explained()` for real marker-effect fits. | Output validated. |
| 33 | Julia | Add single-marker scan kernel with kinship correction. | Tiny GWAS fixtures. |
| 34 | R | Expose `marker_scan()` as opt-in once engine scan results are stable. | Multiple-testing and LOCO wording clear. |
| 35 | Julia | Add LOCO support for mixed-model scans. | Chromosome holdout tests. |
| 36 | R/docs | Add QTL/GWAS status vignette with scale caveats. | Rose/Jason audit. |
| 37 | Julia | Add basic eQTL scan primitives for response matrices. | Tiny cis/trans fixture. |
| 38 | R | Consider `hsquaredQTL` extension boundary before expanding core. | Ada/Rose decision recorded. |
| 39 | Julia | Add GLLVM-style Gaussian response-matrix factor prototype. | Compare to GLLVM.jl on tiny examples. |
| 40 | R | Design wide-response matrix syntax without crowding the core animal model. | Pat/Boole signoff. |
| 41 | Julia | Add Poisson / negative-binomial Laplace prototype. | Non-Gaussian validation fixture. |
| 42 | R | Add family-specific planned errors that name the closest implemented Gaussian path. | User-friendly error tests. |
| 43 | Julia | Add maternal/paternal correlated 2x2 G effect. | Henderson/Noether signoff. |
| 44 | R | Expose correlated direct-maternal grammar only after engine coverage. | Distinguish from current independent two-effect path. |
| 45 | Julia | Add dominance relationship prototype. | AGHmatrix/nadiv comparison where possible. |
| 46 | R | Add dominance syntax once relationship semantics are tested. | No inheritance overclaim. |
| 47 | Julia | Add selfing/clonal/haplodiploid relationship kernels as separate prototypes. | Mendel/Darwin review. |
| 48 | R/docs | Add inheritance-systems roadmap examples with hard fences. | Planned wording only until kernels validate. |
| 49 | Julia | Add CPU backend benchmarking harness for current Phase 1-4 fits. | Benchmark outputs reproducible. |
| 50 | Julia/R | Add first accelerator feasibility probe (Metal locally, CUDA for HPC later) for dense multivariate/GLLVM pieces. | CPU remains trusted default; no speedup claim without benchmark evidence. |

## Twin Phase 4B Board

Reported by the Julia twin on 2026-06-14. This is recorded here so the R lane can
coordinate without guessing.

| # | Slice | Status |
| --- | --- | --- |
| 1 | Review Phase 4B diff | done |
| 2 | Run Julia tests | done |
| 3 | Run docs build | done |
| 4 | Commit Phase 4B | done |
| 5 | Push Phase 4B branch | done |
| 6 | Open draft PR | done: `HSquared.jl#17` |
| 7 | Check PR CI | done, green |
| 8 | Cross-link R bridge issue | done |
| 9 | Address PR review/CI failures | pending if any appear |
| 10 | Merge Phase 4B | human approval only |
| 11 | Add non-CI structured covariance recovery script | next real bite |
| 12 | Record recovery results | pending |
| 13 | Decide loading sign convention | pending |
| 14 | Decide rotation convention | pending |
| 15 | Add shared deterministic multi-trait fixture | pending |
| 16 | Serialize fixture for both repos | pending |
| 17 | Add Julia fixture reader/tests | pending |
| 18 | Ask R lane to consume same fixture | done: R consumed the local twin fixture copy in ordinary CI-safe tests |
| 19 | Define multivariate R grammar | partial: simple `cbind()` live; structured grammar planned |
| 20 | Define long/wide trait ordering | pending |
| 21 | Define covariance vocabulary: us, diag, fa, low-rank | planned |
| 22 | Define multivariate result payload shape | partial: unstructured G/R live |
| 23 | Draft Julia result payload shape without bridge change | pending |
| 24 | Get R issue contract ack | pending |
| 25 | Plan R sommer comparator | done: partial diagonal-residual comparator path recorded in `docs/design/12-multivariate-comparator-plan.md` |
| 26 | Plan ASReml comparator if available | done: manual licensed gate recorded in `docs/design/12-multivariate-comparator-plan.md` |
| 27 | Plan BLUPF90/AIREMLF90 comparator if practical | done: manual executable gate recorded in `docs/design/12-multivariate-comparator-plan.md` |
| 28 | Promote only rows with comparator evidence | always-on Rose rule |
| 29 | Harden multivariate initialization | partial: R named G0/R0 guard live |
| 30 | Add more structured covariance boundary tests | pending |
| 31 | Add SEs or explicitly block them | pending |
| 32 | Add LRT guidance or explicitly block it | pending |
| 33 | Add sparse multivariate design note | pending |
| 34 | Add production-sparse FA design note | pending |
| 35 | Add repeatability recovery/comparator evidence | pending |
| 36 | Promote repeatability after Rose audit | pending |
| 37 | Add two-effect recovery/comparator evidence | pending |
| 38 | Promote two-effect after Rose audit | pending |
| 39 | Add genomic inverse / GBLUP bridge slice | done in R for supplied `Ginv` and marker-built G; broader bridge pending |
| 40 | Add single-step H inverse validation | pending beyond supplied `Hinv` surface |
| 41 | Add APY design/evidence gate | pending |
| 42 | Add standard QG comparator fixtures | pending |
| 43 | Tighten validation-status public table | ongoing |
| 44 | Finish docs-cleanup PR/work | ongoing |
| 45 | Audit README claims | ongoing |
| 46 | Audit package docs claims | ongoing |
| 47 | Coordinate R package public wording | ongoing |
| 48 | Run full local Julia + R checks | per slice |
| 49 | Open final release-readiness audit issues | pending |
| 50 | Cut release only after CI/docs/claims agree | pending |

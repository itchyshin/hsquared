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
- Rose multivariate claim sweep: public claims register and model-status article
  now acknowledge the optional `sommer` diagonal-residual comparator while
  preserving the "not full external-comparator validated" boundary.
- Manual comparator-script smoke coverage: ASReml dry-run and BLUPF90 dry-run /
  temp-write paths are now ordinary CI-safe tests, including the built-package
  template lookup used by `R CMD check`. This hardens the manual gates without
  creating ASReml/BLUPF90 run evidence.
- Manual comparator-run report template: `docs/dev-log/comparator-runs/
  TEMPLATE.md` now gives future ASReml/BLUPF90/DMU/WOMBAT/sommer/JWAS runs a
  standard provenance, estimand-match, result-table, and reviewer-verdict
  surface.
- Rose public-claim audit: the standard quantitative-genetic marker rows in the
  claims/capability/debt tables now carve out the opt-in experimental
  `permanent()`, `common_env()`, and `maternal_genetic()` paths instead of
  describing all such markers as planned-only.
- Non-Gaussian family planned errors: `poisson()`, `binomial()`, and other
  non-Gaussian families now error with the requested family name and point users
  back to the live `family = gaussian()` v0.1 path.
- Inference helper blockers: `confint()`, `vcov()`, `profile()`, and `anova()`
  now fail explicitly for `hsquared_fit` objects, fencing standard errors,
  confidence intervals, profile likelihoods, and likelihood-ratio guidance as
  planned until validated evidence exists.
- Sparse multivariate production design note: `docs/design/
  13-sparse-multivariate-production-plan.md` records the dense-validation to
  sparse-MME ladder, structured-G constraints, diagnostics, CPU/GPU boundary,
  and promotion gates.
- Factor-analytic G-matrix production design note: `docs/design/
  14-factor-analytic-production-plan.md` records planned `diag()`/`lowrank()`/
  `fa()` syntax, loading/rotation boundaries, invariant-first extractors, and
  production gates.
- Reserved factor/G-matrix extractors: `loadings()`, `specific_variance()`,
  `latent_breeding_values()`, and `eigen_G()` now exist but fail for
  `hsquared_fit` with planned, rotation-aware messages.
- G/R matrix aliases: `G_matrix()` and `R_matrix()` now mirror
  `genetic_covariance()` and `residual_covariance()` for `hsquared_fit`
  objects, so applied users can ask for the familiar G and R matrices without a
  second result contract.
- G-matrix interpretation article: a pkgdown article now explains how to read
  the current G/R matrices, correlations, heritabilities, and cross-trait EBVs
  while fencing `P_matrix()`, factor-analytic loadings, evolvability, and
  selection-response tools as future gated work.
- Genomic prediction article: a pkgdown article now separates supplied-`Ginv`
  GREML, marker-built GREML, supplied-variance SNP-BLUP, supplied-`Hinv`
  single-step, and constructed-`Hinv` single-step from APY, QTL/GWAS/eQTL,
  metafounder `H^Gamma` live fitting, and production comparator work.
- QTL/GWAS/eQTL status article: a pkgdown article now separates the reserved
  scan vocabulary and live SNP-BLUP `marker_effects()` /
  `marker_variance_explained()` output from planned marker scans, QTL interval
  scans, GWAS/eQTL tables, scan plots, LOCO, and production scale.
- QTL extension boundary: `hsquared` keeps simple formula/status/result
  vocabulary; high-throughput QTL/GWAS/eQTL execution, file-backed scan
  infrastructure, plots, fine-mapping, and GPU/HPC scan kernels belong in
  optional future `hsquaredQTL` / `HSquaredQTL.jl` extensions unless a tiny
  core scan target is dependency-light and fully validated.
- Inheritance systems roadmap examples: a pkgdown article now shows how
  selfing, clonal, haplodiploid, polyploid, cytoplasmic, imprinting,
  dominance, epistasis, and custom kernels should enter as relationship or
  precision kernels, while keeping every such feature planned until kernels and
  validation exist.
- Wide-response matrix syntax plan: `docs/design/
  16-wide-response-syntax-plan.md` records future `traits(...)` and long
  stacked-cell grammar for GLLVM/omics/community models while keeping current
  `cbind(...)` as the only live multivariate animal-model grammar.
- Trait-ordering contract: `docs/design/17-trait-ordering-contract.md` records
  how current `cbind(...)`, future `traits(...)`, future long data, Julia
  payloads, extractors, and comparator scripts should preserve user-declared
  trait order.
- Structured covariance R-control contract: `docs/design/
  18-structured-covariance-r-control.md` records the planned expert
  `engine_control$genetic_structure` bridge for `diagonal`, `lowrank`, and
  `factor_analytic` genetic covariance, while keeping `cov = diag()` /
  `lowrank()` / `fa()` formula grammar planned until the Julia branch reaches
  main and R bridge tests exist.
- Structured covariance control guardrail: the R bridge now accepts only
  `genetic_structure = "unstructured"` for the current opt-in multivariate
  target and errors for `diagonal`, `lowrank`, `factor_analytic`, and the
  future `rank` control rather than silently ignoring planned controls.
- Structured covariance formula vocabulary: `formula_status()` and planned
  `animal(..., cov = ...)` errors now name the complete planned grammar
  (`us`, `diag`, `lowrank`, `fa`) while keeping those long-format structured
  covariance terms non-executable.
- Julia twin report: Phase 4B slices 1-8 are done; the next real Julia bite is
  the opt-in structured covariance recovery harness.
- R lane next safe bite: keep eating the R-safe documentation/comparator runway
  while Julia owns structured covariance and recovery hardening.
- Published multivariate Mrode target: added in the Mrode 5.1 anchor slice. A
  pure-R CI test reproduces the published supplied-G0/R0 multiple-trait BLUP/MME
  fixed effects and animal BLUPs. This closes the published/Mrode-style target
  gap for supplied-covariance validation only; V4 remains `partial` and still
  needs recovery-gate acceptance or broadening plus another independent
  same-estimand comparator beyond `sommer`.

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
| 16 | R | Design R control syntax for diagonal multivariate G, without default exposure. | done: `docs/design/18-structured-covariance-r-control.md`; control contract only, no live bridge or formula grammar |
| 17 | Julia | Stabilize low-rank multivariate REML tests and diagnostics. | PSD and logLik checks green. |
| 18 | R | Design `cov = lowrank(K)` grammar against the Julia structure. | done: formula/status/errors now reserve `us`, `diag`, `lowrank`, and `fa`; no live formula grammar or bridge |
| 19 | Julia | Stabilize factor-analytic `G = Lambda Lambda' + Psi` engine output names. | Loadings/uniqueness extraction tests green. |
| 20 | R | Add reserved extractor names for loadings, uniqueness, latent breeding values, and eigen-G. | done: names exist with planned/rotation-aware errors; no fitting or interpretation claim |
| 21 | R/docs | Add a G-matrix interpretation vignette for breeders/ecologists. | done: `articles/g-matrix-interpretation` teaches invariant G/R summaries and fences `P_matrix()`, FA loadings, evolvability, and selection-response claims |
| 22 | Julia | Add multivariate external-comparator fixtures where feasible (`sommer`, ASReml if available). | Comparator policy accepted. |
| 23 | R | Add comparator-status rows for multivariate only after evidence exists. | partial: `sommer` diagonal-residual evidence added to the existing multivariate row; dedicated issue #10 tracks full same-estimand, ASReml/BLUPF90, and recovery gates before any covered row. |
| 24 | R | Add `G_matrix()` as an alias or wrapper only if it improves user clarity. | done: `G_matrix()` and `R_matrix()` are aliases over the existing covariance extractors; no new `P_matrix()` estimand or capability claim |
| 25 | Julia | Implement genomic relationship scaling/blending options. | G/GINV tests against known formulas. |
| 26 | R | Expose marker-to-G controls with simple names and safe defaults. | Jason/Hopper review. |
| 27 | Julia | Add single-step `Hinv` construction from A and G. | done: `single_step_inverse` / `fit_single_step_reml` support the ordinary single-step construction. |
| 28 | R | Expose `single_step(..., pedigree = ped, markers = M)` only after Hinv is engine-covered. | done: `target = "single_step_construct"` with parser, bridge, and live alignment guards; remains experimental/partial. |
| 29 | Julia | Add APY approximation prototype. | Numerical agreement and memory benchmarks. |
| 30 | R/docs | Add genomic prediction vignette: GBLUP, SNP-BLUP, supplied variances, and boundaries. | done: article added; no JWAS/ASReml replacement, APY, marker-scan, H-construction, or production-comparator claim |
| 31 | Julia | Add marker-effect REML or AI-REML variance estimation for SNP-BLUP. | Supplied-variance status can move only after recovery. |
| 32 | R | Add `marker_variance_explained()` for real marker-effect fits. | done: opt-in SNP-BLUP fits now return descriptive fitted-marker shares; no scan/QTL/p-value claim |
| 33 | Julia | Add single-marker scan kernel with kinship correction. | Tiny GWAS fixtures. |
| 34 | R | Expose `marker_scan()` as opt-in once engine scan results are stable. | Multiple-testing and LOCO wording clear. |
| 35 | Julia | Add LOCO support for mixed-model scans. | Chromosome holdout tests. |
| 36 | R/docs | Add QTL/GWAS status vignette with scale caveats. | done: status article added; no marker-scan, QTL, GWAS, eQTL, scan-plot, LOCO, or production-scale claim |
| 37 | Julia | Add basic eQTL scan primitives for response matrices. | Tiny cis/trans fixture. |
| 38 | R | Consider `hsquaredQTL` extension boundary before expanding core. | done: core keeps simple vocabulary/result contract; heavy scans, file-backed data, plots, fine-mapping, and accelerator scan kernels are extension-bound |
| 39 | Julia | Add GLLVM-style Gaussian response-matrix factor prototype. | Compare to GLLVM.jl on tiny examples. |
| 40 | R/docs | Design wide-response matrix syntax without crowding the core animal model. | done: `traits(...)` and long stacked-cell grammar recorded as planned Phase 6 syntax; current `cbind(...)` remains the only live multivariate grammar |
| 41 | Julia | Add Poisson / negative-binomial Laplace prototype. | Non-Gaussian validation fixture. |
| 42 | R | Add family-specific planned errors that name the closest implemented Gaussian path. | User-friendly error tests. |
| 43 | Julia | Add maternal/paternal correlated 2x2 G effect. | Henderson/Noether signoff. |
| 44 | R | Expose correlated direct-maternal grammar only after engine coverage. | Distinguish from current independent two-effect path. |
| 45 | Julia | Add dominance relationship prototype. | AGHmatrix/nadiv comparison where possible. |
| 46 | R | Add dominance syntax once relationship semantics are tested. | No inheritance overclaim. |
| 47 | Julia | Add selfing/clonal/haplodiploid relationship kernels as separate prototypes. | Mendel/Darwin review. |
| 48 | R/docs | Add inheritance-systems roadmap examples with hard fences. | done: article added; all selfing/clonal/haplodiploid/polyploid/cytoplasmic/imprinting/dominance/epistasis/custom-kernel examples remain planned until kernels validate |
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
| 20 | Define long/wide trait ordering | done: `docs/design/17-trait-ordering-contract.md`; current live invariant is `cbind()` left-to-right, future `traits(...)` and long-data rules remain planned |
| 21 | Define covariance vocabulary: us, diag, fa, low-rank | partial: R-side control contract and future formula vocabulary recorded; no live R grammar |
| 22 | Define multivariate result payload shape | partial: unstructured G/R live |
| 23 | Draft Julia result payload shape without bridge change | pending |
| 24 | Get R issue contract ack | pending |
| 25 | Plan R sommer comparator | done: partial diagonal-residual comparator path recorded in `docs/design/12-multivariate-comparator-plan.md` |
| 26 | Plan ASReml comparator if available | done: manual licensed gate recorded in `docs/design/12-multivariate-comparator-plan.md` |
| 27 | Plan BLUPF90/AIREMLF90 comparator if practical | done: manual executable gate recorded in `docs/design/12-multivariate-comparator-plan.md` |
| 28 | Promote only rows with comparator evidence | always-on Rose rule |
| 29 | Harden multivariate initialization | partial: R named G0/R0 guard live |
| 30 | Add more structured covariance boundary tests | pending |
| 31 | Add SEs or explicitly block them | done in R: `vcov()` and `confint()` now error with planned/not-implemented scope for `hsquared_fit` |
| 32 | Add LRT guidance or explicitly block it | done in R: `anova()` and `profile()` now error with planned/not-implemented scope for `hsquared_fit` |
| 33 | Add sparse multivariate design note | done: `docs/design/13-sparse-multivariate-production-plan.md` |
| 34 | Add production-sparse FA design note | done: `docs/design/14-factor-analytic-production-plan.md` |
| 35 | Add repeatability recovery/comparator evidence | pending |
| 36 | Promote repeatability after Rose audit | pending |
| 37 | Add two-effect recovery/comparator evidence | pending |
| 38 | Promote two-effect after Rose audit | pending |
| 39 | Add genomic inverse / GBLUP bridge slice | done in R for supplied `Ginv` and marker-built G; broader bridge pending |
| 40 | Add single-step H inverse validation | partial: ordinary construction is surfaced and live-tested; `single_step(..., group =, Gamma =)` now fits an experimental supplied-`Gamma` `H^Gamma` bridge; APY, animal-only metafounder fitting, and production comparator parity remain pending |
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

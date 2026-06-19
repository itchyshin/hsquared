# Twin coordination report v2 — HSquared.jl as of 2026-06-19

Read-only cross-lane scout (workflow `wf_5d380671-4c8`, 8 agents: per-capability
briefs + Ada synthesis). The R lane made **zero edits** to the twin. **Supersedes
the 2026-06-18 report** (which predates PR #17 landing, the Phase 5/6 merges, the
R-side shipping this session, and the twin's own backlog #46–#56).

State pins: twin `origin/main` = `6d14df5`; R `main` = `9fa9193`.

## Headline: R is not the bottleneck

Everything the twin's bridge-activation hand-offs (#42–#45) ask of R is **shipped
or prepared-ready-to-fire**. Shipped on R main: the experimental SE/CI surfaces
(`heritability_interval`, `variance_component`/`heritability` SEs,
`repeatability_interval`, multivariate `covariance_standard_errors` with the
honest failed-calibration disclaimer), `summary()`/`print()` uncertainty display +
`plot.hsquared_fit`, opportunistic PEV/reliability at all four fit sites, the
published Mrode 3.1 + 3.2 anchors + the pure-R Henderson reference solver, the
sommer/pedigreemm benchmark + comparator-policy doc, and honest reserved
extractors (FA + scan names error rather than over-claim). Prepared, fires on the
matching twin payload: a thin R LRT extractor, the DGP-verified recovery harness
(`data-raw/multivariate-recovery-study.R`, ready to RUN), unconditional PEV via
`:selinv`, the `gwas(fit, markers)` wrapper, non-Gaussian activation, and the
`cov=diag/lowrank/fa` relaxation. Every twin ask is already a precise cross-lane
issue.

## Joint critical path (ordered by leverage, lowest-effort-highest-payoff first)

1. **Row-refresh (≈10 min, highest honesty leverage).** `V4-MV-REML` (validation_status.jl
   L233) and `V4-FA` (L240) **still list SEs/LRTs as missing**, but
   `multivariate_covariance_standard_errors` + boundary-aware `covariance_structure_lrt`
   are **already exported + tested** (PR #59 / `990255e`, `src/multivariate.jl` L926/L1000).
   Refresh both rows + tick the `#47` boxes. **R fires:** a thin LRT extractor over the
   exported function (genetic-correlation tests + per-trait h² CIs end-to-end) and softens
   the mandatory failed-calibration disclaimer on the shipped `covariance_standard_errors()`.
   → re-scope **#47** to row-refresh + Rose audit, not open math.
2. **Run the multivariate recovery harness** (`data-raw/multivariate-recovery-study.R`)
   through the engine and record bias±2·MCSE / convergence into its `RECORDED RESULT`
   block (currently PENDING) + a twin checkpoint. This is the known-truth gate **R cannot
   run alone** (#34/#41/#10); DGP is verified. **R fires:** moves the multivariate row in
   capability-status + issue #10 toward covered.
3. **PEV/reliability (#43), one commit.** Add `prediction_error_variance` + `reliability`
   to `result_payload(AnimalModelFit)` via `method=:selinv` (today `:dense` at likelihood.jl
   L1085/1105/1124/1138). **R fires immediately:** deletes its four probe blocks, adds
   `:selinv`, closes **#21**.
4. **Non-Gaussian (#44), blocker-first.** Commit a non-Gaussian `validation_status()` row
   (propose **V6-LAPLACE**, `partial`) recording earned evidence (Gaussian reduces to
   `sparse_reml_loglik` to machine precision; per-family score/weight match finite diffs —
   all already in `test/runtests.jl`) + honest caveats (single-trial Bernoulli σ²a bias,
   binomial m=20 gated). **No new math.** There is **no** such row today, so the R honesty
   gate has nothing to cite — this is the hard dependency before the `MarginalMethod`
   refactor + `result_payload(::NonGaussianFit)`. → split this row out of #44 so it lands first.
5. **Canon (#46 then #49), one serialization workstream.** Commit a deterministic
   Julia-native fitted-Mrode target fixture under `test/fixtures/mrode_animal_comparator/`
   (pedigree, phenotypes, variance ratio, engine EBVs/β/h² from `fit_sparse_reml` +
   `fit_ai_reml`, CI re-solve test), then the gryphon target by the same pattern. **R
   fires:** its shipped reference solver + nadiv/pedigreemm/published-Mrode confrontation
   runs against the pinned engine target → moves V1-MRODE-FIT/V1-COMPARATORS from
   covered_external toward Julia-native / multi-comparator covered.
6. **Scans (#45 then #48).** A **post-fit** marker-scan entry point taking `(fit, markers)`
   routing to `mixed_model_marker_scan` (GLS, relatedness-corrected — not the fixed-effect
   `single_marker_scan`), returning a marshalable table + parity fixture. R is blocked
   because the returned fit carries `Ainv = NULL` (`ainv_status='build_in_julia'`) and no
   scan fn consumes a fit. **R fires:** flips `gwas_table`/`qtl_table`/`eqtl_table`/
   `lod_scores` from honest-error to live + ships `gwas(fit, markers)` (~2–3h). #48
   (calibrated thresholds) is a second wave.
7. **Factor-analytic (#37 → #42 → #47-SE-path → #55), correctly last.** Fix the V4-FA
   recovery calibration via the `em_fa.jl` EM warm-start (#37; today FA 8/10, LR 9/10 —
   did NOT pass), **then** declare a rotation/interpretation convention (a science
   decision, not plumbing), **then** ship the `genetic_structure`/`genetic_loadings`/
   `genetic_uniqueness` payload + parity fixture. R is blocked here on three twin
   deliverables — surfacing rotation-arbitrary Λ for K≥2 would contradict the validated
   sign-only stance. R slice #22 fires on landing.
8. **Quick win #38 (anytime, ~1 line).** The stale `observed information (ratio ~0.99 on a
   250-animal simulation)` is **still live** at `docs/design/03-engine-contract.md:455`.
   Replace with the committed `~8% finite-difference Hessian on the tiny fixture` wording.
   The eigen-G sub-item is already satisfied (hsquared#16 closed). Defer #58 (perf) as
   validation-gated Phase 8.

## Dedup / cross-link actions

- **#47** → re-scope to row-refresh (SEs/LRTs already on main); not open math.
- **#41 (twin) == hsquared#10 (R)** — same recovery+comparator gate, two lanes; #10 is the
  public ledger, #41 the twin task. Cross-link, don't duplicate.
- **#46 + #49** — one serialization workstream (animal-model instance + general pattern,
  gryphon first); write the R confrontation harness once and reuse.
- **#37 (twin) == hsquared#17 (R note)**; **hsquared#22** is the strict R mirror of **#42** —
  no extra R work items.
- **#42 ↔ #47**: expose payload params in the SE Hessian's log-Cholesky parameterization;
  do not give #42 an SE checkbox (structured-fit SEs intentionally absent — rotation-
  nonidentified). **#55 → #42/#47** (evolvability uses the invariant-G payload + covariance SEs).
- **#43 (twin) ↔ hsquared#21 (R)** — clean pair; gate #21's close on #43's payload box; spec
  #43's field shape generically enough to also cover future V2-GBLUP genomic PEV.
- **#44** — split the missing-validation-row sub-task into its own V6-LAPLACE deliverable so
  it lands before the heavier refactor. **#50 (genetic-GLLVM)** depends on both #44 and #37.

## How this was filed

Consolidated for the twin as a single `[from R lane]` coordination issue on
`HSquared.jl` (the joint critical path + R-ready summary + dedup), with targeted
comments on the highest-leverage issues (#47 re-scope, #43 one-commit, #44 V6 split,
#38 still-live). The R lane acts only through issues; the twin (separate thread)
executes the engine work.

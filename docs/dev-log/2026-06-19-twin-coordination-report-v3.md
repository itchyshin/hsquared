# Twin coordination report v3 — HSquared.jl post-:diagonal (2026-06-19, session 3)

Read-only cross-lane scout (workflow `wf_534f18ce-187`, 7 agents: per-deliverable
readiness×R-unblock-leverage briefs + Ada/Shannon ranking, adversarially checked).
The R lane made **zero edits** to the twin. **Supersedes
`2026-06-19-twin-coordination-report-v2.md`** (which predates the `:diagonal`
landing, the standard-payload PEV/reliability promotion, and `nongaussian_result_payload`).

State pins: twin `origin/main` ≈ `6047fe2` (fast-moving — re-fetch);
`validation_status()` = **4 covered / 3 covered_external / ~26 partial / 1 planned**.
R `main` = `34f8a29` (this session's 5 slices). The R verifiable-now backlog is
drained; the frontier is **twin-gated on validation runs and fixtures, not R plumbing**.

## Headline: the `:diagonal` precedent worked — repeat it for the next capability

The `:diagonal` slice shipped the established pattern end-to-end: twin posted
`multivariate_result_payload` + a `structured_covariance_parity` fixture on #61 →
R built to it, fixture-verified the unpack, skip-guarded the live leg. Since then
the twin has shipped two more standard payloads on main — `result_payload` now
carries `prediction_error_variance`/`reliability` as standard `:selinv` fields
(`a1521bf`), and `nongaussian_result_payload` exists. **The next jumps need twin
validation runs + parity fixtures, posted the same way.**

## Ranked critical path (highest R-unblock leverage first)

| # | Deliverable | Twin issue | Effort · type | What R fires on landing | R pre-staged? | → covered? |
| --- | --- | --- | --- | --- | --- | --- |
| **1** | **Multivariate t≥2 recovery + full-R0 comparator** | #47 done / **#49** gate | **M · validation** | `genetic_covariance()`/`residual_covariance()`/`genetic_correlation()`/per-trait `heritability()`/`covariance_structure_lrt()` flip experimental→evidence-backed; recovery-study RESULT block fills | **Yes** — bridge keys, extractors, DGP-verified harness all built; no new bridge keys | Moves V4-MV-REML *toward* covered; needs **both** gates (recovery pass + #49 comparator) |
| **2** | **Multivariate per-trait PEV/reliability block** in `multivariate_result_payload` | #43 / #21 | **S–M · plumbing** (needs a MV PEV kernel) | per-trait `reliability()`/`accuracy()`/`prediction_error_variance()` on multivariate fits | Partial — univariate extractors built; MV raw-request keys absent | No (partial; no comparator) |
| **3** | **Non-Gaussian parity fixture** + freeze one method token | #44 | **S · validation** (engine shipped) | first non-Gaussian family class; the `family` gate opens; reuses generic extractors | **No** — only a refusal gate + planning note (#18) R-side | No (no external comparator) |
| **4** | **`marker_scan_result_payload` + `marker_scan_parity` fixture** | #45 / #23 | **M · plumbing** | new `gwas(fit, markers)` wrapper + `gwas_table()`/`qtl_table()`/`eqtl_table()`/`lod_scores()` (honest: nominal/Bonferroni/BH only) | **Yes** — extractors reserved; post-fit path on main (`postfit.jl`) | No (genome-wide calibration is #48) |
| **5** | **FA Stage-1 only**: metadata-only structured payload (loadings + uniqueness + `loading_convention="sign_only"`) | #42 / #22 | **M · plumbing** (carve-out) | 4 reserved extractors (`genetic_loadings`/`specific_variance`/`latent_breeding_values`/`eigen_G`) flip error→honestly-non-identified descriptive returns | **Yes** — reserved with `rotate` arg + guard | No (rotation + calibration absent) |
| **6** | **Serialized `mrode_fitted_animal/` CSV fixture** (estimated-VC leg) | #46 / #49 / #7 | **M · validation** | one fixture-verified estimated-VC textbook anchor | Yes; unpack already built | No — R-facing rows **already** covered_external (gryphon+sommer); mostly hardens the **Julia** ledger |

## #1 recommendation — multivariate recovery + #49 comparator (validation, not new code)

This is the cheapest **twin** change that is fully **R-pre-staged** and moves a real
capability toward `covered`. The estimator (`fit_multivariate_reml`) and the
recovery harness already exist; the twin's job is a **validation run + a serialized
fixture**, posted on #61 the way `:diagonal` was:

- **(a) Recovery run** — re-pin `sim/phase4_multivariate_reml_recovery.jl` to the
  R-harness truth `G0 = [[1, .3], [.3, .8]]`, `R0 = [[1, −.1], [−.1, 1.2]]` (or accept
  `--G0/--R0/--pedigree`), ≥10 seeds **passing the calibration protocol** (currently
  6/10 unstructured — below gate), recording bias ± 2·MCSE, per-trait EBV accuracy,
  convergence rate, with a Wilson interval on the pass proportion.
- **(b) #49 comparator fixture** — serialize `test/fixtures/multivariate_comparator/`
  (CSV bundle + README): inputs `Y, X, Z, pedigree`; engine targets full `G0`, **full
  `R0` including the off-diagonal residual** (R's current `sommer` comparator covers
  only the diagonal-residual subset), `h2`, `loglik`, `n_genetic_params`.
- **Entry point:** `multivariate_result_payload(fit_multivariate_reml(...; genetic_structure=:unstructured))` — already the R-consumed shape.

It beats the rest because non-Gaussian/scans unblock *new* R surfaces but R is
un-pre-staged (#18) or capped at partial by missing calibration (#48); fitted-Mrode's
R rows are already `covered_external`; FA is L-effort research. This is the only item
where R is fully pre-staged, the twin change is validation, and it advances a flagship
capability (t≥2 animal model) toward `covered`.

## R-lane follow-up that needs no twin work (hsquared#21)

The univariate PEV/reliability promotion already shipped on twin main (`a1521bf`):
`result_payload(::AnimalModelFit)` now returns `prediction_error_variance` and
`reliability` as standard `:selinv` `(ids, values)` fields. The R REML route
(`R/julia-bridge.R:51–58`) still runs `result_payload` **then unconditionally
`merge()`s** `prediction_error_variance(hsq_fit)`/`reliability(hsq_fit)` with the
default `method=:dense`, which **last-wins-clobbers the standard `:selinv` field and
forces a redundant second factorization** (values match — benign — but it is wasteful
and risks contract drift). The fix is an **R-lane edit**: guard the merge on
`!hasproperty(hsq_result, :prediction_error_variance)` (enrich only older engines) and
unpack the now-standard field directly, closing hsquared#21. **Engine-coupled and not
locally live-verifiable** (`julia` is off-PATH here; the change is inside the embedded
Julia command, covered only by the skip-guarded live-bridge tests), so it is queued on
#21 for a live-engine run — not shipped blind.

## Hard-blocked — genuine twin design/research, NOT plumbing

- **FA rotation convention (Stage-2, #37/#42).** The current convention is
  **sign-only and explicitly not an identification**. A real rank>1 rotation/
  interpretation policy is **L-effort research** and the gate for interpreting loading
  axes; calibration also did not pass (FA 8/10, lowrank 9/10) and structured SEs are
  intentionally withheld. Contract **only** the Stage-1 metadata-only payload now
  (rank #5); defer Stage-2.
- **Genome-wide threshold calibration (#48).** Every "calibrate"/"threshold" string in
  `genomic.jl` is currently a negative disclaimer; no permutation / M_eff(GEC) / FDR
  machinery exists. **Julia-lane-solo RNG/simulation research**, required before any
  V5-MARKER row can move toward `covered`. The #45 payload (rank #4) ships an *honest*
  `gwas()` (nominal/Bonferroni/BH only) without it.

Neither blocker belongs on the bridge-activation critical path; both are net-new
research deliverables.

# V4-MV-REML promotion-gate review

Status: **review / recommendation, 2026-06-22.** Lenses: Fisher (inference,
lead), Mrode (validation canon), Curie (recovery). This note reviews whether the
multivariate REML animal model (`V4-MV-REML`) can move `partial → covered`, and
recommends a gate change. It promotes nothing; the covered gate is twin-owned
(`HSquared.jl`), so the recommendation is addressed to Ada/Shannon and the twin.

## Question

The stated covered gate is: "accept or broaden the recovery gate **plus** another
independent same-estimand REML comparator beyond `sommer`." Is the existing
evidence enough, and is that gate well-designed?

## Existing evidence (verified)

1. `sommer` full-unstructured-residual **same-estimand REML** comparator
   reproducing the engine's `phase4_multitrait_parity` G0/R0/β/h²/EBV to
   `≤ 8e-5` (recovers the off-diagonal residual the in-suite diagonal check
   cannot) — `data-raw/multivariate-comparator-study.R`.
2. `MCMCglmm` **Bayesian agreement** (target inside 95% HPD for all 8 covariance
   elements, 4 fixed effects, both h²; EBV cor > 0.9997) — different estimand
   class, correctly labelled not-REML.
3. 100-replicate cold-start **known-truth recovery** (all six G0/R0 elements,
   rg, both h² within bias ± 2·MCSE; 100/100 converged) — "no detectable bias".
4. Mrode Example 5.1 supplied-G0/R0 **BLUP/MME anchor** (CI-runnable).

## Verdict

**Do not promote to covered yet — but the gate as written is over-strict, and
the binding blocker is not what it looks like.**

- **What a 2nd same-estimand REML comparator actually adds:** `sommer` and the
  engine share the estimand *and* estimator class (AI-REML on the same restricted
  likelihood). The one failure mode the existing legs are weakest against is a
  **shared systematic error in the REML objective** that two independently
  authored REML codebases would be unlikely to share. A second REML lineage
  attacks exactly that. MCMCglmm (Bayesian) and the recovery study do not close
  it directly. So the gate is well-targeted in *kind*.
- **But the *number* is the problem.** Checked directly: there is **no free CRAN
  multivariate-animal-model REML package besides `sommer`** — `MCMCglmm` is
  Bayesian (no REML mode), `pedigreemm` is univariate, `breedR` bundles the
  BLUPF90 binaries (collapses to the licensed/registration case), `lme4`/`lme4qtl`
  cannot fit a 2-trait unstructured-G/unstructured-R animal model. Requiring a
  **second** REML comparator therefore hard-couples an open-package "covered"
  claim to a licensed/registration binary (ASReml / BLUPF90 / DMU / WOMBAT) —
  a poor property for an open package, and the maintainer's own concern.

## Recommendation

1. **Make the second REML comparator and the recovery-gate acceptance
   substitutable, not both-required.** Defensible covered basis = the existing
   `sommer` same-estimand REML leg + MCMCglmm cross-class agreement + Mrode MME
   anchor + **either** (a) a second independent REML lineage **or** (b) a passing
   **pre-declared** known-truth recovery gate. Both (a) and (b) attack the
   shared-REML-objective failure mode; either, on top of the existing legs, is a
   reasonable bar for an experimental opt-in path. Keep the **kind** requirement
   (same-estimand REML) — do not let Bayesian agreement substitute. This change
   is the twin's to make in `validation_status.jl` (V4-MV-REML `missing` field).
2. **Highest-leverage action available now, no licensed tool:** the compute-only
   half — re-run the multivariate recovery at a larger / relatedness-richer
   (full-sib, larger-n) DGP under a **pre-declared** pass gate, or formally
   re-state the gate in bias/MCSE terms *declared before running* (per the twin
   `2026-06-14-calibration-failure-response` decision; post-hoc threshold
   relaxation of the failed 6/10 per-seed run is **not** permitted). This removes
   one of the two named blockers using only CPU.
3. **Two honesty fixes regardless of promotion:**
   - The full-unstructured `sommer` parity is a `data-raw` (`.Rbuildignore`d)
     one-time run; the **CI-gated** `sommer` check is **diagonal-residual** only
     (`test-multivariate.R`). Either promote the full-unstructured comparator into
     a `skip_on_cran()` + `skip_if_not_installed("sommer")` in-suite test, or
     reword the capability row so it does not read as a standing CI gate.
   - The recovery evidence is a **low-power non-rejection** of bias (a systematic
     bias below ~0.10–0.16 on G would pass undetected at m=12), not a proof.
     "No detectable bias" must not be worded as "unbiased" in any covered claim.

## Claim boundary

Review only. No capability/validation/public-claim promotion; `V4-MV-REML` stays
`partial`. The gate change (recommendation 1) is twin-owned. The honesty fixes
(recommendation 3) are R-lane wording/test tasks that can be done independently
of promotion. The Julia engine inverts `Ainv` internally, so deep-inbreeding /
high-condition-number pedigrees remain an explicit boundary even after any
promotion.

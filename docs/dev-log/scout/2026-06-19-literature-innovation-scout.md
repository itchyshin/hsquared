# Scout: Literature + Web Innovation Scan (recurring cadence, batch 1)

Date: 2026-06-19
Lens: Jason (landscape scout) · Lane: coordinator / R · Twin: cross-ref read-only
Cadence: first batch of the recurring innovation scout. Scope =
animal-model REML/AI-REML at scale, sparse linear algebra for mixed models,
factor-analytic / reduced-rank G, ssGBLUP/APY, GWAS/QTL, GLLVM /
latent-variable multivariate genetics, non-Gaussian animal models.

HARD RULE honoured: this is scouting/ideas only. No capability claims for
hsquared/HSquared.jl. Every numeric/factual claim is cited to its source; where
unverified, it is flagged. No fabricated citations.

---

## A. Method / paper / tool summaries (what is novel, why it matters)

### 1. Augmented AI-REML — one augmented solve per REML iteration
- Strandén, Mäntysaari, Lidauer, Thompson & Gao (2024), *Genetics Selection
  Evolution* 56:78. https://doi.org/10.1186/s12711-024-00939-x ·
  open: https://pmc.ncbi.nlm.nih.gov/articles/PMC11580194/
- **Novel:** standard AI-REML must solve the mixed-model equations (MME)
  separately for each variance/covariance component to build the AI matrix and
  gradient. The augmented method enlarges the MME with an "update effect" so a
  *single* augmented solve per REML iteration replaces those many solves. The
  paper reports per-iteration elapsed time cut by ~75% / 84% / 86% for two-,
  three-, four-trait GBLUP with preconditioned conjugate gradient (PCG) solving
  (their Table; verified from the open PMC copy).
- **Why it matters to hsquared/HSquared.jl:** the per-component-solve cost is
  exactly what dominates multi-trait AI-REML on the engine side. This is a
  drop-in algorithmic restructuring (no new model class) that the Julia engine
  could adopt once it has an iterative/PCG solve path. **The 75-86% numbers are
  their results on their data — not transferable as an hsquared claim without
  our own benchmark.**

### 2. Augmented AI-REML vs. matrix-free trace estimation (Lanczos/Hutchinson)
- Border & Becker (2019), "Stochastic Lanczos estimation of genomic variance
  components for linear mixed-effects models", *BMC Bioinformatics* 20:411.
  https://doi.org/10.1186/s12859-019-2978-z
- **Novel (still the reference design):** replaces exact trace/log-det in the
  REML objective with Krylov-subspace (Lanczos) + stochastic (Hutchinson-style
  random-probe) estimates, exploiting Krylov shift-invariance so one subspace
  serves multiple variance ratios — matrix-free, no explicit large inverse.
- **Why it matters:** two competing scaling routes for the engine — (a)
  exact-but-restructured (augmented AI-REML, #1) vs. (b) matrix-free stochastic
  (Lanczos). hsquared's stated bias is sparse-direct + selected inverse
  (Takahashi), so #1 is the closer fit short-term; #2 is the dense-G / genomic
  fallback. **Did not find a 2024-2026 successor paper** in this scan — the 2019
  design still appears current; flag as "verify currency before citing as SOTA".

### 3. ssGBLUP missing-pedigree: metafounders vs. unknown-parent groups (UPG)
- Invited review: Masuda et al. / Legarra group, *J. Dairy Sci.* (2022),
  https://doi.org/10.3168/jds.2021-21070 ; plus 2024-2025 simulation/applied
  work (Norwegian Red: Belay et al., *J. Anim. Breed. Genet.* 2024,
  https://doi.org/10.1111/jbg.12939 ; US dairy fertility, *J. Dairy Sci.* 2025,
  https://doi.org/10.1016/j.jds... [see ScienceDirect S0022030224012347]).
- **Novel / current consensus:** metafounders (MF) generalise UPG by giving
  founders a relationship structure (Γ matrix) so G and A are compatible in
  level and scale; recent simulation work reports MF giving best bias/dispersion
  even under incomplete pedigree. (Their conclusion, not ours.)
- **Why it matters:** when hsquared reaches genomic/ssGBLUP territory, the
  founder/UPG/MF design is a *modelling-grammar* decision (how founders enter the
  formula and the relationship payload), not just an engine detail. Worth
  shaping the formula/contract early so MF is expressible later. **Planned-only;
  needs validation before any claim.**

### 4. gllvm 2.0 — fast VA/LA fitting of ordination + JSDM at scale
- Korhonen, Hui, Niku, Taskinen & van der Veen (2025), "gllvm 2.0: fast fitting
  of advanced ordination methods and joint species distribution models",
  *PeerJ* 13:e20338. https://pmc.ncbi.nlm.nih.gov/articles/PMC12704334/
  Companion review: Korhonen et al. (2024), *WIREs Comp. Stat.* e70005,
  https://doi.org/10.1002/wics.70005
- **Novel:** consolidates variational approximation (VA) as the scalable default
  and Laplace (LA) as the accurate fallback, with structured/reduced-rank latent
  covariance and faster fitting for large p.
- **Why it matters:** this is the external canon for the Phase-6 GLLVM-style
  latent genetic-factor path (the LA+VA directive in the 2026-06-18 scout). The
  genetic version replaces the residual latent covariance with a *genetic* G
  built on a relationship kernel — but the VA/LA dual-method scaffolding and
  reduced-rank latent structure transfer directly. Confirms the LA+VA reuse plan
  is aligned with current best practice in the source field.

### 5. Factor-analytic / reduced-rank covariance — still the parsimony workhorse
- Piepho (2024), "Factor-Analytic Variance–Covariance Structures for Prediction
  Into a Target Population of Environments", *Biometrical Journal* 66:2400008,
  https://doi.org/10.1002/bimj.202400008 ; foundational: Meyer (2009), *GSE*
  41:21, https://doi.org/10.1186/1297-9686-41-21
- **Novel / current:** FA / reduced-rank structures keep being the standard
  parsimonious representation of high-dimension genetic (co)variance (MET, GxE,
  multi-trait). Note the FA-vs-PC distinction: FA adds trait-specific variances
  (Λ Λ' + Ψ), so it does *not* reduce rank unless specific variances are zero;
  pure reduced-rank/PC does.
- **Why it matters:** directly informs Kirkpatrick-lane G-matrix grammar
  (`fa(k)` / reduced-rank `rr(k)` covariance keywords). The `Λ Λ' + diag(ψ)`
  algebra is *exactly* the structure already factorised in the sister repos
  (see §B). Strong fit between the canonical estimand and local code patterns.

### 6. Scalable GWAS: sparse-GRM MLMs and variational successors
- fastGWA / fastGWA-GLMM: Jiang et al. (2019), *Nat. Genet.* 51:1749,
  https://doi.org/10.1038/s41588-019-0530-8 ; Jiang et al. (2021) GLMM,
  https://doi.org/10.1038/s41588-021-00954-4
- Newest: "Quickdraws" — spike-and-slab prior + stochastic variational inference
  + GPU, *Nat. Genet.* (Jan 2025), https://doi.org/10.1038/s41588-024-02044-7 .
  Reported +4.97%/+3.25% associations over REGENIE and +22.71%/+7.07% over
  fastGWA on 405,088 UK Biobank samples (**their results, biobank-scale human —
  not a quantitative-genetics breeding/ecology setting; treat as directional
  only**).
- **Why it matters:** confirms the field's scaling direction = *sparse* GRM
  rather than dense, plus variational inference + GPU. Reinforces hsquared's
  sparse-first bias and the GPU-algorithm scout already on file
  (2026-06-13-gpu-algorithm-scout.md). GWAS itself is far down the roadmap.

### 7. Non-Gaussian animal models: Laplace/INLA accuracy caveat
- Holand, Steinsland, Martino & Jensen (2013), "Animal Models and Integrated
  Nested Laplace Approximations", *G3* 3:1241,
  https://doi.org/10.1534/g3.113.006700 (still the key cautionary reference —
  **did not find a 2024-2026 replacement in this scan**).
- **Novel / caution:** for binary/low-count traits with few records per
  individual, the Laplace/INLA Gaussian approximation of the heritability
  posterior can be poor and diverge from MCMC/truth; accuracy improves rapidly
  with replication/trials per individual.
- **Why it matters:** a guardrail for the planned non-Gaussian path. If
  HSquared.jl offers a Laplace family, the docs must state the
  low-information-per-cluster regime where it is unreliable, and a VA or MCMC
  cross-check should gate any heritability claim. Aligns with the LA+VA
  dual-method directive (#4).

---

## B. New reusable patterns in local sister repos (NOT in 00-ecosystem-lessons.md)

Read-only inspection of `DRM.jl/src` and `GLLVM.jl/src`. Three patterns are new
relative to the current ecosystem-lessons doc (which lists only `fit.jl`,
`structured_schur.jl`, `takahashi_selinv.jl`). Provenance by file read; **no
code copied; not yet validated for the QG setting.**

1. **`GLLVM.jl/src/lowrank_cholesky.jl` — Woodbury factor for `M = Λ Λ' + diag(d)`.**
   Implements `M⁻¹` and `logdet(M)` via the Woodbury identity / matrix-determinant
   lemma: one K×K Cholesky of the capacitance `I_K + Λ' D⁻¹ Λ` plus O(pK) BLAS-2,
   instead of O(p³). AD-friendly (eltype-generic, no Float64 hard-coding).
   **This is the exact algebra of the factor-analytic / reduced-rank G in §A-5.**
   The single strongest reusable lead for an `fa(k)`/`rr(k)` genetic covariance
   on the engine side. (00-ecosystem-lessons mentions "Woodbury-style Gaussian
   computation" abstractly but does not point at this file.)

2. **`GLLVM.jl/src/em_squarem.jl` — SQUAREM EM acceleration (gradient-free).**
   Wraps any EM update map G(θ) with squared extrapolation (Varadhan & Roland
   2008, *Scand. J. Statist.* 35:335-353), globalised with backtracking toward
   α=-1 (cannot do worse than plain EM); same fixed point / same MLE, typically
   3-10× fewer iterations (their claim). New-file convention: `include`s
   `em_phylo.jl`, does not modify it. **Reusable as a generic accelerator for any
   EM-style variance-component / FA fit in HSquared.jl** without touching the
   inner model.

3. **`GLLVM.jl/src/em_fa.jl` — closed-form EM factor analysis** (Rubin & Thayer
   1982). Both M-step updates closed form (`Λ_new = S_yη S_ηη⁻¹`,
   `ψ_new = diag(...)/n`); log-lik evaluated via Woodbury so monotone
   non-decrease is testable. **A ready reference implementation for reduced-rank
   G estimation by EM** (an alternative to AI-REML for the FA block), and a
   natural pairing with #2 (SQUAREM) and #1 (Woodbury).

Also noted but already-known/lower-novelty: `DRM.jl/src/variational.jl` (VA, in
the 2026-06-18 scout), `DRM.jl/src/reml_q4.jl` / `heritability.jl` (QG-adjacent
REML/h2 plumbing — worth a deeper read in a future engine slice),
`takahashi_selinv.jl` in both repos (already an ecosystem-lessons lead).

Recommendation: append patterns 1-3 to `docs/design/00-ecosystem-lessons.md`
"Concrete Local Leads" in a later coordinator-lane slice (not this scout — this
note does not edit other files).

---

## C. Ranked innovation ideas (issue-ready)

Each: rationale · phase touched · rough effort · validation flag.

### Innovation 1 — Reduced-rank / factor-analytic genetic covariance `fa(k)` / `rr(k)`, Woodbury-backed
- **Rationale:** FA/reduced-rank is the canonical parsimony tool for
  high-dimension G (§A-5), and the exact `Λ Λ' + diag(d)` algebra is already
  implemented locally (`GLLVM.jl/src/lowrank_cholesky.jl`, §B-1) and pairs with
  closed-form EM (§B-3) + SQUAREM (§B-2). High canon-to-code fit.
- **Phase:** Kirkpatrick G-matrix lane (post-v0.1 multivariate); formula grammar
  + engine. **Effort:** M-L (grammar small; engine FA estimator larger).
- **VALIDATION FLAG:** estimates of reduced-rank G need independent validation
  (Mrode/Meyer multi-trait fixtures + simulation recovery) before any claim.

### Innovation 2 — Augmented AI-REML single-solve restructuring for multi-trait
- **Rationale:** removes the per-component MME-solve bottleneck that dominates
  multi-trait AI-REML; pure algorithmic restructuring, no new model class
  (§A-1). Natural once the engine has a PCG/iterative solve path.
- **Phase:** Gauss/Henderson engine lane (multi-trait REML). **Effort:** M
  (engine-internal; bounded, well-specified in the GSE 2024 paper).
- **VALIDATION FLAG:** must reproduce identical variance components vs. the
  standard AI-REML path on Mrode/known fixtures; the 75-86% speedups are the
  paper's data, **not** an hsquared claim — needs our own benchmark.

### Innovation 3 — SQUAREM EM accelerator as a generic engine utility
- **Rationale:** drop-in, gradient-free, monotone-safe accelerator for any
  EM-style variance-component / FA fit; local reference exists (§B-2). Lowest-risk
  win — same fixed point, so it cannot change the estimate, only the iteration
  count.
- **Phase:** any EM/variance-component engine slice (supports Innovations 1 & the
  Phase-6 GLLVM path). **Effort:** S-M.
- **VALIDATION FLAG:** light — verify same fixed point (identical estimates) and
  monotone log-lik on a test map; no estimand changes, so no new scientific claim.

### Innovation 4 — Dual LA + VA fitting contract for non-Gaussian / latent-factor models, with a low-information guardrail
- **Rationale:** the source field (gllvm 2.0, §A-4) treats VA as the scalable
  default and LA as the accurate fallback; the 2013 INLA caution (§A-7) shows the
  heritability posterior degrades under low information per cluster. Encode the
  `method = "LA"/"VA"` choice + an honest accuracy guardrail before any
  non-Gaussian h2 claim.
- **Phase:** Phase 6 (GLLVM-style latent genetic models) + non-Gaussian families;
  bridge/contract grammar now, engine later. **Effort:** M (contract) / L (engine).
- **VALIDATION FLAG:** strongest gate here — any non-Gaussian heritability output
  needs LA-vs-VA-vs-MCMC agreement on simulated low/high-information regimes
  before leaving "planned".

---

## D. Learn / avoid / defer / validate-against (synthesis)

- **Learn:** augmented AI-REML restructuring (§A-1); Woodbury low-rank factor +
  closed-form EM-FA + SQUAREM as a coherent reduced-rank G toolkit (§B);
  gllvm 2.0 VA/LA dual-method scaffold (§A-4).
- **Avoid:** advertising any speedup or accuracy number from these papers as an
  hsquared property — all are others' results on others' data. Avoid a
  Laplace-only non-Gaussian path without a stated low-information caveat.
- **Defer:** ssGBLUP metafounder/UPG grammar (§A-3) and scalable-GWAS machinery
  (§A-6) — roadmap-relevant but far from v0.1; shape the formula contract so they
  stay expressible later without crowding the easy API.
- **Validate-against:** Meyer (2009) / Mrode multi-trait fixtures for reduced-rank
  G; standard AI-REML for the augmented variant; MCMC/INLA for non-Gaussian h2.

## E. Sources checked
- Strandén et al. 2024 GSE (augmented AI-REML) — fetched (PMC11580194).
- Border & Becker 2019 BMC Bioinf (stochastic Lanczos) — search abstract.
- ssGBLUP MF/UPG: 2022 invited review + Belay 2024 JABG + 2025 JDS — search abstracts.
- gllvm 2.0 (PeerJ 2025) + Korhonen 2024 WIREs review — search abstracts.
- Piepho 2024 Biom. J. + Meyer 2009 GSE (factor-analytic) — search abstracts.
- fastGWA(-GLMM) 2019/2021 + Quickdraws 2025 Nat. Genet. — search abstracts.
- Holand et al. 2013 G3 (INLA animal model) — search abstract.
- XSim v2 (2022), AGHmatrix (2023) — search abstracts; no 2024-26 update surfaced.
- Local: `GLLVM.jl/src/{lowrank_cholesky,em_squarem,em_fa}.jl` read; `DRM.jl/src/`
  + `GLLVM.jl/src/` file listings inspected.
- **Not deep-verified:** all per-paper speedup/accuracy numbers (others' data);
  currency of the Lanczos (2019) and INLA (2013) references as today's SOTA.

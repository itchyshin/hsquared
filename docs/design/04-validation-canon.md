# Validation Canon

Validation is a first-class product surface. A public capability needs evidence
before it is advertised as working.

## Validation Hierarchy

1. Tiny deterministic hand checks.
2. Pedigree and Ainv known examples.
3. Simple Mrode-style examples.
4. ASReml comparison when available.
5. BLUPF90, DMU, or WOMBAT comparison where reproducible.
6. XSim simulation truth for later genomic and selection examples.

## Metrics

Record:

- Ainv construction time;
- model matrix construction time;
- ML/REML optimization time;
- total time;
- peak memory;
- number of records;
- number of animals;
- number of fixed-effect levels;
- number of traits;
- number of nonzero entries.

## Comparator Discipline

Do not compare different estimands. Before calling a difference an engine bug,
confirm the DGP, fitted model, estimator, scale, and missing-data handling.

## Current Validation Atoms

- Tiny deterministic Henderson-style three-animal `Ainv` fixture: checks R
  payload ordering, sparse `Z`, and live Julia `pedigree_inverse()` agreement
  when a sibling `HSquared.jl` checkout is available.
- Optional Mrode9/nadiv pedigree `Ainv` comparator: checks Julia
  `pedigree_inverse()` against `nadiv::makeAinv()` for the Mrode9 pedigree when
  optional dependencies are available.
- Supplied-variance Henderson MME fixture: checks an independent R solve
  against Julia `henderson_mme()` for fixed effects, EBVs, fitted values, h2,
  and dense validation-path PEV/reliability. This does not estimate variance
  components and does not claim production sparse reliability.
- Mrode-style supplied-variance output fixture: checks a twelve-animal
  pedigree example against independent R reference calculations and optional
  live Julia calls for Ainv, fixed effects, EBVs, fitted values, PEV,
  reliability, h2, ML log-likelihood, and dense/sparse REML log-likelihood at
  supplied variance components. This is not variance-component estimation or
  full Mrode fitted-output validation.
- Julia Mrode Example 3.1 published anchor sync: HSquared.jl PR #139
  (`934a91e`) added a native supplied-variance test at `sigma_a2 = 20`,
  `sigma_e2 = 40`, pinning published EBVs for animals 1-8 and the invariant
  male-minus-female sex contrast. This is the Julia-side counterpart to the
  R published-anchor evidence, not estimated variance components, not a
  same-estimand REML comparator, and not a covered-status promotion.
- Sparse REML estimate-recovery check: an optional live test runs the opt-in
  Julia-owned `fit_sparse_reml()` optimizer from two different starting variance
  components and verifies it reaches the same REML optimum (start-independence)
  with positive estimated variances. It compares the same estimand (the REML
  objective) across starts; it is NOT data-generating recovery, supplied-truth
  recovery, an external comparator, or an ASReml-parity claim. When an external
  comparator (ASReml/BLUPF90/DMU/WOMBAT) is added later, the comparator
  discipline above (confirm DGP, fitted model, estimator, scale, missing-data
  handling before calling a difference an engine bug) governs it.
- Sparse-vs-dense REML optimizer agreement: an optional live test fits the same
  Mrode fixture with REML through both the dense optimizer (`fit_variance_components`,
  the default `target = "fit_animal_model"`) and the sparse optimizer
  (`fit_sparse_reml`, `target = "sparse_reml"`) and verifies they reach the same
  REML optimum (matching log-likelihood and variance estimates). This is an
  internal cross-check between two engines of the same estimand; it is not an
  external comparator or a production-fitting claim.
- Independent pure-R REML optimizer cross-check: a pure-R reference
  (`hs_reml_estimate_reference()`, an `optim()` wrapper over the dense Gaussian
  REML objective with no Julia involvement) is optimized on the Mrode fixture;
  its REML variance estimate is verified positive and finite (this part runs on
  CI), and, when the sibling checkout is available, it is matched against the
  Julia `fit_sparse_reml()` estimate. A fully independent (non-Julia)
  implementation of the same estimand; not an external comparator or a
  production-fitting claim.
- External comparator (pedigreemm): an optional, `pedigreemm`-gated test fits a
  deterministic replicated animal-model dataset with `pedigreemm` (an
  established lme4-based REML animal-model package) and verifies that hsquared's
  REML solution is at least as good — by the common verified REML
  log-likelihood — as pedigreemm's, with heritabilities agreeing within a sane
  band. Finding: hsquared/the pure-R reference reach the true REML optimum while
  pedigreemm's optimizer lands slightly off on these pedigree models, and
  pedigreemm cannot fit the saturated one-record-per-animal Mrode fixture at all
  (hence the replicated design). This is a same-estimand external cross-check
  showing hsquared is at least as good as an established package; it is NOT
  ASReml/BLUPF90/DMU/WOMBAT parity, production-software validation, or DGP
  recovery.
- Multivariate t=2 recovery and comparator evidence: the R lane records a
  reproducible 100-replicate cold-start known-truth recovery study for the
  opt-in `target = "multivariate"` path and a reproduced full-unstructured
  `sommer` comparator leg against the shared `phase4_multitrait_parity` target,
  plus a pure-R CI anchor reproducing the published Mrode Example 5.1
  multiple-trait supplied-G0/R0 BLUP/MME fixed effects and animal BLUPs. The
  recovery study reports 100/100 convergence, all six G0/R0 elements, the
  genetic correlation, and both per-trait h2 within bias +/- 2*MCSE, and EBV
  accuracy 0.79/0.74. The full-unstructured `sommer` run agrees with the
  serialized Julia target to <= 8e-5 for G0/R0/beta/h2/EBV and recovers the
  off-diagonal residual covariance that the in-suite diagonal-residual `sommer`
  check cannot test. A Bayesian `MCMCglmm` agreement probe
  (`data-raw/multivariate-mcmcglmm-agreement-study.R`) puts the serialized Julia
  target inside 95% HPD intervals for all 8 covariance elements, all 4 fixed
  effects, and both per-trait h2 values, with posterior-mean EBV correlations
  above 0.9997. Because `MCMCglmm` is Bayesian/MCMC, this leg is agreement
  evidence only and not a same-estimand REML comparator. The Mrode Example 5.1
  anchor is a published supplied-
  covariance BLUP/MME target, not variance-component estimation. This is
  evidence toward the twin-owned V4-MV-REML covered gate, not coverage by
  itself. Promotion still needs the broader or re-declared recovery gate and one
  more independent same-estimand comparator such as ASReml, BLUPF90/AIREMLF90,
  JWAS/equivalent, or another accepted tool.
- Julia ledger sync: HSquared.jl PR #138 (`945bd2a`) mirrored the R-lane
  Mrode Example 5.1 supplied-covariance anchor and `MCMCglmm` Bayesian agreement
  probe into the Julia V4 ledger. This is cross-lane evidence bookkeeping only:
  it does not change the R validation status, it does not make `MCMCglmm` a
  same-estimand REML comparator, and it does not close the twin #46/#49 gates.
- Multivariate MCMCglmm Bayesian agreement probe: an opt-in `data-raw` script
  fits the same two-trait animal-model fixture with `MCMCglmm` using an
  unstructured animal covariance and unstructured residual covariance. With
  seed 20260621, 50,000 iterations, 10,000 burn-in, and thin 40, the serialized
  HSquared.jl target is inside the 95% HPD interval for all eight covariance
  elements, all four fixed effects, and both per-trait h2 values; posterior
  mean EBV correlations are > 0.9997. This is Bayesian agreement evidence only,
  not a same-estimand REML comparator and not a covered-status promotion.

## Locked Derived-Estimand Identities (Standard-Tier Covered-Flip Gate)

Per the 2026-07-09 Standard-Tier Covered-Flip Gate
(`docs/dev-log/decisions.md`), a derived estimand flips `covered` only with a
within-package identity test asserting it equals its defining function of the
covered components, plus a locked, pinned citation for that identity. This
section is that citation lock. It does **not** flip any status, add a
`validation_status()` row, or change `public_covered_count` (stays **5**).

### Multivariate (0.6) identities

- **Genetic correlation** `r_g[i,j] = σ_g,ij / sqrt(σ²_g,i · σ²_g,j)` =
  `cov2cor(G0)`. Identity test:
  `genetic_correlation(fit) == cov2cor(genetic_covariance(fit))` (MV-3,
  `tests/testthat/test-multivariate.R`). Locked citation: Falconer & Mackay
  (1996), *Introduction to Quantitative Genetics*, 4th ed., ch. 19; Lynch & Walsh
  (1998), *Genetics and Analysis of Quantitative Traits*, ch. 21.
- **Per-trait heritability** `h²_k = σ²_a,k / (σ²_a,k + σ²_e,k)` =
  `diag(G0) / (diag(G0) + diag(R0))`. Identity test:
  `heritability(fit)$estimate == diag(G0)/(diag(G0)+diag(R0))` (MV-3, verified on
  the engine's serialized `phase4_multitrait_parity` values). Locked citation:
  Falconer & Mackay (1996), ch. 8, 10; Lynch & Walsh (1998), ch. 4, 7.

These two are the R-lane derived-estimand identity gates for the 0.6
multivariate covered flip; the component estimands `G0`/`R0` are
external-same-estimand-comparator gated (`sommer` in-suite MV-1 + executed
`blupf90+` MV-2). The flip itself remains twin-gated + Darwin biology
sign-off + Rose.

### Direct–maternal Willham identities (A21 C5)

These three already sit under the covered validation-scale
`target = "direct_maternal"` route (the 5th of `public_covered_count`).
A21 C5 locks the identities and the full Willham citations that the
in-surface "Willham 1963, 1972" year-only attribution did not pin. This
is a **retrospective citation lock**, not a covered flip.

Phenotypic variance on this route is
`σ_P = σ²_ad + σ²_am + σ_dm + σ²_e` (coefficient 1 on `σ_dm` for a
non-inbred base: `2 · A[i,dam] = 2 · (1/2) = 1`). The 2×2 `G_dm`
formulation is Willham's, not Falconer's 1965 single-`m` model (that
model fixes `r_am = ±1` and is the special case).

Locked Willham pair (journal, volume, pages):

- Willham, R. L. (1963). The covariance between relatives for characters
  composed of components contributed by related individuals.
  *Biometrics* **19**(1): 18–27. doi:10.2307/2527570
- Willham, R. L. (1972). The role of maternal effects in animal breeding:
  III. Biometrical aspects of maternal effects in animals.
  *Journal of Animal Science* **35**(6): 1288–1293.
  doi:10.2527/jas1972.3561288x

1963 supplies the 2×2 direct–maternal genetic covariance and the
correlation between the two effects. 1972 supplies the biometrical
partition of `σ_P` and the selection-response total.

- **Willham total heritability**
  `h2_T = (σ²_ad + 1.5 · σ_dm + 0.5 · σ²_am) / σ_P`.
  Coefficients `(1, 1.5, 0.5)` predict response to mass selection;
  they are not "total heritable variance" `(1, 2, 1) = Var(A_d + A_m)`.
  `h2_T` can be lower than direct `h2_d = σ²_ad / σ_P` when `r_am < 0`.
  Identity test: `tests/testthat/test-direct-maternal.R` (labelled-triple
  `h2_total_willham` row and `total_heritability()`). Locked citation:
  Willham (1963) *Biometrics* 19(1): 18–27; Willham (1972) *J. Anim. Sci.*
  35(6): 1288–1293.
- **Maternal variance ratio** `m2 = σ²_am / σ_P`. This is a variance
  ratio, not a heritability. The locked denominator **includes** `σ_dm`
  — the covered direct–maternal estimand — and is not the experimental
  two-effect `maternal_proportion()` ratio
  `σ²_m / (σ²_a + σ²_m + σ²_e)`. Identity test:
  `tests/testthat/test-direct-maternal.R` (`m2_maternal`). Locked
  citation: the same Willham pair.
- **Direct–maternal genetic correlation**
  `r_am = σ_dm / sqrt(σ²_ad · σ²_am)`. Implemented correctly in the
  engine as `G_dm[1, 2] / sqrt(G_dm[1, 1] * G_dm[2, 2])`; the R bridge
  surfaces that engine value. A negative `r_am` is real and expected.
  Identity test: **owed** (A21 C4, a separate lease). This lock pins
  the identity and the citation; it does **not** discharge C4 and does
  not claim the test exists. Locked citation: the same Willham pair.

`R` (breeder's equation `R = h²S`) has no surface in either lane; none
is owed (A21 C8). If a selection-response extractor lands, the identity
is `R = h²_T · S` on the Willham scale, not `h²_d · S`.

### Genomic GREML identities (0.7 candidate)

These lock the derived estimand for the **opt-in** R-public genomic GREML
surface (`target = "genomic"`). They do **not** flip status; live count stays
**6** until a separate Rose CLEAN tip audit and lockstep flip. Component
\(\sigma_g^2/\sigma_e^2\) stay external-comparator gated (Totoro exact-`G`
sommer/rrBLUP; engine `blupf90+` on supplied `Ginv`). Recovery for the opt-in
claim is carried by design-53 SUPERSEDE (engine V2-GREML 48-seed + marker≡Q
identity), not by a fresh R 48-seed campaign.

Locked construction citation (relationship scale, not a Mrode genomic-\(h^2\)
pin):

- VanRaden, P. M. (2008). Efficient methods to compute genomic predictions.
  *Journal of Dairy Science* **91**(11): 4414–4423.
  doi:10.3168/jds.2007-0980 (method 1; sample allele frequencies; \(G = WW'/k\)).
- Scale honesty retained from design-43 §1 / design-51 (Legarra 2016 base-
  population discussion as secondary scale literature, not a textbook \(h^2\)
  anchor).

- **Genomic variance ratio**
  \(r_G = \sigma_g^2 / (\sigma_g^2 + \sigma_e^2)\) =
  `genomic_variance_ratio` on the declared kernel
  \(K_\lambda = G + 0.01\,I\). This is a **variance-component ratio on the
  genomic relationship scale**, not pedigree narrow-sense \(h^2\), not a
  founder-base additive heritability, and not generally the fraction of average
  marginal phenotypic variance under ridge. Identity tests:
  `tests/testthat/test-genomic-greml-s0-identity.R` (N2 label pin; julia-free
  mock + optional live) and live `heritability(fit)$component ==
  "genomic_variance_ratio"` on the genomic route
  (`tests/testthat/test-genomic.R`). Locked citation: VanRaden (2008) for \(G\);
  Falconer & Mackay (1996) ch. 8/10 for the two-component variance-ratio form
  (applied here on the genomic scale, with the explicit no-anchor disclosure
  that no clean Mrode genomic-\(h^2\) pin exists).

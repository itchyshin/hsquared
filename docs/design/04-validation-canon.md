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

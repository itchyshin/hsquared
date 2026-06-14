# G-Matrix Interpretation Scout

Date: 2026-06-14

## Question scouted

How should `hsquared` explain G and R matrices to applied breeders,
evolutionary biologists, ecologists, and PhD users without over-claiming the
current opt-in multivariate surface?

## Sources checked

- `.agents/skills/quantgen-scout/references/packages.md` for the local package
  comparison map.
- `HSquared.jl/docs/src/multivariate-models.md` for the current Julia
  multivariate and structured-covariance boundary.
- `HSquared.jl/src/validation_status.jl` and `HSquared.jl/docs/src/validation-status.md`
  for the Phase 4B structured-covariance status: deterministic checks exist,
  but the predeclared recovery calibration did not pass.
- `GLLVM.jl/docs/src/covariance-correlation.md` for the invariant-first
  covariance / correlation explanation.
- `GLLVM.jl/docs/src/pitfalls.md` for the warning that latent loadings are
  rotation- and sign-nonunique.
- `DRM.jl/docs/src/model-guides/cross-family-methods.md` for the same
  loadings-are-not-directly-comparable caution in cross-family latent models.
- Lande & Arnold (1983), "The measurement of selection on correlated
  characters": https://pubmed.ncbi.nlm.nih.gov/28556011/
- Kirkpatrick, Lofsvold & Bulmer (1990), "Analysis of the inheritance,
  selection and evolution of growth trajectories":
  https://pubmed.ncbi.nlm.nih.gov/2323560/
- Hansen & Houle (2008), "Measuring and comparing evolvability and constraint
  in multivariate characters": https://pubmed.ncbi.nlm.nih.gov/18662244/

## Relevant lessons

- Users need the `G` and `R` names, but the canonical result fields should stay
  `genetic_covariance` and `residual_covariance` so the bridge contract remains
  explicit.
- The article should explain diagonals, off-diagonals, and correlations before
  mentioning factor-analytic loadings.
- `P_matrix()` should not be added casually. In the current animal + residual
  model `P = G + R`, but the denominator becomes model-specific once permanent,
  common-environment, maternal, genomic, or structured residual components enter
  the same fit.
- GLLVM/DRM local sister packages already learned the hard lesson: raw loading
  axes are not stable interpretation targets without a rotation or constraint
  policy. `hsquared` should teach invariant G/R/correlation summaries first.
- Classical G-matrix literature motivates future selection-response,
  evolvability, and constraint tools, but those are roadmap targets until the
  estimands, uncertainty, and validation gates exist.

## hsquared action

- Add a short pkgdown article, `Reading G matrices`, that teaches:
  - `G_matrix()` / `genetic_covariance()`;
  - `R_matrix()` / `residual_covariance()`;
  - genetic and residual correlations;
  - per-trait h2 for the current animal + residual model;
  - cross-trait EBVs;
  - why factor loadings and `P_matrix()` remain gated.
- Add the article to the pkgdown article menu after the multivariate article.

## Claim wording risk

High-risk words for this article: "supports", "estimates", "evolvability",
"constraint", "selection response", "factor-analytic", and "production". The
article should use them only with explicit current/future status boundaries.

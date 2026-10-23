# Structured-Covariance Eigenbasis Bridge Contract (R-lane ratification)

Status: **ratified R bridge contract, with a bounded experimental FA opt-in.**
The original contract was ratified on 2026-06-22. A four-trait, rank-one
Gaussian pedigree FA fit is now available through explicit expert control.
This does not establish identifiability, inference, or calibration for every
quantity below and does not promote a covered R-public capability. R formula
grammar remains closed: `cov = fa(K)` is not parsed or fitted.

**Cross-link (2026-09-05):** Julia `V4-FA` is now **engine-covered**
(HSquared.jl `60895208` / #300; validation-scale). That engine row is recorded
in Julia
[`capability-status.md`](https://github.com/itchyshin/HSquared.jl/blob/main/docs/design/capability-status.md)
and
[`12-bridge-compatibility.md`](https://github.com/itchyshin/HSquared.jl/blob/main/docs/design/12-bridge-compatibility.md).
The R `factor-analytic G matrices` row is **partial** for the bounded expert
control only. `hs_validate_genetic_structure_control()` accepts
`"factor_analytic"` only with `rank = 1L` and the four-trait Gaussian pedigree
cell; it still rejects `"lowrank"`. Engine-covered does not imply R-public
coverage; `public_covered_count` stays **7**.

## Purpose

The Julia twin decided a loading rotation/interpretation convention on
`HSquared.jl` `docs/dev-log/decisions/2026-06-19-fa-rotation-convention.md`
("bridge and do inference ONLY on rotation-invariant functionals of `G`; never
bridge raw loadings `Λ`"). That decision was originally gated on joint R-lane
ratification (AGENTS.md rule 2). This file records that historical
acknowledgement and the payload boundary used by the bounded opt-in. It does
not establish general identifiability or serve as broad calibration evidence.
Any wider implementation must satisfy current capability-status and validation
gates.

Cross-lane references: twin `HSquared.jl#42` (engine bridge widening),
`HSquared.jl#37` (FA EM warm-start), `HSquared.jl#61` (joint critical path);
R mirror `hsquared#22`. The rotation-invariant evolvability surface
(`HSquared.jl#55`) is already landed and aligned.

## The identifiability problem (one paragraph)

For `genetic_structure = :lowrank` (`G = ΛΛ′`) or `:factor_analytic`
(`G = ΛΛ′ + Ψ`), `G` is unchanged by `Λ → ΛQ` for orthogonal `K×K` `Q`.
This rotation invariance means that an unconstrained loading matrix is not
uniquely identified; it does not by itself establish local identifiability of
all model parameters. In particular, whether `Ψ` is locally identifiable
depends on the rank, number and structure of traits, constraints, and the data.
Fixed rank alone is not sufficient. A quantity can be locally identifiable
under a specified model and still be poorly estimated or poorly calibrated in
finite samples. The `t = 4`, `K = 1` engine result is bounded validation
evidence for that cell only, not a general identifiability or estimation
guarantee. Do not claim generic identification of `(column-space of Λ, Ψ)`.

## Contract and candidate bridge quantities

The bounded R bridge carries covariance, correlations, heritability, and FA
uniqueness, with a local-identification caveat. Further rotation-invariant
quantities require a specified estimand and their own implementation and
validation checks. The candidate list mirrors the Julia "Exposable" list:

- `genetic_covariance` (`G`), `residual_covariance` (`R`).
- `genetic_correlation`, `residual_correlation`; per-trait `heritability`.
- Per-trait genetic variances `diag(G)` and total genetic variance `tr(G)`.
- Genetic **eigenvalues** (descending), which measure additive genetic
  variance along each principal axis, and the leading eigenpair (`g_max`).
- Genetic **principal axes** (sign-canonicalized eigenvectors of `G`):
  covariance directions when eigenvalues are distinct. At repeated
  eigenvalues only the corresponding eigenspace is unique; these are not
  fitted FA loadings.
- Evolvability family: `evolvability`, `conditional_evolvability`,
  `respondability`, `autonomy`, `mean_evolvability` (already R-surfaced and
  live-verified against the engine `evolvability.jl`).
- `Ψ` (uniquenesses; `:factor_analytic` only, and only if local
  identifiability has been established for the specific model/design; fixed
  rank alone is not that proof).
- Structure metadata for nested-model tests: `genetic_structure`,
  `genetic_rank` (`K`), `n_genetic_params`, `loglik`.
- Standard errors / intervals **only** on identified invariant quantities
  after a separately validated structured-fit information and uncertainty
  path exists. The current observed-information + delta-method path and R
  `covariance_standard_errors()` apply to the unstructured fit; Julia refuses
  structured-fit covariance standard errors.

## Ratified contract: quantities withheld from the bridge

Mirrors the Julia "Withheld" list:

- Raw FA loadings `Λ` as an **identified** estimate. Eigenvectors of the full
  `G` can describe its covariance geometry but do not reconstruct the fitted
  FA loadings because `G` also contains `Ψ`; never bridge that display as FA
  loading estimates or biological axes.
- SEs / CIs / tests on any loading element `Λ[i,k]`.
- SEs / CIs on any individual eigenvector / genetic principal **direction**
  (span-ambiguous under near-degenerate eigenvalues; `genetic_pca` already warns).
- "this factor loads on traits X, Y" interpretive claims as if a factor were
  identified; varimax/oblimin/target-rotated loadings as identified or
  comparator-parity quantities.

## R object / extractor mapping

The bounded structured fit reuses the existing `hsquared_fit` surface. No
loading-bearing extractor is added:

| Quantity | R extractor | Status |
| --- | --- | --- |
| `G`, `R` | `G_matrix()`, `R_matrix()` (aliases over `genetic_covariance`/`residual_covariance`) | live (unstructured/diagonal and bounded FA opt-in) |
| correlations, `h²` | `genetic_correlation()`, `heritability()` | live, including bounded FA opt-in |
| FA uniqueness | `specific_variance()` | live for the bounded FA opt-in; separate identification depends on a regular loading pattern |
| eigenstructure | `eigen_G()` / `genetic_pca`-equivalent, `g_max()` | live (rotation-invariant) |
| evolvability family | `evolvability()` etc. | live, engine-verified |
| invariant SEs | `covariance_standard_errors()` | live for unstructured fits only; structured-fit SEs withheld |
| nested-structure test | `covariance_structure_lrt(constrained, full)` | experimental; FA χ² tail is conditional and uncalibrated |
| raw loadings | `loadings()` | **reserved / display-only, no SE; not a bridged biological axis** |

`G_matrix()`, `R_matrix()`, `genetic_correlation()`, and `heritability()` remain
the first teaching surface; users read covariance/correlation before any axis
interpretation.

## Scope of this contract

This contract describes the invariant R boundary. A bounded four-trait,
rank-one Gaussian FA pedigree cell is available via explicit expert control
and remains experimental. It does not establish broad identifiability,
calibration, or same-model comparator agreement. The R formula parser remains
closed to `cov = fa(K)`; `genetic_structure = "factor_analytic"` is accepted
only for that cell. Wider structured support requires a separate gate.

## Validation gate (no promotion)

This ratification is a **contract**, not evidence. Promotion past `partial`
still requires, per `docs/design/18-structured-covariance-r-control.md` and the
twin gates:

- pinned Julia engine and R bridge revisions for the exact cell;
- signed-off known-truth recovery for the structured fit; the twin's per-seed
  calibration has **not** passed (FA: 8 of 10 scenarios passed; low-rank: 9 of
  10 passed at the last record), so
  the row stays `partial`;
- an external structured-`G` comparator (WOMBAT/ASReml `xfa`, Kirkpatrick & Meyer
  reduced-rank parity);
- R bridge + extractor tests, direct R/Julia parity, and an independent
  same-model Gaussian FA/REML comparison.

Until then: R keeps failing loudly on `genetic_structure = "lowrank"`, on
FA controls outside the bounded cell, and on formula-level
`cov = lowrank()/fa()`.

## Provenance

Mirrors and ratifies `HSquared.jl` decision
`docs/dev-log/decisions/2026-06-19-fa-rotation-convention.md` (Ada, from a
Fisher + Kirkpatrick two-lens proposal; Kirkpatrick & Meyer 2004 *Genetics*
precedent). R-lane ratifying lenses: Boole (grammar), Noether (estimand/notation),
Kirkpatrick (reduced-rank genetic covariance), Fisher (identifiability/SEs),
Hopper (bridge payload), Rose (claim boundary).

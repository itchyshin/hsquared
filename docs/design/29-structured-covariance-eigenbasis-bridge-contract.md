# Structured-Covariance Eigenbasis Bridge Contract (R-lane ratification)

Status: **ratified (R lane), 2026-06-22.** This is the R-lane acknowledgement that
the Julia engine may widen `multivariate_result_payload` to accept
`:lowrank`/`:factor_analytic` fits and expose the eigenbasis + rotation-invariant
functionals below. It does **not** promote any capability: structured
factor-analytic/low-rank fits remain `partial`, and the `cov = lowrank()/fa()`
formula grammar remains planned.

## Purpose

The Julia twin decided the loading rotation/interpretation convention on
`HSquared.jl` `docs/dev-log/decisions/2026-06-19-fa-rotation-convention.md`
("bridge and do inference ONLY on rotation-invariant functionals of `G`; never
bridge raw loadings `Λ`"). That decision is **gated on joint R-lane ratification**
(AGENTS.md rule 2) and the engine change is explicitly **held until the R lane
acks on twin #61/#42**. This file is that ack. It pins the exact payload contract
the R bridge will consume so the two lanes cannot drift when the engine widens
the payload.

Cross-lane references: twin `HSquared.jl#42` (engine bridge widening),
`HSquared.jl#37` (FA EM warm-start), `HSquared.jl#61` (joint critical path);
R mirror `hsquared#22`. The rotation-invariant evolvability surface
(`HSquared.jl#55`) is already landed and aligned.

## The identifiability problem (one paragraph)

For `genetic_structure = :lowrank` (`G = ΛΛ′`) or `:factor_analytic`
(`G = ΛΛ′ + Ψ`), the genetic covariance `G` is invariant under `Λ → ΛQ` for any
orthogonal `K×K` `Q`. The raw loadings `Λ` are therefore rotation-nonidentified:
the likelihood is flat along the rotation orbit, the observed information for the
loading parameters is singular (null space `K(K−1)/2`), and individual loadings
carry **no finite asymptotic standard error**. The identified estimand is `G`
itself (and, for FA, the pair `(column-space of Λ, Ψ)`), not `Λ`.

## Ratified contract — what the bridge MAY carry

The R bridge will consume only rotation-invariant, identified quantities. These
mirror the Julia "Exposable" list exactly:

- `genetic_covariance` (`G`), `residual_covariance` (`R`).
- `genetic_correlation`, `residual_correlation`; per-trait `heritability`.
- Per-trait genetic variances `diag(G)` and total genetic variance `tr(G)`.
- Genetic **eigenvalues** (descending) — additive genetic variance along each
  genetic principal axis — and the leading eigenpair (`g_max`).
- Genetic **principal axes** (sign-canonicalized eigenvectors of `G`) — the
  rotation-invariant "loadings on the principal axes".
- Evolvability family: `evolvability`, `conditional_evolvability`,
  `respondability`, `autonomy`, `mean_evolvability` (already R-surfaced and
  live-verified against the engine `evolvability.jl`).
- `Ψ` (uniquenesses; `:factor_analytic` only — identified given fixed rank `K`).
- Structure metadata for nested-model tests: `genetic_structure`,
  `genetic_rank` (`K`), `n_genetic_params`, `loglik`.
- Standard errors / intervals **only** on the above invariants (`G` elements,
  `h²`, correlations, eigenvalues), via the existing observed-information +
  delta-method path already used for the unstructured fit and already surfaced in
  R by `covariance_standard_errors()`.

## Ratified contract — what the bridge MUST NOT carry

Mirrors the Julia "Withheld" list:

- Raw loadings `Λ` as an **identified** estimate. A rotation-arbitrary
  reconstruction `Λ = U·√Λ_eig` may exist only as an explicitly-flagged,
  point-estimate-only, display/comparator-alignment object — never bridged as
  biological axes.
- SEs / CIs / tests on any loading element `Λ[i,k]`.
- SEs / CIs on any individual eigenvector / genetic principal **direction**
  (span-ambiguous under near-degenerate eigenvalues; `genetic_pca` already warns).
- "this factor loads on traits X, Y" interpretive claims as if a factor were
  identified; varimax/oblimin/target-rotated loadings as identified or
  comparator-parity quantities.

## R object / extractor mapping

When the engine widens the payload, the structured fit reuses the existing
`hsquared_fit` surface — no new loading-bearing extractor is added:

| Quantity | R extractor | Status |
| --- | --- | --- |
| `G`, `R` | `G_matrix()`, `R_matrix()` (aliases over `genetic_covariance`/`residual_covariance`) | live (unstructured/diagonal) |
| correlations, `h²` | `genetic_correlation()`, `heritability()` | live |
| eigenstructure | `eigen_G()` / `genetic_pca`-equivalent, `g_max()` | live (rotation-invariant) |
| evolvability family | `evolvability()` etc. | live, engine-verified |
| invariant SEs | `covariance_standard_errors()` | live, experimental |
| nested-structure test | `covariance_structure_lrt(constrained, full)` | live, experimental |
| raw loadings | `loadings()` | **reserved / display-only, no SE; not a bridged biological axis** |

`G_matrix()`, `R_matrix()`, `genetic_correlation()`, and `heritability()` remain
the first teaching surface; users read covariance/correlation before any axis
interpretation.

## What this unblocks (Julia next step, post-ack)

Per the Julia decision's "Cross-lane" and "Consequences": once this ack is
recorded, the engine may widen `multivariate_result_payload` to **accept**
`:lowrank`/`:factor_analytic` and emit the eigenbasis + invariants + invariant
SEs above (never loadings). The R bridge then adds `genetic_structure`/`rank`
plumbing and the structured-result tests gated in
`docs/design/18-structured-covariance-r-control.md` (rank/initial-value
validation; `G_matrix()` reconstructs `ΛΛ′ (+ Ψ)` from the returned eigenbasis;
rotation/sign metadata present before any display loadings).

## Validation gate (no promotion)

This ratification is a **contract**, not evidence. Promotion past `partial`
still requires, per `docs/design/18-structured-covariance-r-control.md` and the
twin gates:

- the engine payload-widening commits on `HSquared.jl` `main`;
- signed-off known-truth recovery for the structured fit — the twin's per-seed
  calibration has **not** passed (FA ~8/10, low-rank ~9/10 at last record), so
  the row stays `partial`;
- an external structured-`G` comparator (WOMBAT/ASReml `xfa`, Kirkpatrick & Meyer
  reduced-rank parity);
- R bridge + extractor tests on a deterministic fixture.

Until then: R keeps failing loudly on `genetic_structure = "lowrank"/"factor_analytic"`
and on formula-level `cov = lowrank()/fa()`, exactly as today.

## Provenance

Mirrors and ratifies `HSquared.jl` decision
`docs/dev-log/decisions/2026-06-19-fa-rotation-convention.md` (Ada, from a
Fisher + Kirkpatrick two-lens proposal; Kirkpatrick & Meyer 2004 *Genetics*
precedent). R-lane ratifying lenses: Boole (grammar), Noether (estimand/notation),
Kirkpatrick (reduced-rank genetic covariance), Fisher (identifiability/SEs),
Hopper (bridge payload), Rose (claim boundary).

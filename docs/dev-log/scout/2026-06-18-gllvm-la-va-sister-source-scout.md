# Scout: GLLVM Laplace + VA reuse sources (Phase 6)

Date: 2026-06-18
Lens: Jason (landscape scout) · Lane: R / coordinator · Twin: cross-ref read-only

## Purpose

Maintainer directive: the Phase 6 GLLVM models must be fit by **both Laplace
approximation (LA) and variational approximation (VA)** (cf. the `gllvm`
package's `method = "LA"/"VA"`). Per the standing reuse rule, locate the LA + VA
machinery already present in the local sister repos rather than reinventing.

## Findings (read-only `grep`, not yet deep-read)

| Sister repo | Lane | Laplace | VA |
| --- | --- | --- | --- |
| `drmTMB` | R | `R/missing-data.R` (FIML/Laplace) | — |
| `DRM.jl` | Julia | `src/gaussian_ranef.jl`, `src/gaussian_core.jl`, `src/locscale_marginal.jl` | **`src/variational.jl`** (dedicated VA module) |
| `gllvmTMB` | R | `R/gllvmTMB.R`, `R/fit-multi.R` | `R/gllvmTMB.R`, `R/output-methods.R` (VA path) |
| `GLLVM.jl` | Julia | `src/postfit.jl`, `src/structured_schur.jl`, `src/confint_*.jl` | (not surfaced by this grep) |

All four repos exist locally under `~/Dropbox/Github Local/`.

## Reuse map (proposed, for the Julia engine lane)

- **VA** → primary source `DRM.jl/src/variational.jl`; cross-check the
  `gllvmTMB` VA path for the GLLVM-specific lower bound.
- **Laplace** → `gllvmTMB` / `GLLVM.jl` and `drmTMB` / `DRM.jl` (TMB / autodiff
  marginal Laplace over the latent variables).

## Caveats

- Provenance located by filename/grep only; files have **not** been read in
  depth or validated. No code copied.
- The estimator (LA + VA) is **Julia-lane engine work** in `HSquared.jl`; the R
  lane surfaces the `method` / control choice and the validation.
- Phase 6 is **planned** — this scout makes no capability claim. Recorded so the
  twin and future sessions inherit the reuse map. Adapt architecture/process
  patterns and record provenance; do not copy statistical claims without
  independent validation.

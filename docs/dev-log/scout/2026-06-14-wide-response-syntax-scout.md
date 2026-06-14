# Wide-Response Syntax Scout

Date: 2026-06-14

## Question scouted

How should `hsquared` eventually express high-dimensional response matrices
for GLLVM, omics, and community-style models without crowding the current animal
model API or implying current support?

## Sources checked

- `docs/design/02-formula-grammar.md`, `docs/design/01-v0.1-contract.md`,
  `docs/design/13-sparse-multivariate-production-plan.md`, and
  `docs/design/14-factor-analytic-production-plan.md` for current
  `cbind(...)`, long-format `trait`, and factor-analytic boundaries.
- `gllvmTMB/README.md` and `gllvmTMB/vignettes/gllvmTMB.Rmd` for the clearest
  local UX lead: wide `traits(...)` input and long `value ~ ...`, `trait =`,
  `unit =` input reach the same stacked-trait model.
- `gllvmTMB/src/gllvmTMB.cpp` for the local computational pattern:
  stacked-trait rows with per-row family/link vectors and latent covariance
  dispatch.
- `GLLVM.jl/docs/src/response-families.md`, `GLLVM.jl/docs/src/working-with-a-fit.md`,
  and `GLLVM.jl/docs/src/gllvmtmb-parity.md` for the matrix-first Julia pattern
  (`fit_gllvm(Y; family, K, ...)`), ordination/loadings post-fit tools, and the
  honest gap around formula front ends.
- `DRM.jl` / `drmTMB` for the narrower lesson that `cbind()` is familiar for
  small multi-column responses but should not become the high-dimensional GLLVM
  syntax.
- `gllvm` package homepage: <https://jenniniku.github.io/gllvm/>
- `gllvm()` reference: <https://jenniniku.github.io/gllvm/reference/gllvm.html>
- Niku et al. GLLVM count/biomass anchor:
  <https://ideas.repec.org/a/spr/jagbes/v22y2017i4d10.1007_s13253-017-0304-7.html>
- CRAN `gllvm` manual:
  <https://cran.rstudio.com/web/packages/gllvm/gllvm.pdf>

## Relevant lessons

- `traits(...)` is the best future wide-data marker because it names response
  columns without pretending they are fixed-effect terms.
- Current `cbind(...)` should remain the live small Gaussian multivariate bridge,
  not the long-term GLLVM/omics interface.
- Long and wide data should compile to the same internal observed-cell object.
- Missing response cells must be cell-level missingness, not silent unit-level
  deletion.
- Family/link metadata should start simple: one family/link for the matrix, with
  per-trait family support gated later.
- Loadings and ordination need rotation/sign metadata before public biological
  interpretation.

## hsquared action

- Add `docs/design/16-wide-response-syntax-plan.md`.
- Add a Phase 6 pointer from `docs/design/05-roadmap.md`.
- Mark next-50 row 40 done as a design-only slice.

## Claim wording risk

High-risk phrases: "`traits(...)` fits", "GLLVM support", "omics model",
"ordination available", "per-trait families supported", and "wide response
matrices supported". These must remain planned until the parser, bridge, engine,
validation, and public extractors exist.

# Scout: Pedigree Status Diagnostics

Date: 2026-06-13
Question: should `hs_data()` expose pedigree diagnostics before fitting?

## Sources Checked

- Local `drmTMB`, `gllvmTMB`, `DRM.jl`, and `GLLVM.jl` checkouts.
- Project quantgen scout map in `.agents/skills/quantgen-scout/references/`.
- Current `hsquared` v0.1 parser and bridge payload implementation.

## Relevant Lesson

The local sister packages do not provide animal-pedigree code to reuse, but
they consistently make structured relationship and precision inputs visible
before expensive fitting. `GLLVM.jl` and `gllvmTMB` in particular keep sparse
phylogenetic precision inputs, IDs, and status boundaries explicit.

For `hsquared`, the analogous user-facing move is to expose simple pedigree
coverage and parent-link diagnostics in the R data container before promising
pedigree inverse construction or animal-model fitting.

## hsquared Action

- Add `pedigree_status` to `summary(hs_data(...))` and `data_status()`.
- Report counts for pedigree rows, unique IDs, phenotype coverage, pedigree-only
  IDs, founders, known sire/dam links, missing known parents, duplicate IDs,
  self-parent rows, and same-known-parent rows.
- Keep stronger v0.1 parser validation in `model_spec()` and `hsquared()`.

## Claim Risk

Do not describe `pedigree_status` as validation of an animal-model fit,
construction of `Ainv`, or evidence that full pedigree modelling works. Allowed
wording: pedigree diagnostics, pedigree coverage, parent-link counts, and
pre-fitting data checks.

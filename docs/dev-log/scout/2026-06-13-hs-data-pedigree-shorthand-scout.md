# Scout Note: hs_data Pedigree Shorthand

Date: 2026-06-13
Lane: R
Active lenses: Jason, Boole, Noether, Emmy, Pat, Rose
Spawned subagents: none

## Question

Should the v0.1 R formula parser allow `animal(1 | id)` to use a pedigree
stored in `data = hs_data(..., pedigree = ped)`?

## Sources Checked

- `gllvmTMB/CONTRIBUTING.md`: user-facing long and wide formula shapes should
  reach the same internal engine path.
- `gllvmTMB/vignettes/gllvmTMB.Rmd`: long and wide examples are documented as
  the same model after internal conversion.
- `DRM.jl/AGENTS.md`: R and Julia formula parity should include supported
  syntax and reserved-syntax rejections.
- `DRM.jl/ROADMAP.md`: the R-side bridge owns user ergonomics while Julia owns
  the engine.
- `GLLVM.jl/CLAUDE.md`: one concern per commit and verify before claiming.

## Lesson

The sister packages support a split where the public R surface can offer a
friendlier data-shape-specific spelling, as long as it resolves to the same
internal model contract and public docs clearly name the boundary. For
`hsquared`, the explicit spelling `animal(1 | id, pedigree = ped)` remains the
portable R-Julia contract. The shorthand `animal(1 | id)` is acceptable only
when `data` is an `hs_data()` bundle with a pedigree component.

## hsquared Action

- Keep `animal(1 | id, pedigree = ped)` as the canonical explicit syntax.
- Add the bundle shorthand `animal(1 | id)` for `data = hs_data(..., pedigree =
  ped)`.
- Preserve the same bridge payload shape: `y`, `X`, sparse `Z`, normalized
  pedigree metadata, and Julia target metadata.
- Error clearly when neither a formula pedigree nor an `hs_data()` pedigree is
  available.

## Claim Risk

Low if wording stays precise. The shorthand is parser/data-container ergonomics
only. It does not add animal-model fitting, Ainv construction, genomic fitting,
or QTL/eQTL support.

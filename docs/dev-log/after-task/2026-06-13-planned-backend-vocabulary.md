# Planned Backend Vocabulary

Date: 2026-06-13

Active lenses: Lovelace, Karpinski, Grace, Rose, Pat.

Spawned subagents: none.

## Scope

Expand the R control vocabulary so future CPU/GPU backend choices can be
recorded consistently with the design plan. This is control metadata only. No
backend execution path is implemented in this slice.

## Implementation

Changed `hs_control()`:

- `backend`: `auto`, `cpu`, `threads`, `cuda`, `amdgpu`, `metal`, `oneapi`;
- `accelerator`: `auto`, `none`, `gpu`, `cuda`, `amdgpu`, `metal`, `oneapi`.

Updated:

- phase-0 control tests;
- `hs_control()` Rd;
- NEWS;
- public claims register;
- capability status;
- validation debt;
- model-status article.

## Validation

Local checks:

- `air format .`: completed.
- `Rscript -e "devtools::document()"`: regenerated `man/hs_control.Rd`.
- `Rscript -e "devtools::test(filter = 'phase0-api')"`: `27 pass`,
  `0 fail`, `0 warnings`, `0 skips`.
- `Rscript -e "devtools::test()"`: `143 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live bridge activated sibling `HSquared.jl`.
- `git diff --check`: clean.
- `Rscript -e "pkgdown::check_pkgdown()"`: `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors | 0 warnings | 0 notes`.

Remote checks:

- R-CMD-check `27457948686`: passed on commit
  `5feac1f Expand planned backend controls`.
- pkgdown `27457948693`: passed on commit
  `5feac1f Expand planned backend controls`.
- GitHub Pages build and deployment `27457985141`: passed.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- `hs_control()` stores planned backend and accelerator names;
- planned vocabulary includes CPU threads, CUDA, AMDGPU, Metal, and oneAPI.

Blocked wording:

- GPU execution works;
- Metal, CUDA, AMDGPU, or oneAPI backends are available;
- backend benchmarking exists;
- CPU/GPU numerical agreement has been tested.

## Next Work

1. Have the Julia lane mirror backend names in `HSControl` and future backend
   types.
2. Add backend availability diagnostics before any user-facing execution path.
3. Add CPU/GPU comparison tests only after a real accelerator path exists.

## Coordination

Julia twin thread `019ebb88-ee69-7be2-850c-0e4840c34734` was handed the exact R
backend vocabulary and the Rose guardrail: vocabulary only, no backend
execution claim.

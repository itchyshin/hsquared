# GPU And Algorithm Scout

Date: 2026-06-13

Active lenses: Jason, Gauss, Karpinski, Grace, Rose.

Spawned subagents: none.

## Scope

Record source-backed backend and algorithm leads for later `HSquared.jl` engine
work. No implementation or public performance claim is made.

## Sources

Primary or official sources checked:

- CUDA.jl documentation;
- AMDGPU.jl documentation;
- Metal.jl documentation;
- oneAPI.jl backend documentation and repository;
- KernelAbstractions.jl documentation and repository;
- JuliaGPU learning page;
- Takahashi selected inverse source page;
- sparseinv CRAN manual;
- APY genomic inverse PubMed and Interbull pages;
- sparse AI-REML and augmented AI-REML papers.

## Implementation

Added `docs/dev-log/scout/2026-06-13-gpu-algorithm-scout.md`.

## Validation

Local checks:

- `git diff --check`: clean.

Remote checks:

- Pending first push for this scout slice.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- these are backend and algorithm leads;
- CPU is still the trusted baseline;
- GPU and algorithm choices require later implementation and validation.

Blocked wording:

- any GPU backend runs today;
- APY, selected inverse, or AI-REML is implemented in the package;
- any speedup or ASReml-level performance is supported by this scout.

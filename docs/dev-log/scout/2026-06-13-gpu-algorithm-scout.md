# GPU And Algorithm Scout

Date: 2026-06-13

Active lenses: Jason, Gauss, Karpinski, Grace, Rose.

Spawned subagents: none.

## Purpose

Record source-backed ideas for later `HSquared.jl` engine work. This is not an
implementation plan and does not support public performance claims.

## Backend Sources Checked

- [CUDA.jl documentation](https://cuda.juliagpu.org/stable/): NVIDIA GPU
  programming in Julia, from array programming to lower-level CUDA kernels.
- [AMDGPU.jl documentation](https://amdgpu.juliagpu.org/): AMD/ROCm GPU
  programming in Julia.
- [Metal.jl documentation](https://metal.juliagpu.org/stable/): macOS GPU
  programming in Julia.
- [oneAPI.jl backend page](https://juliagpu.org/backends/oneapi/): Julia
  interface to Intel oneAPI accelerators; source describes the package as
  early development.
- [oneAPI.jl repository](https://github.com/JuliaGPU/oneAPI.jl): notes Linux
  support and Julia version requirements.
- [KernelAbstractions.jl documentation](https://juliagpu.github.io/KernelAbstractions.jl/):
  vendor-neutral kernel programming over Julia GPU backends.
- [KernelAbstractions.jl repository](https://github.com/JuliaGPU/KernelAbstractions.jl):
  lists supported backends including NVIDIA CUDA, AMD ROCm, Intel oneAPI, and
  Apple Metal.
- [JuliaGPU learning page](https://juliagpu.org/learn/): describes the CUDA
  stack as the most mature Julia GPU stack.

## Backend Lessons For HSquared.jl

- CPU remains the trusted baseline and validation reference.
- CUDA should be first production-HPC target when GPU work becomes real.
- Metal matters for local Mac development, but should start with small
  validation and smoke tests.
- AMDGPU matters for ROCm clusters, but should be optional and tested on real
  hardware.
- oneAPI should stay experimental until the team has a reliable Linux/Intel
  test surface.
- KernelAbstractions-style kernels are attractive for custom repeated kernels,
  but vendor BLAS/sparse libraries and ordinary Julia array dispatch should be
  used where they are already stronger.

## Algorithm Sources Checked

- [Takahashi et al. selected inverse, ACM DOI](https://dl.acm.org/doi/10.1145/360680.360704):
  classic selected-inverse idea for computing selected elements of a sparse
  matrix inverse from factors.
- [sparseinv CRAN manual](https://cran.r-project.org/web/packages/sparseinv/sparseinv.pdf):
  current R package manual describing SuiteSparse/Takahashi-equation sparse
  inverse subset computation.
- [APY inverse PubMed entry](https://pubmed.ncbi.nlm.nih.gov/26584903/):
  inexpensive inversion of genomic relationship matrices for many genotyped
  individuals.
- [APY Interbull article](https://journal.interbull.org/index.php/ib/article/view/1602):
  APY for genomic relationship inverse in single-step genomic BLUP.
- [Johnson and Thompson sparse AI-REML paper](https://www.journalofdairyscience.org/article/S0022-0302%2895%2976654-1/fulltext):
  REML variance-component estimation for a univariate animal model using sparse
  matrix techniques.
- [Augmented AI-REML paper](https://pmc.ncbi.nlm.nih.gov/articles/PMC11580194/):
  newer work on reducing REML iteration cost with iterative solvers.

## Algorithm Lessons For HSquared.jl

- Phase 1 should privilege sparse mixed-model equations, AI-REML/REML
  likelihood clarity, and tiny/Mrode validation before accelerators.
- Takahashi-style selected inverse is a serious candidate for PEV/reliability
  and uncertainty extraction after sparse factorization exists.
- APY belongs in the genomic/single-step roadmap, not v0.1, and needs careful
  core/noncore validation before public claims.
- Iterative solver and augmented-AI ideas are promising for huge systems, but
  should enter after direct sparse reference fits exist.
- GPU work should begin with dense marker/factor/GLLVM operations and backend
  agreement tests, not irregular pedigree sorting or symbolic sparse
  factorization.

## Claim Boundary

This scout supports research direction only. It does not show that `hsquared`
or `HSquared.jl` implements CUDA, Metal, AMDGPU, oneAPI, KernelAbstractions,
Takahashi selected inverse, APY, or AI-REML.

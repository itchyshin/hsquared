# Engine-scaling prototypes (cross-lane research, R lane → HSquared.jl)

**Status: research prototypes, not package code.** These are standalone Julia
scripts written from the R lane to *hand the Julia engine thread benchmarked,
validated starting points* for the matrix-free / GPU scaling stack (HSquared.jl
issues [#51](https://github.com/itchyshin/HSquared.jl/issues/51),
[#58](https://github.com/itchyshin/HSquared.jl/issues/58)). They do **not** ship
in the `hsquared` R package and are not part of any public claim. Run them with a
local Julia (validated on 1.10.0); the GPU script needs `Metal.jl` in a project
environment.

The goal is to answer the four asks on the engine side — *a new algorithm, a
working algorithm, a speedy algorithm, and GPU control* — for the regimes where
the existing engine path runs out of room, while being explicit about the regime
where the existing path is already optimal.

## The regime map (the key strategic finding)

Matrix-free / iterative methods are **not** a universal win. Which tool wins
depends entirely on the structure of the coefficient matrix `C`:

| Regime | Structure | Winning method | Evidence |
| --- | --- | --- | --- |
| **Sparse pedigree** animal model | `A⁻¹` sparse, modest fill-in | **Direct sparse CHOLMOD** (already in `fit_ai_reml`) | `matrix-free-pedigree-pcg.jl`: matrix-free PCG = 64.5 s vs CHOLMOD factorize 0.04 s at n=5000. PCG is the *wrong* tool here. |
| **Dense genomic G** (`G = WW'/m`) | low rank `m < n`, dense `n×n` if formed | **Low-rank exact AI-REML** (matrix-determinant-lemma + Woodbury) | `matrix-free-genomic-reml.jl`: full REML at n=80 000 in ~8 s; dense `G` would be 51 GB. |
| **Huge `m` and huge `n`** | neither dimension small | PCG solve + **stochastic-Lanczos-quadrature logdet** (MC-REML) | `matrix-free-genomic-reml.jl` SLQ demo: logdet rel-err 2.8e-3 at nv=24. |
| **GEMM-heavy inner loops** | dense marker products `W(W'B)` | **GPU offload** (validated, narrow blocks) | `gpu-vapply-bench.jl`: 3.4×–10.7× on Metal — see precision caveat. |

The headline correction to issue #51's sequence: *don't put a matrix-free PCG MME
solver in front of the sparse-pedigree path* — `fit_ai_reml` (sparse Henderson MME
+ CHOLMOD + Takahashi selected inverse) is already the right, exact, fast answer
there. The matrix-free/low-rank/GPU stack earns its keep in the **dense-G genomic,
single-step H, and huge-n** regimes, not in the classic sparse animal model.

## 1. Exact low-rank AI-REML for the genomic regime — `matrix-free-genomic-reml.jl`

Model `y = Xβ + g + e`, `g ~ N(0, va·G)`, `G = Wt·Wt'` with `Wt` the centred/scaled
markers `/ √m` (so `diag(G) ≈ 1` and `va` is on the trait scale),
`V = ve·I + va·Wt·Wt'`. Two classical identities make the **entire** REML objective,
the analytic AI-REML gradient, and the average-information matrix exact and cheap
*without ever forming or factoring the n×n `V` or `G`*:

- **matrix determinant lemma:** `logdet(V) = n·log(ve) + logdet(K)`,
  `K = I_m + (va/ve)·S`, `S = Wt'Wt` (m×m).
- **Woodbury:** `V⁻¹B = (1/ve)·(B − (va/ve)·Wt·(K⁻¹·(Wt'B)))`.

Every AI-REML trace term reduces to an m×m or p×p trace (exact — no stochastic
trace needed while `m` is moderate). One-time setup is `S = Wt'Wt`, O(n·m²); each
AI-REML iteration is O(m³ + n·m) — **linear in n**.

Validated results (seeded):

```
(a) exactness vs a dense reference, at fixed (va, ve):
    -2logL  matfree = 680.16425367   dense = 680.16425367   abs_err = 2.27e-13
    analytic AI score == central finite-difference of -2logL (all printed digits)

(b) known-truth VC recovery + timing (truth va=0.60 ve=1.00 h²=0.375):
    n=2000   m=1000   va_hat=0.599 ve_hat=1.092 h2=0.354   setup 0.04s  solve 0.46s  (6 it)
    n=8000   m=1500   va_hat=0.581 ve_hat=0.982 h2=0.372   setup 0.15s  solve 0.83s  (6 it)
    n=30000  m=2000   va_hat=0.609 ve_hat=0.994 h2=0.380   setup 0.72s  solve 2.98s  (6 it)   [dense G = 7.2 GB skipped]
    n=80000  m=3000   va_hat=0.575 ve_hat=1.000 h2=0.365   setup 2.80s  solve 5.02s  (6 it)   [dense G = 51.2 GB skipped]

(d) SLQ logdet(K) vs exact (the bridge to the huge-m regime):
    exact = 1595.71   SLQ(nv=24, L=30) = 1600.17   rel_err = 2.80e-03
```

AI-REML converges in 6 iterations; recovery is within sampling error of truth at
every size. The dense path is infeasible by n=80 000 (51 GB `G`); the low-rank path
fits it in ~8 s. **`fit_ai_reml` is the exact reference** the genomic low-rank
estimate should be validated against on a shared fixture (the math is identical;
only the linear algebra differs).

## 2. GPU control on Metal — `gpu-vapply-bench.jl`, `gpu-precision-check.jl`

The dominant kernel of every matrix-free iteration is `u = W·(W'B)` — pure
GEMV/GEMM against the n×m marker panel, the natural GPU offload target (same
`KernelAbstractions` / `GPUArrays` pattern maps CUDA/AMDGPU/oneAPI). On this Mac's
Metal GPU vs CPU BLAS (Float32):

```
n=100000 m=3000 k=1    speedup 3.36x   rel_err 8.9e-7     (GEMV, exact)
n=100000 m=3000 k=8    speedup 3.89x   rel_err 7.6e-7     (narrow GEMM, exact)
n=100000 m=3000 k=32   speedup 7.68x   rel_err 3.0e-2     (!! see below)
n=100000 m=3000 k=64   speedup 6.92x   rel_err 3.1e-2     (!!)
k=32, scaling n: 4.5x (n=20k) → 10.7x (n=200k)
```

**Precision landmine (verified against a Float64 ground truth):** at wide blocks
`k ≥ 32`, Metal silently dispatches a *reduced-precision* GEMM path. CPU-Float32
stays accurate to 5.6e-7 for all `k`; Metal-Float32 is accurate (5.2e-7) at `k=8`
but jumps to **3.0e-2** at `k ≥ 32` — i.e. ~2 lost digits, unacceptable for REML.
The trigger is the block width `k`, not the reduction depth `n`, so it is a kernel
dispatch effect, not Float32 accumulation.

Implication for wiring up the engine's `MetalBackend`/`CUDABackend` tags:
**CPU correctness first, GPU validated.** Keep GPU blocks narrow (`k ≤ 8`), or
force the accurate GEMM path / accumulate in higher precision, and *always* check
GPU output against a CPU-Float64 result on a reduced size before trusting it.
Float64 is not available on Apple GPUs at all, which sharpens the point.

## 3. Symbolic-once Cholesky for the sparse AI-REML loop — `symbolic-once-cholesky.jl`

A free, exact speedup to the engine's *existing* sparse path. `fit_ai_reml`
(`likelihood.jl:378-381`) calls a full `cholesky(Symmetric(lhs); check=true)`
**inside** the AI iteration loop, but the MME sparsity pattern is invariant across
iterations (only the `1/ve`, `1/va` scalings change values). Factoring symbolically
once and using `cholesky!(F, lhs_k)` (numeric refactor only) thereafter gives:

```
q=5000    nnz(Ainv)=31978    solve rel-err(reuse vs fresh)=0.00   fresh 0.294s  symbolic-once 0.115s  2.55x
q=20000   nnz(Ainv)=127884   solve rel-err=0.00                   fresh 1.396s  symbolic-once 0.977s  1.43x
q=50000   nnz(Ainv)=319726   solve rel-err=0.00                   fresh 4.721s  symbolic-once 3.254s  1.45x
q=100000  nnz(Ainv)=639430   solve rel-err=0.00                   fresh 11.878s symbolic-once 7.651s  1.55x
```

Solves are **bit-identical** (rel-err exactly 0.0). The speedup is **1.43–2.55×
(2.55× at q=5k, settling to ~1.4–1.6× for q≥20k); flat-to-declining in q, not
widening** — honest reading: symbolic analysis is a ~constant fraction of each
CHOLMOD factorize, so this is a real constant-factor win, not an asymptotic one.
Worth taking (free, correctness-preserving), but not the "speedy algorithm"
headline. Adjacent hardening items in the same loop:

- **[R-lane-verified by reading source]** `likelihood.jl:381` has **no `try/catch`
  around the factorization** (unlike the dense path) → a near-boundary non-PD
  overshoot throws an uncaught `PosDefException`.
- **[design-pass lead]** the σ²ₐ→0 score arithmetic at `:389` has the *shape*
  (`1/σ²ₐ²` prefactor × a difference of terms — confirmed by reading the line);
  the *claim* that it catastrophically cancels as σ²ₐ→0 is a numerical-behavior
  inference from the design pass, to confirm with a near-boundary run.

The non-inbred Henderson `A⁻¹` is built directly in O(q) here because the engine's
own `pedigree_inverse` reaches a **dense** numerator-relationship helper
(`inbreeding_coefficients` → `_numerator_relationship`) capped at 10 000 rows
(`pedigree.jl:106-109`, validation-only), so it throws above that — itself a
sparse-`A⁻¹` construction gap worth a separate engine slice.

See `engine-scaling-plan.md` for the full adversarially-verified staged plan
(Stage A symbolic-once + selinv, Stage B low-rank Woodbury + matrix-free PCG +
stochastic fallback, Stage C GPU), with the repo-grounded risk register.

## Files

- `matrix-free-genomic-reml.jl` — exact low-rank AI-REML + dense validation + known-truth recovery + SLQ logdet demo. Deps: stdlib only.
- `matrix-free-genomic-gls.jl` — the earlier GLS-only proof (matrix-free V⁻¹ via PCG vs dense Cholesky; 12.2× at n=12k, exact to 2.7e-13).
- `matrix-free-pedigree-pcg.jl` — the sparse-pedigree PCG experiment that established direct CHOLMOD wins that regime (needs `HSquared` on the load path).
- `gpu-vapply-bench.jl` — Metal vs CPU for `W(W'B)`, GEMV and GEMM. Deps: `Metal`, in a project env.
- `gpu-precision-check.jl` — CPU-f32 vs Metal-f32 vs Float64 ground truth (the k≥32 diagnosis).
- `symbolic-once-cholesky.jl` — symbolic-once `cholesky!` vs fresh `cholesky` in the AI-REML loop, on a real pedigree-structured sparse `A⁻¹`. Deps: stdlib only.
- `engine-scaling-plan.md` — the adversarially-verified staged engineering plan (provenance + risk register + division of labour) feeding HSquared.jl #51/#58.

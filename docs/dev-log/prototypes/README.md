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

## 4. APY sparse genomic inverse — `apy-sparse-ginv.jl`

A genuine **first open-Julia APY** (Algorithm for Proven and Young; scout-confirmed
no open implementation exists — verified locally for JWAS, plus a General-registry
name sweep; re-confirm before any public first-implementation claim). APY removes
the dense-G fill-in cliff that the matrix-free / low-rank work and the design pass
both flagged: it approximates `G⁻¹` by a **sparse** matrix whose non-core block is
**diagonal** (`Pocrnic et al. 2016`), so `nnz ~ c² + 2cn + n` vs `(c+n)²` dense.

**Scope:** the sparse `G⁻¹` recursion + its core-sizing only. GBLUP-only; the
single-step `H⁻¹ = A⁻¹ + scatter(G_APY⁻¹ − A22⁻¹)` and the `(1−w)G + w·A22` SPD
blend live in the twin (`genomic.jl`) and are **not** exercised here.

This prototype was hardened after a 4-lens adversarial verification panel
(`wgztxoz8y`) — the panel independently confirmed the core block-inverse math to
`2.7e-16` (signs, broadcasts, Schur all correct) but showed the *first* draft's
validation was weak/flattering. The shipped version closes every finding:

```
(i) SHARP correctness (c<n, SCATTERED core — the real proof; c=n alone is a tautology
    that cannot catch sign/permutation/misalignment bugs):
    ||G_APY^-1 - inv(Sigma_APY)||/||.|| = 3.41e-15   (core=20, non=40)
    ||G_APY^-1 * Sigma - I|| = 5.6e-15 ;  symmetry 7.6e-15
    nn=1 exactness vs (G+lambda I)^-1 = 4.3e-15   (certifies the non-core ridge path)
    floor guard active (66 Mnn floored at ridge 1e-12) ;  marker-built==dense-built = 2.9e-16

(ii) recovery, BOTH an optimistic clean-rank GRM AND a realistic VanRaden GRM
     (fidelity-to-full = cor(EBV_APY, EBV_fullG), NOT accuracy; accuracy-vs-true is separate):
   lowrank(d=250)  EIG98 core=234 (12% of n)   fidelity 0.978 [seed 0.978-0.992]  acc-vs-true 0.930  nnz/dense 0.22
   vanraden        EIG98 core=1173 (59% of n)  fidelity 0.9995                     acc-vs-true 0.733  nnz/dense 0.83
   -> APY's sparsity win REQUIRES genomic dimension << n. On realistic markers at n=2000 the
      effective dimension is ~60% of n, so APY barely compresses; the win is asymptotic in n/Ne.

(iii) under-rank failure mode (read via the vs-full drop, not the cross-seed number alone):
     EIG98 core=234 fidelity 0.985 ; tiny core=39 fidelity 0.805  (cross-seed cor is the under-ranking signature)

(iv) randomized-SVD core sizing (never forms G): rSVD EIG98 == dense-eig EIG98 exactly
     (lowrank 234==234 ; vanraden 1173==1173)

(v) APY marker-based build at scale (G never formed; core from rSVD):
   n=10000  core=381  nnz/dense=0.075  build 0.43s
   n=40000  core=571  nnz/dense=0.028  build 3.22s   [dense G^-1 = 12.8 GB skipped]
   n=100000 core=761  nnz/dense=0.015  build 11.72s  [dense G^-1 = 80.0 GB skipped]
```

Build cost is `O(c·m·n + c²·n + c³)` — the marker product `Gcn=Wc·Wn'/m` dominates.
**Validation debt:** real-marker (LD/MAF/pedigree-relatedness) recovery and a BLUPF90
comparator-parity run are not done; the recovery target here is a controlled GRM.

## 5. Meuwissen-Luo O(n) sparse inbreeding — `meuwissen-luo-inbreeding.jl`

The **>10,000-pedigree unlock.** The engine's `pedigree_inverse` routes the
inbreeding vector `F` through `_numerator_relationship` — a **dense n×n** recursion
hard-capped at 10,000 animals (`pedigree.jl:106-109`) — so **no pedigree above 10k
can build A⁻¹ today**. This computes the full `F` via the `A = L D L'` decomposition
(`a_ii = Σ_k L_ik²·d_k`, the i-th row of `L` propagated up the ancestors of `i`,
ordered by a tiny stdlib max-heap), never forming the dense A.

```
correctness vs an INDEPENDENT dense tabular A (textbook recursion, engine-free):
  n=500  both-parents          max|F_ML - F_dense| = 0.00e+00
  n=2000 both-parents          max|F_ML - F_dense| = 0.00e+00
  n=1500 inbred (sib-mating)   max|F_ML - F_dense| = 0.00e+00   (max F = 0.5000)
  n=2000 35% one-parent-known  max|F_ML - F_dense| = 0.00e+00
scale (dense path throws > 10,000; ~12-generation pedigree):
  n=20000  0.48s   n=50000 1.53s   n=100000 3.48s   n=250000 9.86s
```

**Bit-exact** against an independent dense tabular A across both-parents, full-sib
inbreeding, and one-parent-known pedigrees (the dense tabular is a different
algorithm, so the `0.0` match is the verification). Hand-off to the twin: replace the
dense-F bottleneck in `pedigree_inverse` with this, removing the 10k cap. Cost scales
with total ancestor count (shallow / many-founder real pedigrees are fast; deeply
interconnected synthetic ones are slower — as with any Meuwissen-Luo).

## 6. Symbolic-once `fit_ai_reml` — `symbolic-once-fit_ai_reml.patch.md`

The ready-to-apply #58 PR seed (diff + parity test) for the symbolic-once `cholesky!`
refactor benchmarked in §3. Twin's lane to apply; not applied from here.

## 7. Batched CPU mixed-model marker scan — `batched-marker-scan.jl`

An **exact**, drop-in speedup for the engine's post-fit marker scan
(`_mixed_marker_scan_stats`, `genomic.jl:627`). The GLS cache is already built
once; the only remaining cost is a per-marker `cholV \ w_j` (an O(n²) BLAS-2
triangular solve, **per marker**). Replacing the marker loop with one BLAS-3
solve over the whole centered marker matrix `W` — `Vinv_W = cholV \ W`, then
`PW`, `denom = colsum(W .* PW)`, `alpha = (Wᵀ Py) ./ denom` — is the *same
arithmetic, column for column*:

```
n=2000  p=3  m=20000   max|d effects|=2.9e-16  max|d se|=5.6e-17  max|d chisq|=3.6e-14
per-marker loop = 38.19s    batched = 0.82s    => 46.8x   (EXACT, not an approximation)
```

The diffs are machine-precision (BLAS reassociation only), so the batched kernel
is **element-wise equivalent** to the per-marker loop that mirrors the engine.
It is a drop-in for `_mixed_marker_scan_stats` and composes with LOCO (batch per
group cache via `cache_for_marker(j)`, then concatenate). This is the CPU
reference that gates the GPU marker-scan work (#51): ~47× on CPU alone, exact,
before any GPU. Twin's lane to apply; not applied from here. Dense
validation-scale; not a sparse production scan or a calibrated-significance claim
(that is #48).

## 8. AI-REML convergence/robustness hardening — `ai-reml-hardening.jl`

Two gaps in the engine's AI-REML loop (`likelihood.jl:356-420`), with a faithful
dense mirror that reproduces them + a verified fix:

- **No PD guard (`likelihood.jl:381`).** `cholesky(Symmetric(lhs); check = true)`
  throws a bare `PosDefException` (LAPACK stacktrace) mid-iteration when the
  mixed-model `lhs` is not positive-definite — the common real cause being a
  **rank-deficient / collinear fixed-effect design X** (the `X'X/σ²ₑ` block is
  then singular). The prototype's guarded factorization (`cholesky(…; check =
  false)` + `issuccess` + a rank test) turns it into a clear, actionable error:
  *"the fixed-effect design X is rank-deficient (rank 2 < 3 columns) — drop
  collinear/aliased terms."*
- **σ²ₐ→0 step instability.** `score_a` and the AI information scale with
  `1/σ²ₐ²` / `1/σ²ₐ`, so the Newton step is numerically delicate near the
  boundary; the step-halving (`:407-413`) guards positivity but not the
  factorization. The fix composes a guarded factor with step-halving.

```
well-posed:  raw == guarded to 0.00e+00 (non-regressive)
collinear X: raw -> cryptic PosDefException ; guarded -> clear rank-deficient error
recovery over 20 seeds: mean sa2=0.652 (truth 0.6), se2=0.930 (truth 1.0), 20/20 conv
```

The dense loop mirrors `likelihood.jl` line-for-line (lhs / score / AI-information
/ step-halving) and recovers the truth on average, so the guard maps straight onto
the engine's sparse loop. Twin's lane to apply (#58).

## Files

- `matrix-free-genomic-reml.jl` — exact low-rank AI-REML + dense validation + known-truth recovery + SLQ logdet demo. Deps: stdlib only.
- `matrix-free-genomic-gls.jl` — the earlier GLS-only proof (matrix-free V⁻¹ via PCG vs dense Cholesky; 12.2× at n=12k, exact to 2.7e-13).
- `matrix-free-pedigree-pcg.jl` — the sparse-pedigree PCG experiment that established direct CHOLMOD wins that regime (needs `HSquared` on the load path).
- `gpu-vapply-bench.jl` — Metal vs CPU for `W(W'B)`, GEMV and GEMM. Deps: `Metal`, in a project env.
- `gpu-precision-check.jl` — CPU-f32 vs Metal-f32 vs Float64 ground truth (the k≥32 diagnosis).
- `symbolic-once-cholesky.jl` — symbolic-once `cholesky!` vs fresh `cholesky` in the AI-REML loop, on a real pedigree-structured sparse `A⁻¹`. Deps: stdlib only.
- `engine-scaling-plan.md` — the adversarially-verified staged engineering plan (provenance + risk register + division of labour) feeding HSquared.jl #51/#58.
- `apy-sparse-ginv.jl` — first open-Julia APY sparse genomic inverse: sharp c<n correctness, dual-GRM honest recovery, randomized-SVD core sizing, large-n build. Deps: LinearAlgebra + SparseArrays. (Scout note: `../scout/2026-06-20-apy-sparse-ginv-scout.md`.)
- `meuwissen-luo-inbreeding.jl` — Meuwissen-Luo O(n) sparse inbreeding (the >10k-pedigree A⁻¹ unlock); bit-exact vs dense tabular, n=250k in ~10s. Deps: stdlib only.
- `symbolic-once-fit_ai_reml.patch.md` — ready-to-apply #58 PR seed (diff + parity test) for the symbolic-once `cholesky!` refactor.
- `batched-marker-scan.jl` — exact drop-in speedup for the post-fit marker scan (`_mixed_marker_scan_stats`): one BLAS-3 `cholV \ W` vs the per-marker BLAS-2 loop; element-wise equivalent (≤3e-14), 46.8× at n=2000/m=20000. The CPU reference that gates the GPU marker scan (#51/#48). Deps: stdlib only.
- `ai-reml-hardening.jl` — faithful dense AI-REML mirror demonstrating the engine's unguarded `cholesky(check=true)` (`likelihood.jl:381`) crypto-failing on rank-deficient X + a guarded fix (clear error); non-regressive (raw==guarded to 0.0), recovers truth over 20 seeds (0.652/0.930). Deps: stdlib only. Twin's lane to apply (#58).

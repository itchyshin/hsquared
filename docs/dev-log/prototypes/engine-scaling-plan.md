# Engine scaling plan (design pass, adversarially verified)

> Provenance: a 9-agent design + adversarial-verification workflow run from the R
> lane (Ada/Gauss/Karpinski/Fisher lenses), reading the live HSquared.jl source and
> running the matrix-free prototypes in this directory. Subagent claims with
> file:line are leads to confirm, not established fact; the R-lane-verified items
> are called out in the cross-lane comments on HSquared.jl #51/#58. Verbatim plan
> below.

Everything is grounded against live source and a live Julia probe. Here is the plan.

---

# HSquared.jl Engine Scaling Plan — Exact, Fast REML + Real GPU Control

**Status:** design + live-verified prototype evidence. R-lane (Ada/Gauss/Karpinski lenses) authored this against `HSquared.jl` working tree; twin (`julia/s4-mv-coldstart`) owns the merge. This is a PR proposal, not a merge — coordinate, do not collide.

**One-line thesis (corrected by the verify stage):** This *hardens and scales an estimator that already exists and is already exact* (`fit_ai_reml` + `selinv_trace_against`). It is a **SUPERSEDE**, not a new estimator. The dense O(n³) path stays as the validation reference; the sparse AI-REML path becomes the default; matrix-free + GPU are scoped to the *narrow* regimes where they actually pay.

**Live-verified facts (this build, Julia 1.10, `--project=HSquared.jl`):**
- `cholesky!(F, Symmetric(lhs2))` in-place refactor reproduces dense truth to **rel-resid 2.1e-16**; `nnz(L)` is **invariant** across variance changes. → Stage A's load-bearing claim holds.
- CHOLMOD factor type on this build is `Factor{Float64, Int64}` → annotate **loosely** as `Factor{Float64}` (do not pin the index type).
- `selinv_trace_against` already computes the exact AI trace term `tr(A⁻¹·Cᵘᵘ)`; no stochastic estimator is in the current Gaussian univariate path, so **there is no variance-component gradient bias today**.

---

## 1. The Staged Plan

### Stage A — Exact sparse AI-REML via symbolic-once Cholesky + Takahashi selinv (the working+correct replacement for the dense path)

**Algorithm.** Assemble the Henderson MME `C` once with `_sparse_mme_system` (`likelihood.jl:1500`); **symbolic-factor once** on iteration 1 (`F = cholesky(Symmetric(lhs))`), then **`cholesky!(F, Symmetric(lhs_k))`** for every subsequent AI iteration (numeric refactor only — the union pattern of `Z'Z` and `Ainv` is invariant; only the `1/σ²ₑ`, `1/σ²ₐ` scalings change values). Score trace term `tr(A⁻¹·Cᵘᵘ)` comes **exactly** from `selinv_trace_against(F, Ainv, nfixed)` (`takahashi_selinv.jl:168`) — no stochastic trace. AI matrix from the two `_reml_project` re-solves (`likelihood.jl:441`), reusing `F`.

**Exact Julia packages.** `SparseArrays` + SuiteSparse CHOLMOD (already the only sparse dep; AMD ordering built in). **No new dependency.** The selinv is already in-repo.

**Complexity.** Symbolic analysis once: amortized to zero. Per iteration: one CHOLMOD numeric refactor `O(nnz(L))` + one selinv back-recursion `O(nnz(L))` + two triangular re-solves `O(nnz(L))`. **Near-linear in `nnz(L)` for pedigree Ainv** (measured fill ratio ~0.65 at q=50k in the verify stage). **Hard scope boundary (R7):** this is pedigree-only — a dense genomic Ginv / single-step H⁻¹ makes `nnz(L)/dense → 1.00`, so the factor silently becomes `O(q³)`. State this boundary explicitly.

**Correctness gate vs dense evaluator.**
1. Bit-for-bit estimate parity: `fit_ai_reml` (symbolic-reuse) vs the current per-iteration-refactor `fit_ai_reml` and vs the dense `_reml_negloglik` optimum, `rtol ≤ 1e-10` on a Mrode-scale fixture (n≈8).
2. **Close the test gap (verify caveat 1):** add a dense-truth selinv assertion — `selinv_trace_against(F, Ainv, nfixed) ≈ sum(Ainv .* inv(Matrix(C))[uu])` on a tiny fixture. The current test (runtests.jl:1934-1935) only checks self-consistency vs the `takahashi_selinv` broadcast; the diagonal/PEV is checked vs dense (1856-1857) but the **trace term is not**. Verify stage ran this live: error **0.0**.
3. `selinv_trace_against` exactness holds because `pattern(dC/dσ²ₐ) = pattern(Ainv) ⊆ pattern(C random block) ⊆ pattern(L+Lᵀ)` (Cholesky fill is a graph-theoretic superset). Add an `@assert` if the dC/dθ pattern ever reaches off-pattern (the `idx==-1 → 0.0` fallback at `takahashi_selinv.jl:185` silently drops off-pattern contributions — safe for Ainv/Iₘ only).

**Benchmark.** Per-iteration wall time + allocations as `q ∈ {1e3, 1e4, 5e4, 1e5}` on a **real `pedigree.jl` Ainv** with real `X,Z` incidence. The widening time-gap vs naive per-iteration `cholesky` is the "speedy" evidence; **if the gap is flat the speed claim is hollow even though correctness holds** (verify caveat: `cholesky!` silently re-runs symbolic analysis on a pattern change — assert pattern invariance AND benchmark the widening gap). Report `nnz(L)` fill ratio at each q.

**Required hardening before shipping Stage A:**
- Wrap the per-iteration factorization in `try/catch PosDefException` (the dense path has it at `likelihood.jl:304`; `fit_ai_reml:381` does **not** — an interior overshoot throws uncaught). Add EM half-step fallback on failure.
- σ²ₐ→0 boundary: the score `-0.5/σ²ₐ²·(...)` (`likelihood.jl:389`) multiplies a `1e16` prefactor by a difference of underflowing terms → catastrophic cancellation. The **selinv stays exact** (minLpivot constant to σ²ₐ=1e-8); the risk is the Newton step, handled by the existing 60-halving guard + EM fallback. Reparameterize to log-variance or γ=σ²ₑ/σ²ₐ in the reference.
- Document full-column-rank `X` as a precondition (a duplicate X column throws `PosDefException` — rank-deficient X is undetected today).

---

### Stage B — Exact low-rank Woodbury (default) + matrix-free PCG; stochastic trace as a fenced fallback (huge/genomic n)

**The verify stage's central correction:** the genomic regime is **better served exactly** than stochastically. `fit_snp_blup_reml` (`genomic.jl:309`) already routes genomic REML through the exact sparse AI-REML path with `Z=W` (centered markers), `Ainv=Iₘ`. The maintainer's own prototype validates **exact low-rank Woodbury + matrix-determinant-lemma AI-REML** to dense `abs_err 2.3e-13`, analytic score = finite-diff to all digits. So:

- **Rank-B default (genomic, moderate m):** exact low-rank Woodbury. Every trace reduces to an exact `m×m` trace; `selinv_trace_against` already gives `tr(Iₘ·Cᵘᵘ)` exactly whenever the `m×m` block factorizes (m up to a few thousand). **No stochastic trace needed.**
- **Rank-B primitive (huge n, factorization-free MME solve):** matrix-free `mul!(out, C, v)` operator + Krylov PCG. Pin bit-for-bit to `fit_snp_blup_reml` / `cholesky\` (≤1e-8).
- **Rank-C fallback (narrow):** Hutchinson trace + SLQ logdet **only** where even the `m×m` (or a dense Ginv/Hinv) is infeasible.

**Exact Julia packages.** `Krylov.jl` (CG/PCG, `cg`), Jacobi/diagonal preconditioner first. Operator via `LinearMaps.jl` or a hand-rolled `mul!`. SLQ logdet borrows the GLLVM `_slq_logdet_with_invprobes!` pattern. **All new deps gated behind extensions where possible** (Krylov is pure-Julia, cheap to add as a hard dep if preferred).

**Complexity.** Memory `O(nnz + n_geno·m)`, no dense V, no `O(n³)`/`O(q³)`. Per PCG iter = one relationship-apply (dense GEMV for genomic W, SpMV for pedigree). `k_cg` × `N_probes` × outer iters applies.

**Correctness gate.**
1. Operator: `mul!(out,C,v)` vs `C*v` from `_sparse_mme_system`, ≤1e-12.
2. PCG solution vs `cholesky\` ≤1e-8.
3. Converged (σ²ₐ,σ²ₑ) vs `fit_snp_blup_reml` on a fixture where both run.
4. **Stochastic fallback gets its own validation_status row** and must report Monte Carlo error. It must NOT inherit the exact path's "covered". Required: a **bias-vs-N curve** + comparator run, **reorthogonalized Lanczos** (full/selective — the SLQ probe shows ghost-eigenvalue error growing m=10:6.7e-7 → m=40:6.4e-5 without it).

**Benchmark.** PCG iters-to-tol and time vs `cholesky\` as n grows, on **real MME conditioning** (not the diagonally-dominant `B*B'+25I` stand-ins — on the real MME-derived K the SLQ logdet hit rel_err **2.8e-3**, *above* the design's own <1e-3 gate). Crossover (matrix-free beats direct) is in the n,q ~ 10⁵–10⁶ range.

**Honest blocker carried forward:** stochastic SCORE is unbiased, but the EM/AI fixed point of a noisy score carries an **O(1/√N) VC bias floor** — the estimator is NOT unbiased. Single-step A₂₂⁻¹ apply is under-specified (`genomic.jl:2068` flags `A₂₂⁻¹ = inv(A[g,g])`, NOT `(Ainv)[g,g]`); design the inner solve (Henderson/Colleau indirect, or APY sparse G⁻¹) before any matrix-free single-step claim. APY is **load-bearing, not optional** for keeping G sparse.

---

### Stage C — GPU control: wire the backend tags to real dense execution (genomic/marker-scan regime only)

**The verify stage's headline correction:** the marker-scan win is **mostly a CPU-batching win, not a GPU win.** Reformulating the per-marker loop (`genomic.jl:635-652`) into one BLAS-3 batched solve gave **30.24× on CPU alone** (10.106s → 0.334s, agreement 3.1e-10) at n=2000, m=5000. The GPU increment on top is only the GEMM-throughput ratio (~2-8× further, M1 Ultra fp32 vs CPU BLAS), and only above n≳1500 or m≳5000 with device-resident arrays.

**Algorithm.** (1) Batched CPU marker scan (CPU reference): replace the per-marker `cholV \ w` loop with one `PW = cholV\W − Vinv_X*(cholXtVinvX\(Vinv_X'*W))`; `denom = vec(sum(W.*PW; dims=1))`; `alpha = (W'*Py)./denom`. (2) Port the *same* batched GEMM + triangular solve to the device. GPU targets are the **dense blocks only**: `G = WWᵀ/k` (`genomic.jl:89`), batched `cholV\W`, projection GEMM. Sparse Cholesky + selinv **stay on CPU/CHOLMOD** (Metal has no mature sparse story).

**Exact Julia packages / arch.** `KernelAbstractions.jl` + `GPUArrays.jl` for vendor-agnostic kernels; `Metal.jl` (local, M1 Ultra — wraps MPS for dense GEMV/potrf), `CUDA.jl`/`AMDGPU.jl`/`oneAPI.jl` as portability targets. **Package extensions (weakdeps)**, see §3. The generic `mul!`/`ldiv!`/`dot` that `GPUArrays` overloads gives CPU-identical results up to fp reduction order.

**Complexity.** Dense GEMM/syrk `O(n²m)` / `O(nm²)` — genuinely BLAS-3-bound, the only honest GPU candidate.

**Correctness gate.** GPU vs CPU **fp tolerance**, NOT bit-for-bit (fp64 ~1e-8; fp32 ~1e-4, **explicitly labelled**). Never silently downcast inference to fp32. Metal fp64 is emulated/slow → fp64-GPU falls back to CPU. **No `backend_info()` row may flip `execution_available=true`** until a real Metal agreement run passes the 8-point Promotion Gate (`docs/design/09-backend-algorithm-roadmap.md`). **Only Metal is runnable here** — CUDA/AMDGPU/oneAPI rows stay `:planned`.

**Benchmark.** §3 Metal microbench: CPU-batched vs Metal for `G=WWᵀ` and batched `cholV\W` across n,m, reporting the crossover floor and the residual GPU multiplier on top of the free 30×.

---

## 2. Prototype First — the single de-risking deliverable

**Build this first (live Julia, this is what the operator runs next):**

> **The symbolic-once `cholesky!` in-place AI-REML hot loop** — extend `fit_ai_reml` (`likelihood.jl:356-436`) to factor once on iteration 1, then `cholesky!(F, Symmetric(lhs_k))` thereafter, keeping `selinv_trace_against` and `_reml_project` untouched — instrumented on a **real large pedigree (q ~ 50k–100k)** for per-iteration wall time + `nnz(L)` fill ratio, **AND** the identical loop with a dense genomic Ginv random block.

**Why this one first.** It simultaneously (a) proves sparse scaling works where claimed (pedigree), (b) exposes the dense-fill cliff where it does not (genomic → `O(q³)`), and (c) pinpoints the *only* place a GPU dense-Cholesky path is worth building — all **before a single GPU kernel is written.** It is the cheapest, highest-certainty win and the de-risking gate for B and C.

**Exact validation (match the dense evaluator on a known fixture):**
1. Estimate parity vs current `fit_ai_reml` and dense optimum, `rtol ≤ 1e-10` (Mrode n≈8 fixture in `test/fixtures`).
2. Dense-truth selinv trace: `selinv_trace_against(F, Ainv, nfixed) ≈ sum(Ainv .* inv(Matrix(C))[uu])` — the missing test.
3. **Assert pattern invariance** across iterations (`cholesky!` re-analyzes silently on pattern change — a silent FLOP-saving failure with no error).

**Speedup metric to report.** Per-iteration time and allocations at `q ∈ {1e3,1e4,5e4,1e5}`; the gap vs naive per-iteration `cholesky` **must widen with q** (live-verified at small scale: refactor rel-resid 2.1e-16, nnz(L) invariant). Plus `nnz(L)/dense` fill ratio at each q — pedigree should stay well below 1; the genomic block should hit ~1.0 (the cliff).

**Second prototype (Stage C reference, no GPU yet):** the **CPU batched marker-scan** reformulation — captured 30× locally at 3.1e-10 agreement, no new dependency, becomes the exact reference the Metal port must match. Do **not** prototype the matrix-free PCG GPU path first — it has **no CPU reference in `src/` yet** (grep-confirmed: no `cg`/`pcg`/`mul!`/Hutchinson), so there is nothing to validate against.

---

## 3. GPU: weakdeps/extensions Project.toml + runnable Metal benchmark

**Project.toml additions (package-extension design — the local slate is clean: Metal not in depot, no `ext/`, no weakdeps):**

```toml
[deps]
LinearAlgebra = "37e2e46d-..."
SparseArrays  = "2f01184e-..."
Optim         = "429524aa-..."
Krylov        = "ba0b0d4f-..."   # Stage B: pure-Julia, add as hard dep

[weakdeps]
KernelAbstractions = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
GPUArrays          = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
Metal              = "dde4c033-4e86-420c-a63e-0dd931031962"
CUDA               = "052768ef-5323-5732-b1bb-66c8b64840ba"
AMDGPU             = "21141c5a-9bdb-4563-92ae-f87d6854732e"
oneAPI             = "8f75cd03-7ff8-4ecb-9b8f-daf728133b1b"

[extensions]
HSquaredMetalExt  = "Metal"
HSquaredCUDAExt   = "CUDA"
HSquaredAMDGPUExt = "AMDGPU"
HSquaredoneAPIExt = "oneAPI"

[compat]
Krylov = "0.9"
KernelAbstractions = "0.9"
GPUArrays = "10, 11"
Metal = "1"
```

Each `ext/HSquared<Vendor>Ext.jl` overloads the dispatch on `MetalBackend()`/`CUDABackend()`/… and flips that backend's `backend_info()` row to `execution_available=true` **only when the extension loads AND the agreement test passes**. CPU path is untouched and remains the default + reference.

**Runnable Metal microbench (this Mac):**

```julia
# bench/metal_grm.jl — run: julia --project=. -e 'using Metal' first to confirm load
using LinearAlgebra, Random, BenchmarkTools
Random.seed!(1); n=2000; m=5000
W = randn(Float32, n, m)
@btime $W * $W';                    # CPU fp32 GEMM (G = WWᵀ, genomic.jl:89 shape)
using Metal
Wg = MtlArray(W)
@btime Metal.@sync $Wg * $Wg';      # Metal fp32 GEMM
# agreement: norm(Array(Wg*Wg') - W*W')/norm(W*W')  → expect ~1e-4 fp32
```

Report: CPU-batched time, Metal time, the crossover floor (n,m where Metal wins after the free 30× CPU batching), and fp32 agreement (~1e-4, labelled). **Promotion gate stays closed until this passes the 8-point gate; only the Metal row may flip.**

---

## 4. What to tell the twin (#58 / #61)

**Division of labour (R-lane operator prototypes ↔ twin owns):**

| Work | Owner | Rationale |
|---|---|---|
| **Stage A prototype** (symbolic-once `cholesky!` loop + real-pedigree benchmark + dense-truth selinv test) | **R-lane operator prototypes; twin merges** | Cheapest, highest-certainty, de-risking gate; live Julia available here. Hand twin a validated diff. |
| Stage A production hardening (PosDefException guard, EM fallback, log-variance reparam in `fit_ai_reml`) | **Twin owns** | Touches the production estimator in `src/likelihood.jl` (Julia lane). |
| Stage B exact low-rank Woodbury default + matrix-free operator/PCG | **Twin owns; R-lane co-prototypes the operator** | New `src/` code; twin's lane. R-lane can prototype + bit-pin the operator against `fit_snp_blup_reml`. |
| Stage B stochastic fallback (Hutchinson/SLQ) + bias-vs-N curve | **Twin owns** | Needs its own validation_status row; honesty-gated. |
| Stage C CPU batched marker-scan (the 30× reference) | **R-lane operator prototypes** | No new dep, pure reformulation of `genomic.jl:635-652`, becomes the GPU reference. |
| Stage C GPU extensions (weakdeps, Metal ext, agreement test) | **Twin owns** | Touches Project.toml + new `ext/`; twin's release/CI hygiene (Grace/Karpinski lenses). |

**Exact correctness contract (the honesty gate):**
1. Stage A: **bit-for-bit** estimate parity with current `fit_ai_reml` (`rtol ≤ 1e-10`) AND dense-truth selinv trace (error 0.0 on the fixture). No "covered" without both.
2. Stage B exact path: bit-pinned to `fit_snp_blup_reml`; the stochastic fallback gets a **separate** validation_status row, reports MC error, and may **not** be reported to more digits than MC SD supports.
3. Stage C: GPU = CPU up to **fp tolerance** (fp64 1e-8 / fp32 1e-4 labelled), never bit-for-bit; **no `execution_available=true`** and no public "runs on GPU" claim until a real Metal run passes the 8-point Promotion Gate; CUDA/AMDGPU/oneAPI stay `:planned`.
4. Complexity boundary stated publicly: near-linear is **pedigree-only**; genomic/single-step dense Ginv makes the factor `O(q³)` (new risk **R7**).

---

## 5. Honest risks + guardrails

| # | Risk | Guardrail |
|---|---|---|
| R1 | **`cholesky!` silently re-analyzes** on a pattern change → speed win evaporates with no error, correctness still looks fine | Assert pattern invariance across iterations; benchmark widening time-gap vs q (flat gap ⇒ hollow speed claim); fall back to full `cholesky` on PosDef signal |
| R2 | **Stochastic VC bias floor** — SLQ/Hutchinson score is unbiased but the AI fixed point carries O(1/√N) bias; on real MME, SLQ logdet hit 2.8e-3 > the <1e-3 gate | Exact low-rank Woodbury is the genomic default; stochastic is rank-C fallback only, with reorthogonalized Lanczos, bias-vs-N curve, separate validation row, MC-error reporting |
| R3 | **GPU under-delivers** — marker-scan win is 30× CPU batching, GPU adds only ~2-8× above a size floor; Metal has no sparse story | Ship CPU batched reformulation as a *prior* deliverable; label GPU increment as the residual GEMM ratio, not the headline; AutoBackend falls back to CPU below the floor |
| R4 | **σ²ₐ→0 boundary** — catastrophic cancellation in the score arithmetic; cond(C)→∞ degrades PCG exactly where needed | log-variance/γ reparam in reference; existing 60-halving + EM fallback; selinv itself stays exact (minLpivot constant to 1e-8) |
| R5 | **Uncaught PosDefException** in `fit_ai_reml:381` (unlike dense path:304) | Add try/catch + EM half-step fallback inside the AI loop |
| R6 | **Rank-deficient X** undetected (throws PosDefException mid-loop) | Document full-rank X as precondition or add an upstream rank check |
| R7 | **Complexity cliff** — genomic Ginv / single-step H⁻¹ makes `nnz(L)/dense=1.00` → silent `O(q³)` | State pedigree-only scope boundary in summary/risks; APY (sparse G⁻¹ via ~Ne core animals) is load-bearing for single-step, not optional |
| R8 | **Single-step A₂₂⁻¹ apply** is under-specified (`A[g,g]` is a dense submatrix of the never-formed dense A) | Design the inner solve (Henderson/Colleau indirect or APY) before any matrix-free single-step claim; restrict matrix-free to GBLUP until then |
| R9 | **selinv off-pattern silent zero** (`takahashi_selinv.jl:185` returns 0.0 for off-pattern lookups) — safe for Ainv/Iₘ, would corrupt any future estimator whose dC/dθ reaches off-pattern | Add an `@assert` if the dC/dθ pattern ever changes |

**Relevant file paths (all absolute):**
- `/Users/z3437171/Dropbox/Github Local/HSquared.jl/src/likelihood.jl` — `fit_ai_reml:356`, `_sparse_mme_system:1500`, dense path `:131`, `_reml_project:441`, `_ai_newton_step:449`, dense guard `_check_dense_validation_size:1523`, PosDefException guard present at `:304` (dense) but absent at `:381` (AI loop).
- `/Users/z3437171/Dropbox/Github Local/HSquared.jl/src/takahashi_selinv.jl` — `selinv_trace_against:168`, off-pattern fallback `:185`, `_selinv_zvals:58`.
- `/Users/z3437171/Dropbox/Github Local/HSquared.jl/src/genomic.jl` — `fit_snp_blup_reml:309` (exact genomic AI-REML route), per-marker loop `:635-652`, `G=WWᵀ/k:89`, ridge inverse `:114`.
- `/Users/z3437171/Dropbox/Github Local/HSquared.jl/src/control.jl` — `backend_info` hardcodes `execution_available=false`/`:planned` at `:81-83`.
- `/Users/z3437171/Dropbox/Github Local/HSquared.jl/src/backends.jl` — backend type tags `:1-67`, `BACKEND_INFO_SYMBOLS:73`.
- `/Users/z3437171/Dropbox/Github Local/HSquared.jl/test/runtests.jl` — selinv self-consistency test `:1924-1935` (trace-vs-dense-truth missing), PEV-vs-dense `:1856-1857`.
- `/Users/z3437171/Dropbox/Github Local/HSquared.jl/docs/design/09-backend-algorithm-roadmap.md` — 8-point Promotion Gate.
- `/Users/z3437171/Dropbox/Github Local/HSquared.jl/docs/design/08-genomics-qtl-gpu-hpc-plan.md` — GPU/genomics algorithm rule (GPU → dense marker/factor/response, not sparse factorization).
- `/Users/z3437171/Dropbox/Github Local/HSquared.jl/Project.toml` — deps are `LinearAlgebra + SparseArrays + Optim` (not "ONLY LinearAlgebra + SparseArrays" — correct the framing in any prose).

**Active lenses:** Ada, Gauss, Karpinski, Fisher, Curie, Henderson, Grace, Rose.
**Spawned subagents:** none (review perspectives only).
**Current lane:** coordinator (design pass; `HSquared.jl` read-only — no edits made; one live Julia probe run via `/tmp/hsq_probe.jl`).
**Next safe action:** R-lane operator builds the Stage A prototype (symbolic-once `cholesky!` loop on a real `pedigree.jl` Ainv at q∈{1e3..1e5} + the dense-truth selinv test), reports the widening-time-gap + fill-ratio table, then hands the validated diff to the twin as the #58/#61 PR seed.
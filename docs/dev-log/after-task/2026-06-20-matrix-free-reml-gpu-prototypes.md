# After-task — Matrix-free genomic REML + Metal GPU prototypes (cross-lane engine help)

- **Date:** 2026-06-20 (session 3, cont.)
- **Lane:** coordinator / cross-lane research (no R package code touched)
- **Active lenses:** Ada (orchestrator), Gauss (numerical), Henderson (animal-model),
  Karpinski (Julia performance), Fisher (estimand/recovery), Rose (audit)
- **Spawned subagents:** none (operator-run prototyping + benchmarking)
- **Engine binary:** local Julia 1.10.0 (`~/.juliaup/bin/julia`); Metal.jl in a temp project env

## Why
User directive: *"help the Julia side as much as possible — a new algorithm, a
working algorithm, a speedy algorithm, and GPU control"*, working **with** the
active HSquared.jl thread, doing what they are not doing. The engine thread is
racing random-regression (#54) and multivariate REML recovery (V4-MV-REML); the
matrix-free scaling stack (#51) and GPU (#58) were untouched → complementary lane.

## What I built (research prototypes, not package code)
All under `docs/dev-log/prototypes/` with a results README. Standalone Julia.

1. **Exact low-rank AI-REML for the genomic regime** (`matrix-free-genomic-reml.jl`).
   `V = ve·I + va·Wt·Wt'`; matrix-determinant-lemma + Woodbury make the full REML
   objective, the analytic AI-REML gradient, and the average-information matrix
   exact and cheap **without forming the n×n `V`/`G`**. One-time setup O(n·m²);
   per-iteration O(m³ + n·m), linear in n. No stochastic trace needed while `m`
   is moderate (all trace terms are exact m×m reductions).
2. **Metal GPU benchmark + precision diagnosis** (`gpu-vapply-bench.jl`,
   `gpu-precision-check.jl`) for the dominant kernel `u = W(W'B)`.
3. Carried forward the two earlier prototypes (`matrix-free-genomic-gls.jl`,
   `matrix-free-pedigree-pcg.jl`) that established the regime map.

## Verified results
- **Exactness:** matrix-free `-2logL` == dense reference to **2.27e-13**; analytic
  AI score == central finite-difference of `-2logL` to all printed digits.
- **Recovery + speed** (truth va=0.60 ve=1.00 h²=0.375): vâ within sampling error
  of truth at n=2k/8k/30k/80k; **full REML at n=80 000 in ~8 s** (2.80 s setup +
  5.02 s solve, 6 AI iterations) where dense `G` = **51.2 GB** is infeasible.
- **Huge-m bridge:** SLQ logdet(K) rel-err **2.8e-3** at nv=24, L=30.
- **GPU:** Metal `W(W'B)` **3.4×–10.7×** vs CPU BLAS; exact (rel-err ~1e-6) for
  narrow blocks `k≤8`. **Precision landmine:** Metal's wide-GEMM (`k≥32`) silently
  drops ~2 digits (3.0e-2) — *verified against Float64*: CPU-f32 stays 5.6e-7, only
  Metal degrades, and the trigger is block width `k` not depth `n`. Mitigation:
  keep GPU blocks narrow or validate vs CPU-Float64.

## Strategic finding (the regime correction)
Matrix-free is **not** universal. Direct sparse CHOLMOD (the existing `fit_ai_reml`)
wins the sparse-pedigree regime decisively (0.04 s factorize vs 64.5 s matrix-free
PCG at n=5000). The matrix-free / low-rank / GPU stack earns its keep in dense-G
genomic, single-step H, and huge-n. Posted to the twin as a proposed re-scope of
#51's step 1.

## Cross-lane comms
- Full brief + runnable core posted to HSquared.jl **#51**
  (`issuecomment-4757925615`); delivery pointer + B/C scoping closure on **#58**
  (`issuecomment-4757928611`).
- Asked the twin for: a shared genomic fixture to validate the low-rank estimate
  against `fit_ai_reml`; confirmation they're not already on these pieces; a read
  on the #51 re-scope.

## Honesty / status
- No `hsquared` R package code changed; **no public capability claim added**. These
  are clearly-marked research prototypes feeding cross-lane engine issues.
- The "speedy/working/exact" claims are backed by the runnable scripts + the
  recorded outputs above; the dense-infeasible sizes are labelled as skipped, not
  benchmarked against a phantom dense run.

## Addendum — symbolic-once Cholesky + adversarially-verified design pass
- **Symbolic-once `cholesky!` for the sparse AI-REML loop** (`symbolic-once-cholesky.jl`).
  `fit_ai_reml` (`likelihood.jl:378-381`) full-factors the MME every iteration, but
  the pattern is invariant. Benchmarked on a real pedigree-structured sparse `A⁻¹`:
  **bit-identical solves (rel-err 0.0)**, **~1.4–1.6× constant-factor speedup**
  (flat in q — symbolic analysis is a ~constant fraction of each factorize; reported
  honestly, not as a headline).
- **R-lane-verified (by reading source)** two robustness gaps in the same loop:
  `likelihood.jl:381` has no `try/catch` around the factorization (uncaught
  `PosDefException` on a near-boundary overshoot); the σ²ₐ→0 score arithmetic
  (`:389`) has catastrophic cancellation.
- **Design pass `wms6xwbj4`** (9 agents, adversarial verify, read live HSquared.jl +
  ran the prototypes) independently reproduced the low-rank Woodbury result (2.3e-13)
  and produced the full staged plan + risk register, saved verbatim to
  `prototypes/engine-scaling-plan.md`. Key cross-confirmation: GPU pays off only in
  the dense/genomic regime, not sparse AI-REML; the genomic default is exact (no
  stochastic trace), since `fit_snp_blup_reml` already routes `Z=W, A⁻¹=Iₘ` through
  the exact path; the 30× marker-scan figure is mostly CPU batching, not GPU.
- **Attribution discipline:** the cross-lane comment separates R-lane-verified items
  from design-pass leads (subagent file:line claims to confirm).
- Third twin comment posted: HSquared.jl **#58** `issuecomment-4758004745`
  (engine-improvement follow-up).

## Next
- On the twin's shared genomic fixture: prove low-rank == `fit_ai_reml`, then
  bridge an R `target = "genomic_reml"` scalable path.
- If the twin wants GPU wired: a narrow-block-safe `W(W'B)` extension behind a
  weakdep, CPU-validated.
- If the twin wants it: turn symbolic-once + the PosDef guard into a ready
  `likelihood.jl` diff (her lane — only on request).

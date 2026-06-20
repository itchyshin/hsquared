# APY Sparse Genomic Inverse Scout

Date: 2026-06-20

Active lenses: Jason, Gauss, Henderson, Fisher, Curie, Rose.

Spawned subagents: none.

## Purpose

Ground an implementation-ready spec for the APY (Algorithm for Proven and
Young) sparse inverse of the genomic relationship matrix `G`, to feed a
benchmarked Julia prototype in `HSquared.jl` (engine help for twin issue #51,
which flags APY as "No open Julia implementation exists"). Research direction
only; no `hsquared`/`HSquared.jl` APY capability is claimed by this note.

## Question Scouted

What is the exact APY recursion, the core-size rule, what "validated" means for
an APY prototype, what reference implementations exist (open Julia or not), and
the numerical pitfalls?

## Sources Checked (primary where possible)

- Pocrnic, Lourenco, Masuda, Legarra, Misztal 2016, *Genetics Selection
  Evolution* / PMC4858800 — fetched verbatim: block inverse formula, `M_nn`
  definition, non-core recursion, EIG90/95/98 ≈ `Ne·L`/`2Ne·L`/`4Ne·L`
  dimensionality, six populations Ne 20–200, GEBV_REG vs GEBV_APY > 0.99 at
  EIG99.
- Misztal 2016, *Genetics* 202:401–409 / PubMed 26584903 — theory of why
  recursion works (small dimensionality from small Ne); off-diagonals of the
  non-core block are dropped.
- Misztal, Legarra, Aguilar 2014 (J Dairy Sci) — original APY recursion on
  proven/young animals (foundational).
- Fragomeni et al. 2020, *J Anim Sci* 98(12):skaa374 — core-dependent changes:
  too-small core → GEBV fluctuations up to ~1 SDa WITHOUT loss of mean
  accuracy; ~2% of GRM is noise; different adequate cores correlate > 0.99.
- Bradford, Pocrnic, Fragomeni, Lourenco, Misztal 2022, GSE / PMC9682752 —
  core-subset optimisation (CAPTCHA-blocked on fetch; conclusion corroborated
  by Fragomeni 2020 + BLUPF90 docs: random core of adequate size is the
  practical default).
- BLUPF90 wiki (`undoc:apy_in_blup90iod2`) + manual — `preGSf90` with
  `OPTION snp_svd stop` prints `EIG 98% <n>`; that count is the core size;
  core animals are then chosen RANDOMLY. Canonical production APY.
- JWAS.jl v2.3.6 local source (`~/.julia/packages/JWAS/1xzHb`) — inspected
  directly.

## Verified: no open Julia APY implementation (twin #51 correct, one nuance)

- JWAS.jl has core/non-core ID *bookkeeping* only: `PedModule.genoSet!` has a
  3-arg method (`forSSBR.jl:58`, tagged `#for APY`) that reads a core-ID file
  and partitions `setG_core` / `setG_notcore`. But the single-step entry points
  (`single_step/SSGBLUP.jl:7`, `SSBR.jl:73`) call only the **2-arg** `genoSet!`
  (no core file). There is **no APY G-inverse recursion** anywhere in JWAS —
  no `Gcc⁻¹`, no `Mnn = diag(…)`, no block assembly. The core/non-core
  partitioner is orphaned scaffolding never reached by the fitting pipeline.
- Depot-wide grep for "APY" returns only substring false positives (`anim`,
  `Conda`, `parse`). No package implements the recursion.
- Verdict: twin #51's "No open Julia implementation exists" is correct for the
  *computation*. Record the nuance that JWAS ships a partial, unwired core/
  non-core partitioner — a head-start on the ID layer, not the math.

## Lessons For HSquared.jl

- **Recursion (verbatim, Pocrnic 2016):**
  `G_APY⁻¹ = [[Gcc⁻¹, 0],[0, 0]] + [[-Gcc⁻¹Gcn],[I]] · Mnn⁻¹ · [[-GncGcc⁻¹, I]]`
  with `Mnn = diag{ g_ii − g_ic Gcc⁻¹ g_ci }` (a DIAGONAL — this is the entire
  source of sparsity). Non-core block is diagonal; only the core block is dense.
- **Sparsity:** nnz ≈ `c² + 2·c·n + n` (dense core + two cross blocks via the
  `Gcc⁻¹·Gcn` map + diagonal non-core), vs `(c+n)²` dense. Cost
  `O(c³) + O(n·c²)`, not `O((c+n)³)`.
- **Core size:** number of eigenvalues of `G` explaining ~98% of variance
  (EIG98 ≈ `4·Ne·L`, L = genome length in Morgans). Default = EIG98; EIG99 for
  the >0.99 GEBV correlation target. Core composition is ~irrelevant at adequate
  size → **random core** is the production default (BLUPF90).
- **Validation:** (a) `cor(EBV_APY, EBV_fullG) → ~0.99` at EIG98–99;
  (b) nnz(APY⁻¹) ≪ dense; (c) accuracy recovers monotonically as core grows
  (EIG90 ~0.03 below peak → EIG98 peak); (d) failure mode = too-small core →
  GEBV swings up to ~1 SDa across random core draws, mean accuracy intact but
  individual rankings unstable.
- **Pitfalls:** `Gcc` needs a ridge/blend with `A22` to be SPD before
  inverting; `m_nn,i` can go non-positive with a bad core or no blending (guard
  it); core draw must be seeded for reproducibility; for single-step, combine as
  `H⁻¹ = A⁻¹ + scatter(G_APY⁻¹ − A22⁻¹)` where `A22 = A[g,g]` (the dense
  pedigree SUBMATRIX), NOT `(A⁻¹)[g,g]` — the twin already does this correctly
  at `HSquared.jl/src/genomic.jl:2095`.

## hsquared Action

- This is a Julia-lane prototype (the twin's lane). hsquared (R lane) adds no
  APY claim. Coordination only via twin #51.
- When a twin APY prototype lands, the R-lane surface is at most an opt-in
  `engine`/control knob (`core =`/`apy =`) behind the existing supplied-`Ginv`
  path — defer until the twin has a recovery-validated `G_APY⁻¹`.

## Claim Boundary

Supports research direction only. Neither `hsquared` nor `HSquared.jl`
implements APY today; the twin's genomic inverse is a dense regularized
`inv(G + ridge·I)` and the single-step `H⁻¹` is dense/validation-scale.

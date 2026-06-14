# Structured Covariance R-Control Scout

Date: 2026-06-14

## Question

How should `hsquared` design the first R-side control surface for structured
multivariate genetic covariance (`diagonal`, `lowrank`, `factor_analytic`)
without exposing live syntax before the Julia engine branch is on `main` and R
bridge tests exist?

## Sources Checked

Local:

- `docs/design/09-multivariate-plan.md`
- `docs/design/13-sparse-multivariate-production-plan.md`
- `docs/design/14-factor-analytic-production-plan.md`
- `R/model-spec.R`
- `tests/testthat/test-formula-animal.R`
- `gllvmTMB/R/fit-multi.R`
- `GLLVM.jl/src/lowrank_cholesky.jl`
- `GLLVM.jl/src/structured_schur.jl`
- `HSquared.jl/test/runtests.jl` on the local feature branch
  `codex/phase5-marker-adjustments`

External:

- sommer package documentation and manual:
  <https://www.rdocumentation.org/packages/sommer/versions/4.1.2/topics/mmer>
- ASReml-R reference manual / covariance structures:
  <https://asreml.kb.vsni.co.uk/wp-content/uploads/sites/3/ASReml-R-Reference-Manual-4.2.pdf>
- gllvm documentation:
  <https://www.rdocumentation.org/packages/gllvm/versions/1.0/topics/gllvm>

## Lessons

- The current live R grammar should stay simple: `cbind(...)` on the left-hand
  side plus `animal(1 | id, pedigree = ped)`.
- The first structured covariance bridge should be an expert opt-in control,
  not a new public formula grammar:

```r
control = hs_control(
  engine = "julia",
  engine_control = list(
    target = "multivariate",
    genetic_structure = "diagonal" # or "lowrank" / "factor_analytic"
  )
)
```

- Long-format formula syntax should remain planned until the R lane can parse
  trait order, covariance vocabulary, and result metadata together:

```r
animal(trait | id, pedigree = ped, cov = diag())
animal(trait | id, pedigree = ped, cov = lowrank(K = 2))
animal(trait | id, pedigree = ped, cov = fa(K = 2))
```

- `gllvmTMB` is a good local warning pattern: when structured covariance terms
  can be over-parameterised or target an unsupported slot, fail loudly with a
  targeted message rather than silently collapsing the model.
- `GLLVM.jl` is the local computation pattern for future `lowrank`/`fa`
  internals: keep the invariant covariance `Lambda Lambda' + diag(d)` explicit
  and use Woodbury-style operations where possible.
- ASReml and sommer show why users expect named covariance structures, but they
  also reinforce that covariance-structure comparisons are estimand-sensitive.
  R should not claim ASReml/sommer parity from a control keyword alone.
- The local `HSquared.jl` checkout has green PR checks for Phase 4B structured
  covariance, but the relevant commits are not on `origin/main`; R therefore
  must record a contract only, not ship live bridge support.

## hsquared Action

Add a design note defining the R control contract and promotion gates. Keep
`formula_status()`, `model_status`, vignettes, and public claims at planned or
partial until Julia main and R bridge tests prove support.

## Claim Wording Risk

High-risk wording:

- "supports `cov = fa(K)`"
- "fits factor-analytic G matrices"
- "diagonal multivariate model implemented"
- "ASReml-style structured covariance"

Allowed wording after this slice:

- "R-side structured covariance control contract planned"
- "Julia feature branch has partial structured covariance evidence"
- "`cov = diag()` / `lowrank()` / `fa()` remain planned R formula grammar"

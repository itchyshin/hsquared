# Ecosystem Lessons

This project borrows operating habits from `drmTMB`, `DRM.jl`, `gllvmTMB`, and
`GLLVM.jl`, but it must rewrite the statistical contracts for quantitative
genetics.

## What To Borrow

- From `drmTMB`: formula discipline, fitted/planned/missing separation,
  after-task reports, check logs, small PRs, and reader-first tutorials.
- From `DRM.jl`: twin-package discipline, R-to-Julia parity thinking,
  launchable team roles, quality batteries, selected-inverse algorithm leads,
  and license-boundary care.
- From `gllvmTMB`: long/wide data discipline, capability status tables,
  validation rows, and public examples that do not outrun the engine.
- From `GLLVM.jl`: Julia performance honesty, explicit limitations, sparse and
  low-rank computation, Woodbury-style Gaussian computation, Laplace paths,
  and live parity scoreboards.
- From the portable agent kit: repository memory is authoritative; private
  memory is a routing layer only.
- From genomic/QTL packages such as JWAS.jl and XSim.jl: genomics belongs in
  the roadmap from the start, but validation and simulation evidence must come
  before claims.
- From relationship-matrix packages such as AGHmatrix and nadiv: plant,
  polyploid, dominance, and epistatic users need first-class relationship
  design rather than animal-only defaults.

## What To Adapt

`hsquared` is not a distributional-regression package and not a general GLLVM
package. Its organizing object is quantitative genetics: heritability,
breeding values, relationship matrices, G matrices, and inheritance-structured
mixed models.

The package should borrow the operating system, not the statistical claims.

## What Not To Copy

- Do not copy TMB-specific implementation claims.
- Do not copy `gllvmTMB`'s covariance keyword grid as the public grammar unless
  it matches quantitative-genetic syntax.
- Do not copy GPL source from related projects without an explicit license
  decision.
- Do not advertise ASReml-level performance before comparator evidence exists.
- Do not let genomic, QTL, or unusual-inheritance ambition crowd the first easy
  API.

## Concrete Local Leads

- `DRM.jl/src/takahashi_selinv.jl` is a serious local reference for selected
  sparse inverse entries after `HSquared.jl` has sparse factorizations. Treat it
  as an algorithm lead, not as copy-paste source, until provenance and tests
  are explicit.
- `GLLVM.jl/src/fit.jl` shows how much can be gained by profiling nuisance
  variance, using low-rank structure, and keeping gradients close to the hot
  linear-algebra path.
- `GLLVM.jl/src/structured_schur.jl` is a useful design lead for
  matrix-free/low-rank structured precision work and for later GLLVM-style
  genetic factor models.
- `gllvmTMB/CLAUDE.md` records a valuable grammar lesson: keep long and wide
  user paths paired, keep capability status explicit, and separate ordinary
  random effects from structured kernels in the user-facing vocabulary.

# Ecosystem Lessons

This project borrows operating habits from `drmTMB`, `DRM.jl`, `gllvmTMB`, and
`GLLVM.jl`, but it must rewrite the statistical contracts for quantitative
genetics.

## What To Borrow

- From `drmTMB`: formula discipline, fitted/planned/missing separation,
  after-task reports, check logs, small PRs, and reader-first tutorials.
- From `DRM.jl`: twin-package discipline, R-to-Julia parity thinking,
  launchable team roles, quality batteries, and license-boundary care.
- From `gllvmTMB`: long/wide data discipline, capability status tables,
  validation rows, and public examples that do not outrun the engine.
- From `GLLVM.jl`: Julia performance honesty, explicit limitations, sparse and
  low-rank computation, and live parity scoreboards.
- From the portable agent kit: repository memory is authoritative; private
  memory is a routing layer only.

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

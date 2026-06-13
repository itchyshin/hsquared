# hsquared

`hsquared` is the planned R interface for an open, Julia-backed
quantitative-genetic modelling system. The R package owns the applied-user
surface: formula syntax, data validation, summaries, extractors, examples, and
eventually the bridge to the `HSquared.jl` engine.

This repository is in Phase 0. It is a package scaffold with team memory,
roadmap, and honest placeholder functions. It does not fit animal models yet.

The intended two-package shape is:

```text
hsquared       R package: friendly modelling interface for applied users
HSquared.jl    Julia package: sparse quantitative-genetic engine
```

The first implementation target is a univariate Gaussian animal model:

```r
fit <- hsquared(
  y ~ sex + age + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian(),
  REML = TRUE
)
```

That syntax is a v0.1 target, not a working example in this scaffold.

## Installation

```r
# install.packages("pak")
pak::pak("itchyshin/hsquared")
```

## Development

Run the local checks with:

```r
devtools::check()
```

The project operating system lives in:

- `AGENTS.md`
- `ROADMAP.md`
- `docs/design/`
- `docs/dev-log/`
- `.agents/skills/`

Repository memory is authoritative. Chat memory only points agents toward the
right files.

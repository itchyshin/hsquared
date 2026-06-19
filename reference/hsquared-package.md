# hsquared: R Interface for Julia-Backed Quantitative-Genetic Models

The hsquared package is the planned R-facing interface for heritability,
breeding-value, G-matrix, and inheritance-structured
quantitative-genetic models backed by the HSquared.jl Julia engine.

## Details

v0.1 fits the univariate Gaussian animal model
`y ~ fixed + animal(1 | id, pedigree = ped)` by REML
(average-information) through the HSquared.jl engine: the default
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
call fits when a local Julia and `HSquared.jl` are available, and
otherwise errors with install guidance. Genomic, single-step,
repeatability, two-effect, and multivariate Gaussian models also fit
through opt-in, experimental engine paths; factor-analytic and
non-Gaussian models remain planned.

## See also

Useful links:

- <https://itchyshin.github.io/hsquared/>

- <https://github.com/itchyshin/hsquared>

- <https://github.com/itchyshin/HSquared.jl>

- Report bugs at <https://github.com/itchyshin/hsquared/issues>

## Author

**Maintainer**: Shinichi Nakagawa <itchyshin@gmail.com>

Authors:

- Shinichi Nakagawa <itchyshin@gmail.com>

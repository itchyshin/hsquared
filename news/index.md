# Changelog

## hsquared 0.0.0.9000

### New features

- [`animal()`](https://itchyshin.github.io/hsquared/reference/animal.md)
  is now exported as an inert formula marker, and
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  now parses the narrow v0.1 formula contract
  `animal(1 | id, pedigree = ped)` before stopping at the planned Julia
  bridge boundary
  ([\#4](https://github.com/itchyshin/hsquared/issues/4),
  [\#6](https://github.com/itchyshin/hsquared/issues/6)).
- [`hs_control()`](https://itchyshin.github.io/hsquared/reference/hs_control.md)
  now has an experimental `engine = "julia"` option that lets local
  developers run the tiny v0.1 animal-model payload through a sibling
  `HSquared.jl` checkout via JuliaCall. The default engine remains
  validation-only, and general fitted animal-model support is still
  planned ([\#6](https://github.com/itchyshin/hsquared/issues/6)).
- Added an internal R-to-Julia bridge payload builder for the v0.1
  animal-model contract. It creates `y`, `X`, sparse `Z`, normalized
  pedigree metadata, and the validated Julia `animal_model_spec()`
  target used by the experimental Julia engine
  ([\#6](https://github.com/itchyshin/hsquared/issues/6)).
- Added a local-only experimental JuliaCall smoke path for the tiny v0.1
  payload when a sibling `HSquared.jl` checkout is available. This
  validates bridge shape against Julia `pedigree_inverse()` and
  `fit_animal_model()` but is not yet the public
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  fitting path ([\#6](https://github.com/itchyshin/hsquared/issues/6)).
- Added the first `hsquared_fit` object and extractor contract,
  including
  [`variance_components()`](https://itchyshin.github.io/hsquared/reference/variance_components.md),
  [`heritability()`](https://itchyshin.github.io/hsquared/reference/heritability.md),
  [`breeding_values()`](https://itchyshin.github.io/hsquared/reference/breeding_values.md),
  [`fixef()`](https://itchyshin.github.io/hsquared/reference/fixef.md),
  [`ranef()`](https://itchyshin.github.io/hsquared/reference/ranef.md),
  [`logLik()`](https://rdrr.io/r/stats/logLik.html),
  [`AIC()`](https://rdrr.io/r/stats/AIC.html),
  [`predict()`](https://rdrr.io/r/stats/predict.html), and
  [`summary()`](https://rdrr.io/r/base/summary.html) methods over
  internal fit objects. These are contract plumbing only until the Julia
  engine returns real fits
  ([\#5](https://github.com/itchyshin/hsquared/issues/5)).
- Added
  [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  as a lightweight R data container for phenotype, pedigree, genotype,
  marker, expression, annotation, and environment inputs. It records ID
  maps for future integrated genomic/QTL/eQTL workflows, but does not
  fit models ([\#8](https://github.com/itchyshin/hsquared/issues/8)).
- Added Phase 0 project operating documentation, an honest placeholder
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  entry point, and
  [`hs_control()`](https://itchyshin.github.io/hsquared/reference/hs_control.md)
  for planned engine controls.

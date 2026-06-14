# Wide-Response Matrix Syntax Plan

Status: **design note only**. The current R package does not parse or fit
GLLVM-style wide response matrix models. The live multivariate path remains the
opt-in Gaussian `cbind(...) ~ animal(1 | id, pedigree = ped)` bridge. This note
records the future Phase 6 syntax boundary.

## Purpose

High-dimensional omics, community ecology, and trait-panel workflows often start
as a matrix:

```text
rows = samples, individuals, plots, sites, or families
columns = traits, species, genes, transcripts, metabolites, or markers
cells = observed responses
```

The user-facing grammar should let users keep that shape when it is natural,
while the engine receives the same explicit stacked-trait representation needed
for sparse animal, genomic, and GLLVM computation.

The rule:

```text
wide user data -> explicit response matrix Y + trait metadata
long user data -> explicit value/trait/unit columns
engine data    -> observed response cells with row, trait, family, and link maps
```

## Scout Notes

Local sources checked:

- `gllvmTMB/README.md` uses a wide `traits(...)` left-hand side for one row per
  unit and one column per trait, while long data use `value ~ ...`, `trait =`,
  and `unit =`. Both routes are documented as reaching the same stacked-trait
  model.
- `gllvmTMB/src/gllvmTMB.cpp` is explicitly a stacked-trait multivariate TMB
  template with per-row family/link vectors and latent covariance dispatch.
- `GLLVM.jl/docs/src/response-families.md` keeps the Julia engine matrix-first:
  `fit_gllvm(Y; family, K, ...)`, with `Y` as a response matrix and family
  dispatch over Gaussian, binomial, Poisson, negative-binomial, beta, ordinal,
  gamma, and two-part fitters.
- `GLLVM.jl/docs/src/working-with-a-fit.md` is the post-fit pattern to reuse:
  ordination scores, loadings, rotation metadata, predictions, residuals, and
  model-comparison summaries, with rotation-invariant covariance interpretation.
- `GLLVM.jl/docs/src/gllvmtmb-parity.md` records that matrix-level fitting is
  available while formula front ends for wide/long data and `traits()` remain
  parity work.
- `DRM.jl` / `drmTMB` provide the narrower lesson that `cbind()` is familiar for
  two-column distributional responses, but it should not be overloaded as the
  long-term high-dimensional GLLVM interface.

External anchors checked:

- The `gllvm` R package documents multivariate GLLVM fitting by maximum
  likelihood with Laplace, variational, or extended variational approximations:
  <https://jenniniku.github.io/gllvm/>
- The `gllvm()` reference describes a multivariate GLLVM API with `y`, `X`,
  `TR`, `formula`, `family`, latent-variable count, row effects, and related
  controls:
  <https://jenniniku.github.io/gllvm/reference/gllvm.html>
- Niku et al. describe GLLVMs for multivariate count and biomass data, including
  latent variables for unexplained species covariation and ordination:
  <https://ideas.repec.org/a/spr/jagbes/v22y2017i4d10.1007_s13253-017-0304-7.html>
- The current CRAN manual for `gllvm` records a matrix input style and
  prediction/latent-variable extractors:
  <https://cran.rstudio.com/web/packages/gllvm/gllvm.pdf>

## Accepted Future Syntax

### Wide User Data

For users with one row per unit and one response column per trait:

```r
# planned, not current
fit <- hsquared(
  traits(gene1, gene2, gene3) ~ batch + treatment +
    sample_factors(K = 2) +
    animal_fa(K = 2, id = id, pedigree = ped),
  data = expr_wide,
  family = gaussian()
)
```

For ecological community or count matrices:

```r
# planned, not current
fit <- hsquared(
  traits(sp1, sp2, sp3, sp4) ~ environment +
    site_factors(K = 2) +
    animal_fa(K = 1, id = lineage, pedigree = ped),
  data = community_wide,
  family = negative_binomial()
)
```

Boole verdict: `traits(...)` is more memorable than treating a long list of
responses as a giant `cbind(...)`. It says "these columns are the response
matrix" and leaves `cbind()` for the current small Gaussian multivariate bridge
and ordinary two-column family responses.

### Long User Data

For users whose data are already stacked:

```r
# planned, not current
fit <- hsquared(
  value ~ trait + trait:treatment +
    sample_factors(K = 2) +
    animal_fa(K = 2, id = id, pedigree = ped),
  data = expr_long,
  trait = "trait",
  unit = "sample",
  family = gaussian()
)
```

Noether verdict: the long and wide forms must compile to the same internal
object:

```text
Y_obs: observed response vector
unit_id: encoded row/sample/site/individual ID
trait_id: encoded trait/species/gene column ID
X: fixed-effect design over observed cells
latent terms: sample/environment/genetic factors
animal terms: pedigree/genomic relationship kernels over IDs
family/link: either one family for all cells or explicit per-trait metadata
```

### Current Live Multivariate Path

Keep this as the only live R multivariate grammar until Phase 6 evidence exists:

```r
hsquared(
  cbind(y1, y2) ~ x + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian(),
  control = hs_control(
    engine = "julia",
    engine_control = list(target = "multivariate")
  )
)
```

`cbind(...)` is still right for the current small Gaussian animal-model bridge.
It is not the preferred future GLLVM or omics syntax because large response
matrices need trait metadata, family/link maps, missing-cell accounting, and
file-backed data options.

## Deferred Or Rejected Syntax

Deferred:

```r
Y ~ batch + sample_factors(K = 5)
expr_matrix ~ batch + animal_fa(K = 2, id = id, pedigree = ped)
hsquared_matrix(Y, X, ...)
```

These are compact, but ambiguous in R formula evaluation. `Y` might be a matrix
object, a column named `Y`, or a delayed/on-disk object. The first public formula
should prefer explicit response-column declaration through `traits(...)`.

Rejected for first public use:

```r
cbind(gene1, gene2, gene3, gene4, gene5, gene6, ...) ~ ...
```

This becomes unreadable at omics or community scale and gives no place to attach
trait metadata.

## Trait Metadata Contract

Future `traits(...)` should allow optional trait metadata through `hs_data()` or
arguments:

```r
bundle <- hs_data(
  phenotypes = sample_data,
  expression = expr_matrix,
  annotation = gene_annotation
)

# planned, not current
hsquared(
  traits_from(expression) ~ batch + treatment + sample_factors(K = 5),
  data = bundle,
  family = negative_binomial()
)
```

Minimum metadata:

```text
trait name
response family
link
offset / exposure, if any
trait group or chromosome / gene annotation, if relevant
missing-cell count
```

Per-trait family support should be a later gate. The first Phase 6 grammar can
require one family and one link for the whole matrix.

## Missing Response Cells

Wide `traits(...)` input:

```text
NA in a response trait column -> unobserved response cell
NA in a predictor/grouping column -> fail-loud unless an explicit missing-data
                                    model is implemented
```

Long input:

```text
NA in value -> unobserved response cell
missing trait/unit IDs -> fail-loud
```

R should marshal missing response cells as dropped observed cells or as `NaN`
only when the Julia engine contract explicitly masks `NaN`. It should never
silently drop the whole individual/sample when only one trait is missing.

## Engine Payload Shape

The R-to-Julia payload should be explicit rather than formula-shaped:

```text
Y: matrix-like response object or observed-cell vector
Y_shape: n_units x n_traits
observed_mask: sparse/logical mask or observed-cell index
unit_ids: encoded units
trait_ids: encoded traits
trait_names: original response names
X: fixed-effect design over observed cells
effects: animal/genomic/sample/environment latent terms
families: family/link metadata
offsets/weights: optional, observed-cell aligned
metadata: maps back to row names, trait names, annotations, and input columns
```

For large matrices, `Y` may later be file-backed. The first implementation should
stay in-memory and validation-scale.

## Result Contract

Future wide-response fits should expose:

```r
loadings(fit)
ordination(fit)
trait_scores(fit)
individual_scores(fit)
latent_breeding_values(fit)
G_matrix(fit)
R_matrix(fit)
trait_correlations(fit)
fitted(fit)
residuals(fit)
fit_diagnostics(fit)
```

Do not expose these as interpreted biological axes until a rotation convention,
diagnostics, and validation evidence exist. `G_matrix()` / covariance summaries
are the invariant first outputs.

## Validation Gates

Before public `traits(...)` fitting:

1. Wide-to-long equivalence on a deterministic Gaussian fixture.
2. Missing response cell fixture where one cell is missing but the unit remains
   in the model.
3. Family/link metadata fixture for at least one non-Gaussian family.
4. Rotation/sign convention for loadings and scores.
5. Recovery simulation for latent covariance and, if animal terms are included,
   genetic covariance.
6. Comparator against `gllvm` / `GLLVM.jl` where the same estimand exists.
7. Rose audit of README, vignettes, capability status, and claims register.

## User Documentation Order

1. Start with ordinary `cbind(...)` multivariate animal models because they are
   live today.
2. Introduce `traits(...)` as planned future syntax for high-dimensional
   response matrices.
3. Explain that wide and long data are two front doors to the same stacked-cell
   model.
4. Teach invariant outputs first: covariance/correlation matrices and fitted
   values.
5. Teach ordination and loadings only with rotation warnings.

Pat verdict: users are gold. The common animal-model path should stay:

```r
y ~ fixed + animal(1 | id, pedigree = ped)
```

Wide-response GLLVM syntax should feel like a separate advanced lane, not extra
ceremony forced onto the v0.1 animal model.

## Synchronized Updates Needed Later

- `docs/design/02-formula-grammar.md`: add `traits(...)` only when parser
  reservation exists.
- `formula_status()`: add rows only when the R package can reject or parse the
  syntax explicitly.
- `docs/design/06-public-claims-register.md` and `capability-status.md`: keep
  GLLVM-style models `planned` until evidence lands.
- `HSquared.jl` engine docs: define the matrix/observed-cell payload before R
  exposes a live bridge.

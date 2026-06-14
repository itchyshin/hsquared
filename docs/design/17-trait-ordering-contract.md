# Trait Ordering Contract

Status: **design note plus current invariant**. The current implemented
multivariate R path is the opt-in `cbind(...)` Gaussian animal model. This note
records the ordering rules that current and future multivariate, GLLVM, omics,
and comparator paths should share.

## Purpose

Trait ordering is a small surface with a large blast radius. The same order must
flow through:

```text
R formula -> response matrix Y -> Julia payload -> covariance matrices
-> breeding values -> extractor tables -> comparator scripts -> plots
```

The principle is:

```text
preserve user-declared trait order; never sort traits alphabetically unless the
user explicitly asks for that order.
```

Animal or pedigree IDs may be normalized for sparse relationship matrices.
Trait order is different: it is a user-facing coordinate system and should stay
stable.

## Current Live Rule: `cbind(...)`

Current fitted multivariate grammar:

```r
hsquared(
  cbind(weight, length) ~ sex + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian(),
  control = hs_control(
    engine = "julia",
    engine_control = list(target = "multivariate")
  )
)
```

Rule:

```text
trait_order = columns of the evaluated cbind response, in left-to-right LHS order
Y           = n_records x n_traits, columns in trait_order
G0/R0       = n_traits x n_traits, rows and columns in trait_order
EBV table   = animals crossed with trait_order
```

Current tests already pin the simple form:

```text
cbind(y1, y2) -> trait_names = c("y1", "y2")
```

If the evaluated response has column names, use them. If R drops or mangles
names, recover names from the `cbind(...)` symbols where possible. If recovery
is impossible, use `trait1`, `trait2`, ... as a last-resort internal label and
record that fallback in diagnostics before any public production claim.

Missing response cells do not change `trait_order`. A missing `weight` cell is a
missing `weight` observation, not a reason to move or drop the `weight` trait.

## Future Wide Rule: `traits(...)`

Planned Phase 6 syntax:

```r
# planned, not current
hsquared(
  traits(gene1, gene2, gene3) ~ batch + sample_factors(K = 2),
  data = expr_wide,
  family = gaussian()
)
```

Rule:

```text
trait_order = arguments to traits(...), left to right
Y           = selected columns in trait_order
metadata    = annotation rows matched by trait name, not used to reorder by default
```

Do not let annotation, chromosome, gene position, or matrix-storage details
silently reorder traits. If a biological order is useful, it should be an
explicit user option such as `trait_order = marker_map$gene`.

## Future Bundle Rule: `traits_from(...)`

Planned convenience syntax:

```r
bundle <- hs_data(
  phenotypes = sample_data,
  expression = expr_matrix,
  annotation = gene_annotation
)

# planned, not current
hsquared(
  traits_from(expression) ~ batch + sample_factors(K = 5),
  data = bundle,
  family = negative_binomial()
)
```

Default rule:

```text
trait_order = column order of the named expression/genotype/omics matrix
```

Allowed future override:

```r
# planned, not current
traits_from(expression, order_by = annotation$position)
```

The override must be explicit and must record the ordering variable in fit
metadata.

## Future Long Rule

Planned long stacked-cell syntax:

```r
# planned, not current
hsquared(
  value ~ trait + trait:treatment + sample_factors(K = 2),
  data = expr_long,
  trait = "trait",
  unit = "sample",
  family = gaussian()
)
```

Preferred rule:

```text
if `trait` is a factor: use levels(trait)
if `trait` is character: use first appearance in the data
if user supplies `trait_order`: use that exact vector after validation
```

Validation:

- every observed trait must appear in `trait_order`;
- `trait_order` cannot contain duplicates or empty names;
- traits in `trait_order` with no observed responses are allowed only if the
  model explicitly supports all-missing trait columns; otherwise fail loud;
- long and wide representations of the same data must compile to identical
  `trait_order`, `Y`, observed-cell maps, and extractor outputs.

## Julia Payload Rule

For the current animal-model multivariate bridge, R sends:

```text
Y: n_records x n_traits
traits: trait_order
```

If a Julia engine prefers a `traits x records` orientation for a future GLLVM
kernel, the bridge may transpose internally, but the payload metadata must still
record:

```text
Y_orientation
trait_order
record_order
observed_cell_index
```

Every result returning a trait-indexed object must carry names in
`trait_order`.

## Extractor Rule

Covariance and correlation matrices:

```text
rownames(G_matrix(fit)) == trait_order
colnames(G_matrix(fit)) == trait_order
rownames(R_matrix(fit)) == trait_order
colnames(R_matrix(fit)) == trait_order
```

Tabular outputs:

```text
heritability(fit): rows in trait_order
breeding_values(fit): within each ID, rows or columns in trait_order
loadings(fit): rows in trait_order
ordination/trait_scores: trait rows in trait_order
```

Comparator files should write trait names and order explicitly. A comparator run
without a trait-order statement is not promotion evidence.

## User-Facing Error Rule

Future errors should say what order was expected:

```text
`trait_order` must contain each observed trait exactly once. Missing: gene3.
Duplicate: gene2.
```

For current `cbind(...)`:

```text
Multivariate `cbind()` responses require unique, non-empty trait names. Rename
or wrap response columns before fitting.
```

The current implementation has not yet added the unique-name guard, so this is a
future hardening item rather than a current claim.

## Validation Gates

Before widening any multivariate or GLLVM claim:

1. `cbind(a, b)` and `cbind(b, a)` produce correspondingly permuted `Y`, G/R,
   h2, and EBV outputs, not silently identical labels.
2. Long and wide versions of the same fixture agree when supplied the same
   explicit trait order.
3. Missing response cells preserve trait order.
4. Comparator scripts record and verify trait order before comparing matrices.
5. Julia tests verify any internal transposition returns results with the R
   trait order restored.

## Coordination Notes

- R lane owns user-facing trait order in formula parsing, payload metadata, and
  extractors.
- Julia lane owns engine orientation and must report result names/order back to
  R.
- Rose blocks any external-comparator or recovery claim if trait order is not
  explicit in the evidence.

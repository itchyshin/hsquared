# Metafounder and H^Gamma R bridge contract

Status: **CONTRACT ONLY**, 2026-06-21 (R lane / Ada, Shannon, Boole, Noether,
Hopper, Henderson, Curie, Fisher, Jason, Rose, Grace). No R fitting branch lands
in this slice.

## 0. Why

The next science contract after the multivariate validation gate and fit-time
plot-data payload work is Candidate A: an R-facing metafounder bridge plus
single-step `H^Gamma`. The Julia twin now has the dense validation-scale
primitives on main, but the R package should not expose a model path until the
syntax, payload, validation, and public claims are explicit.

The user-facing direction is:

```r
hsquared(
  y ~ fixed + metafounder(1 | id, pedigree = ped, group = mf_group, Gamma = Gamma),
  data = dat,
  control = hs_control(engine = "julia",
                       engine_control = list(target = "metafounder"))
)

hsquared(
  y ~ fixed + single_step(
    1 | id,
    pedigree = ped,
    markers = M,
    group = mf_group,
    Gamma = Gamma
  ),
  data = dat,
  control = hs_control(engine = "julia",
                       engine_control = list(target = "metafounder_single_step"))
)
```

Neither syntax fits today in R. `metafounder()` is an inert reserved marker, and
the existing `single_step()` construction path does not yet accept `group` or
`Gamma`.

## 1. Current Julia target

Pinned from sibling `HSquared.jl` main `758349d` (merged PR #128):

- `metafounder_relationship(pedigree, group_of, Gamma)` builds animal-only
  `A^Gamma` from a supplied dense `m x m` metafounder covariance and
  animal-aligned group labels.
- `metafounder_relationship_inverse(pedigree, group_of, Gamma)` returns the
  animal-only `inv(A^Gamma)` precision.
- `metafounder_inverse(pedigree, group_of, Gamma)` returns the combined
  `[metafounders; animals]` Henderson inverse; this is distinct from
  `inv(A^Gamma)`.
- `metafounder_animal_model(y, X, Z, pedigree, group_of, Gamma, sigma_a2,
  sigma_e2)` is supplied-variance only.
- `metafounder_single_step_inverse(pedigree, group_of, Gamma, G, genotyped_rows;
  tau, omega, blend_weight, ridge)` replaces the classical pedigree relationship
  in single-step construction with `A^Gamma`.
- `fit_metafounder_single_step(...)` is supplied-variance; `fit_metafounder_single_step_reml(...)`
  estimates variance components by REML on the supplied-`Gamma` relationship.

Engine tests already pin:

- `Gamma = 0` reduction to the ordinary relationship / ordinary single-step path;
- nonzero-`Gamma` sensitivity;
- agreement with manually building `A^Gamma` and calling ordinary
  `single_step_inverse()`;
- guard behavior for incompatible `genotyped_rows` and singular raw `G`.

## 2. R syntax reservation

`metafounder()` reserves both pieces the future bridge needs:

```r
metafounder(1 | id, pedigree = ped, group = mf_group, Gamma = Gamma)
```

Contract:

- `group` is an animal-to-metafounder group assignment aligned to normalized
  pedigree IDs after the usual parent-before-offspring sort.
- `Gamma` is supplied by the user, symmetric, finite, and on the relationship
  scale. It is **not estimated** by `hsquared`.
- MF and UPG stay distinct: `unknown_parent_group()` is still a separate planned
  syntax reservation, not an alias for metafounders.
- The first R model path should reject missing `group`, missing `Gamma`, a
  non-square `Gamma`, duplicated or unmapped group labels, and `Gamma` estimation
  controls.

For single-step `H^Gamma`, extend the existing construction grammar only after a
live bridge probe:

```r
single_step(1 | id, pedigree = ped, markers = M, group = mf_group, Gamma = Gamma)
```

The existing ordinary construction remains:

```r
single_step(1 | id, pedigree = ped, markers = M)
```

so the parser must keep the two branches unambiguous.

## 3. Payload shape

Future `target = "metafounder"` payload:

```text
y, X, Z
id, sire, dam
group_of              # aligned to normalized pedigree ids
Gamma                 # dense m x m matrix, supplied by user
variance_components   # required for supplied-variance bridge, absent for REML later
metadata$relationship_source = "metafounder"
metadata$gamma_source = "supplied"
```

Future `target = "metafounder_single_step"` payload:

```text
y, X, Z
id, sire, dam
markers               # genotyped rows reordered to normalized pedigree order
genotyped_rows        # 1-based pedigree-row indices
group_of              # aligned to normalized pedigree ids
Gamma                 # dense m x m matrix, supplied by user
knobs = list(tau, omega, blend_weight, ridge)
initial
metadata$relationship_source = "metafounder_single_step"
metadata$gamma_source = "supplied"
```

The `genotyped_rows` and marker-row ordering rules are inherited from
`docs/design/25-single-step-construction-bridge.md`.

## 4. Extractor contract

Do not expose metafounder-specific extractors until the result shape is pinned.
Candidate extractors:

- `metafounder_effects(fit)` only if the engine returns explicit combined-system
  metafounder solutions, not merely animal EBVs from `inv(A^Gamma)`.
- `gamma_matrix(fit)` or a fit-diagnostic `Gamma` field only as supplied input
  provenance, not an estimated parameter.
- ordinary `breeding_values()`, `variance_components()`, `heritability()`, and
  `fit_diagnostics()` for animal-only metafounder and `H^Gamma` fits, using the
  same partial/experimental wording as genomic and single-step surfaces.

## 5. Validation gates

Minimum R-side gates before claiming even partial R bridge support:

1. Pure-R parser and payload tests for `group_of` alignment under normalized
   pedigree order.
2. Live Julia parity probe for `Gamma = 0` reduction:
   metafounder animal model -> ordinary supplied-variance animal model, and
   `H^Gamma` -> ordinary single-step construction.
3. Live nonzero-`Gamma` sensitivity: predictions change relative to the ordinary
   path while labels and dimensions remain stable.
4. Explicit guard tests for invalid `Gamma`, unmapped groups, duplicate marker
   rows, and missing `group`/`Gamma`.
5. Status rows, docs, and NEWS all state supplied-`Gamma`, dense/validation-scale,
   opt-in, partial, and not comparator-validated.

Promotion beyond partial needs external validation. BLUPF90-family execution is
currently locally blocked because `renumf90`, `airemlf90`, `blupf90`, `remlf90`,
and `gibbsf90` are not on PATH.

## 6. Rose boundary

Allowed wording after this contract slice:

- "The R package reserves the metafounder `group` + supplied-`Gamma` syntax."
- "The R/J bridge contract for metafounder `A^Gamma` and single-step `H^Gamma`
  is documented."
- "The Julia twin has dense validation-scale primitives for supplied-`Gamma`
  metafounder relationships and `H^Gamma` single-step."

Blocked wording:

- "R fits metafounder models."
- "R fits `H^Gamma` single-step models."
- "`Gamma` is estimated."
- "BLUPF90 comparator evidence exists."
- "Metafounder or `H^Gamma` support is covered."

# Trait Ordering Contract Scout

Date: 2026-06-14

## Question scouted

How should `hsquared` define trait order across current `cbind()` multivariate
fits, future `traits(...)` wide-response syntax, long stacked-cell data, Julia
payloads, extractors, and comparator scripts?

## Sources checked

- `R/model-spec.R` and `R/bridge-payload.R`: current `cbind(...)` parsing uses
  the evaluated response matrix column order, carries `trait_names`, and sends
  `Y` as records x traits.
- `tests/testthat/test-multivariate.R`: current tests pin `cbind(y1, y2)`,
  `payload$metadata$trait_names`, shared fixture ordering, NA cell marshalling,
  and extractor normalization.
- `docs/design/09-multivariate-plan.md`: existing Phase 3 engine contract says
  `Y` is records x traits and trait labels come from the `cbind` column names.
- `docs/design/16-wide-response-syntax-plan.md`: future wide syntax uses
  `traits(...)`; long syntax uses explicit `trait =` and `unit =`.
- `gllvmTMB/README.md`: wide `traits(...)` and long `value ~ ...`, `trait =`,
  `unit =` routes should reach the same stacked-trait model.
- `GLLVM.jl/docs/src/response-families.md`: Julia GLLVM matrix APIs may use
  response x site orientation, so hsquared must record orientation explicitly if
  a future bridge transposes.

## Relevant lessons

- Preserve user-declared trait order. Do not sort alphabetically by default.
- Current `cbind(...)` order is left-to-right column order.
- Future `traits(...)` order should be left-to-right argument order.
- Future long-data order should use factor levels, first appearance, or an
  explicit `trait_order`, in that preference order.
- Missing response cells should not alter trait order.
- Comparator evidence must record trait order before comparing matrices.

## hsquared action

- Add `docs/design/17-trait-ordering-contract.md`.
- Add pointers from the multivariate and wide-response design notes.
- Mark the twin Phase 4B row "Define long/wide trait ordering" done.

## Claim wording risk

High-risk phrases: "long data supported", "`traits(...)` supported",
"trait_order implemented", "wide-to-long equivalence tested", and "comparator
validated trait order". These remain planned except for the current `cbind()`
ordering invariant already exercised by existing tests.

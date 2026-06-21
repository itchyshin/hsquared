# After-task — single_step(1 | id) hs_data bundle shorthand (2026-06-20 s6)

## Goal

Wire the `hs_data()` bundle shorthand for single-step construction that doc 25
deliberately **deferred**: when `data` is an `hs_data()` container bundling a
pedigree and genotypes, `single_step(1 | id)` should resolve both from the bundle
(the `animal(1 | id)` precedent), so neither `pedigree =` nor `markers =` is
required. A "Users are gold" UX nicety over the proven construction path.

## Shipped

- **`R/model-spec.R`** —
  - `hs_model_data_context()` now carries `id = data$id` (the bundle's id column).
  - `hs_parse_relinv_primary_call(call, data, env, model_data = NULL)` and
    `hs_parse_single_step_construct(..., model_data = NULL)` take the model-data
    context; the call site threads it.
  - single_step routing: construct when explicit `pedigree`/`markers` are present
    **or** (no `Hinv` and the bundle has both pedigree + genotypes).
  - pedigree/markers each resolve from the explicit arg, else the bundle; explicit
    args override.
  - `hs_single_step_bundle_markers()` coerces the genotypes component (matrix →
    as-is; data frame → the bundle's `id` column or explicit row names) into the
    numeric dosage matrix the construction path expects.
  - the supplied-`Hinv` fall-through error for single_step now also points at the
    construction on-ramps (so a bare `single_step(1 | id)` or a partial bundle is
    not left at a `Hinv`-only message).
- **Tests** (`test-single-step-construct.R`) — pure-R: bundle == explicit spec
  parity, explicit-override, the coercion helper, an end-to-end **non-default-id +
  data-frame genotypes** drive (exercises the id-threading), directing-error
  cases; **live**: the bundle shorthand fits identically to the explicit call
  (variance components + GEBVs to 1e-8).
- **Docs** — doc 25 §2/§6 (shorthand LANDED), NEWS single-step bullet,
  capability-status row, `genomic-markers.R` roxygen.

## Honesty

- Pure R sugar over the proven `single_step_construct` path — no new engine
  contract consumed, so no twin coordination needed. Single-step construction
  stays `partial (R)`/experimental/REML-only/dense; promotion twin-gated.
- Adversarial verify (6-lens Workflow) caught **one shared blocker**: the slice
  shipped a failing pure-R test — the reworded "needs a pedigree" error gained a
  backtick that broke a `fixed = TRUE` substring match. `rcmdcheck` reproduced it
  where a `as.data.frame(test_file(...))` summary had masked it (lesson: trust the
  default reporter / `rcmdcheck`, not a hand-rolled count). Fixed the message to
  keep the literal "needs a pedigree" **and** the bundle pointer. Folded the
  majors: stale `?single_step` roxygen ("explicit `pedigree =` is required"); the
  bare/partial-bundle error now directs to construction; an id-threading
  end-to-end test.

## Verification

- `air`; `devtools::document()`; pure-R `test-single-step-construct` **38/0/0/5**;
  **LIVE** `test-single-step-construct.R` **54/0/0/0** on the bridge;
  `pkgdown::check_pkgdown()` clean; `rcmdcheck(args="--no-manual")` **0/0/0**.

## Next

1. Validation depth; await twin (#93 naming map, #61 metafounder/FA payloads;
   `breeding_values_plot_data` parity when the preparer lands).
2. **Pre-existing gap (separate slice):** `formula_status()` does not enumerate
   the single-step *construction* or *bundle* forms (only the supplied-`Hinv`
   example). Adding rows means editing five positionally-synced vectors — left out
   here to stay surgical.

# 38 — Multivariate Grammar Freeze (0.6.0)

> **STATUS: RATIFIED — Boole freeze + maintainer, 2026-07-11** (§H resolved in
> the Ratification section). This is the Boole gate item 4 artifact (auto-routing grammar +
> argument-naming freeze) and a **precondition** of the `0.6.0` multivariate
> covered flip, not a follow-up to it (`docs/dev-log/decisions.md`,
> "2026-07-09: Standard-Tier Covered-Flip Gate", item four:
> `docs/dev-log/decisions.md:100`). It freezes **names and a dispatch predicate**;
> it is **not** the implementation. The default-path auto-route it specifies is
> the MV-4 R-lane slice
> (`docs/design/36-phase3-6-execution-plan.md:115`); the code change (removing the
> default-path abort and wiring the auto-dispatch) lands under this frozen
> contract. Nothing here is binding until Boole freezes it and the maintainer
> accepts it.

## Purpose and scope

The multivariate Gaussian animal model is **engine-covered** in the twin
(`HSquared.jl` `V4-MV-REML`, `partial → covered` on 2026-06-22, HSquared.jl#161;
`docs/design/33-v4-multivariate-promotion-gate-review.md:88`) but the R-public
surface is still **experimental / opt-in**: today it fits only through
`control = hs_control(engine = "julia", engine_control = list(target =
"multivariate"))` (`docs/design/17-trait-ordering-contract.md:33`,
`tests/testthat/test-multivariate.R:444`). The `0.6.0` release promotes the
R-public surface to **covered** (`docs/dev-log/decisions.md:128`). Per the
twin-discipline non-negotiable, that R flip earns its own R-lane evidence and is
not auto-conferred by the engine flip
(`docs/design/36-phase3-6-execution-plan.md` §3.5).

Before that flip, Boole must freeze two things so the promoted surface cannot
drift: **(A)** the auto-routing predicate (how a formula auto-selects the
multivariate engine target), and **(B)** the user-facing argument names for the
multivariate surface. This document is that freeze. It also records the two
adjacent invariants the freeze depends on — family-aware disambiguation and the
trait-ordering / missing-cell marshalling — because a name freeze is meaningless
if either can silently change what `cbind(...)` routes to.

The freeze covers the **2-trait unstructured-`G0` Gaussian pedigree animal
model**, which is the trait count the recovery gate (48-seed, `q=80/n=240`,
2-trait; `docs/design/33-v4-multivariate-promotion-gate-review.md:95`) and the
same-estimand `sommer` comparator (`tests/testthat/test-multivariate.R:509`,
`:608`) actually exercise. The **grammar** admits `k ≥ 2` traits; the **covered
numeric claim** at 0.6 is scoped to `k = 2` (see Open questions).

---

## A. The auto-routing predicate (dispatch key)

### A.1 What changes

**Today (opt-in required).** On the default `engine = "fit"` path a multivariate
response **aborts** and instructs the user to opt in
(`R/hsquared.R:84`–`93`):

```r
# current default-path behaviour
if (isTRUE(spec$response$multivariate)) {
  hs_abort_unsupported_syntax(
    "The multivariate animal model is experimental and opt-in; ...
     Use ... engine_control = list(target = \"multivariate\") ..."
  )
}
```

Fitting requires the explicit `engine = "julia", target = "multivariate"` spelling
(`R/hsquared.R:262`–`278`).

**Frozen at 0.6 (auto-route).** On the default `engine = "fit"` path, a
multivariate Gaussian cbind response **auto-selects** the multivariate REML
target and dispatches to the same fitter the opt-in path uses
(`hs_fit_julia_multivariate_payload`, `R/hsquared.R:262`). The opt-in spelling
`engine = "julia", target = "multivariate"` **remains a valid alias** (back-compat;
no deprecation) but is **no longer required**.

The canonical call that must fit on the default path after the flip:

```r
hsquared(
  cbind(weight, length) ~ sex + animal(1 | id, pedigree = ped),
  data   = dat,
  family = gaussian(),
  REML   = TRUE
)
```

Nothing downstream of the top-level gate needs to change to enable this: the spec
already sets the multivariate target string
(`spec$bridge$target <- "fit_multivariate_reml(Y, X, Z, Ainv; method = :REML)"`,
`R/model-spec.R:346`) and the payload already builds the `Y` matrix and marks
`response_type = "multivariate"` (`R/bridge-payload.R:186`–`195`, `:222`–`231`).
The **only** blocker is the default-path abort at `R/hsquared.R:84`. The freeze
authorises removing that abort and dispatching on the predicate below.

### A.2 The frozen dispatch key

The multivariate REML target is selected **iff** every clause holds:

```text
route → fit_multivariate_reml   ⟺
    isTRUE(spec$response$multivariate)                         # (1) cbind, ≥2 numeric bare columns, Gaussian branch
  ∧ identical(spec$family$family, "gaussian")                 # (2) family gate
  ∧ identical(spec$family$link,   "identity")                 # (3) link gate
  ∧ identical(primary_type, "animal")                         # (4) pedigree-relationship primary
  ∧ is.null(second_spec)                                      # (5) no permanent()/common_env()/maternal_genetic()
  ∧ length(iid_effects) == 0L                                 # (6) no bare (1 | g) i.i.d. effect
  ∧ !identical(spec$random$animal$design, "random_regression")# (7) not an rr(...) design
```

Grounding for each clause:

- **(1)** `spec$response$multivariate` is set to `TRUE` only by the Gaussian
  multivariate branch of `hs_build_response_spec()` — an `is.matrix()` cbind
  response with `≥ 2` numeric columns that is **not** the binomial-counts case
  (`R/model-spec.R:387`–`440`, return at `:434`). This flag *is* the dispatch
  key's core; the freeze pins its meaning.
- **(2)–(3)** `spec$family` is `list(family = family$family, link = family$link)`
  (`R/model-spec.R:352`). On the default path `allow_families = "gaussian"`
  (`R/hsquared.R:64`–`73`) and `hs_validate_model_inputs()` requires the
  identity link for `gaussian` (`R/model-spec.R:729`–`750`), so (2)∧(3) are
  already guaranteed on the default path; they are named explicitly so the
  predicate stays correct if `allow_families` is ever widened on this path.
- **(4)–(7)** already enforced by the multivariate fence in the spec builder,
  which rejects any multivariate response that is not `cbind(...) ~ fixed +
  animal(1 | id, pedigree = ped)` (`R/model-spec.R:324`–`345`). The freeze pins
  that fence: at 0.6 the covered multivariate surface is **pedigree-`animal`,
  random-intercept, single-effect** only.

`primary_type`, `second_spec`, and `iid_effects` are the local bindings in
`hs_build_model_spec()` (`R/model-spec.R:78`–`309`).

### A.3 What the key deliberately excludes

- A **univariate** response (`y ~ ...`) never matches clause (1); the default
  univariate animal-model path is untouched.
- A **`cbind(successes, failures)` binomial** response never matches clause (1)
  (it takes the binomial-counts branch, §B) and never matches (2) on the default
  path (binomial is not in `allow_families`); it is rejected on the default path
  with the existing family error, never fitted as a 2-trait Gaussian.
- **Multivariate + any non-`animal` primary, second effect, i.i.d. effect, or
  `rr(...)` design** fails clauses (4)–(7) and keeps its current "planned, not
  implemented" error (`R/model-spec.R:324`–`345`).

---

## B. Family-aware disambiguation (frozen)

`cbind(a, b)` is overloaded in R model formulas: under `gaussian()` it is a
**2-trait multivariate response**; under `binomial()` it is the canonical
**successes/failures counts** response (the `glm()` convention). The
disambiguation is resolved by **family**, at the response-parse level, **before**
the multivariate branch is reached (`R/model-spec.R:369`–`385`):

```r
# R/model-spec.R:376  — checked FIRST, ahead of the family-blind multivariate branch
if (is.matrix(response) && ncol(response) == 2L && is_cbind &&
    identical(family$family, "binomial") && identical(family$link, "logit")) {
  return(hs_build_binomial_counts_response(lhs, response))   # multivariate = FALSE, binomial_counts = TRUE
}
```

**Frozen contract:**

1. `cbind(t1, t2, ...)` **+ `family = gaussian()`** → multivariate Gaussian
   (`multivariate = TRUE`), routed by §A.
2. `cbind(successes, failures)` **+ `family = binomial()` (logit)** → binomial
   counts (`multivariate = FALSE`, `binomial_counts = TRUE`,
   `R/model-spec.R:473`–`519`), routed to the **non-Gaussian binomial path**
   (currently the opt-in `target = "nongaussian"`;
   `docs/design/31-nongaussian-per-record-trials-activation-plan.md`). It is
   **never** a 2-trait Gaussian.
3. On the **default `engine = "fit"` path**, `binomial()` is not fitted (it is
   not in `allow_families`, `R/hsquared.R:64`–`73`) and errors with the standing
   family message pointing to the non-Gaussian opt-in
   (`R/model-spec.R:735`–`750`). The 0.6 auto-route **does not** change this: it
   promotes only the `family = gaussian()` multivariate case.

This ordering (family check first) is the load-bearing invariant. Boole freezes
it: **the multivariate auto-route is `family = gaussian()`-gated, and no
family-blind path may reach the multivariate branch for a two-column cbind.**

---

## C. Trait ordering and NA → missing-trait marshalling (frozen)

These are inherited from the Trait Ordering Contract
(`docs/design/17-trait-ordering-contract.md`) and pinned here as preconditions of
the flip.

### C.1 Trait order

- `trait_order` = the columns of the evaluated `cbind(...)` response, **in
  left-to-right LHS order**; traits are **never** sorted alphabetically or
  reordered by any downstream concern
  (`docs/design/17-trait-ordering-contract.md:20`, `:46`).
- Trait names come from the evaluated response column names; if those are blank
  or mangled they are recovered from the `cbind(...)` bare symbols
  (`all.vars(lhs)`); the last-resort `trait1, trait2, ...` fallback is recorded
  in diagnostics (`R/model-spec.R:423`–`433`,
  `docs/design/17-trait-ordering-contract.md:56`).
- Names must be **unique and non-empty**; duplicate or empty names fail loud
  before fitting (`hs_validate_multivariate_trait_names()`,
  `R/model-spec.R:521`–`550`; `tests/testthat/test-multivariate.R:33`).
- `cbind(...)` arguments must be **bare column symbols**; a derived column
  (`cbind(y1, y1 + y2)`, `cbind(log(y1), y2)`) is rejected so a trait can never
  be mislabelled (`hs_validate_cbind_bare_columns()`, `R/model-spec.R:556`–`573`).
- `trait_order` flows unchanged through `Y → payload → G0/R0 → EBV → extractor
  tables`. Every trait-indexed extractor output carries names in `trait_order`:
  `dimnames(G_matrix(fit)) == trait_order`,
  `heritability(fit)$trait == trait_order`, `breeding_values(fit)` rows in
  `trait_order` (`docs/design/17-trait-ordering-contract.md:184`–`201`;
  `tests/testthat/test-multivariate.R:343`, `:461`, `:587`).

### C.2 Missing cells

- `NA` **inside** the `cbind(...)` response matrix marks a **missing trait
  record** for that (row, trait) cell; the individual stays in the model and its
  other traits are still used
  (`docs/design/17-trait-ordering-contract.md:65`; the calf-2/`y2` cell in
  `tests/testthat/test-multivariate.R:9`, `:27`).
- A missing cell **does not** change `trait_order` and is **not** a reason to
  drop or move a trait (`docs/design/17-trait-ordering-contract.md:65`).
- The payload carries the response as the `Y` matrix (`payload$y = NULL`,
  `payload$Y = unname(as.matrix(values))`, `R/bridge-payload.R:186`–`195`); the
  live bridge marshals `NA` cells to `NaN` for the engine to mask
  (`tests/testthat/test-multivariate.R:393`).
- **Observed** cells must be finite; each trait column must have **≥ 1** observed
  value (`R/model-spec.R:408`–`422`).
- `NA` in a **fixed-effect** or **grouping** column is **not** a missing-trait
  cell and fails loud (`R/model-spec.R:201`–`208`;
  `tests/testthat/test-multivariate.R:63`).

---

## D. Frozen user-facing argument names

Everything in this table is **API-stable at 0.6** — names, spellings, and the
shape of returned objects for covered multivariate fits (the API Stability
Contract's "STABLE" promise, `docs/design/35-api-stability-contract.md:22`–`46`).
Numerical values are not frozen (they may improve as the engine hardens).

### D.1 Formula / call surface

| Surface | Frozen spelling | Notes |
| --- | --- | --- |
| Response constructor | `cbind(trait1, trait2, ...)` | bare column symbols; left-to-right = `trait_order` |
| Primary term | `animal(1 \| id, pedigree = ped)` | identical to univariate; `animal`, `pedigree`, `1 \| id` frozen |
| Family | `family = gaussian()` | the only family that auto-routes to MV (§B) |
| Method | `REML = TRUE` | ML (`REML = FALSE`) not implemented anywhere |
| Top-level args | `formula`, `data`, `family`, `REML`, `control` | unchanged from `hsquared()` |
| Fixed effects | ordinary formula RHS (`sex + age + ...`) | base-R `model.matrix()` semantics |

### D.2 Extractor surface (covered subset for MV fits)

| Extractor | Frozen output shape | Anchor |
| --- | --- | --- |
| `genetic_covariance()` / `G_matrix()` | `k × k`, `dimnames = trait_order × trait_order` | `test-multivariate.R:343`, `:570` |
| `residual_covariance()` / `R_matrix()` | `k × k`, `dimnames = trait_order × trait_order` | `test-multivariate.R:347`, `:573` |
| `genetic_correlation()` | `k × k`, `dimnames = trait_order × trait_order` | `test-multivariate.R:348`, `:574` |
| `residual_correlation()` | `k × k`, `dimnames = trait_order × trait_order` | `test-multivariate.R:349`, `:575` |
| `heritability()` | long df, one row per trait; columns include `trait`, `estimate` | `test-multivariate.R:461`, `:576` |
| `breeding_values()` / `ranef()` | long df; columns `id`, `trait`, `value`; rows in `trait_order` within id | `test-multivariate.R:587`–`593` |
| `fixef()` | long df; columns `term`, `trait`, `estimate` | `test-multivariate.R:578`–`585` |
| `nobs()` | integer = count of **observed** response cells | `test-multivariate.R:352`, `:463` |
| `logLik()` / core S3 (`print`, `summary`, `coef`) | present; `logLik` errors on non-convergence | `test-multivariate.R:353`, `:356` |

The freeze pins **presence, names, and shape**, not the numbers. Column
*additions* to the long extractor frames (e.g. an interval column) are allowed as
long as the frozen columns keep their names and meaning.

### D.3 Explicitly NOT frozen at 0.6 (stay experimental)

These remain behind the experimental fence
(`docs/design/35-api-stability-contract.md:48`–`69`); they may change or be
removed without a deprecation cycle:

- **Structured-covariance controls.** `engine_control$genetic_structure`:
  `"unstructured"` is the covered default; `"diagonal"` is reachable but
  experimental (no loadings / no rotation ambiguity); `"lowrank"` and
  `"factor_analytic"` are **gated / planned** on a validated rotation convention
  (`R/julia-bridge.R:3170`–`3233`; `tests/testthat/test-multivariate.R:229`).
  `engine_control$rank` is **reserved** and errors
  (`R/julia-bridge.R:3209`–`3231`).
- **Initial values.** `engine_control$initial = list(G0 = ..., R0 = ...)`
  (named PD matrices; `R/julia-bridge.R` `hs_validate_multivariate_initial`,
  `tests/testthat/test-multivariate.R:279`).
- **Iteration / engine knobs.** `engine_control$iterations`,
  `engine_control$julia_project`.
- **The `cov = us()/diag()/lowrank()/fa()` term grammar** — surfaced
  diagnostically only, not a fitting contract at 0.6
  (`docs/design/02-formula-grammar.md:84`–`104`,
  `docs/design/35-api-stability-contract.md:60`).
- **All intervals / SEs on MV fits** — asymptotic delta-method, **not
  coverage-calibrated** (`docs/design/35-api-stability-contract.md:55`).
- **Plot-data payloads** (`genetic_correlation_plot_data`,
  `genetic_pca_plot_data`) — rotation-invariant, eigenstructure-not-loadings,
  experimental (`tests/testthat/test-multivariate.R:464`–`480`).
- **The opt-in spelling itself** — `engine = "julia", target = "multivariate"`
  keeps working as a back-compat alias but is not the promoted surface; its
  stability rides on the default-path auto-route, not on the `engine_control`
  vocabulary.

---

## E. API-stable at 0.6 vs experimental — summary

**Becomes API-stable (STABLE tier) at 0.6:**

1. The **default-path auto-route**: `cbind(≥2 bare gaussian columns) ~ fixed +
   animal(1 | id, pedigree = ped)` with `family = gaussian()`, `REML = TRUE`
   fits the multivariate REML animal model **without** an opt-in control.
2. The **frozen dispatch key** (§A.2) — the exact clause set that selects the
   multivariate target.
3. **Family-aware disambiguation** (§B) — cbind + `binomial()` never becomes a
   2-trait Gaussian.
4. The **`cbind(...)` response grammar** — bare columns, left-to-right
   `trait_order`, unique/non-empty names, derived-column rejection.
5. **NA → missing-trait-cell** semantics (§C.2).
6. The **covered extractor names + shapes** for MV fits (§D.2).

**Stays experimental (no stability promise) at 0.6:**

- `genetic_structure` (incl. `"diagonal"`), `rank`, `initial`, `iterations`, and
  every `engine_control` knob on the MV surface.
- Multivariate combined with genomic / single-step / metafounder / second-effect
  / multi-effect / random-regression — all still `planned`.
- `k ≥ 3` traits: the **grammar** parses them; the **covered numeric claim** is
  scoped to `k = 2` (Open questions).
- All intervals / SEs / plot-data on MV fits.
- The `cov = ...()` term grammar.

This partition must match the `lifecycle` badges and
`docs/design/35-api-stability-contract.md` exactly at flip time.

---

## F. What this freeze does NOT cover

- **It is not the implementation.** Removing the `R/hsquared.R:84` abort, adding
  the default-path auto-dispatch, and (optionally) auto-selecting
  `target = "multivariate"` when `engine = "julia"` is used with no explicit
  target, are MV-4 code tasks executed **under** this frozen contract.
- **It does not promote anything.** The `partial → covered` R flip is the
  separate 0.6 gate event and requires the full Standard-Tier Covered-Flip Gate:
  the component (`G0`/`R0`) external same-estimand comparator, the derived
  (`h2_T`, `r_g`) within-package identity tests + locked citations, the
  textbook/no-anchor disclosure, Darwin's biology sign-off on the
  covariance/correlation, and Rose's audit
  (`docs/dev-log/decisions.md:72`–`104`). This freeze is item **four** of that
  gate.
- **It does not touch the `traits(...)` wide-response future.** `cbind(...)`
  stays the multivariate grammar; `traits(...)` remains planned Phase-6 syntax
  and is out of scope here (`docs/design/16-wide-response-syntax-plan.md:136`–
  `:155`).
- **It does not change the univariate default path** or any non-Gaussian path.

---

## G. Verification checklist (for the flip, under this freeze)

Each item is a test/audit the MV-4 implementation and the 0.6 gate must satisfy;
they verify the freeze holds, not that the estimator is correct (that is the
recovery/comparator gate).

1. **Auto-route:** the canonical call in §A.1 fits on the default path (no
   `hs_control`) and produces a `hsquared_fit` with `spec$target ==
   "multivariate"`. (New default-path analogue of
   `tests/testthat/test-multivariate.R:444`.)
2. **Opt-in alias preserved:** the explicit `engine = "julia", target =
   "multivariate"` call still fits identically (`test-multivariate.R:444`).
3. **Disambiguation:** `cbind(succ, fail) ~ ... , family = binomial()` on the
   default path errors with the family/non-Gaussian message and is never fitted
   as a 2-trait Gaussian; under the opt-in nongaussian target it routes to the
   binomial path.
4. **Order permutation:** `cbind(a, b)` and `cbind(b, a)` produce correspondingly
   permuted `Y`, `G0`/`R0`, `h2`, and EBV outputs, not silently identical labels
   (`docs/design/17-trait-ordering-contract.md:231`).
5. **Missing cell:** a fixture with one missing trait cell keeps the individual
   in the model and `nobs()` counts observed cells only
   (`test-multivariate.R:1`, `:352`).
6. **Fence intact:** multivariate + `genomic()/single_step()/permanent()/
   common_env()/maternal_genetic()/(1|g)/rr(...)` all still error "planned, not
   implemented" (`R/model-spec.R:324`–`345`).
7. **Names unchanged:** the §D.2 extractor names/shapes match the Phase-4 parity
   fixture (`test-multivariate.R:509`).
8. **Badge partition:** every non-covered MV knob (§D.3) carries an experimental
   badge; the covered extractors are not mislabelled
   (`docs/design/35-api-stability-contract.md:93`).

---

## H. Open questions (for Boole / maintainer)

1. **Trait count of the covered claim.** The grammar admits `k ≥ 2`; the
   recovery gate and `sommer` comparator are `k = 2`
   (`docs/design/33-v4-multivariate-promotion-gate-review.md:95`,
   `tests/testthat/test-multivariate.R:509`). Proposal: **freeze the grammar for
   `k ≥ 2` but scope the covered numeric claim to `k = 2` at 0.6**, and either
   (a) keep `k ≥ 3` parseable-and-fittable-but-experimental, or (b) gate `k ≥ 3`
   behind an explicit opt-in until a `k ≥ 3` recovery/comparator leg exists.
   Boole/maintainer to choose (a) or (b).
2. **`engine = "julia"` with no explicit target.** Should a multivariate response
   under `engine = "julia"` and an unset `target` **auto-select**
   `"multivariate"` (symmetry with the default path), or keep erroring and
   require the explicit target? Today it defaults `target` to
   `"fit_animal_model"` and then aborts (`R/hsquared.R:167`–`183`). Proposal:
   auto-select for symmetry; flagged here rather than silently frozen.
3. **Residual structure of the covered claim.** The engine estimates
   **unstructured `R0`**; the in-suite `sommer` CI gate checks a
   **diagonal-residual** target (`tests/testthat/test-multivariate.R:608`,
   `:687`) while the full-unstructured `sommer` parity is a `data-raw` one-time
   run (`docs/design/33-v4-multivariate-promotion-gate-review.md:70`). The freeze
   pins the **grammar/names** (unstructured `R0` is the default surface); whether
   the covered claim's in-suite comparator must be promoted to full-unstructured
   before the flip is a gate decision, not a naming one
   (`docs/design/33-v4-multivariate-promotion-gate-review.md:103`, retained debt).
4. **`"diagonal"` genetic structure at 0.6.** `genetic_structure = "diagonal"`
   is reachable and honesty-clean (no rotation ambiguity;
   `R/julia-bridge.R:3205`). Confirm it stays **experimental** at 0.6 (this
   document's assumption) rather than being promoted alongside `"unstructured"`.

---

## Ratification

- **Boole (formula/API freeze):** **RATIFIED 2026-07-11** — §A (predicate), §B
  (disambiguation), and §D (argument names) frozen as a precondition of the 0.6
  flip.
- **Darwin (biology sign-off on the recovered quantity — the genetic
  covariance/correlation):** tracked separately under the Covered-Flip Gate,
  item three (`docs/dev-log/decisions.md:95`).
- **Maintainer:** **RATIFIED 2026-07-11** — accepts the API-stable-at-0.6
  partition (§E); §H resolved as below.

**§H resolutions (maintainer, 2026-07-11):**

1. **Trait count** — grammar frozen for `k ≥ 2`; the covered numeric claim is
   scoped to `k = 2` at 0.6. `k ≥ 3` stays **parseable-and-fittable-but-
   experimental** (option (a)); no k≥3 opt-in gate.
2. **`engine = "julia"` with no explicit target** — **auto-selects
   `"multivariate"`** for symmetry with the default path.
3. **Residual structure** — unstructured `R0` is the frozen surface; whether the
   in-suite comparator must be promoted to full-unstructured before the flip is a
   **gate** decision (0.6 flip), not part of this freeze.
4. **`diagonal` genetic structure** — stays **experimental** at 0.6.

The default-path auto-route (MV-4) is now authorised to implement against this
frozen predicate.

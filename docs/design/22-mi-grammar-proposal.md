# `mi()` Grammar Proposal for the Animal Model (PROPOSAL)

Status: **planning only, no capability claimed.** There is no `mi()`,
`miss_control()`, `impute_model()`, or missing-data handling in `R/` today, and
no engine support in `HSquared.jl`. This note refines the *syntax surface* for
missing-data handling in hsquared. Every grammar and control choice below is a
**PROPOSAL awaiting maintainer sign-off** (Boole/Ada for syntax; Noether/
Henderson for estimands). It does **not** describe shipped behaviour.

Parent: [`08-missing-data-plan.md`](08-missing-data-plan.md) (the standing
design and FIML/Laplace approach). This note is the Boole-lens refinement of
that parent's "Proposed R syntax surface" section and its open questions 2-4 and
8. Read the parent first; this note assumes its scope, non-scope, and reuse map.

## What this note adds over the parent

The parent records the `mi()` + `miss_control()` design and the sister-repo
reuse map. It does **not** resolve the one structural fork the two R sisters
disagree on: drmTMB treats a missing predictor as **row-level**; gllvmTMB treats
it as a **unit-level** quantity broadcast across a unit's trait rows. hsquared's
animal model is univariate today but multi-trait via `cbind()` is an opt-in
path ([`17-trait-ordering-contract.md`](17-trait-ordering-contract.md)), so the
fork is live the moment `mi()` meets `cbind()`. This note picks the rule, ties
it to hsquared's own grammar, and marks each choice syntax vs estimand.

Provenance for every claim below: `drmTMB/R/missing-data.R` (row-level form,
`miss_control()`/`impute_model()` surface) and `gllvmTMB/R/missing-predictor.R`
(unit-level broadcast, the `mi_group()` level marker, and
`gll_resolve_mi_latent_level()` collapse logic).

## 1. Control + token surface (SYNTAX — Boole/Ada sign-off)

Adopt the parent's surface verbatim; both sisters share it, so cross-package
transfer is free.

```r
# Missing responses (regime A)
hsquared(weight ~ sex + animal(1 | id, pedigree = ped), data = dat,
         family = gaussian(),
         missing = miss_control(response = "include"))

# Missing covariate (regime B, latent path)
hsquared(weight ~ sex + mi(birth_mass) + animal(1 | id, pedigree = ped),
         data = dat, family = gaussian(),
         missing = miss_control(predictor = "model"),
         impute  = list(birth_mass = birth_mass ~ sex + animal(1 | id, pedigree = ped)))

miss_control(response  = c("drop", "include"),  # PROPOSAL default "drop"
             predictor = c("fail", "model"),    # PROPOSAL default "fail"
             engine    = "laplace")             # only accepted value in v1
```

Boole rulings on the surface (each a PROPOSAL):

- **`mi(x)` token, not `latent()`/`model_missing()`** (parent open Q2). Both R
  sisters and the planned `GLLVM.jl` R bridge use `mi()`; keeping it satisfies
  the "R and Julia syntax stay transferable" mantra. `mi()` reads as a verb on
  the variable, parses with the same recursive collector both sisters use
  (`drm_find_mi_calls` / `gll_find_mi_calls`), and is short enough not to crowd
  the common formula. **Recommend `mi()`.**
- **Bare variable only in v1.** `mi(x)`, never `mi(log(x))`, `mi(x:z)`, or
  `mi(x) + mi(w)`. Both sisters enforce exactly this (`length(mi_call) == 2 &&
  is.symbol(...)`, and the `term.labels` identity check that rejects `mi()`
  inside interactions). The error must name the unsupported form and point at
  `y ~ z + mi(x)` (mantra: "name the unsupported syntax").
- **`impute = list(<var> = <var> ~ <rhs>)`**, a one-element named list whose
  name (if given) and LHS must both equal the `mi()` variable (parent open Q3).
  A bare formula is Gaussian sugar; `impute_model(x ~ rhs, family = ...)` is the
  non-Gaussian factory. v0.1 needs only the Gaussian path, so
  `impute_model()` can be stubbed/deferred without blocking the M2 slice.
  **Recommend formula-list shape**, matching both sisters.
- **`miss_control()` separate from `hs_control()`** (parent open Q1). Missingness
  policy is statistical (changes the estimand/likelihood), not executional
  (engine, tolerances). Keeping it a distinct argument mirrors both sisters and
  keeps `hs_control()` about *how to fit*, not *what is being fit*. **Recommend
  separate `missing =` argument.**
- **Defaults `response = "drop"`, `predictor = "fail"`** (parent open Q5).
  Backward-compatible: today's complete-case behaviour is preserved bit-for-bit
  when the user passes nothing. An applied user who never touches `mi()` sees no
  change. **Recommend conservative defaults.** (`"include"`-by-default is an
  estimand change and is Noether/Henderson's call, not Boole's.)

## 2. Missing response vs missing predictor (mixed SYNTAX + estimand)

Two regimes, exactly as the parent. Boole's concern is that the *grammar* keeps
them visibly distinct, because they are different estimands.

- **Missing RESPONSE — `miss_control(response = "include")`.** No token in the
  formula; the missingness is read from `NA` in the response column. The row is
  retained, contributes zero likelihood via an observed-`y` mask, and keeps its
  design row so its EBV/fitted value stays defined. Both sisters implement this
  as a logical mask parallel to `y` (`drm_tmb_observed_y`, gllvmTMB
  `is_y_observed`). For the animal model this is the ASReml-like behaviour the
  directive names: a pedigree member with no phenotype still gets a predicted
  breeding value through its relatives. **Syntax:** none beyond the control
  switch. **Estimand (Henderson/Fisher):** the masked row's EBV is a pure
  prediction from the relationship structure; confirm it is reported as EBLUP /
  conditional mode, never "posterior mean".
- **Missing PREDICTOR — `mi(x)` + `miss_control(predictor = "model")` +
  `impute =`.** The missing `x` becomes a latent variable integrated by Laplace,
  conditional on the predictor model in `impute`. The predictor model's RHS may
  carry hsquared structured terms so the latent covariate borrows the right
  covariance (section 4). **Syntax:** the `mi()` token plus the `impute` formula.
  **Estimand (Noether/Henderson):** the joint density factorisation
  `p(y | x) · p(x | predictor model)` and the level-aware covariance.

Grammar guard (both sisters enforce, Boole endorses): `mi()` without
`predictor = "model"` is a loud error, and `impute =` without
`predictor = "model"` is a loud error. The token and the control switch must
agree, so the user cannot half-declare a missing-predictor model.

## 3. Row-level vs unit-level broadcast for multi-trait (the fork)

This is the one structural difference between the sisters, and the heart of this
note.

- **drmTMB (`R/missing-data.R`):** `mi(x)` is **row-level**. The latent vector
  `x_miss` has one entry per missing data row; the covariate density is
  evaluated per row. Correct when each row is an independent record.
- **gllvmTMB (`R/missing-predictor.R`):** `mi(x)` is **unit-level**. The missing
  `x` is one quantity per unit, broadcast across all trait rows of that unit
  (`mi_unit_id` maps long rows to units; `x_full(u)` is broadcast to every row
  of unit `u`). The Gaussian covariate density is evaluated once per unit. The
  package documents this as "the ONE structural adaptation vs drmTMB", and notes
  that for singleton units it **collapses to the per-row drmTMB form** — the
  cross-package contract.

### Boole ruling for the animal model (PROPOSAL)

**The latent-bearing level is the animal (the `id` keyed by `animal()`), not the
data row.** A covariate measured on an animal — birth mass, a genotype score, a
maternal trait — is a property of the animal, recorded once, and shared by every
record of that animal. The gllvmTMB unit-level rule is the correct one; drmTMB's
row-level form is the special case where each animal has exactly one record.

This lands cleanly on hsquared's two multi-trait layouts:

- **Wide `cbind()` layout** (`cbind(weight, length) ~ sex + mi(birth_mass) +
  animal(1 | id, ...)`): one row of `Y` per animal, traits across columns. The
  unit is already the row, so the broadcast is across the **trait columns** of
  that row. `mi(birth_mass)` is one latent per animal, shared by the `weight`
  and `length` equations. No long-row map is needed in the wide layout; the
  animal *is* the row. This is the natural, low-friction case.
- **Repeated-records / future long layout** (multiple rows per `id`, e.g.
  repeatability models with `animal()` + a permanent-environment effect): the
  unit is the animal, several rows share it, and the gllvmTMB `mi_unit_id`
  broadcast applies directly — one latent `birth_mass` per animal, broadcast to
  every record.

**Consequence for grammar:** the broadcast level is **inferred from the
`animal()`/`id` key**, which hsquared already has, so the *common* animal-level
case needs no extra token. This is more ergonomic than gllvmTMB, which has no
pedigree key and therefore must default to the wide-row `unit` and offer
`mi_group(g)` to name a coarser level.

**Borrow `mi_group(g)` only for the coarser-than-animal case (PROPOSAL,
defer past M2).** A covariate at a level *above* the animal — a contemporary
group, a cohort, a *species* in a multi-species pedigree — is the directive's
"species → pedigree/relmat" target. For that, adopt gllvmTMB's marker inside the
impute RHS:

```r
impute = list(group_feed = group_feed ~ mi_group(cohort))   # x lives at cohort level
```

Validation must enforce gllvmTMB's invariant: `x` is **constant within its
level** (one observed value per animal, or per group). gllvmTMB aborts loudly
when `x` varies within a unit/group ("must be constant within a unit" / "must
have one observed value per group"); hsquared must do the same, because a
within-level-varying `mi()` is almost always a data error or a wrong-level
declaration. **Default level = animal (`id`); `mi_group()` is opt-in for a
coarser level; both are estimand-bearing and need Noether/Henderson sign-off on
the level semantics, not just Boole on the token.**

## 4. Interaction with the pedigree / relationship structure (estimand — Noether/Henderson)

The predictor model's RHS may carry hsquared's structured terms so the latent
covariate borrows the right covariance. This is where the animal model is
*richer* than either sister.

- **Animal-level latent covariate with genetic structure.** When the missing
  covariate is itself heritable (birth mass, a trait used as a predictor of
  another), the impute RHS can carry `animal(1 | id, pedigree = ped)` so the
  latent `x` field is `N(0, sigma_x^2 A)` through the **same sparse `Ainv`**
  already marshalled for the response model's `animal()` term. gllvmTMB does
  exactly this with `phylo(1 | species, tree =)` inside the impute formula, and
  the parent's reuse map names the `animal()`-in-impute-formula analogue. Boole's
  syntax point: the impute RHS reuses the *identical* `animal()`/`relmat()`
  grammar as the main formula — no new covariance vocabulary. The error surface
  and parser are shared.
- **`relmat(1 | id, K = K)`** for a genomic/known relationship matrix, same
  pattern, same grammar.
- **Intercept-only structured term in v1.** Both sisters restrict the structured
  impute term to an intercept (`gllvmTMB` rejects `phylo(1 + z | species)`;
  `drmTMB` requires `(Intercept)` only). hsquared should match: `animal(1 | id,
  ...)` in the impute RHS, not a structured slope. Error names the restriction.
- **Identifiability flag (parent open Q8 — ESTIMAND, hard gate for
  Noether/Henderson/Fisher).** When the **response** model carries `animal(1|id)`
  *and* the **predictor** model for `mi(x)` also carries `animal(1|id)` on the
  same `id`, the two additive-genetic fields are on the same level and may be
  weakly identified or confounded. gllvmTMB's design-59 warns of exactly this and
  defaults to *independent* structure. hsquared needs its own ruling: this is
  **not** a Boole syntax call. Boole's only contribution is that the grammar must
  make the choice *visible* (the user writes `animal()` in the impute RHS
  explicitly; nothing is silently inferred), so the maintainers can attach a
  warning or a documented identifiability condition to a syntactically explicit
  term. **Recommend: explicit level declaration in the impute RHS (parent open
  Q4), never inferred from `hs_data()` keys, precisely so the confounding case is
  legible to the reader and to the validator.**

## 5. Syntax vs estimand split (the sign-off map)

| Choice | Class | Sign-off |
| --- | --- | --- |
| `mi()` token name and bare-variable-only rule | Syntax | Boole / Ada |
| `miss_control(response, predictor, engine)` shape + arg names | Syntax | Boole / Ada |
| `impute = list(x = x ~ rhs)` shape; `impute_model()` factory | Syntax | Boole / Ada |
| `missing =` separate from `hs_control()` | Syntax | Boole / Ada |
| Conservative defaults `response="drop"`, `predictor="fail"` | Syntax (back-compat) | Boole / Ada |
| Error wording for unsupported `mi()` / mismatched control | Syntax | Boole / Ada |
| **Default broadcast level = animal (`id`)** | **Estimand** | Noether / Henderson |
| **`mi_group(g)` coarser-level semantics** | **Estimand** | Noether / Henderson |
| **Within-level constancy invariant for `mi(x)`** | **Estimand** | Noether / Henderson |
| **Masked-response EBV interpretation (EBLUP, no posterior)** | **Estimand** | Henderson / Fisher |
| **Level-aware predictor covariance (`Ainv` borrow)** | **Estimand** | Noether / Henderson |
| **Same-level `animal()` confounding ruling (parent Q8)** | **Estimand** | Noether / Henderson / Fisher |
| `"include"`-by-default response policy (if reconsidered) | Estimand | Henderson / Fisher |

Boole signs off the rows marked Syntax. The Estimand rows are flagged here so
the grammar exposes them explicitly, but they are **not** Boole's to approve.

## Files that must change together when this is implemented (not now)

Listed for the eventual M1/M2 slice so the change set stays coherent. **No edit
is proposed in this note.**

- [`08-missing-data-plan.md`](08-missing-data-plan.md) — parent; update its
  "Proposed R syntax surface" to reference this note's level ruling.
- [`02-formula-grammar.md`](02-formula-grammar.md) — add `mi()` and `mi_group()`
  to the grammar table and the unsupported-syntax error catalogue.
- [`17-trait-ordering-contract.md`](17-trait-ordering-contract.md) — record that
  a `mi()` latent is animal-level and broadcasts across `cbind()` trait columns.
- [`03-engine-contract.md`](03-engine-contract.md) — Hopper records the payload
  additions (`observed_response` mask; `mi_family`, `mi_observed`, the level map,
  structured-precision handle) at the bridge boundary.
- `R/formula-status.R` — once implemented, move `mi()` from absent to its honest
  status; until then it must stay unlisted (Rose gate: no claim leaks).
- [`06-public-claims-register.md`](06-public-claims-register.md) /
  `capability-status.md` — keep missing-data as PLANNED until M1 lands.

## Summary (3 lines)

1. Adopt the parent's `mi()` + `miss_control()` + `impute =` surface verbatim
   (shared with drmTMB and gllvmTMB); Boole signs off the token, control shape,
   conservative defaults, and error wording as SYNTAX.
2. Resolve the row-level (drmTMB) vs unit-level (gllvmTMB) fork in favour of
   **animal-level**: a `mi(x)` latent is one quantity per `animal()`/`id`,
   broadcast across `cbind()` trait columns (wide) or repeated records (long),
   collapsing to the row-level form for singleton animals.
3. The level rule, the within-level constancy invariant, the `Ainv`-borrowing
   predictor covariance, and the same-level `animal()` confounding question are
   ESTIMANDS requiring Noether/Henderson (and Fisher) sign-off — not Boole's —
   and the grammar is designed so each is explicit and legible, never inferred.

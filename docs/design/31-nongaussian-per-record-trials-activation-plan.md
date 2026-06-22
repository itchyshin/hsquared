# Per-Record Varying-Trial Binomial Activation Plan (R formula/bridge)

Status: **PLAN ONLY.** This is a design plan for activating per-record
varying-trial Binomial responses in the R formula/bridge surface. It does **not**
activate them. As of this writing the R `cbind(successes, failures)` route still
requires equal row totals (a single common trial count), and that constraint
stands until the live R-Julia round-trip in §Tests/§Gates passes on the Codex
lane. Nothing here promotes the non-Gaussian capability beyond `partial`.

Authoring lens: Boole (formula/API), with the gap and round-trip framed for
Hopper (bridge) and Curie (tests). Builds on, and does not restate,
`docs/design/21-nongaussian-la-va-method.md` (the LA/VA method contract). Read
that first for the family enum, the `NonGaussianFit` result shape, the loglik vs
ELBO distinction, and the load-bearing Bernoulli/binomial caveats; this plan
narrows to one item it lists as `planned`: per-record varying `n_trials`.

## Purpose

The R bridge currently models a `binomial(logit)` `cbind(successes, failures)`
response only when every record has the **same** number of trials (equal
`successes + failures`). The Julia engine's `BinomialResponse` already supports a
**per-record** trial vector `n_trials[i]` (the basis the non-Gaussian fixture
already serializes), and the R normalizer already round-trips a serialized
`n_trials` vector at the payload boundary. The one missing link is the R
**formula path**: the parser deliberately rejects unequal `cbind` row totals
instead of building a per-record `n_trials` vector. This plan specifies the
parser, payload, normalizer-confirmation, family-awareness, test, and claim-gate
steps to close that link — and the explicit boundary that none of it is live in R
until the Codex-lane round-trip test passes.

Why it matters for users (Pat lens): unequal trials per record is the **common**
binomial-counts case in breeding/ecology data (different numbers of eggs, seeds,
offspring, or repeated assays per individual). Forcing equal row totals makes the
counts route usable only for balanced designs; the unbalanced case is exactly
where users reach for a binomial-counts GLMM. The engine can already do it
honestly; the R surface is the gap.

## Current state

### What `cbind(successes, failures)` does now

Under `family = binomial(link = "logit")`, a two-column `cbind(successes,
failures)` left-hand side is detected as a **binomial-counts** response (the R
`glm` convention), not a two-trait multivariate Gaussian. The family-aware branch
that does this is `hs_build_response_spec()` in `R/model-spec.R:308-317`, which
routes to `hs_build_binomial_counts_response()` (`R/model-spec.R:405-456`) *before*
the family-blind multivariate `cbind` branch. The success column is the modelled
response; the per-record trial count is `successes + failures`. A binary 0/1
response under `binomial()` stays Bernoulli (no `cbind`, no counts).

### Where the equal-totals guard lives (cite)

The constraint is enforced in `hs_build_binomial_counts_response()` at
**`R/model-spec.R:437-446`**:

```r
n_trials <- unique(totals)
if (length(n_trials) != 1L) {
  stop(
    "`cbind(successes, failures)` row totals (successes + failures) must all ",
    "be equal: the engine's binomial family uses a single common trial count. ",
    "Per-record varying trial counts are a planned engine follow-up ",
    "(HSquared.jl binomial per-record n_trials).",
    call. = FALSE
  )
}
```

`totals <- successes + failures` is computed at `R/model-spec.R:429`. The spec
field that leaves this function is a **scalar** `n_trials = as.integer(n_trials)`
(`R/model-spec.R:454`), carried as `spec$response$n_trials`. This is the single
line that must change to admit a per-record vector; everything downstream keys off
the value it produces.

Two downstream consumers also currently assume a scalar `n_trials` and must be
audited as part of activation (they do not enforce the equal-totals rule, but they
encode the scalar assumption):

- **Family-symbol mapper** `hs_nongaussian_family_symbol()`,
  `R/julia-bridge.R:438-455`. It returns `"binomial"` only when
  `!is.null(n_trials) && n_trials > 1L` (`R/julia-bridge.R:443`); on a *vector*
  `n_trials`, `n_trials > 1L` is a length-n logical and `if (...)` would use only
  the first element — a silent mis-classification risk (see §Family-awareness).
- **Bridge marshalling** `hs_fit_julia_nongaussian_payload()`,
  `R/julia-bridge.R:521-544`. It does `JuliaCall::julia_assign("hsq_n_trials",
  as.integer(n_trials))` and builds the engine keyword `n_trials_kw <- "n_trials =
  Int(hsq_n_trials), "` (`R/julia-bridge.R:543-544`) — `Int(...)` is a scalar
  coercion that would error on a vector. The payload itself is carried verbatim at
  `R/bridge-payload.R:96-98` (`n_trials = spec$response$n_trials`), which is
  shape-agnostic and needs no change.

### What the engine + normalizer already support

- **Engine.** `HSquared.jl`'s `BinomialResponse` carries per-record trials (the
  per-record `n_trials[i]` path referenced as the twin's binomial-trials work);
  `fit_laplace_reml(...; family = :binomial, n_trials = ...)` accepts the vector.
  This is engine provenance, not an R claim.
- **Normalizer.** The R result normalizer already preserves a serialized
  `n_trials` vector when an engine payload supplies one: `R/julia-bridge.R:592-594`
  coerces `raw$n_trials` with `as.integer(...)` (shape-preserving — a vector stays
  a vector) and `R/julia-bridge.R:648-649` attaches it to the result. This is the
  *read* (engine -> R result) direction.
- **Fixture.** `tests/testthat/fixtures/non_gaussian_parity/` already pins a
  per-record vector: the `binomial_vector_variational` case serializes `n_trials =
  2;4;5;6;10;12` (`expected_payload_metadata.csv`) from
  `binomial_phenotypes.csv` (trials `2,4,5,6,10,12`). The fixture README is
  explicit that it "does not activate non-Gaussian R formula parsing".

### The crucial distinction (do not conflate)

The normalizer preserving a serialized `n_trials` vector is **not** the same as
live R formula activation. The fixture exercises the *read* path (a hand-written
Julia payload -> R result) with **no R formula parse and no live engine call**.
Activation requires the *write* path: an unbalanced R `cbind(...)` formula ->
per-record `n_trials` vector in the spec/payload -> live engine fit ->
round-tripped result. That write path is fenced today by the
`R/model-spec.R:437-446` guard. Passing the fixture says the result shape is
understood; it does not say the formula can produce a varying-trial fit.

## The gap

One concept: a per-record varying trial count `n_trials[i]` from an **unbalanced**
`cbind(successes, failures)` response.

- **Engine:** supports it (`BinomialResponse` per-record `n_trials`).
- **Normalizer (read):** preserves it (`R/julia-bridge.R:592-594`, `648-649`).
- **Fixture:** serializes it (`binomial_vector_variational`).
- **R formula (write):** **rejected** at `R/model-spec.R:437-446`.

The gap is exactly the write path. The guard converts "honest engine capability"
into "unsupported R syntax" with a clear message. Activation flips that single
guard from a rejection into a per-record vector build, and propagates the vector
shape through the two scalar-assuming consumers above.

## Activation design

Each step is independently reviewable (Boole/Hopper barrier on the parser+payload
shape before any live wiring, per the §2 barrier in
`docs/design/21-nongaussian-la-va-method.md`).

### 1. Parser change (`R/model-spec.R`, `hs_build_binomial_counts_response`)

Replace the equal-totals rejection at `R/model-spec.R:437-446` with a per-record
vector build:

- Keep every existing validation **unchanged**: numeric (`:408-413`), finite/no-NA
  (`:414-419`), non-negative integers (`:422-428`), and the
  `totals >= 1` per-record minimum (`:429-436`). These are correct for per-record
  trials too — each record still needs `>= 1` trial.
- Replace `n_trials <- unique(totals); if (length(n_trials) != 1L) stop(...)` with
  `n_trials <- as.integer(totals)` — a **length-n integer vector** of per-record
  trials (no longer collapsed by `unique()`).
- Return `n_trials` as that vector in the spec field (`R/model-spec.R:454`). The
  `binomial_counts = TRUE` flag and the success-count `values` are unchanged.

Naming/parseability (Boole): the user-facing grammar does **not** change —
`cbind(successes, failures)` already reads as the binomial-counts response. The
only behavioural change is that unbalanced totals stop erroring. No new argument,
no new marker, nothing for users to memorize. This keeps the "easy, easy, easy"
mantra: the common unbalanced case just works, with the same syntax breeders
already know from `glm`.

A balanced design remains a valid special case: `n_trials = c(3,3,3,3)` is a
length-n vector whose elements happen to be equal — semantically identical to the
old scalar `3`. The engine treats Bernoulli as the all-ones case, so a
`cbind(y, 1-y)` response yields `n_trials = c(1,1,...)` and still maps to the
Bernoulli reduction (see §Family-awareness).

### 2. Bridge payload (carry `n_trials` as a length-n vector)

- `R/bridge-payload.R:96-98` already carries `n_trials = spec$response$n_trials`
  verbatim — **shape-agnostic, no change needed**. It will carry the vector once
  the parser produces one. (Confirm the comment at `R/bridge-payload.R:96-97`,
  which says "Common per-record trial count", is reworded to "per-record trial
  count vector" so the payload contract reads honestly.)
- **Marshalling must change** (`hs_fit_julia_nongaussian_payload`,
  `R/julia-bridge.R:543-544`). The scalar coercion `n_trials = Int(hsq_n_trials)`
  must become a vector marshal: assign the integer vector and pass it as
  `n_trials = Vector{Int}(hsq_n_trials)` (or the engine's accepted vector
  keyword). The exact keyword/type is a Hopper/engine confirmation item — match
  whatever `fit_laplace_reml(...; n_trials = <vector>)` expects on the twin lane.
  Verify length-1 and length-n both marshal (a single-record balanced fit must
  still work).

### 3. Normalizer (already preserves it — confirm)

No change required for the read path. `R/julia-bridge.R:592-594` and `:648-649`
already preserve a vector `n_trials`. Activation should add a **test** (not code)
asserting the round-tripped result `n_trials` equals the input per-record vector,
to pin that the write path and the read path agree. Re-confirm during
implementation that no intermediate step (e.g. a length check or a `[[1L]]`
extraction) collapses the vector.

### 4. Family-awareness (must stay Binomial, never a 2-trait MV Gaussian)

Two guarantees, both load-bearing:

- **Never silently multivariate.** The family-aware `cbind` detection at
  `R/model-spec.R:308-317` already routes a `binomial()`-with-`cbind` response to
  the binomial-counts builder *before* the multivariate branch. This is the
  silently-wrong bug that was fixed (coordination board 2026-06-20): a binomial
  `cbind` must not be modelled as two Gaussian traits. Activation must not
  reorder, weaken, or bypass this branch. A guard test must keep asserting it
  (see §Tests).
- **Never silently Bernoulli.** `hs_nongaussian_family_symbol()`
  (`R/julia-bridge.R:438-455`) currently classifies via `n_trials > 1L`
  (`:443`). On a **vector** `n_trials`, `n_trials > 1L` is length-n and `if (...)`
  silently uses element 1 only — so a vector like `c(1, 4, 5)` (first element 1)
  would mis-map to `"bernoulli"` and **drop the trial counts**. This must change to
  a vector-safe rule. Proposed rule, stated for Boole/Hopper sign-off:
  - `family == "binomial"`, `n_trials` is `NULL` or every element `== 1`  ->
    `"bernoulli"` (the all-ones reduction);
  - `family == "binomial"`, `n_trials` has any element `> 1`  -> `"binomial"`
    (carry the vector);
  - i.e. use `all(n_trials == 1L)` / `any(n_trials > 1L)`, not a scalar compare.
  This keeps the existing scalar-`n_trials` unit tests (`test-binomial-counts.R`
  lines 89-106) passing — a scalar is the length-1 case of the same rule — while
  making the vector case correct.

The single rule "every trial == 1 means Bernoulli, otherwise Binomial" is the only
place family classification depends on `n_trials`; it must be the one source of
truth so the parser, payload, and engine agree on the family symbol.

## Tests to add

Three layers; the first two are pure-R and Claude-draftable, the third is the
live gate (Codex). Mirror the existing structure in
`tests/testthat/test-binomial-counts.R` (which has the current
`"varying row totals errors clearly"` test at lines 40-57 — that test must be
**inverted** on activation: varying totals should now build a vector, not error).

Pure-R (no Julia), Claude-draftable:

1. **Parser builds a per-record vector.** An unbalanced `cbind(succ, fail)` with
   totals e.g. `c(3, 3, 4, 3)` builds `spec$response$binomial_counts == TRUE`,
   `spec$response$n_trials == c(3, 3, 4, 3)` (integer, length n, order-preserving),
   and `spec$response$values == succ`. This replaces the current
   error-expecting test at `test-binomial-counts.R:40-57`.
2. **Balanced totals still collapse to equal elements, not a scalar.** Totals
   `c(3,3,3,3)` build `n_trials == c(3,3,3,3)` (a length-n vector, semantically the
   old scalar) — pin the shape so a later refactor cannot silently re-collapse it.
3. **All-ones reduces to Bernoulli.** `cbind(y, 1-y)` builds `n_trials` all-ones
   and the family symbol resolves to `"bernoulli"`.
4. **Payload carries the vector.** The built payload has `n_trials` equal to the
   per-record vector (shape preserved through `R/bridge-payload.R:96-98`).
5. **Family-symbol mapper is vector-safe.** `hs_nongaussian_family_symbol(...,
   n_trials = c(1, 4, 5))` returns `"binomial"` (regression guard for the
   element-1 silent-Bernoulli risk); `c(1,1,1)` returns `"bernoulli"`; scalar
   cases from lines 89-106 still hold.
6. **Read-path round-trip (normalizer).** A serialized vector `n_trials` (reuse
   the `binomial_vector_variational` fixture) normalizes to the same vector —
   confirms the read path already in place (`R/julia-bridge.R:592-594`,`648-649`).
7. **Family guard (still family-checked).** Two guards that must survive
   activation:
   - a `binomial()` `cbind` with varying totals is **no longer rejected** (it
     builds a binomial-counts spec) — but is **still family-aware**: it is
     `binomial_counts == TRUE`, never `multivariate == TRUE`;
   - a `gaussian()` `cbind` is **still** multivariate (no regression of the
     family-blind-bug fix) — i.e. removing the equal-totals guard must not leak
     the binomial branch into the Gaussian path.

Live (skip-guarded, Codex lane — requires JuliaCall + Julia + local
`HSquared.jl`):

8. **Live round-trip vs the engine.** An **unbalanced** `cbind(succ, fail)` fit
   through `target = "nongaussian"` must (a) succeed, (b) report
   `result$family == "binomial"`, (c) match a direct
   `fit_laplace_reml(...; family = :binomial, n_trials = <vector>)` element-wise to
   tolerance (mirror the balanced live test at `test-binomial-counts.R:108-148`,
   but with varying `n_trials`), and (d) report **no heritability** (latent
   scale). This is the test that actually authorises the claim change; it cannot
   run in the Claude lane.

## Validation / claim gates

Activation of per-record varying trials may be claimed in `capability-status.md`
and `validation-debt-register.md` **only** when:

1. the live round-trip test (§Tests #8) passes against `HSquared.jl` and is
   recorded in `docs/dev-log/check-log.md` with exact commands and outcome;
2. the pure-R parser/payload/family-symbol tests (§Tests #1-7) pass under
   `devtools::test()`;
3. **no heritability** is reported for any binomial fit (the latent-scale honesty
   gate from `docs/design/21-nongaussian-la-va-method.md` §3 is unchanged — there
   is no residual-variance scale, so no `h2`);
4. the non-Gaussian capability **stays `partial`** — this widens the accepted
   input shape (balanced -> unbalanced trials) but adds **no** comparator,
   calibration, or recovery evidence and triggers **no** promotion. The Bernoulli
   small-information `sigma_a2` boundary caveat and the loglik-vs-ELBO labelling
   (§21 caveats) still apply verbatim.

This plan does **not** clear gates 1-2; it specifies them. Until gate 1 passes on
the Codex lane, every status row must keep the current wording: "single common
trial count; equal `cbind` row totals required ... per-record varying-trial
formula activation remains a planned follow-up."

### Files that must change together (on activation, not now)

- `R/model-spec.R` (parser: the guard at `:437-446` -> vector build at `:454`).
- `R/julia-bridge.R` (family-symbol mapper `:443`; marshalling `:543-544`).
- `R/bridge-payload.R` (comment `:96-97` only; the carry at `:98` is unchanged).
- `tests/testthat/test-binomial-counts.R` (invert the `:40-57` error test; add
  §Tests #1-8).
- `docs/design/21-nongaussian-la-va-method.md` (the "Update (...)" notes near
  `:262` and `:270` that list per-record varying `n_trials` as `planned`).
- `docs/design/capability-status.md` (the `hsquared()` fit-entry row, line 16, and
  the simple-Gaussian/non-Gaussian wording at line 39's neighbourhood).
- `docs/design/validation-debt-register.md` (the experimental non-Gaussian bridge
  row, line 36, with the "equal `cbind` row totals required" clause).
- `docs/design/19-on-main-bridge-gap.md` (the bridge-gap row at `:68` and the
  remaining-gaps note at `:91`).
- `docs/dev-log/coordination-board.md` + a `docs/dev-log/check-log.md` entry +
  an after-task report (Definition of Done).

## Lane split

- **R-draftable now (Claude):** the parser change, the payload comment, the
  family-symbol vector-safe rule, and pure-R parser/payload/family-symbol/
  normalizer tests (§Tests #1-7). These need no Julia and can be written and
  locally verified with `devtools::test()` (skip-guarded live tests skip cleanly).
- **Codex (live verification):** the skip-guarded live round-trip (§Tests #8) and
  the marshalling against the real engine keyword/type
  (`R/julia-bridge.R:543-544`). Claude cannot run JuliaCall here, so Claude cannot
  authorise the claim change. The marshalling code can be **drafted** by Claude but
  its correctness against the engine vector keyword is a Codex confirmation.
- **Twin (engine, no edits from this repo):** the engine already supports the
  per-record path; no Julia edit is requested by this plan. If the engine's vector
  keyword name/type differs from the scalar one, that is a Hopper coordination item
  recorded on the board, not an edit made from the R lane.

## Claim boundary

- This is a **plan**. Per-record varying-trial Binomial models are **not**
  activated in R. The `R/model-spec.R:437-446` equal-totals guard stands, and the
  R `cbind(successes, failures)` route still requires equal row totals today.
- The R normalizer preserving a serialized `n_trials` vector (the fixture read
  path) is **not** live formula activation. No R formula parse, no live engine
  call, is exercised by that fixture.
- Activation requires the live R-Julia round-trip test (§Tests #8), which is the
  **Codex** lane. Claude cannot run JuliaCall in this environment and therefore
  cannot verify or claim activation.
- Non-Gaussian stays **`partial`** (latent/liability scale, no heritability). This
  plan adds **no** comparator, calibration, or recovery evidence and proposes
  **no** promotion. All Bernoulli/binomial caveats from
  `docs/design/21-nongaussian-la-va-method.md` remain in force.

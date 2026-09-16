# check-log — 2026-09-02 h2 A21 C1/C2/C3: `rr()` argument naming + the RR heritability accessor

**Arc:** A21 HOLD-WITH-CONDITIONS, conditions **C1**, **C2**, **C3**
**Lane:** `claude/lane-h2-twin-20260901` @ `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Trigger:** `~/local-scratch/h2-a21-estimand-claim-panel-2026-09-02.md` §3.1, §3.2, §6
**Lens:** Boole (grammar / argument naming / error contracts), with Pat on the reader path

## The gap

Two public surfaces asserted a formula the parser **refuses** and an accessor that
**does not exist**, on a route the same paragraph calls `covered`:

- `rr(t, k = 2)` — the parser accepts only `rr(covariate, order = k)`
- "`heritability()` returns h²(t) as a CURVE" — the RR accessor is `rr_heritability()`;
  `heritability()` had no RR branch and fell through to a generic
  *"part of the planned v0.1 contract"* miss

Both are **verified false statements**, not stylistic drift. The second is the worse
reader failure: its trailing clause ("a scalar call errors") is *accidentally true*, so
the sentence looks verified, while the error a user actually received said **planned** on
a route the same page called **covered**. A Pat-lens reader concludes either that the
package is stale or that the covered claim is false. Both conclusions are wrong.

## What was measured first (live, not read)

| Check | Method | Result |
|---|---|---|
| `rr(age, k = 2)` | live `hsquared()` | ERROR — "argument `k` is planned, not implemented … accepts only `rr(covariate, order = k)`" |
| `rr(age, order = 2)` | live `hsquared()` | grammar accepted; stops at the opt-in fence |
| `rr_heritability` exported | `getNamespaceExports()` | TRUE |
| RR normalizer fields | `R/julia-bridge.R` `hs_normalize_random_regression_result` | no `heritability` field, so the generic miss was structural, not incidental |
| Is the fix already on another ref? | `git show <ref>:…` across **all** 30+ local/remote refs | **no ref** carries `order = 2` here; **every** ref carries `rr(t, k = 2)` |

That last row matters for lane safety: the defect is **inherited from `main`**, universal
across branches, and no one else is mid-fix, so this is not a forked second fix.

A third defective surface the panel did not list was found by grep: `R/formula-status.R`,
which is **printed to users** by `formula_status()`.

## What changed

| File | Change |
|---|---|
| `docs/design/06-public-claims-register.md` | RR row: `rr(t, k = 2)` → `rr(t, order = 2)`; the h²(t) clause now names `rr_heritability()` and states that `heritability()` errors and points at it |
| `vignettes/articles/model-status.Rmd` | same two fixes in the published pkgdown article |
| `R/formula-status.R` | the RR behaviour string now names `rr_heritability()` as the accessor (third surface, found by grep) |
| `R/extractors.R` | **C3** — `heritability.hsquared_fit()` gains an RR branch: a target-named scope error naming `rr_heritability()` / `rr_genetic_variance()` / `rr_correlation()` / `rr_eigenfunctions()`, plus the matching roxygen fence paragraph |
| `tests/testthat/test-random-regression.R` | two scoped contract tests + an `hs_rr_mock_fit()` helper built through the **real** normalizer |
| `man/heritability.Rd` | regenerated |

C3 is **message-only** — `heritability()` still refuses on an RR fit, it just says why and
where to go. It follows the in-repo precedent `hs_block_multivariate_response_scale()`,
which already blocks a target with a named scope message "rather than the generic
'planned v0.1 contract' miss". No estimand, number, or return value changed.

## Tests of the tests

The claim-surface guard was **verified to fail when the defect returns**: reintroducing
`rr(t, k = 2)` in the register turned the test red and named the offending line (24).
Restored immediately after. Without that check the guard could have passed vacuously.

The guard is skip-guarded on file existence because `docs/` and `vignettes/articles` are
both `.Rbuildignore`d — it is a source-tree contract test, mirroring
`helper-realdata-manifest.R`. It also covers `capability-status.md`, which was already
correct, so the guard protects it from regressing.

## Commands and outcomes

```sh
Rscript -e 'devtools::document()'                     # OK
Rscript -e 'devtools::test(reporter = "check")'        # [ FAIL 0 | WARN 0 | SKIP 70 | PASS 2336 ]
Rscript -e 'devtools::check(document = FALSE, args = "--no-manual")'   # see below
air format <the 3 edited R/test files>                # my new lines already clean
```

All 70 skips are pre-existing live-Julia / missing-comparator-package guards.

`air format .` was run and then **deliberately reverted on 22 unrelated files**: it
rewrites pre-air manual alignment across the package (including the careful
direct-maternal block the panel signed off in §1.1). Reformatting them would widen a
prose-honesty commit into a package-wide diff. Checked separately that `air` leaves
**every line this slice adds** untouched, so the new code is air-clean; only the
inherited alignment is not.

## What was deliberately NOT done

- **No `validation_status()` row** for RR k=2 or direct-maternal. Owner-gated, and per
  panel §4.2 the sequencing is deliberate: the register had to be corrected *first* so a
  future row is not drafted from the wrong grammar into the exported table.
- **No covered flip; `public_covered_count` stays 5.** No status word changed.
- **`make_dm_fit`'s `r_am` inconsistency NOT fixed** (mock says `-0.4`; its own components
  imply `-0.4714`). That is panel C4, it is a *fixture* defect rather than a false public
  claim, and repairing it means choosing which of two values is canonical — deferred to
  post-0.5 with the owner, not decided here.
- **No push, no rebase, no G10 sign, no version bump.**
- **C5–C9 not attempted** — after-push scope by the panel's own sequencing.

## Still open

- **C4** — `r_am` identity assertion in both lanes + the `make_dm_fit` repair.
- **C5** — register `h2_T`, `m2`, `r_am` in `04-validation-canon.md` §Locked
  Derived-Estimand Identities with full Willham citations.
- **C6/C7** — the two-`m2`-denominator sentence; the no-row disclosure clause in
  `.onAttach` and the register.
- Owner push decision (DP-1) and the two `validation_status()` rows (G-AG-5).

# check-log — 2026-09-01 h2 A24 (preview): MV-4 claim-surface honesty

**Arc:** A24 pulled forward as a Block 1 post-push item (the drift it repairs sits on the
0.5.0 release branch, not on a future 0.6 branch)
**Lane:** R · `claude/lane-h2-twin-20260901` @ `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Trigger:** `~/local-scratch/h2-post-050-spine-mv4-s6.md` §0 finding (b)
**Lens:** Boole (grammar reachability / status vocabulary / error contracts), with Pat on
the reader path and Rose's covered-flip fence held throughout

## The gap

MV-4 — the `cbind()` multivariate default-path auto-route — was implemented and merged in
PR #132 (`ff89ac7`), an ancestor of this branch. **No public claim surface was updated when
it landed.** Two surfaces then said something outright false:

- `vignettes/articles/multivariate.Rmd:194` — "fitted **only** through `engine = "julia"`
  and `target = "multivariate"`"
- `vignettes/articles/model-status.Rmd` — "Multi-trait `cbind(...)` responses fit **only**
  through the experimental `engine = "julia", target = "multivariate"` path"

Both are **understatements of reachability**, not overclaims, so neither trips Rose's
overclaim fence and neither is a push blocker. They are still wrong, and a user following
the documentation would find the documentation wrong.

The honest tension the repair has to preserve: **the routing became default while the claim
stayed `partial`.** Both are intentional. The docs said neither clearly.

## What was measured first (live, not read)

Run against the sibling engine worktree `~/local-scratch/lanes/HSquared.jl-h2-twin-20260901`
via `HSQUARED_JULIA_PROJECT`. Fixture: the 8-animal two-sire/two-dam pedigree from
`test-multivariate.R`, one `NA` trait cell.

| Check | Method | Result |
|---|---|---|
| Default path routes `cbind()` to the MV fitter | `engine = "validate"`, read `spec$bridge$target` | `fit_multivariate_reml(Y, X, Z, Ainv; method = :REML)` |
| Default path **fits** (no `control =` at all) | live `hsquared()` | `converged = TRUE`, 538 iters, `target = multivariate`, G0/R0/per-trait h²/EBVs returned |
| `engine = "julia"` with **no** `target` (doc 38 §H.2) | live `hsquared()` | auto-selects `target = multivariate`, converged |
| Default path + `engine_control = list(initial = list(G0=, R0=))` | live `hsquared()` | converged, multivariate |
| Default path + `engine_control = list(genetic_structure = "diagonal")` | live `hsquared()` | `genetic_structure = diagonal`, off-diagonal G0 exactly 0 |

So the auto-route is real on both entry points, and the engine controls that used to ride
on `engine = "julia"` work on the default call too. The merge note was right; it is now
also verified.

## What changed

| File | Change |
|---|---|
| `vignettes/articles/multivariate.Rmd` | opens by separating **reachability (default)** from **claim (`partial`)**; primary example drops `control =`; the explicit spelling kept as a still-works second example; §H.2 no-target behaviour documented; `initial =` example moved to `engine_control` on the default call; the false claim-boundary bullet replaced by two bullets (default route / still `partial`, `public_covered_count` unmoved) |
| `vignettes/articles/model-status.Rmd` | the second false "fit only through" sentence rewritten; the opt-in list intro now names the multivariate model as the exception; the MV bullet says "routed on the default path"; the not-available list corrected |
| `vignettes/articles/fitting-models.Rmd` | MV section and the two "remaining opt-in models" paragraphs corrected |
| `vignettes/articles/g-matrix-interpretation.Rmd` | "experimental and opt-in" → default-routed but experimental; example simplified |
| `vignettes/articles/formula-grammar.Rmd` | the two "opt-in `cbind()` path" statements corrected |
| `README.md` | the opt-in/experimental block split: MV is experimental but not opt-in |
| `R/formula-status.R` | `print()` header line; the `cbind()` row's fitting status `"fitted (opt-in multivariate)"` → `"fitted (default route, experimental multivariate)"`; behaviour string rewritten (it said "requires … engine = \"julia\", target = \"multivariate\"") |
| `R/validation-status.R` | MV row notes gain an explicit ROUTING paragraph; the **default-path row's** notes no longer list multivariate among the opt-in targets, and now say the MV row is default-routed yet not part of the covered claim |
| `R/extractors.R` | `hs_multivariate_extractor_default()` error now names the reachable syntax instead of `target = "multivariate"` |
| `R/hsquared-package.R` | package-level roxygen: MV moved out of the opt-in list, with the experimental caveat kept |
| `tools/write-capability-ledger-summary.R` | routes gain an explicit `default_route` flag (reachability) separate from `expect` (claim); new `partial` + default permission wording; MV card's call and scope updated |
| `vignettes/articles/includes/capability-ledger-summary.md` | regenerated from the above |
| `docs/design/capability-status.md` | MV row reachability rewritten with the PR/SHA; "Not the default" removed; notes now state reachability ≠ claim; the `hsquared()` entry-point row no longer calls MV an explicit experimental target |
| `docs/design/06-public-claims-register.md` | same two corrections in the register |
| `docs/design/41-lane-goal-to-1.0.md` §6 | "First slice on the spine: **MV-4**" → corrected: MV-4 merged, doc 38 ratified, remaining 0.6 work is evidence assembly |
| `docs/design/36-phase3-6-execution-plan.md` §4 + rung table | same correction, and the 0.6 row now marks MV-4 / MV-1 done |
| `NEWS.md` | one entry, explicitly labelled a reachability correction and not a promotion |
| `tests/testthat/test-phase0-api.R` | the `formula_status()` pin follows the new status string |
| **Julia lane** `LOOP/GOAL.md` | "Do not start MV-4 or other 0.6+ spine work" → the STOP is unchanged but MV-4 is recorded as already merged and the 0.6 remainder reframed as evidence assembly (cross-lane edit; the only Julia-lane file touched) |

## Commands and outcomes

```sh
Rscript tools/write-capability-ledger-summary.R    # wrote 156 lines (4 +/5 - vs previous)
Rscript -e 'devtools::document()'                  # OK
Rscript -e 'devtools::test()'                      # [ FAIL 0 | WARN 0 | SKIP 70 | PASS 2336 ]
Rscript -e 'devtools::check(document = FALSE, args = "--no-manual")'   # see below
air format .                                       # then reverted on 22 unrelated files
```

The 70 skips are the pre-existing live-Julia / missing-comparator guards; the count is
unchanged from the A21 entry.

`air format .` again rewrote pre-air manual alignment across 22 files this slice does not
touch (`R/fit-object.R`, `R/gwas.R`, `R/julia-bridge.R`, several `sim/`, `tools/`, and test
files). Reverted, exactly as in the A21 entry — a documentation-honesty commit should not
carry a package-wide reformat. The lines this slice adds are air-clean.

## What was deliberately NOT done

- **No covered flip. `public_covered_count` stays 5.** Default routing is reachability;
  the `partial → covered` move is G10 and owner-only. Every rewritten surface says so
  explicitly rather than leaving it to be inferred.
- **The `validation_status()` capability key was NOT renamed.** It still reads
  `"experimental multivariate REML estimator (opt-in)"`, and "(opt-in)" in that key is now
  inaccurate. It is left alone on purpose: the string is a machine key threaded through
  `tools/write-capability-ledger-summary.R`, two `test-phase0-api.R` assertions, and — the
  binding reason — **two dated comparator-run evidence records**
  (`2026-06-21-multivariate-tool-availability.md`, `2026-09-01-blupf90-tool-unavailability.md`)
  that cite it verbatim and must not be rewritten. Renaming it breaks traceability from
  dated evidence to a live row. **Recommendation: A28 (the Boole freeze-closure audit)
  decides the key vocabulary deliberately, with an alias or a recorded rename**, rather
  than a drive-by rename inside a prose fix. The row's `notes` now carry the routing
  correction, so `validation_status()` output is not misleading in substance.
- **No push, no rebase, no version bump, no Registrator, no S5 touch.**
- **No new Totoro multivariate recovery run.** The MV-5 run-or-supersede disposition
  (spine §0 finding (a)) is an owner decision and is untouched here.
- **No widening of the frozen predicate.** `k ≥ 3` stays experimental, `diagonal` stays
  experimental; the multivariate vignette now says the `genetic_structure` control is
  opt-in *on the default path as anywhere else*, so "default route" cannot be read as
  "everything multivariate is default".

## Still open

- **DP-1** — owner push. Nothing here is CI-verified.
- **A28** — the `validation_status()` key vocabulary above, plus the audit that the
  `k ≥ 3` and `diagonal` experimental fences are enforced on every surface, not merely
  documented.
- **A25** — MV-5 disposition; **A26** — R↔engine element-wise parity at the promotion
  fixture; **A27** — Darwin sign on the recovered covariance; **A29** — Rose pre-flip audit.

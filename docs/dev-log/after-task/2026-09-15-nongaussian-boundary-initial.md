# After-task — 2026-09-15 non-Gaussian boundary/initial records (#222 #225 / PR #229)

## 1. Goal

Write repo-visible records (check-log entry + this after-task report) for `hsquared`
PR #229, already merged, which closed #222 and #225: `target = "nongaussian"` now
forwards `engine_control$initial`/`$restart_check` to `HSquared.fit_laplace_reml()`
and the generic bridge wrapper now surfaces the engine's `boundary` flag next to
`converged`. This is a records-only task: no code, test, or NEWS change is made here.

## 2. Implemented

Documented, in `docs/dev-log/check-log.md` (2026-09-15 entry, appended at the end)
and this report, the R-side change already on `main` at merge commit `c4dc5926`:

- `R/julia-bridge.R` — `hs_engine_control_honoured_keys[["nongaussian"]]` (line 4193)
  gains `"initial"`/`"restart_check"`; `hs_nongaussian_three_field_julia_command()`
  (lines 868-936) forwards both conditionally into the Julia command string; new
  `hs_ng09_boundary(raw)` (lines 817-835) next to `hs_ng09_converged(raw)`
  (lines 794-805).
- `R/conditions.R` — new `hs_abort_boundary_refused()` (line 97).
- `R/hs_control.R` (roxygen) + regenerated `man/hs_control.Rd` — document `initial`,
  `restart_check`, and the `boundary` result field.
- `NEWS.md` — one bullet under the existing development-version header.
- `tests/testthat/test-nongaussian-boundary-and-initial.R` (new) and
  `test-nongaussian-three-field-v09.R` (extended).

Also recorded: the Rose audit (`rose-r7.md`) verdict CHANGES (C-1..C-4, all text) and
its disposition (`repair-229.md`), the optional items (O-1/O-2 applied on the branch's
last two commits, O-3 left as-is), and the twin issue HSquared.jl#347 filed against the
engine's own message.

## 3a. Decisions and Rejected Alternatives

- **Cited the orchestrator's full live-suite number rather than re-running the full
  suite in this records session.** The task's own checks (document/check/filtered live
  test) were run fresh, with real output, in this worktree. The full, unfiltered live
  suite (`FAIL= 0 ERROR= 0 SKIP= 3 PASS= 3657`, R branch head `e3df9062` vs Julia main
  `a4cf08e5`) is attributed to the orchestrator's own measurement and cited as such,
  not claimed as this session's own run — consistent with how the 2026-09-13 entry
  cited the same class of number and with rose-r7's own explicit "taken on trust"
  disclosure for the equivalent figures on this PR. Rejected: re-running the full live
  suite myself — rejected because the task scoped this session's own live evidence to
  the filtered `nongaussian-*` run, and a records session re-running a multi-minute
  full suite to reproduce a number already reported by another role adds runtime
  without adding evidence of a different kind.
- **No code, test, or NEWS change made in this session**, per the task's explicit
  "docs only" framing. The Rose optional item O-1 (a `fit_diagnostics()` row for
  `search_boundary`) is recorded as tracked by hsquared#230, not implemented here.

## 4. Files Touched

- `docs/dev-log/check-log.md` — one entry appended at the end (2026-09-15).
- `docs/dev-log/after-task/2026-09-15-nongaussian-boundary-initial.md` — this report.

No R, test, NEWS, or `DESCRIPTION` file touched by this session.

## 5. Checks Run

- `Rscript -e 'devtools::document()'` then `git status --porcelain` — clean; **empty**
  diff (no drift between committed `man/`/`NAMESPACE` and a fresh regeneration on this
  branch head).
- `Rscript -e 'r <- devtools::check(".", document = FALSE, quiet = TRUE, error_on =
  "never"); cat("errors=", length(r$errors), " warnings=", length(r$warnings), "
  notes=", length(r$notes), "\n")'` (`OPENBLAS_NUM_THREADS=1 JULIA_NUM_THREADS=4`, run
  in the background, polled with an until-loop, no sleep chain) — **errors= 0
  warnings= 0  notes= 0**.
- Live filtered run (`HSQUARED_JULIA_TESTS=true HSQUARED_JULIA_PROJECT=<local
  HSquared.jl checkout, `origin/main` `a4cf08e5`> NOT_CRAN=true
  OPENBLAS_NUM_THREADS=1 JULIA_NUM_THREADS=4 Rscript -e 'devtools::test(filter =
  "nongaussian-three-field-v09|nongaussian-boundary-and-initial", reporter =
  "summary")'`) — both files fully green (`nongaussian-boundary-and-initial`: 25 dots;
  `nongaussian-three-field-v09`: 131 dots), "Your tests deserve a gold medal", exit
  code 0.
- FULL LIVE SUITE (orchestrator-reported, R branch head `e3df9062` — before the final
  two docs-only commits — vs Julia main `a4cf08e5`): `FAIL= 0  ERROR= 0  SKIP= 3
  PASS= 3657`. Not re-run by this session; cited as the orchestrator's own
  measurement (see §3a).
- CI (`gh run list -R itchyshin/hsquared --branch main -L 2`): R-CMD-check on the
  PR #229 merge commit (`c4dc5926`) — SUCCESS; pkgdown on the prior merge commit —
  SUCCESS.
- `Rscript <brain>/tools/check-after-task.R
  docs/dev-log/after-task/2026-09-15-nongaussian-boundary-initial.md` — see §6.

## 6. Tests of the Tests

Not applicable in the usual sense (no code changed this session). The one check
applicable to a records-only task is the after-task validator itself
(`check-after-task.R`), which fails closed rather than passing vacuously: it requires
all twelve section headers verbatim and, separately, requires the literal phrase
"does NOT cover" (case-insensitive) to actually appear in §12's body, not just the
heading — so a report with an empty or heading-only §12 would fail it. This report was
written with §12's negative-space bullets already in place and the validator was run
once, after the fact, against the finished file (see §5) — it was not deliberately run
against a broken draft first, so this is evidence the finished report satisfies the
gate, not evidence the gate discriminates (that property is inherent to the validator's
own source, read in full before writing this report, not demonstrated fresh here).

## 7a. Issue Ledger

- **#222** (hsquared) — CLOSED by PR #229.
- **#225** (hsquared) — CLOSED by PR #229.
- **#230** (hsquared) — OPEN. Follow-on filed by Rose's audit (O-1): add a
  `search_boundary` row to `fit_diagnostics()` for non-Gaussian fits, distinct from
  the existing `at_boundary`/`at_boundary_condition` rows. Not implemented here.
- **HSquared.jl#347** — OPEN. The engine's own `ArgumentError`
  (`src/nongaussian.jl:907-909`) carries the same "retry with `restart_check = true`"
  advice that Rose's C-1 corrected on the R side; filed against the engine as a
  docstring/message-only fix, no behaviour change. Not this repo's to fix.
- **`restart_estimate` consumption** (O-3, no issue filed) — the value is written to
  the wire (`Dict(...)` in the command builder) and appears in the test literal, but
  is not consumed by the R normalizer or surfaced on the result object. Recorded as a
  residual (§10), not filed as a separate issue, per rose-r7's own framing of it as
  optional.

## 8. Consistency Audit

Cross-checked every factual claim in this report against primary sources rather than
carrying forward summaries: `gh pr view 229` (title, body, mergedAt, mergeCommit,
commits) for the merge SHA and the three post-audit commits; `gh issue view` on #222,
#225, #230, and HSquared.jl#347 for open/closed state and exact wording; direct reads
of `R/julia-bridge.R`, `R/conditions.R`, and the two "docs+test"/"docs" commits
(`db449788`, `ddc5b8313`) to confirm O-1 and O-2 were in fact applied on this branch
(O-2 in particular: `git show ddc5b8313 -- R/julia-bridge.R` confirms
`format(initial, digits = 15, ...)` replaced the un-dated `digits` default) and that
O-3 was not. `git diff 22cfe51..c4dc592 --stat` confirms the 8-file footprint rose-r7
recorded (no drift between the audit and the merged tree). `gh run list` confirms CI
is green on the merge commit, resolving rose-r7's own "CI is not green at audit time"
NOT-COVERED item.

## 9. What Did Not Go Smoothly

- The first attempt to background `devtools::check()` used a plain worktree-local
  `Rscript ... &` inside a single shell command; the wrapping shell process exited
  when that tool call returned, killing the detached job before it could write output
  (empty log, no running process on a follow-up check). This is the same failure mode
  the 2026-09-13 after-task recorded under its own §9 ("a stray `&` ... reaped the
  detached process"). Recurrence, not a new class of mistake — fixed the same way,
  by using the harness's own `run_in_background` facility instead of a bare `&`.

## 10. Known Residuals

- `restart_estimate` is written to the Julia `Dict(...)` and appears in the test
  literal but is not consumed by the R normalizer or exposed on the fit result — see
  §7a (O-3). Harmless (unknown envelope keys are ignored), not a user-facing
  deliverable of PR #229.
- `fit_diagnostics()` does not yet carry a `search_boundary` row (#230, open); the
  documented access path for `boundary` remains `fit$result$boundary` only.
- The `at_boundary`/`search_boundary` naming distinction is documented in `?hs_control`
  and in this report, but is not enforced by any test that would catch the two
  concepts being confused in a future PR.

## 11. Team Learning

- **A records-only task should still cite, not silently omit, a number it did not
  itself measure.** The task specified an orchestrator-measured full-live-suite count
  distinct from this session's own filtered run; the honest way to include it is
  explicit attribution ("orchestrator-reported ... not re-run by this session"), not
  quietly presenting it as this session's own evidence and not dropping it either.
  This mirrors rose-r7's own explicit "taken on trust" disclosure for the equivalent
  numbers on this same PR — citing a number's source is itself part of the evidence.
- **Backgrounding discipline recurs across sessions and needs a standing habit, not a
  one-off fix.** The bare-`&`-inside-a-shell-call failure mode was already recorded
  once (2026-09-13 after-task §9) and recurred here before being caught. Recorded
  again to reinforce: always use the harness's `run_in_background` (or an explicit
  `nohup`/`disown`) for anything that must outlive the launching command, never a bare
  trailing `&`.

## 12. Cross-Product Coverage

This slice is two additive `engine_control` keys (`initial`, `restart_check`) and one
additive result field (`boundary`) on exactly one Julia target, `nongaussian` — not a
cross-cutting flag that touches other targets' behaviour. Stated for completeness
against the campaign's own §12 precedent (2026-09-13 entry), which established that
`engine_control` levers must be audited on the product axis, not just their own:

- **`initial`/`restart_check` forwarding (#225) covers:** the `nongaussian` target
  only — `hs_fit_julia_nongaussian_payload()` and
  `hs_nongaussian_three_field_julia_command()`. It **does NOT cover** any other Julia
  target's `initial` semantics: `fit_animal_model`, `ai_reml`,
  `henderson_mme`/`metafounder`/`snp_blup`, `multi_effect`, `multivariate`, and the
  rest each have their own pre-existing, unrelated `initial` shape and validator
  (a plain numeric vector, a two/three-component named vector, a list with `G_dm`,
  etc., per `?hs_control`); this PR changes none of them. `restart_check` is not added
  to any other target's honoured-keys row, so it errors as unsupported everywhere else
  — unchanged, and confirmed by rose-r7's own check of the forwarding gate.
- **`boundary` result-field surfacing (#222) covers:** the generic non-Gaussian bridge
  wrapper's result list (`fit$result$boundary`), reachable from any route that calls
  `hs_normalize_nongaussian_three_field_v09()`. It **does NOT cover**:
  `fit_diagnostics()` (no `search_boundary` row yet — #230, open); the legacy
  pre-v0.9 `hs_normalize_nongaussian_result()` envelope (confirmed unreferenced by any
  live command builder in this repo, per r7-222-225.md, so left untouched by design,
  not by oversight); any Gaussian route (the concept does not apply there — Gaussian
  targets have no search-bracket boundary to report); and `restart_estimate`, which
  reaches the wire but not the R result object (§10, O-3).
- **The advice-wording fix (Rose C-1) covers:** the R-side `hs_ng09_boundary()`
  backstop message and `NEWS.md`/roxygen prose. It explicitly **does NOT cover** the
  engine's own `ArgumentError` at `HSquared.jl` `src/nongaussian.jl:907-909`, which
  carries the identical wrong advice and is the production-path message a user
  actually sees (the Julia payload builder refuses first, so the R-side backstop is
  presently unreachable in the wired route) — tracked as HSquared.jl#347, open, not
  this repo's to fix.
- **Release/version surface — explicitly out of scope, not silently skipped:** no
  `DESCRIPTION` version bump, no tag, no CRAN submission, no capability-status or
  validation-debt row change, no `public_covered_count` change (stays 7). This
  records session's own checks (`devtools::check()`, the filtered live test) cover
  only what PR #229 already shipped; they do **NOT** cover a CRAN-submission-grade
  `--as-cran` check, a cross-OS CI matrix run, or any evidence toward a future
  `experimental -> covered` status flip for the non-Gaussian target.

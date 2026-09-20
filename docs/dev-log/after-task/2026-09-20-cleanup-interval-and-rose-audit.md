# After-task — 2026-09-20 (later) #351 root cause, repeated-records warning, cleanup, sparse interval, Rose audit

## 1. Goal

Close the second half of the repeated-measures arc and the debts it left:
root-cause the reported standard-error failure, stop the silent `V_PE`
absorption, clear the recurring local-check noise, give the sparse route its
missing interval, and run the Rose audit the Definition of Done requires.

## 2. Implemented

- **`4b338d6`** — `hs_warn_unmodelled_repeated_records()`; the `#351` root cause
  (a notebook defect, not an engine failure); `formula_status()` discoverability;
  a contract fix to `heritability_se`.
- **`4b4c08c`** — roxygen pin 8.0.0 → 8.1.0; `^\.vscode$` in `.Rbuildignore`;
  `.gitignore` blanket `settings.json` replaced with the two paths it protected;
  `sommer` installed locally; the two deferred warning pins; a defect fix in the
  new warning on multivariate responses.
- **`4dfad4b9` (HSquared.jl) + `35f9150`** — `multi_effect_sum_ratio_interval()`
  and its R wiring, so the sparse route has a repeatability interval.

## 3a. Decisions and Rejected Alternatives

- **Warned rather than refused** on repeated records without `permanent()`.
  `HSquared.jl#352` item 3 asked the R side to refuse. Refusing would reject
  models legitimately specified that way, and — decisively — a warning can now
  name a reachable alternative, which a refusal could not when the issue was
  filed. Suppressible.
- **Did not open `multi_effect` to `permanent()`.** My first attempt did; a test
  showed an earlier router already sends `permanent()` to `repeatability` with
  the closest working call printed. Reverted: one model, one surface.
- **Replaced the blanket `settings.json` ignore rather than deleting it.** It was
  doing real work (hiding `.claude/settings.local.json` and
  `.vscode/settings.json`); deleting it would have exposed both. The precise
  paths keep the behaviour and remove the contradiction with the tracked file.
- **Installed `sommer` instead of keeping the two errors as "known".** They had
  been reported as a pre-existing condition in three prior check runs this
  session; installing the Suggests makes the MV-1/MV-1b comparator tests
  actually execute here, which is the point of having them.
- **Pinned both surfaced warnings by engine message**, accepting that a future
  engine fix will fail these tests. That is the intent, and the comments say so.
- **Built the sparse interval from the fitted components** rather than reusing
  `repeatability_interval()`, which refits densely and would have re-imposed the
  escaped ceiling. Generalised `_ratio_delta_ci` to a summed ratio instead of
  duplicating it.

## 4. Files Touched

`R/conditions.R`, `R/hsquared.R`, `R/formula-status.R`, `R/hs_control.R`,
`R/julia-bridge.R`, `man/hs_control.Rd`, `NEWS.md`, `.Rbuildignore`,
`.gitignore`, `DESCRIPTION`, `NAMESPACE`, `docs/design/capability-status.md`,
`dev-test/great_tit_animal_model.qmd`,
`dev-test/RESULTS-animal-pe-vs-asreml.md` (new),
`tests/testthat/test-repeated-records-warning-352.R` (new),
`tests/testthat/test-repeatability-sparse-352.R`,
`tests/testthat/test-multivariate.R`, `tests/testthat/test-repeatability.R`.
Julia: `src/likelihood.jl`, `src/HSquared.jl`,
`test/test_352_multi_effect_se.jl`.

## 5. Checks Run

- `devtools::test()` **FAIL=0 ERROR=0 SKIP=102 PASS=3040**.
- `devtools::check()` **0 errors / 0 warnings / 0 notes** — the FULL check, with
  no `--no-manual`, no `--no-build-vignettes`, and no
  `_R_CHECK_FORCE_SUGGESTS_=false`. This is the first clean check of the session.
- `pkgdown::check_pkgdown()` **PASS**. `bash tools/preamble_cap.sh` **CAP OK**.
- Julia `Pkg.test()` **PASS**; new interval block **14/14**.
- NAMESPACE semantic equality proved by `parseNamespaceFile()` on both versions:
  exports, S3 methods, and the package → symbol import map all identical.
- Real-data interval: repeatability **0.44944 [0.42555, 0.47356]**, SE
  **0.012257** on 11,856 records / 10,937 pedigree.

## 6. Tests of the Tests

The sparse interval's load-bearing test is agreement with the dense
`repeatability_interval()`, which reaches the answer by a genuinely different
route (it REFITS from raw matrices). Agreement on estimate, SE, and both
endpoints at ~1e-6 is evidence the new path is correct, not merely
self-consistent. Two of my own errors were caught by tests rather than by
inspection: the `multi_effect` change was unreachable, and the multivariate pin
asserted a repeated-records warning on a fixture with one record per animal.

## 7a. Issue Ledger

- **HSquared.jl#351** — root-caused and reported; the reported symptom was a
  notebook defect. Not closed by me; the remaining-asks call is the maintainer's.
- **HSquared.jl#352** — all three asks now addressed. Proposed for closure with
  a summary comment; not closed unilaterally.
- **HSquared.jl#365** — open, disposition with the maintainer.
- **HSquared.jl#343** — still open; now user-visible as a warning.
- **#138** — untouched, still open.

## 8. Consistency Audit

**Rose audit of the whole arc (`ec5d684..35f9150`): CLEAN.**
`docs/design/` diff is ONE line (the repeatability row); the row still reads
**partial**; `public_covered_count` is **7**; `Version: 0.9.0`;
`R/validation-status.R` and `validation-debt-register.md` **untouched**; **zero**
new occurrences of "covered" in the design diff; every new ASReml mention is a
fencing or negative statement, and the capability row does **not** cite ASReml as
evidence; `NEWS.md` additions contain none of "covered"/"validated"/
"production"/"calibrated" as claims. No blockers.

## 9. What Did Not Go Smoothly

- **I wrote three claims that my own later work falsified** — "no
  repeatability-coefficient interval is returned" in `?hs_control`,
  capability-status, and NEWS. Corrected in the same commit that made them false,
  plus the `max_dense_cells` note that was true only for the dense route.
- **The new warning had a defect on multivariate responses**: it printed the
  univariate `permanent()` recipe, which that route rejects — the exact
  hsquared#212 class the repo guards against. Found by reading test output, not
  by the tests themselves.
- **I misread a fixture** and asserted a repeated-records warning on data with
  one record per animal. The test failed immediately.
- **My `--no-build-vignettes` flag manufactured a check error** I had been
  reporting as pre-existing for several runs. The full check has 0 errors.

## 10. Known Residuals

- `HSquared.jl#365` (loglik convention) open; `loglik` still not comparable
  across `scale_method`.
- The standard errors and intervals are asymptotic and **not**
  coverage-calibrated. No coverage study was run.
- Repeatability stays **partial**: no external comparator gate, no recovery
  campaign.
- `initial`/`iterations` still not forwarded on the sparse route
  (`HSquared.jl#343`).
- `sommer` here is **4.4.7**; the repo's recorded comparator evidence cites
  **4.4.5**. A local toolchain note, not a re-run of that evidence.
- Julia CI is `workflow_dispatch`-only and does not fire on push.

## 11. Team Learning

- **Clear the recurring noise early.** The roxygen pin, `.vscode`, and absent
  `sommer` made me revert files and re-report the same two "errors" repeatedly
  across the session. One commit took the local check from "2 errors, 1 note,
  known-benign" to a genuinely clean 0/0/0 — and a clean baseline is what makes
  the NEXT regression visible.
- **A flag you added to make a check cheaper can manufacture a finding.** I
  carried `--no-build-vignettes` for several runs and reported its artifact as a
  pre-existing defect. Re-run the unmodified command before calling something
  pre-existing.
- **When you document a limitation, note where the claim lives.** I wrote the
  "no interval" limitation into three surfaces and had to find all three again
  two commits later.

## 12. Cross-Product Coverage

- **Covers:** the repeated-records warning on any univariate animal-only spec
  and a distinct multivariate variant; the sparse repeatability interval for
  `which = 1:2`; the cleanup items.
- The warning **does NOT cover**: designs where a non-`permanent()` id-level
  effect already absorbs the correlation (deliberately skipped — it would be a
  false positive), nor any judgement about whether the second component is
  identifiable; it counts records per individual, nothing more.
- The sparse interval **does NOT cover**: coverage calibration, profile or
  bootstrap intervals, a boundary/rail optimum (it returns `NaN` with
  `boundary = TRUE` by design), or any `which` other than the animal+PE sum as
  wired through R.
- **Release/status surface — out of scope, not silently skipped:** no version
  bump (**0.9.0**), no tag, no CRAN action, `public_covered_count` stays **7**,
  no `validation_status()` row added or flipped, repeatability stays **partial**
  on both lanes, ASReml remains forbidden as a covered leg, **#138** stays open.

# 2026-09-02 — A25 (Rose): DESCRIPTION still called multivariate opt-in

**Arc:** A25 as dispatched — Rose multivariate claim-surface audit for 0.6
readiness. (The spine assigns A25 = MV-5 disposition; this is **A29-shaped work
under the A25 label**, and **MV-5 disposition remains OPEN**.)
**Lane:** R (`hsquared`).
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Branch:** `claude/lane-h2-twin-20260901`. **Not pushed.**

    10|## Problem

A24 repaired the post-MV-4 "fitted only through an opt-in engine path"
falsehood across README, `capability-status.md`,
`06-public-claims-register.md`, `validation_status()`, `claim_boundary()`, the
package help, and the error text. It **missed `DESCRIPTION`**, which still read:

> Genomic, single-step, SNP-BLUP, repeatability, two-effect, and **multivariate**
> animal models also fit through **opt-in, experimental engine paths**

False for multivariate since MV-4 (`hsquared` PR #132, `ff89ac7`, merged
    20|2026-07-12): a `cbind()` Gaussian response with an `animal()` term routes on
the **default** `hsquared()` call, with no `engine`/`target` argument.

This is the **highest-reach** wording defect found in the A25 sweep. The
`Description` field is republished on the CRAN package page, every CRAN mirror,
the pkgdown home page, and `packageDescription()` — while
`man/hsquared-package.Rd` (the surface A24 *did* fix) already said the honest
thing two files away:

> A `cbind()` multivariate Gaussian response also routes on that default path,
> though the multivariate capability stays experimental.
    30|
The error understates reachability, so there is **no claim-inflation risk**. It
is patched because the repo contradicted itself on its most-published sentence.

## Change

`DESCRIPTION` — the five genuinely opt-in targets keep their sentence;
multivariate is split out as default-routed **and** still labelled experimental
and not covered:

> Genomic, single-step, SNP-BLUP, repeatability, and two-effect animal models
> fit through opt-in, experimental engine paths; multivariate cbind() animal
    40|> models route on the default call but are likewise experimental and not
> covered; factor-analytic and non-Gaussian models are planned.

"experimental and not covered" is carried deliberately so the routing
correction cannot be read as a promotion.

## Commands and outcomes

| Command | Result |
|---|---|
| `Rscript -e 'read.dcf("DESCRIPTION")'` | DCF parse OK, 17 fields; `Description` re-wraps cleanly at 78 cols |
    50|| `testthat::test_file("tests/testthat/test-package.R")` | **1 pass, 0 fail**; startup experimental notice unchanged |
| `rg` for the sentence elsewhere | not duplicated — `DESCRIPTION` is the only site |
| `man/hsquared-package.Rd` `\description{}` provenance | comes from an explicit roxygen `@description` in `R/hsquared-package.R`, **not** from the `Description` field — so no `devtools::document()` re-run is required and none was done |
| `git diff HEAD..origin/codex/2026-07-13-v07-performance-localization -- DESCRIPTION` | see below |

`devtools::check()` was not run: this is a single prose field, DCF-validated,
with the package-level test green.

## Escalation for the owner — DP-8 is wider than the spine records

    60|The spine's §5 DP-8 row describes the conflict with
`origin/codex/2026-07-13-v07-performance-localization` as a **README** conflict.
Measured here, that branch's `DESCRIPTION` also **deletes** honest wording this
branch carries:

- "Experimental package: the first CRAN release targets 0.5.0, not 1.0.0."
- "Report point estimates only for rows marked covered in `validation_status()`;
  uncertainty intervals are experimental and not coverage-calibrated."

and it keeps the same false "multivariate … opt-in" clause. **No test pins the
    70|experimental wording in `DESCRIPTION`**, so a merge of that branch would
silently drop D-41 label content from a public channel. Owner decision; flagged,
not resolved.

## Fence

- **No covered flip.** R multivariate stays `partial`;
  `public_covered_count` stays **5**.
- No push, no CRAN action, no version bump, no G10 sign, no Totoro/DRAC.

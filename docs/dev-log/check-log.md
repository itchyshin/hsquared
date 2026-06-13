# Check Log

Append exact commands and outcomes here. Do not replace repository evidence
with private memory.

## 2026-06-12

- Rehydrated R repo:
  - `git status --short --branch`
  - `git remote -v`
  - `git log --oneline --decorate -5`
  - `gh run list --repo itchyshin/hsquared --limit 5`
- Result before Phase 0 R edits: clean `main`, tracking `origin/main`, latest
  R-CMD-check run green.
- Coordinated with Julia twin thread
  `019ebb88-ee69-7be2-850c-0e4840c34734`; instructed it to own only
  `HSquared.jl` and avoid R-repo writes.
- Verified Julia twin from live state after coordination:
  - `git status --short --branch` in `HSquared.jl`
  - `git log --oneline --decorate -5` in `HSquared.jl`
  - `gh repo view itchyshin/HSquared.jl --json nameWithOwner,visibility,isPrivate,url,defaultBranchRef`
  - `gh run list --repo itchyshin/HSquared.jl --limit 5`
- Result: `HSquared.jl` is public at
  `https://github.com/itchyshin/HSquared.jl`, on clean `main`, latest commit
  `079dbf2`, latest GitHub Actions CI run passed.
- Local Phase 0 R commands:
  - `for d in .agents/skills/*; do python3 /Users/z3437171/.codex/skills/.system/skill-creator/scripts/quick_validate.py "$d" || exit 1; done`
  - `air format .`
  - `Rscript -e 'devtools::document(); devtools::test()'`
  - `Rscript -e 'devtools::check(error_on = "warning")'`
- Result: all local skill validations passed; formatting completed; R tests
  passed with `0 fails | 0 warnings | 12 pass`; R CMD check passed with
  `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - `rg -n "TODO|\[TODO|fits animal|fits fast|implemented model|ASReml-level" README.md DESCRIPTION AGENTS.md ROADMAP.md docs .agents R tests`
- Result: matches were intentional claim-audit text only; no public wording
  says fitting is implemented.
- Follow-up Rose sweep used a broader unsupported-claim pattern and softened
  unsupported performance phrasing from `fast sparse` to `sparse`.
- After the clean full package check, final edits were prose-only claim-audit
  changes in README/design docs and generated Rd text. A subsequent
  `Rscript --vanilla -e 'cat("R ok\n")'` startup probe became unresponsive and
  was interrupted; use the next GitHub Actions run as the post-push R runtime
  verification.
- `git diff --check`
- Result: clean after trimming one trailing blank line in the testthat
  snapshot.
- Committed and pushed R Phase 0 scaffold:
  - `git commit -m "Install Phase 0 operating system"`
  - `git push origin main`
- Result: commit `d956a25` pushed to `main`.
- Remote R CI:
  - `gh run watch 27452325194 --repo itchyshin/hsquared --exit-status`
- Result: R-CMD-check passed in GitHub Actions in 1m33s.
- Public visibility:
  - `gh repo edit itchyshin/hsquared --visibility public --accept-visibility-change-consequences`
  - `gh repo view itchyshin/hsquared --json nameWithOwner,visibility,isPrivate,url,defaultBranchRef`
  - `gh repo view itchyshin/HSquared.jl --json nameWithOwner,visibility,isPrivate,url,defaultBranchRef`
- Result: both `itchyshin/hsquared` and `itchyshin/HSquared.jl` are public on
  `main`.
- GitHub ledger:
  - Added shared labels and Phase 0-8 milestones to both repos.
  - Opened `hsquared` issues #1-#7.
  - Opened `HSquared.jl` issues #1-#7.
- Final evidence commit:
  - `git commit -m "Record Phase 0 R closeout evidence"`
  - `git push origin main`
  - `gh run watch 27452446531 --repo itchyshin/hsquared --exit-status`
- Result: final commit `2268ff4` is on `main`; R-CMD-check passed in GitHub
  Actions in 1m12s.

## 2026-06-13

- Rehydrated R repo:
  - `git status --short --branch`
  - `git remote -v`
  - `git log --oneline --decorate -5`
  - `gh run list --limit 5`
- Result before Phase 1A R edits: on `main`, tracking `origin/main`;
  latest remote R-CMD-check runs were green.
- Coordinated with Julia twin thread
  `019ebb88-ee69-7be2-850c-0e4840c34734`.
- Result: Julia lane reported `HSquared.jl` commits for pedigree inverse
  utilities and the genomics/GPU/HPC roadmap, with CI and Documenter green.
- Local package commands:
  - `Rscript -e "devtools::document()"`
  - `git diff --check`
  - `Rscript -e "devtools::test()"`
  - `Rscript -e "pkgdown::build_site()"`
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - `Rscript -e "devtools::check()"`
- Result: documentation regenerated; whitespace check clean; testthat passed
  with `22 pass`; pkgdown site built locally into ignored `pkgdown-site/`;
  `pkgdown::check_pkgdown()` reported no problems; R CMD check passed with
  `0 errors | 0 warnings | 0 notes`.
- Formula/API checks:
  - `animal()` is now an exported inert formula marker.
  - `hs_build_model_spec()` parses the v0.1
    `animal(1 | id, pedigree = ped)` contract, validates pedigree/data IDs,
    builds fixed design matrices, and stops before fitting.
  - Tests cover accepted syntax, pedigree-column synonyms, unsupported
    trait/covariance syntax, missing pedigree IDs, and bridge-boundary
    wording.
- Documentation and public-site checks:
  - Added `_pkgdown.yml`, a pkgdown GitHub Actions workflow, and initial
    vignettes/articles for overview, model status, and the genomics/GPU
    roadmap.
  - Added `docs/design/07-genomics-qtl-gpu-plan.md` and a scout note for
    local packages, quantitative-genetic packages, and GPU backends.
- Rose wording sweep:
  - Public wording says parser/design-stage or planned where fitting,
    genomics, QTL/eQTL, GLLVM, GPU, and HPC features are not implemented.
  - No public wording claims fitted animal models, Julia bridge execution,
    GPU acceleration, or genomic/QTL support as implemented.
- Known check friction:
  - Early snapshot tests around Phase 0 bridge-boundary wording were replaced
    with direct `expect_error()` checks after snapshot update tooling created
    noisy EOF/diff prompts. The formula parser keeps focused snapshots for
    unsupported syntax.
- Remote GitHub Actions after push:
  - `gh run watch 27455226958 --repo itchyshin/hsquared --exit-status`
  - Result: R-CMD-check passed in 1m55s.
  - `gh run watch 27455226953 --repo itchyshin/hsquared --exit-status`
  - Result: initial pkgdown workflow failed while initializing `gh-pages`
    because the runner had no git author identity.
  - Fix: added a `Configure git identity` step to
    `.github/workflows/pkgdown.yaml`.
  - Follow-up run `27455290071` reached the deploy step, initialized
    `gh-pages`, and then failed while building reference pages because
    `library(hsquared)` could not find an installed package on the runner.
  - Fix: added an explicit `R CMD INSTALL .` step before deployment.
- Remote GitHub Actions after install-step fix:
  - `gh run watch 27455352894 --repo itchyshin/hsquared --exit-status`
  - Result: pkgdown passed in 1m19s and pushed `gh-pages`.
  - `gh run watch 27455352898 --repo itchyshin/hsquared --exit-status`
  - Result: R-CMD-check passed in 1m46s.
  - `gh api --method POST repos/itchyshin/hsquared/pages -f "source[branch]=gh-pages" -f "source[path]=/"`
  - Result: GitHub Pages enabled for
    `https://itchyshin.github.io/hsquared/`.
  - `gh run watch 27455403672 --repo itchyshin/hsquared --exit-status`
  - Result: Pages build and deployment passed.
  - `curl -L --max-time 20 -I https://itchyshin.github.io/hsquared/`
  - Result: live site returned `HTTP/2 200`.

## 2026-06-13 R bridge payload slice

- Rehydrated local state before edit:
  - `git status --short --branch`
  - Result: on `main`, tracking `origin/main`, with a clean worktree before
    the bridge-payload slice.
- Local implementation checks:
  - `Rscript -e "devtools::document()"`
  - Result: documentation regenerated; `man/hsquared-package.Rd` updated with
    package URLs.
  - `Rscript -e "devtools::test()"`
  - Result after payload and test hardening: `49 pass`, `0 fail`.
  - `git diff --check`
  - Result after removing a trailing snapshot blank line and deleting brittle
    snapshots: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - First `Rscript -e "devtools::check()"`
  - Result: failed in tests because an ordinary error snapshot differed between
    interactive and built-package contexts.
  - Fix: replaced formula-error snapshots with direct `expect_error()`
    assertions and removed the obsolete `_snaps` fixture.
  - Final `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Bridge/API evidence:
  - Added internal `hs_build_bridge_payload()`.
  - Tests cover numeric `y`, dense fixed `X`, sparse animal-incidence `Z`,
    normalized parent-before-offspring pedigree order, parent index metadata,
    method/family payload fields, cycle rejection, and the current
    `HSquared.animal_model_spec()` stop-boundary wording.
- Rose wording sweep:
  - README, vignettes, and design docs say internal bridge payload only.
  - No public wording claims Julia execution, `Ainv` construction, or fitted
    animal models as implemented.
- Remote GitHub Actions after push:
  - `git push origin main`
  - Result: commit `c5c348e` pushed to `origin/main`.
  - `gh run watch 27455845170 --repo itchyshin/hsquared --exit-status`
  - Result: R-CMD-check passed in 1m24s.
  - `gh run watch 27455845181 --repo itchyshin/hsquared --exit-status`
  - Result: pkgdown passed in 1m20s and deployed the site.
  - `gh run watch 27455874827 --repo itchyshin/hsquared --exit-status`
  - Result: Pages build and deployment passed. GitHub emitted a
    non-blocking Node.js 20 deprecation annotation for Pages actions.
  - `curl -L --max-time 20 -I https://itchyshin.github.io/hsquared/`
  - Result: live site returned `HTTP/2 200`.
  - `gh issue comment 6 --repo itchyshin/hsquared --body ...`
  - Result: issue #6 updated with evidence at
    `https://github.com/itchyshin/hsquared/issues/6#issuecomment-4697408730`.

## 2026-06-13 R fitted object and extractor contract slice

- Local implementation checks:
  - `Rscript -e "devtools::document()"`
  - Result: `NAMESPACE` regenerated and Rd topics written for
    `variance_components()`, `heritability()`, `breeding_values()`,
    `fixef()`, and `ranef()`.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `65 pass`, `0 fail`.
  - First `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: failed because five new extractor topics were missing from the
    reference index.
  - Fix: added an `Extractor contract` section to `_pkgdown.yml`.
  - Final `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - First `Rscript -e "devtools::check()"`
  - Result: `0 errors`, `0 warnings`, `1 note`; NOTE was an unqualified
    `logLik()` call inside `AIC.hsquared_fit()`.
  - Fix: changed `AIC.hsquared_fit()` to call `stats::logLik(object)`.
  - Final `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- API evidence:
  - Added internal `hs_new_fit()`.
  - Added extractor generics and `hsquared_fit` methods for variance
    components, heritability, breeding values, fixed effects, random effects,
    log-likelihood, AIC, prediction, and summary.
  - Tests use mocked result fields only; `hsquared()` still does not fit or
    return an `hsquared_fit` object.
- Rose wording sweep:
  - README, vignettes, and design docs describe this as an extractor contract
    over future/internal fit objects, not as fitted animal-model support.

## 2026-06-13 R data container slice

- GitHub issue setup:
  - `gh issue create --repo itchyshin/hsquared --title "R data container for phenotype/pedigree/genotype inputs" ...`
  - Result: created issue #8 for the `hs_data()` data-container lane.
- Local implementation checks:
  - `Rscript -e "devtools::document()"`
  - Result: `NAMESPACE` regenerated and `man/hs_data.Rd` written.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `81 pass`, `0 fail`.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- API evidence:
  - Added `hs_data()` for phenotype, pedigree, genotype, marker, expression,
    annotation, and environment inputs.
  - Tests cover phenotype/pedigree ID checks, genotype and expression ID maps,
    genotyped-without-phenotype and phenotyped-without-genotype bookkeeping,
    default-row-name rejection, and unsupported component shapes.
- Rose wording sweep:
  - Public wording says lightweight data container and ID maps only.
  - No public wording claims file-backed genomics, streaming, QTL/eQTL scans,
    or model fitting.

## 2026-06-13 R live Julia bridge smoke slice

- Rehydrated state before closeout:
  - `git status --short --branch`
  - `gh run list --repo itchyshin/hsquared --limit 5`
  - `git status --short --branch` in sibling `HSquared.jl`
  - `gh run list --repo itchyshin/HSquared.jl --limit 5`
- Result:
  - `hsquared` was clean at `644c75e` before the bridge-smoke edit.
  - `HSquared.jl` was clean at `798cfb7` after the twin committed the
    `HSData` mirror; Julia CI, Documenter, and Pages had passed.
- Local implementation checks:
  - `Rscript -e "devtools::document()"`
  - Result: completed after loading `hsquared`.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `93 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge test activated the sibling project at
    `~/Dropbox/Github Local/HSquared.jl` and returned an internal
    `hsquared_fit`.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Bridge/API evidence:
  - Added internal `hs_fit_julia_payload()`.
  - The tiny smoke path checks for Julia, `JuliaCall`, and a sibling
    `HSquared.jl` project before running.
  - The bridge sends `y`, `X`, dense guarded `Z`, pedigree IDs/parents,
    method, and initial variance values into Julia.
  - Julia builds `Ainv` through `pedigree_inverse()`, calls
    `fit_animal_model()`, returns `result_payload()`, and R normalizes the
    result into the existing internal `hsquared_fit` contract.
  - Tests assert convergence, finite log-likelihood, variance components,
    breeding-value IDs, fixed-effect naming, heritability, and `logLik()`.
  - A dense-size guard refuses payloads above `max_dense_cells`.
- Cross-repo learning:
  - The first live smoke exposed a Julia-side type-order issue where
    `HSData` referenced `HSDataIDMap` before it was defined.
  - The sibling Julia lane fixed and committed that work in
    `798cfb7 Add HSData input container`; local Julia `Pkg.test()` and
    Documenter checks were verified from the R/coordinator lane.
- Rose wording sweep:
  - README, model status, engine contract, capability status, validation debt,
    and public claims register now say local internal bridge smoke only.
  - Public wording still says ordinary `hsquared()` calls do not fit models and
    production/user-facing bridge execution remains planned.

## 2026-06-13 R opt-in Julia engine slice

- Goal: make the live Julia bridge reachable through an explicit experimental
  user-facing control while keeping the default `hsquared()` call
  validation-only.
- Active lenses: Ada, Shannon, Hopper, Lovelace, Emmy, Grace, Rose, Pat.
- Spawned subagents: none.
- Implementation evidence:
  - Added `engine = c("validate", "julia")` to `hs_control()`.
  - Kept Julia-specific knobs in `engine_control`: currently `julia_project`,
    `initial`, and `max_dense_cells`.
  - Updated `hsquared()` so `control = hs_control(engine = "julia")` calls the
    experimental Julia bridge and returns an internal `hsquared_fit`.
  - Default `hs_control(engine = "validate")` still parses, validates, builds
    the bridge payload, and stops with an informative message.
  - Added validation for named `engine_control` and positive
    `max_dense_cells`.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: regenerated `animal`, `hs_control`, `hsquared`, and package Rd
    topics.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `105 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live tests activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says experimental opt-in tiny local engine path.
  - Public wording does not claim general animal-model fitting, sparse
    production bridge execution, ASReml-level support, or large-data readiness.

## 2026-06-13 R PEV and reliability extractor contract

- Goal: mirror Julia's new dense experimental PEV/reliability extractor
  vocabulary on the R fitted-object side without claiming the live bridge
  payload returns those fields yet.
- Active lenses: Fisher, Pat, Emmy, Hopper, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added exported `prediction_error_variance()` generic and
    `hsquared_fit` method.
  - Added exported `reliability()` generic and `hsquared_fit` method.
  - Added future-compatible bridge normalization for
    `raw$prediction_error_variance` and `raw$reliability` if Julia adds those
    fields to `result_payload()`.
  - Updated pkgdown extractor index.
  - Updated claim register, capability status, validation debt, engine
    contract, README, NEWS, and model-status article.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: regenerated `NAMESPACE` and extractor Rd topics.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `111 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge test still confirms reliability is absent from the current
    Julia payload.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says R extractor contract only.
  - Public wording does not claim current live bridge PEV/reliability,
    production sparse PEV/reliability, or comparator validation.

## 2026-06-13 R sparse Z bridge marshalling

- Goal: use the Julia twin's `sparse_csc_matrix()` helper so the opt-in R
  bridge sends sparse `Matrix::dgCMatrix` slots instead of densifying `Z`.
- Active lenses: Hopper, Lovelace, Karpinski, Grace, Rose.
- Spawned subagents: none.
- Julia handoff:
  - `HSquared.jl` commit `6b530e4 Add sparse CSC bridge marshalling`.
  - Julia CI, Documenter, and Pages were green before the R slice started.
- Implementation evidence:
  - Removed dense `Z` conversion from `hs_julia_assign_payload()`.
  - Added `hs_sparse_csc_slots()` to expose `nrow`, `ncol`, zero-based
    `colptr`, zero-based `rowval`, and numeric `nzval`.
  - Added `hs_julia_assign_sparse_csc()` to construct Julia
    `SparseMatrixCSC` objects through `HSquared.sparse_csc_matrix()`.
  - Removed `max_dense_cells` from the active engine-control surface.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: regenerated `hs_control` Rd.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `116 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Remote checks:
  - Commit: `2a9ba37 Use sparse Z bridge marshalling`.
  - `gh run watch 27457225007 --exit-status`
  - Result: R-CMD-check passed in GitHub Actions.
  - `gh run watch 27457225023 --exit-status`
  - Result: pkgdown passed in GitHub Actions.
  - `gh run watch 27457267046 --exit-status`
  - Result: GitHub Pages build and deployment passed. The run emitted a
    GitHub-hosted Node.js 20 deprecation annotation for Pages actions.
- Rose wording sweep:
  - Public wording says sparse `Z` marshalling, not production sparse fitting.
  - Public wording does not claim large-data readiness, Mrode validation, or
    production bridge performance.

## 2026-06-13 Tiny Ainv validation fixture

- Goal: add the first tiny deterministic validation atom for issue #7 without
  claiming Mrode, ASReml, or production sparse fitting coverage.
- Active lenses: Curie, Fisher, Gauss, Jason, Rose, Grace.
- Spawned subagents: none.
- Scout evidence:
  - Read local `drmTMB` animal-relatedness and Julia-bridge tests.
  - Read local `gllvmTMB` sparse pedigree `Ainv` tests, validation register,
    cross-package validation article, and Gaussian REML pilot report.
  - Checked Henderson, Mrode, AGHmatrix, and nadiv public sources for the
    validation ladder.
  - Persisted lessons in
    `docs/dev-log/scout/2026-06-13-validation-fixtures.md`.
- Implementation evidence:
  - Added internal `hs_tiny_animal_validation_fixture()`.
  - Added tests that pin R payload ID ordering, parent indices, sparse `Z`,
    and live Julia `pedigree_inverse()` agreement for the three-animal
    fixture when a sibling `HSquared.jl` checkout is available.
  - Updated capability status, validation debt, public claims register,
    NEWS, and model-status article.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::test(filter = 'validation-fixtures')"`
  - Result: passed with `8 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live fixture activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `124 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Remote checks:
  - Commit: `c161a7f Add tiny Ainv validation fixture`.
  - `gh run watch 27457494019 --exit-status`
  - Result: R-CMD-check passed in GitHub Actions.
  - `gh run watch 27457494023 --exit-status`
  - Result: pkgdown passed in GitHub Actions.
  - `gh run list --limit 8`
  - Result: GitHub Pages build and deployment `27457528612` passed.
- Rose wording sweep:
  - Public wording says tiny deterministic Ainv validation fixture.
  - Public wording does not claim Mrode validation, ASReml comparison,
    production sparse fitting, large-pedigree readiness, or genomic
    validation.

## 2026-06-13 Mrode9 pedigree Ainv comparator

- Goal: add the first optional Mrode-sourced pedigree `Ainv` comparator without
  claiming fitted Mrode animal-model validation.
- Active lenses: Curie, Fisher, Gauss, Jason, Rose, Grace.
- Spawned subagents: none.
- Source:
  - `nadiv::Mrode9`, documented by `nadiv` as a pedigree adapted from example
    9.1 of Mrode (2005).
- Implementation evidence:
  - Added optional `nadiv` Suggests entry.
  - Added internal `hs_mrode9_pedigree_validation_fixture()`.
  - Added tests that load `nadiv::Mrode9`, compute `nadiv::makeAinv()`, align
    names, and compare with Julia `HSquared.pedigree_inverse()` when both
    `nadiv` and the sibling Julia bridge are available.
- Local checks:
  - `air format . && Rscript -e "devtools::test(filter = 'mrode-validation')"`
  - Result: passed with `8 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live comparator activated sibling `HSquared.jl`.
  - `air format . && Rscript -e "devtools::test()"`
  - Result: passed with `132 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated sibling `HSquared.jl`.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Remote checks:
  - Commit: `f0e71c7 Add Mrode9 Ainv comparator`.
  - `gh run watch 27457712229 --exit-status`
  - Result: R-CMD-check passed in GitHub Actions.
  - `gh run watch 27457712238 --exit-status`
  - Result: pkgdown passed in GitHub Actions.
  - `gh run list --limit 8`
  - Result: GitHub Pages build and deployment `27457742164` passed.
- Rose wording sweep:
  - Public wording says Mrode9 pedigree-Ainv comparator.
  - Public wording does not claim fitted Mrode animal-model validation,
    ASReml/BLUPF90/DMU/WOMBAT comparison, production sparse fitting, or
    large-pedigree readiness.

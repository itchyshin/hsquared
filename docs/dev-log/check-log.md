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

## 2026-06-13 Planned backend vocabulary controls

- Goal: align `hs_control()` with the CPU/GPU backend vocabulary in the
  genomics/QTL/GPU plan without claiming backend execution.
- Active lenses: Lovelace, Karpinski, Grace, Rose, Pat.
- Spawned subagents: none.
- Implementation evidence:
  - Expanded `backend` values to `auto`, `cpu`, `threads`, `cuda`, `amdgpu`,
    `metal`, and `oneapi`.
  - Expanded `accelerator` values to `auto`, `none`, `gpu`, `cuda`,
    `amdgpu`, `metal`, and `oneapi`.
  - Added control-validation tests.
  - Updated public claims, capability status, validation debt, NEWS, and the
    model-status article.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: regenerated `man/hs_control.Rd`.
  - `Rscript -e "devtools::test(filter = 'phase0-api')"`
  - Result: passed with `27 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `143 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says planned backend/control vocabulary only.
  - Public wording does not claim CPU/GPU execution, Metal/CUDA/AMDGPU/oneAPI
    availability, backend benchmarking, or CPU/GPU numerical agreement.
- Remote checks:
  - Commit: `5feac1f Expand planned backend controls`.
  - `gh run list --limit 8`
  - Result: R-CMD-check `27457948686` passed in GitHub Actions.
  - Result: pkgdown `27457948693` passed in GitHub Actions.
  - Result: GitHub Pages build and deployment `27457985141` passed.

## 2026-06-13 Backend status diagnostics

- Goal: add an honest R-side backend diagnostic surface that exposes planned
  backend vocabulary while marking backend execution unavailable.
- Active lenses: Lovelace, Karpinski, Grace, Rose, Pat.
- Spawned subagents: none.
- Implementation evidence:
  - Added exported `backend_info()`.
  - Added `print.hs_backend_info()`.
  - Added tests that check planned backend rows, requested-backend flags,
    `selectable = TRUE`, `execution_available = FALSE`, and `status =
    "planned"`.
  - Added `backend_info()` to the pkgdown reference index.
  - Updated NEWS, public claims, capability status, validation debt, and the
    model-status article.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: regenerated `NAMESPACE` and `man/backend_info.Rd`.
  - `Rscript -e "devtools::test(filter = 'phase0-api')"`
  - Result: passed with `35 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `151 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: clean.
  - First `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: failed because `_pkgdown.yml` was missing the new `backend_info`
    topic from the reference index.
  - Second `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says `backend_info()` reports planned backend vocabulary and
    unavailable execution status.
  - Public wording does not claim runtime backend probes, CPU/GPU execution,
    backend benchmarking, or CPU/GPU numerical agreement.
- Remote checks:
  - Commit: `498d41f Add backend status diagnostics`.
  - `gh run list --limit 8`
  - Result: R-CMD-check `27458148965` passed in GitHub Actions.
  - Result: pkgdown `27458148970` passed in GitHub Actions.
  - Result: GitHub Pages build and deployment `27458179717` passed.

## 2026-06-13 Planned genomic and QTL formula markers

- Goal: reserve readable genomics/QTL formula vocabulary while rejecting it
  honestly until implementation exists.
- Active lenses: Boole, Jason, Lovelace, Rose, Pat.
- Spawned subagents: none.
- Scout input:
  - Read local sibling formula-marker patterns in `gllvmTMB` and `DRM.jl`.
  - Useful local lesson: reserve readable markers, but keep parser and engine
    support explicit so decorative formula terms do not imply computation.
- Implementation evidence:
  - Added inert `genomic()`, `single_step()`, `markers()`, `marker_scan()`,
    and `qtl_scan()` functions.
  - Added parser detection for those markers before model-frame construction.
  - Added planned-not-implemented errors for genomic, marker-scan, single-step,
    and QTL/eQTL terms.
  - Added tests and a pkgdown reference topic.
  - Updated NEWS, public claims, capability status, validation debt, and the
    model-status article.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: regenerated `NAMESPACE` and `man/genomic_markers.Rd`.
  - `Rscript -e "devtools::test(filter = 'formula-animal')"`
  - Result: passed with `17 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `158 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says inert planned markers and planned-not-implemented
    parser errors.
  - Public wording does not claim genomic prediction, marker scanning,
    QTL/eQTL analysis, single-step fitting, or marker-effect estimation.
- Remote checks:
  - Commit: `dc53584 Add planned genomic QTL markers`.
  - `gh run list --limit 8`
  - Result: R-CMD-check `27458338370` passed in GitHub Actions.
  - Result: pkgdown `27458338374` passed in GitHub Actions.
  - Result: GitHub Pages build and deployment `27458374477` passed.

## 2026-06-13 Planned standard QG and inheritance formula markers

- Goal: reserve readable Phase 2+ formula vocabulary for permanent
  environment, common environment, parental effects, inheritance kernels, and
  custom relationship/precision terms while rejecting it honestly until
  implementation exists.
- Active lenses: Boole, Jason, Darwin, Emmy, Rose, Pat.
- Spawned subagents: none.
- Scout input:
  - Read local `gllvmTMB` animal keyword conventions.
  - Read local `drmTMB` structured-effect status patterns.
  - Read local `DRM.jl` parse-time `relmat()`/`animal()` marker pattern.
  - Read local `GLLVM.jl` structured precision and performance design notes.
  - Useful local lesson: formula vocabulary should be explicit and
    discoverable, but parser support must not imply fitted model support.
- Implementation evidence:
  - Added inert `permanent()`, `common_env()`, `maternal_genetic()`,
    `maternal_env()`, `paternal_genetic()`, `paternal_env()`,
    `cytoplasmic()`, `imprinting()`, `dominance()`, `epistasis()`,
    `relmat()`, and `precision()` functions.
  - Generalized parser planned-marker detection so those markers fail before
    model-frame construction.
  - Added planned-not-implemented parser tests and pkgdown reference topic.
  - Updated NEWS, README, formula grammar, public claims, capability status,
    validation debt, model-status article, and scout notes.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: regenerated documentation; `man/qg_effect_markers.Rd` exists.
  - `Rscript -e "devtools::test(filter = 'formula-animal')"`
  - Result: passed with `33 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `174 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says inert planned markers and planned-not-implemented
    parser errors.
  - Public wording does not claim permanent environment, common environment,
    maternal/paternal, dominance, epistasis, custom relationship/precision,
    cytoplasmic, or imprinting models are fitted.
- Remote checks:
  - Commit: `14e5781 Add planned quantitative genetics markers`.
  - `gh run list --limit 8`
  - Result: R-CMD-check `27458665520` passed in GitHub Actions.
  - Result: pkgdown `27458665528` passed in GitHub Actions.
  - Result: GitHub Pages build and deployment `27458695360` passed.

## 2026-06-13 Formula grammar roadmap article

- Goal: make the pkgdown site easier for applied users by separating parsed
  v0.1 syntax from planned quantitative-genetic, inheritance-kernel, genomic,
  marker, multivariate, and factor-analytic syntax.
- Active lenses: Pat, Boole, Rose, Grace.
- Spawned subagents: none.
- Scout/style input:
  - Used `prose-style-review`: reader first, purpose before mechanics, and
    implemented/partial/planned separation.
  - Used `rose-pre-public-audit`: public claims must not imply fitted Phase 2+
    support.
- Implementation evidence:
  - Added `vignettes/articles/formula-grammar.Rmd`.
  - Added the article to the pkgdown navbar and article list.
  - Added a NEWS entry.
- Local checks:
  - `air format .`
  - Result: completed.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Replaced a too-broad "Works today" heading with "Parsed today".
  - Public wording says the article is a grammar map and that planned markers
    are syntax reservations only.
- Remote checks:
  - Commit: `92c1d12 Add formula grammar roadmap article`.
  - `gh run list --limit 8`
  - Result: R-CMD-check `27458831298` passed in GitHub Actions.
  - Result: pkgdown `27458831294` passed in GitHub Actions.
  - Result: GitHub Pages build and deployment `27458861190` passed.

## 2026-06-13 Formula grammar status diagnostic

- Goal: give users a compact R-side status table for parsed, reserved, and
  planned grammar terms.
- Active lenses: Pat, Boole, Emmy, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added exported `formula_status()`.
  - Added `print.hs_formula_status()`.
  - Added tests for non-empty rows, parsed/reserved/planned status, and print
    output.
  - Added pkgdown reference entry.
  - Updated README, NEWS, model-status article, formula grammar article,
    capability status, public claims, and validation debt.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: regenerated `NAMESPACE` and `man/formula_status.Rd`.
  - `Rscript -e "devtools::load_all(quiet = TRUE); print(formula_status())"`
  - Result: printed a 20-row `hs_formula_status` table.
  - `Rscript -e "devtools::test(filter = 'phase0-api')"`
  - Result: passed with `47 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `186 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says diagnostic/status table.
  - Public wording does not say `formula_status()` expands the parser or
    enables fitting.
- Remote checks:
  - Commit: `52d57dd Add formula grammar status diagnostic`.
  - `gh run list --limit 8`
  - Result: R-CMD-check `27459051476` passed in GitHub Actions.
  - Result: pkgdown `27459051483` passed in GitHub Actions.
  - Result: GitHub Pages build and deployment `27459084347` passed.

## 2026-06-13 GPU/backend and algorithm scout

- Goal: record source-backed backend and algorithm leads for later
  `HSquared.jl` engine work.
- Active lenses: Jason, Gauss, Karpinski, Grace, Rose.
- Spawned subagents: none.
- Sources checked:
  - Official JuliaGPU documentation for CUDA.jl, AMDGPU.jl, Metal.jl,
    oneAPI.jl, and KernelAbstractions.jl.
  - Source pages for Takahashi selected inverse, sparse inverse subset, APY
    genomic relationship inverse, sparse AI-REML, and augmented AI-REML.
- Implementation evidence:
  - Added `docs/dev-log/scout/2026-06-13-gpu-algorithm-scout.md`.
- Local checks:
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - The scout says research direction only.
  - It does not claim backend execution, selected-inverse, APY, or AI-REML is
    implemented.
- Remote checks:
  - Commit: `6d6f1f1 Add GPU and algorithm scout`.
  - `gh run list --limit 8`
  - Result: R-CMD-check `27459211479` passed in GitHub Actions.
  - Result: pkgdown `27459211480` passed in GitHub Actions.
  - Result: GitHub Pages build and deployment `27459245659` passed.

## 2026-06-13 Expanded genomics/QTL/GLLVM/GPU plan

- Goal: convert the maintainer's extended prompt into a durable 20-section
  technical and strategic plan for `hsquared` and `HSquared.jl`.
- Active lenses: Ada, Jason, Karpinski, Pat, Rose.
- Spawned subagents: none.
- Local sibling scout:
  - `find /Users/z3437171/Dropbox/Github\ Local -maxdepth 2 -type d ...`
  - Result: found local `drmTMB`, `gllvmTMB`, `DRM.jl`, `GLLVM.jl`, and many
    GLLVM branch/worktree folders; no `PMTMB` folder was found by name.
  - Read targeted local references:
    `DRM.jl/src/takahashi_selinv.jl`, `DRM.jl/src/DRM.jl`,
    `gllvmTMB/CLAUDE.md`, `GLLVM.jl/src/fit.jl`, and
    `GLLVM.jl/src/structured_schur.jl`.
- Implementation evidence:
  - Expanded `docs/design/07-genomics-qtl-gpu-plan.md` into the requested
    design plan covering architecture, grammar, data integration, genomics,
    QTL/eQTL, GLLVMs, CPU/GPU backends, HPC, validation, outputs, roadmap,
    risks, and the first minimal implementation.
  - Updated `vignettes/articles/genomics-gpu-roadmap.Rmd` with user-facing
    QTL/eQTL and multivariate/GLLVM roadmap examples.
  - Updated `docs/design/00-ecosystem-lessons.md` with concrete local lessons
    from `DRM.jl`, `GLLVM.jl`, and `gllvmTMB`.
- Local checks:
  - `git diff --check`
  - Result: clean.
  - `LC_ALL=C rg -n "[^\\x00-\\x7F]" docs/design/07-genomics-qtl-gpu-plan.md docs/design/00-ecosystem-lessons.md vignettes/articles/genomics-gpu-roadmap.Rmd docs/dev-log/after-task/2026-06-13-expanded-genomics-qtl-gpu-plan.md NEWS.md`
  - Result: no non-ASCII matches in edited files.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - The plan and pkgdown article call genomic, QTL/eQTL, GLLVM, GPU, and HPC
    examples planned targets only.
  - Public wording does not claim those workflows are implemented, benchmarked,
    or ASReml-level.
- Remote checks:
  - Commit: `f806a96 Expand genomics QTL GPU plan`.
  - `gh run list --limit 8`
  - Result: R-CMD-check `27459396773` passed in GitHub Actions.
  - Result: pkgdown `27459396771` passed in GitHub Actions.
  - Result: GitHub Pages build and deployment `27459433476` passed.

## 2026-06-13 Opt-in bridge PEV/reliability enrichment

- Goal: enrich the experimental local R-to-Julia bridge with dense
  validation-path prediction-error-variance and reliability fields when the
  sibling `HSquared.jl` checkout exposes exported extractors.
- Active lenses: Hopper, Lovelace, Fisher, Emmy, Rose, Grace.
- Spawned subagents: none.
- Bridge review:
  - Read `docs/design/01-v0.1-contract.md` and
    `docs/design/03-engine-contract.md`.
  - Inspected R bridge code and tests.
  - Inspected sibling `HSquared.jl` state on clean `main` at `5960af1`, where
    `prediction_error_variance(fit)` and `reliability(fit)` exist as dense
    validation-path functions but base `result_payload(fit)` remains stable.
- Implementation evidence:
  - Updated `hs_fit_julia_payload()` to merge optional
    `prediction_error_variance` and `reliability` fields into the R-side raw
    result by calling exported Julia dense validation extractors when they are
    defined.
  - Added a Julia-free normalizer test for optional PEV/reliability fields.
  - Updated live Julia bridge smoke tests to assert PEV/reliability IDs and
    finite values.
  - Updated README, model-status article, v0.1 and engine contracts,
    capability status, validation debt, claims register, NEWS, and
    coordination board.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::test(filter = 'julia-bridge')"`
  - Result: passed with `34 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The test activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `195 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: clean.
  - `rg -n "PEV/reliability waiting|does not return them yet|not yet in live R bridge|PEV or reliability through the current live|waiting on Julia result-payload|current Julia bridge payload does not" README.md NEWS.md vignettes docs R tests`
  - Result: no stale wording matches.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says dense validation-path enrichment for tiny opt-in local
    bridge examples only.
  - Public wording does not claim production sparse PEV/reliability, Mrode
    fitted-output validation, or general animal-model fitting.

## 2026-06-13 Model specification preview helper

- Goal: add a user-facing `model_spec()` inspector for the parsed v0.1 animal
  model contract without widening fitting claims.
- Active lenses: Emmy, Hopper, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `model_spec()` and `"hs_model_spec"` / `"summary_hs_model_spec"`
    methods.
  - The inspector validates `animal(1 | id, pedigree = ped)`, builds the same
    internal bridge payload as `hsquared()`, and reports response, family,
    method, fixed columns, sparse `Z` dimensions, animal IDs, pedigree
    founders, and Julia targets.
  - Added tests for preview fields, compact summaries, no fitted result field,
    and planned-marker error reuse.
  - Updated README, model-status article, pkgdown reference index, capability
    status, claims register, coordination board, and NEWS.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `NAMESPACE` and `man/model_spec.Rd`.
  - `Rscript -e "devtools::test(filter = 'model-spec-inspect')"`
  - Result: passed with `24 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `219 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - First result: failed because `_pkgdown.yml` was missing the new
    `model_spec` topic.
  - Fix: added `model_spec` to the Start here reference index.
  - Second result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Public wording says `model_spec()` previews the parsed contract and does
    not fit a model.
  - Public wording does not claim general animal-model fitting.

## 2026-06-13 hs_data parser integration

- Goal: let the v0.1 R parser use an `hs_data()` bundle directly for the
  phenotype/pedigree path.
- Active lenses: Emmy, Pat, Hopper, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added internal `hs_model_data_context()` to unwrap `hs_data()` into
    `phenotypes` plus a formula environment containing named components such as
    `pedigree`, `genotypes`, `markers`, `expression`, `annotation`, and
    `environment`.
  - `model_spec()` and `hsquared()` can now parse
    `animal(1 | id, pedigree = pedigree)` when `data` is an `hs_data()` object
    with a pedigree component.
  - Updated tests, README, model-status article, v0.1 contract, status tables,
    claims register, NEWS, and roxygen docs.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `hs_data.Rd`, `hsquared.Rd`, and `model_spec.Rd`.
  - `Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: passed with `17 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test(filter = 'model-spec-inspect')"`
  - Result: passed with `29 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `225 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says `hs_data()` integration is for the v0.1
    phenotype/pedigree parser path.
  - Public wording does not claim file-backed storage, automatic genotype/omics
    model construction, or broader fitting support.

## 2026-06-13 hs_data ID-overlap summary

- Goal: make `summary(hs_data(...))` more useful for phenotype, pedigree,
  genotype, and expression ID checks.
- Active lenses: Emmy, Pat, Rose.
- Spawned subagents: none.
- Implementation evidence:
  - Added an `id_overlap` table to `summary.hs_data()`.
  - The table reports phenotype, pedigree, genotype, expression, and mismatch
    counts using the existing `id_map`.
  - Updated tests, README, model-status article, capability status, claims
    register, NEWS, and coordination board.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: completed; no generated file changes.
  - `Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: passed with `19 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `227 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording describes an ID diagnostic only.
  - Public wording does not claim modelling support from genotype or expression
    components.

## 2026-06-13 hs_data marker-map validation

- Goal: add conservative marker-map metadata validation to `hs_data()`.
- Active lenses: Emmy, Jason, Pat, Rose.
- Spawned subagents: none.
- Scout:
  - Read `quantgen-scout` and local package map.
  - Searched local `drmTMB`, `gllvmTMB`, `DRM.jl`, and `GLLVM.jl` for marker
    and map vocabulary.
  - Recorded `docs/dev-log/scout/2026-06-13-marker-map-validation-scout.md`.
- Implementation evidence:
  - Added private `hs_validate_marker_map()`.
  - `hs_data(markers = ...)` now requires marker ID, chromosome, and position
    columns using common aliases.
  - Marker IDs must be non-missing and unique; chromosomes cannot be missing or
    empty; positions must be finite, numeric, and non-negative.
  - Stored normalized metadata in private `hs_marker_map_spec`.
  - Updated tests, README, model-status article, capability status, validation
    debt, claims register, NEWS, and roxygen docs.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `hs_data.Rd`.
  - `Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: passed with `26 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `234 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says marker metadata validation only.
  - Public wording does not claim genotype parsing, PLINK/VCF ingestion, marker
    imputation, marker scans, genomic fitting, or QTL/eQTL fitting.

## 2026-06-13 hs_data genotype-marker alignment

- Goal: check that genotype marker columns match supplied marker-map IDs.
- Active lenses: Emmy, Jason, Pat, Rose.
- Spawned subagents: none.
- Scout:
  - Reused `docs/dev-log/scout/2026-06-13-marker-map-validation-scout.md` and
    updated it with the alignment rule.
- Implementation evidence:
  - Added private `hs_validate_genotype_marker_alignment()` and
    `hs_genotype_marker_ids()`.
  - When both `genotypes` and `markers` are supplied, genotype marker column
    names must match marker-map IDs exactly, allowing different order but no
    missing or extra markers.
  - Stored private `hs_genotype_marker_spec` with marker IDs and marker-map
    indices.
  - Updated tests, README, model-status article, capability status, validation
    debt, claims register, NEWS, and roxygen docs.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `hs_data.Rd`.
  - `Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: passed with `34 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `242 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says genotype-marker alignment validation only.
  - Public wording does not claim genotype parsing, marker imputation, marker
    scans, genomic fitting, or QTL/eQTL fitting.

## 2026-06-13 hs_data marker-status summary

- Goal: expose marker-map and genotype-marker alignment diagnostics through
  `summary(hs_data(...))`.
- Active lenses: Emmy, Jason, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `marker_status` to `summary.hs_data()`.
  - The table reports marker-map marker count, genotype marker-column count,
    aligned marker-column count, chromosome count, coordinate range, and
    alignment status.
  - `print.summary_hs_data()` prints marker status only when marker or genotype
    marker components are present.
  - Updated tests, README, model-status article, capability status, validation
    debt, claims register, NEWS, and roxygen docs.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: passed with `41 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `hs_data.Rd`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `249 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says marker-status diagnostics only.
  - Public wording does not claim genotype parsing, marker imputation, marker
    scans, genomic fitting, or QTL/eQTL fitting.

## 2026-06-13 data_status diagnostic helper

- Goal: add a direct user-facing status helper for `hs_data()` diagnostics.
- Active lenses: Emmy, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added exported `data_status()` S3 generic.
  - Added `data_status.hs_data()` and `print.hs_data_status()`.
  - The helper reports component presence, ID-overlap diagnostics, and
    marker-status diagnostics using the existing `hs_data()` summary surfaces.
  - Added tests and pkgdown reference-index coverage.
  - Updated README, model-status article, capability status, validation debt,
    claims register, NEWS, and coordination board.
- Local checks:
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `NAMESPACE` and `data_status.Rd`.
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: passed with `46 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `254 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says `data_status()` is a diagnostic helper only.
  - Public wording does not claim fitting, genotype parsing, relationship
    matrix construction, marker scanning, genomic fitting, or QTL/eQTL fitting.

## 2026-06-13 hs_data pedigree-status diagnostics

- Goal: expose pedigree coverage and parent-link diagnostics through
  `summary(hs_data(...))` and `data_status()`.
- Active lenses: Emmy, Henderson, Pat, Rose, Grace.
- Spawned subagents: none.
- Scout:
  - Searched local `drmTMB`, `gllvmTMB`, `DRM.jl`, and `GLLVM.jl` for
    relationship, parent, pedigree, and precision patterns.
  - Recorded `docs/dev-log/scout/2026-06-13-pedigree-status-scout.md`.
- Implementation evidence:
  - Added `pedigree_status` to `summary.hs_data()`.
  - Added pedigree-status printing to `print.summary_hs_data()` and
    `print.hs_data_status()`.
  - `data_status()` now includes pedigree diagnostics alongside ID and marker
    diagnostics.
  - Updated tests, README, model-status article, capability status, validation
    debt, claims register, NEWS, and roxygen docs.
- Local checks:
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `hs_data.Rd` and `data_status.Rd`.
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: passed with `55 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `263 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says pedigree diagnostics only.
  - Public wording does not claim pedigree inverse construction, Ainv support,
    animal-model fitting, genomic fitting, or QTL/eQTL fitting.

## 2026-06-13 hs_data pedigree shorthand for animal()

- Goal: let `animal(1 | id)` use the pedigree stored in
  `data = hs_data(..., pedigree = ped)`, while keeping explicit
  `animal(1 | id, pedigree = ped)` as the canonical portable contract.
- Active lenses: Ada, Shannon, Boole, Noether, Emmy, Hopper, Grace, Rose, Pat.
- Spawned subagents: none.
- Scout:
  - Checked local `gllvmTMB`, `DRM.jl`, and `GLLVM.jl` guidance for formula
    parity, one-engine data-shape conversion, R-Julia bridge ownership, and
    verify-before-claim discipline.
  - Recorded
    `docs/dev-log/scout/2026-06-13-hs-data-pedigree-shorthand-scout.md`.
- Implementation evidence:
  - `hs_build_model_spec()` now passes the original `hs_data()` context to the
    animal parser.
  - `animal(1 | id)` resolves to the bundle pedigree only when `data` is an
    `hs_data()` object with a pedigree component.
  - Plain data frames and `hs_data()` objects without a pedigree still error
    clearly and require an explicit pedigree source.
  - `model_spec()` summaries now record whether the pedigree came from the
    formula or the `hs_data()` bundle.
  - `formula_status()` reports the bundle shorthand as parsed today.
  - Updated tests, README, formula/status articles, capability status,
    validation debt, claims register, NEWS, and roxygen docs.
- Local checks:
  - `Rscript -e "devtools::test(filter = 'formula-animal|model-spec-inspect|phase0-api')"`
  - Result: passed with `122 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `animal.Rd`, `hsquared.Rd`, and `model_spec.Rd`.
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `276 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: passed with no output.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n 'henderson_mme.*estimate|Henderson MME.*estimate|supplied-variance.*log-likelihood|log-likelihood.*supplied-variance|production sparse reliability.*implemented|general animal-model support|AI-REML is implemented|Mrode fitted-output validation is covered|ASReml parity|fast|faster|speedup' README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  - Result: hits were planned, blocked, negated, or prior scan/report records.
  - Public wording says optional dense validation-path PEV/reliability for the
    supplied-variance Henderson MME bridge only.
  - Public wording does not claim variance-component estimation, log-likelihood
    support, AI-REML, Mrode fitted-output validation, ASReml parity, production
    sparse reliability, or speedup.
- Remote checks for commit `1489185`:
  - GitHub Actions R-CMD-check `27462976668`: passed in 1m29s.
  - GitHub Actions pkgdown `27462976666`: passed.
  - GitHub Pages build/deploy `27463009993`: passed.

## 2026-06-13 fitted/residual extractors for hsquared_fit

- Goal: add ordinary R `fitted()` and `residuals()` methods for
  `hsquared_fit` objects with normalized fitted-value predictions and response
  values.
- Active lenses: Emmy, Pat, Fisher, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `fitted.hsquared_fit()` over the normalized `predictions` result
    field.
  - Added `residuals.hsquared_fit()` using the stored response vector and
    fitted values.
  - Added guards for missing response values and response/fitted length
    mismatch.
  - Updated NEWS, README, model-status article, v0.1 contract, engine
    contract, capability status, validation debt, public claims, and board.
- Local checks:
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'fit-object')"`
  - Result: documentation updated, formatting completed, and focused tests
    passed with `39 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `340 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - First run result: `0 errors | 0 warnings | 1 note`; note identified
    unqualified internal calls to `predict()` and `fitted()`.
  - Namespace fix: changed internal calls to `stats::predict()` and
    `stats::fitted()`.
  - `air format . && Rscript -e "devtools::test(filter = 'fit-object')" && Rscript -e "devtools::check()"`
  - Result: focused tests passed with `39 pass`, `0 fail`, `0 warnings`, and
    `0 skips`; `devtools::check()` returned `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n 'fitted\\(\\).*general|residuals\\(\\).*general|residuals.*fit model|fitted.*fit model|general animal-model support|production sparse|ASReml parity|speedup|fast|faster' README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  - Result: hits were planned, blocked, negated, or prior scan/report records.
  - Public wording says fitted/residual extractor methods for `hsquared_fit`
    objects only.
  - Public wording does not claim general model fitting, production sparse
    fitting, ASReml parity, or speedup.
- Remote checks for commit `09f3135`:
  - GitHub Actions R-CMD-check `27463241417`: passed in 1m37s.
  - GitHub Actions pkgdown `27463241406`: passed.
  - GitHub Pages build/deploy `27463273446`: passed.

## 2026-06-13 EBV/BLUP aliases and accuracy extractor

- Goal: add applied-user extractor ergonomics for `hsquared_fit` objects:
  `EBV()`, `BLUP()`, and `accuracy()`.
- Active lenses: Emmy, Falconer, Fisher, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `EBV()` and `BLUP()` as S3 aliases for `breeding_values()`.
  - Added `accuracy()` as a derived square-root reliability extractor.
  - Added guardrails for malformed reliability payloads and values outside
    `[0, 1]`.
  - Updated NEWS, README, model-status article, v0.1 contract, engine
    contract, capability status, validation debt, public claims, and board.
- Local checks:
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'fit-object')"`
  - Result: documentation updated, formatting completed, and focused tests
    passed with `48 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `349 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n 'accuracy\\(\\).*validated|accuracy\\(\\).*general|EBV\\(\\).*general|BLUP\\(\\).*general|production accuracy|production sparse|general animal-model support|ASReml parity|speedup|fast|faster' README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  - Result: hits were planned, blocked, negated, or prior scan/report records.
  - Public wording says alias and derived extractors for `hsquared_fit` objects
    only.
  - Public wording does not claim general model fitting, production accuracy,
    production sparse fitting, ASReml parity, or speedup.
- Remote checks for commit `046a8e6`:
  - GitHub Actions R-CMD-check `27463477466`: passed in 1m33s.
  - GitHub Actions pkgdown `27463477467`: passed in 1m49s.
  - GitHub Pages build/deploy `27463517699`: passed; Node.js 20 deprecation
    warning is from the Pages action stack, not this package code.
- Remote checks for evidence commit `66d4d36`:
  - GitHub Actions R-CMD-check `27463547679`: passed in 1m30s.
  - GitHub Actions pkgdown `27463547685`: passed in 1m36s.
  - GitHub Pages build/deploy `27463582542`: passed; Node.js 20 deprecation
    warning is from the Pages action stack, not this package code.
- Issue ledger:
  - Issue #5 updated:
    <https://github.com/itchyshin/hsquared/issues/5#issuecomment-4698196423>.

## 2026-06-13 hs_data environment-key diagnostics

- Goal: add `hs_data()` diagnostics for environment/covariate metadata keyed
  to phenotype records.
- Active lenses: Emmy, Darwin, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `environment_id` to `hs_data()`.
  - Added `hs_environment_spec` metadata for keyed environment tables.
  - Added `summary(hs_data(...))$environment_status`.
  - Added `data_status(...)$environment_status` and print support.
  - Added tests for keyed coverage, unkeyed environment tables, and invalid
    environment-key inputs.
  - Updated README, model-status article, capability status, validation debt,
    public claims, NEWS, roxygen docs, and board.
- Local checks:
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: documentation updated, formatting completed, and focused tests
    passed with `74 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `368 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n "environment.*model|environment.*fit|multi-environment.*support|environment_id.*fit|environment_id.*model|genomic.*implemented|QTL.*implemented|eQTL.*implemented|GLLVM.*implemented|GPU.*implemented|supports genomic|supports QTL|supports eQTL|ASReml parity|speedup|fast|faster" README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  - Result: hits were planned, blocked, negated, or prior scan/report records.
  - Public wording says environment-key diagnostics only.
  - Public wording does not claim environmental model terms,
    multi-environment animal models, automatic environment joins, genomic/QTL
    fitting, GLLVM support, GPU execution, ASReml parity, or speedup.
- Remote checks for commit `07c8145`:
  - GitHub Actions R-CMD-check `27463896935`: passed in 1m37s.
  - GitHub Actions pkgdown `27463896936`: passed in 1m34s.
  - GitHub Pages build/deploy `27463935270`: passed; Node.js 20 deprecation
    warning is from the Pages action stack, not this package code.
- Issue ledger:
  - Issue #8 updated:
    <https://github.com/itchyshin/hsquared/issues/8#issuecomment-4698232188>.

## 2026-06-13 hs_data annotation-feature diagnostics

- Goal: add `hs_data()` diagnostics for expression feature columns keyed to
  annotation metadata rows.
- Active lenses: Emmy, Jason, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `annotation_id` to `hs_data()`.
  - Added `hs_annotation_spec` metadata for keyed annotation tables.
  - Added `summary(hs_data(...))$annotation_status`.
  - Added `data_status(...)$annotation_status` and print support.
  - Added tests for keyed annotation coverage, unkeyed annotation tables, and
    invalid annotation-key inputs.
  - Updated README, model-status article, capability status, validation debt,
    public claims, NEWS, roxygen docs, and board.
- Local checks:
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: documentation updated, formatting completed, and focused tests
    passed with `94 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `388 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n "annotation.*model|annotation.*fit|annotation_id.*fit|annotation_id.*model|eQTL.*implemented|omics.*implemented|expression.*model|expression.*fit|automatic.*annotation|genomic.*implemented|QTL.*implemented|GLLVM.*implemented|GPU.*implemented|supports eQTL|supports omics|supports QTL|ASReml parity|speedup|fast|faster" README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  - Result: hits were planned, blocked, negated, or prior scan/report records.
  - Public wording says annotation-feature diagnostics only.
  - Public wording does not claim eQTL fitting, omics models, automatic
    annotation joins, marker/QTL/GWAS fitting, GLLVM support, GPU execution,
    ASReml parity, or speedup.
- Remote checks for commit `cc62dd2`:
  - GitHub Actions R-CMD-check `27464161209`: passed.
  - GitHub Actions pkgdown `27464161179`: passed.
  - GitHub Pages build/deploy `27464191840`: passed.
- Issue ledger:
  - Updated issue #8:
    <https://github.com/itchyshin/hsquared/issues/8#issuecomment-4698262135>.

## 2026-06-13 hs_data expression-status diagnostics

- Goal: add `hs_data()` diagnostics for expression matrix/data-frame shape and
  feature naming without adding eQTL or omics modelling.
- Active lenses: Emmy, Jason, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `summary(hs_data(...))$expression_status`.
  - Added `data_status(...)$expression_status` and print support.
  - The status table reports expression rows, expression IDs, expression
    feature count, named feature count, unnamed feature count, duplicate named
    feature count, and component type.
  - Added tests for data-frame expression inputs, named matrix features with
    duplicate feature IDs, and unnamed expression matrix columns.
  - Updated README, model-status article, capability status, validation debt,
    public claims, NEWS, roxygen docs, and board.
- Local checks:
  - `Rscript -e "devtools::document()"`
  - Result: documentation updated; wrote `hs_data.Rd` and `data_status.Rd`.
  - `air format . && Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: formatting completed, and focused tests passed with `101 pass`,
    `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `395 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n "expression.*model|expression.*fit|expression_status.*fit|expression_status.*model|eQTL.*implemented|omics.*implemented|automatic.*expression|automatic.*annotation|genomic.*implemented|QTL.*implemented|GLLVM.*implemented|GPU.*implemented|supports eQTL|supports omics|supports QTL|ASReml parity|speedup|fast|faster" README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  - Result: hits were planned, blocked, negated, prior scan/report records, or
    the intended new `without fitting eQTL or omics models` wording.
  - Public wording says expression-status diagnostics only.
  - Public wording does not claim eQTL fitting, omics models, automatic
    expression or annotation joins, marker/QTL/GWAS fitting, GLLVM support,
    GPU execution, ASReml parity, or speedup.
- Remote checks:
  - GitHub Actions R-CMD-check `27464519542`: passed for commit `c5e97d1`.
  - GitHub Actions pkgdown `27464519547`: passed for commit `c5e97d1`.
  - GitHub Pages build/deploy `27464558016`: passed after the pkgdown publish.
  - Pages emitted the upstream Node.js 20 action deprecation annotation from
    the Pages action stack; no package-code failure.
- Issue ledger:
  - Updated issue #8:
    <https://github.com/itchyshin/hsquared/issues/8#issuecomment-4698297184>.

## 2026-06-13 hs_data genotype-status diagnostics

- Goal: add `hs_data()` diagnostics for genotype matrix/data-frame shape and
  marker-column naming without adding genomic, marker-scan, or QTL modelling.
- Active lenses: Emmy, Jason, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `summary(hs_data(...))$genotype_status`.
  - Added `data_status(...)$genotype_status` and print support.
  - The status table reports genotype rows, genotype IDs, marker-column count,
    named marker-column count, unnamed marker-column count, duplicate named
    marker-column count, missing genotype value count, and component type.
  - Fixed duplicate-name handling in genotype and expression feature helper
    paths by replacing `setdiff()` with order-preserving name filtering.
  - Added tests for matrix genotype inputs, data-frame genotype inputs,
    unnamed genotype matrix columns, duplicate genotype marker columns, and
    missing genotype values.
  - Updated README, model-status article, capability status, validation debt,
    public claims, NEWS, roxygen docs, and board.
- Local checks:
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: documentation updated, formatting completed, and focused tests
    passed with `108 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `402 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - First run result: `0 errors | 0 warnings | 1 note`; note was
    `unable to verify current time` from timestamp verification.
  - `Rscript -e "devtools::check()"`
  - Rerun result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n "genotype.*model|genotype.*fit|genotype_status.*fit|genotype_status.*model|genomic.*implemented|marker.*implemented|QTL.*implemented|eQTL.*implemented|omics.*implemented|automatic.*genotype|automatic.*marker|GLLVM.*implemented|GPU.*implemented|supports genomic|supports QTL|supports eQTL|ASReml parity|speedup|fast|faster" README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  - Result: hits were planned, blocked, negated, prior scan/report records, or
    the intended new `without fitting genomic, marker-scan, or QTL models`
    wording.
  - Public wording says genotype-status diagnostics only.
  - Public wording does not claim genomic fitting, genotype parsing, marker
    scanning, QTL/GWAS/eQTL fitting, automatic genotype/model construction,
    GLLVM support, GPU execution, ASReml parity, or speedup.
- Remote checks:
  - GitHub Actions R-CMD-check `27464791701`: passed for commit `fd0cbd9`.
  - GitHub Actions pkgdown `27464791712`: passed for commit `fd0cbd9`.
  - GitHub Pages build/deploy `27464830072`: passed after the pkgdown publish.
  - Pages emitted the upstream Node.js 20 action deprecation annotation from
    the Pages action stack; no package-code failure.
- Issue ledger:
  - Updated issue #8:
    <https://github.com/itchyshin/hsquared/issues/8#issuecomment-4698325286>.

## 2026-06-13 supplied-variance Henderson MME validation fixture

- Goal: add an internal supplied-variance Henderson mixed-model-equation
  validation atom for issue #7.
- Active lenses: Curie, Henderson, Fisher, Hopper, Rose, Grace.
- Spawned subagents: none.
- Scout:
  - Checked local `HSquared.jl/src/likelihood.jl` to confirm
    `henderson_mme()` is a supplied-variance solver, not a variance-component
    optimizer.
  - Checked local `GLLVM.jl/CLAUDE.md` for verify-before-claim discipline.
  - Recorded
    `docs/dev-log/scout/2026-06-13-henderson-mme-validation-scout.md`.
- Implementation evidence:
  - Added `hs_henderson_mme_validation_fixture()`.
  - Added `hs_solve_henderson_mme_reference()` as an independent R MME solve.
  - Added tests comparing fixed effects, EBVs, fitted values, and h2 against
    expected fixture values.
  - Added an optional live Julia test comparing the R fixture with
    `HSquared.henderson_mme()` when a sibling checkout is available.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::test(filter = 'validation-fixtures')"`
  - Result: passed with `19 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live fixture activated sibling `HSquared.jl`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `287 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live bridge activated sibling `HSquared.jl`.
  - `Rscript -e "devtools::document()"`
  - Result: completed.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n "general animal-model support|production sparse fitting is validated|Mrode validation is covered|ASReml comparison is covered|GPU execution is (available|implemented)|fits general animal|supports genomic|supports QTL|supports eQTL" README.md vignettes docs/design docs/dev-log NEWS.md`.
  - Result: hits were planned, blocked, or negated wording only.
  - Public wording says supplied-variance Henderson MME validation fixture only.
  - Public wording does not claim variance-component estimation, general
    fitting, Mrode fitted-output validation, AI-REML, or production sparse
    fitting.
- Remote checks for commit `ec2a9cc`:
  - GitHub Actions R-CMD-check `27461936435`: passed in 1m40s.
  - GitHub Actions pkgdown `27461936446`: passed in 1m36s.
  - GitHub Pages build/deploy `27461969071`: passed; Node.js 20 deprecation
    warning is from the Pages action stack, not this package code.

## 2026-06-13 validation_status evidence diagnostics

- Goal: add a user-facing validation evidence status helper for issue #7.
- Active lenses: Curie, Fisher, Pat, Rose, Grace.
- Spawned subagents: none.
- Skill used:
  - `validation-canon-review`: read current validation canon and validation
    debt register before editing.
- Implementation evidence:
  - Added exported `validation_status()`.
  - Added `print.hs_validation_status()`.
  - The helper reports current partial validation atoms and planned comparator
    lanes with claim-boundary wording.
  - Added tests, roxygen docs, pkgdown reference entry, README/model-status
    wording, capability status, validation debt, public claims, NEWS, and board
    updates.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::test(filter = 'phase0-api')"`
  - Result: passed with `56 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `NAMESPACE` and `validation_status.Rd`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `295 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n "validation_status\\(\\).*fit|validation_status\\(\\).*run|validation_status\\(\\).*covered|ASReml parity|GPU speedup|general animal-model fitting is implemented|production sparse fitting is validated" README.md R man tests vignettes docs/design docs/dev-log NEWS.md _pkgdown.yml`.
  - Result: hits were planned, blocked, or negated wording only.
  - Public wording says `validation_status()` is a diagnostic helper only.
  - Public wording does not claim checks are run, fitting is available,
    validation rows are covered, ASReml parity, GPU speedup, or production
    sparse fitting.
- Remote checks for commit `a52337a`:
  - GitHub Actions R-CMD-check `27462165978`: passed in 1m38s.
  - GitHub Actions pkgdown `27462165981`: passed in 1m42s.
  - GitHub Pages build/deploy `27462200373`: passed; Node.js 20 deprecation
    warning is from the Pages action stack, not this package code.

## 2026-06-13 marker/QTL/eQTL extractor contract

- Goal: reserve user-facing marker, QTL, GWAS, and eQTL output extractor names
  without implying model fitting support.
- Active lenses: Jason, Fisher, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `marker_effects()`, `marker_variance_explained()`, `qtl_table()`,
    `gwas_table()`, `eqtl_table()`, and `lod_scores()`.
  - Each extractor is an S3 generic.
  - `hsquared_fit` methods return matching future result payload fields.
  - Default methods error clearly that marker-scan, QTL, GWAS, and eQTL models
    are not fitted yet.
  - Added tests, roxygen docs, pkgdown reference entry, README/model-status
    wording, capability status, validation debt, public claims, NEWS, and board
    updates.
- Local checks:
  - `air format . && Rscript -e "devtools::test(filter = 'fit-object')"`
  - Result: passed with `32 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `NAMESPACE` and `marker_extractors.Rd`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `306 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n "qtl_table\\(\\).*fit|gwas_table\\(\\).*fit|eqtl_table\\(\\).*fit|marker_effects\\(\\).*fit|marker-scan.*implemented|GWAS.*implemented|eQTL.*implemented|QTL.*implemented|supports QTL|supports eQTL|supports genomic" README.md R man tests vignettes docs/design docs/dev-log NEWS.md _pkgdown.yml`.
  - Result: hits were planned, blocked, or negated wording only.
  - Public wording says output extractor vocabulary only.
  - Public wording does not claim marker scanning, QTL, GWAS, eQTL, genomic
    fitting, or generated result tables.
- Remote checks for commit `ab5d5dd`:
  - GitHub Actions R-CMD-check `27462369055`: passed in 1m51s.
  - GitHub Actions pkgdown `27462369052`: passed in 1m40s.
  - GitHub Pages build/deploy `27462402877`: passed.

## 2026-06-13 supplied-variance Henderson MME bridge target

- Goal: expose an explicit opt-in R-to-Julia bridge target for
  supplied-variance Henderson MME validation.
- Active lenses: Hopper, Lovelace, Henderson, Fisher, Rose, Grace.
- Spawned subagents: none.
- Skills used:
  - `bridge-contract-review`: kept the target under `engine_control` and mapped
    Julia result fields back to the R S3 object contract.
  - `engine-contract-review`: kept the payload within the v0.1 animal-model
    contract and avoided log-likelihood or optimizer claims.
- Implementation evidence:
  - Added `engine_control$target` validation for `"fit_animal_model"` and
    `"henderson_mme"`.
  - Added required `engine_control$variance_components` validation for
    `target = "henderson_mme"`.
  - Added `hs_fit_julia_henderson_mme_payload()`.
  - Added an R normalizer for the Julia `henderson_mme()` result shape.
  - `hsquared()` now dispatches to `henderson_mme()` only when explicitly
    requested through the experimental Julia engine.
  - Added live tests against the existing Henderson MME validation fixture.
  - Updated README, model-status article, v0.1 contract, engine contract,
    capability status, validation debt, public claims, NEWS, roxygen docs, and
    coordination board.
- Local checks:
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'julia-bridge|phase0-api')"`
  - Result: docs updated, formatting completed, focused tests passed with
    `111 pass`, `0 fail`, `0 warnings`, and `0 skips`; live Julia bridge
    activated sibling `HSquared.jl`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `327 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - First run result: `0 errors | 0 warnings | 1 note`; note was
    `unable to verify current time` from timestamp verification.
  - `Rscript -e "devtools::check()"`
  - Rerun result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n "henderson_mme.*estimate|henderson_mme.*logLik|supplied-variance.*log-likelihood|general animal-model support|production sparse fitting|AI-REML|ASReml parity|fit.*Mrode|optimizer" README.md R man tests vignettes docs/design docs/dev-log NEWS.md`.
  - Result: hits were planned, blocked, negated, or the intended
    `optimizer_status = "not_run"` diagnostic.
  - Public wording says supplied-variance validation bridge target only.
  - Public wording does not claim variance-component estimation, log-likelihood
    support, AI-REML, Mrode fitted-output validation, ASReml parity, or
    production sparse fitting.
- Remote checks for commit `99d974a`:
  - GitHub Actions R-CMD-check `27462704120`: passed in 1m51s.
  - GitHub Actions pkgdown `27462704121`: passed.
  - GitHub Pages build/deploy `27462736392`: passed.

## 2026-06-13 fit diagnostics extractor

- Goal: add a conservative `fit_diagnostics()` extractor for `hsquared_fit`
  objects so users and developers can inspect engine, method, target,
  convergence, optimizer status, iterations, log-likelihood metadata, and
  dense-validation-path flags without refitting or implying production support.
- Active lenses: Emmy, Hopper, Jason, Pat, Rose, Grace.
- Spawned subagents: none.
- Sibling scout:
  - Checked local `drmTMB`, `gllvmTMB`, `GLLVM.jl`, and `DRM.jl` fit-summary
    and post-fit patterns.
  - Recorded decision in
    `docs/dev-log/scout/2026-06-13-fit-diagnostics-sibling-scout.md`.
- Implementation evidence:
  - Added `fit_diagnostics()` generic, default method, `hsquared_fit` method,
    and `print.hs_fit_diagnostics()`.
  - Added scalar formatting for result diagnostics while preserving extra Julia
    payload diagnostics such as `gradient_norm`.
  - Added tests for the extractor, default error, and print method.
  - Updated README, NEWS, model-status article, public claims register,
    capability status, roxygen docs, and pkgdown reference index.
- Local checks:
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'fit-object|julia-bridge|phase0-api')"`
  - Result: docs updated, formatting completed, focused tests passed with
    `171 pass`, `0 fail`, `0 warnings`, and `0 skips`; live Julia bridge
    activated sibling `HSquared.jl`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `408 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - First run result: `0 errors | 0 warnings | 1 note`; note was
    `unable to verify current time`.
  - `Rscript -e "devtools::check()"`
  - Rerun result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording boundary:
  - `fit_diagnostics()` is documented as an inspection helper over existing
    result payloads.
  - No public wording claims new model-fitting support, production sparse
    reliability, ASReml parity, or GPU/backend execution.
- Remote checks for commit `908288d`:
  - GitHub Actions R-CMD-check `27465212098`: passed in 1m30s.
  - GitHub Actions pkgdown `27465212092`: passed.
  - GitHub Pages build/deploy `27465247244`: passed.
  - Pages emitted the upstream Node 20 actions deprecation annotation for
    `actions/checkout@v4` and `actions/upload-artifact@v4`; package checks and
    deployment succeeded.

## 2026-06-13 coef/nobs S3 fit methods

- Goal: make `hsquared_fit` objects behave a little more like ordinary R fit
  objects by adding `coef()` as a fixed-effect alias and `nobs()` as an
  observation-count extractor.
- Active lenses: Emmy, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `coef.hsquared_fit()` delegating to `fixef()`.
  - Added `nobs.hsquared_fit()` using `result$nobs` with a response-payload
    fallback.
  - Added tests for `coef()`, `nobs()`, fallback behavior, and missing
    observation metadata.
  - Added `importFrom(stats, nobs)` through roxygen after `R CMD check` caught
    the missing namespace generic during clean namespace loading.
  - Updated README, NEWS, model-status article, capability status, and public
    claims register.
- Local checks:
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'fit-object')"`
  - Result: docs updated, formatting completed, focused tests passed with
    `58 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()" && Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()" && Rscript -e "devtools::check()"`
  - Result before import fix: full tests passed with `412 pass`; pkgdown had
    `No problems found`; `devtools::check()` failed with `3 warnings` and
    `2 notes` because `nobs` was not imported for namespace S3 registration.
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'fit-object')" && Rscript -e "devtools::check()"`
  - Result after import fix: focused tests passed with `58 pass`; package check
    passed with `0 errors`, `0 warnings`, and `0 notes`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `git diff --check`
  - Result: clean.
- Rose wording boundary:
  - `coef()` and `nobs()` are S3 ergonomics over existing payload fields.
  - No public wording claims new fitting, variance-component estimation,
    production sparse PEV/reliability, or comparator parity.
- Remote checks for commit `64b6c89`:
  - GitHub Actions R-CMD-check `27465482460`: passed in 1m31s.
  - GitHub Actions pkgdown `27465482452`: passed.
  - GitHub Pages build/deploy `27465520405`: passed.
  - Pages emitted the upstream Node 20 actions deprecation annotation for
    `actions/checkout@v4` and `actions/upload-artifact@v4`; package checks and
    deployment succeeded.

## 2026-06-13 Henderson MME bridge PEV/reliability parity

- Goal: let the supplied-variance Henderson MME bridge target attach dense
  validation-path PEV and reliability when the sibling `HSquared.jl` checkout
  exposes applicable `prediction_error_variance()` and `reliability()` methods.
- Active lenses: Hopper, Lovelace, Henderson, Fisher, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added an `applicable()`-guarded JuliaCall enrichment step for
    `target = "henderson_mme"`.
  - Added optional `prediction_error_variance` and `reliability` normalization
    to `hs_normalize_julia_henderson_mme_result()`.
  - Added a mocked normalizer test and live bridge assertions for local
    `HSquared.jl` checkouts that expose the MME extractor methods.
  - Updated README, model-status article, v0.1 contract, engine contract,
    validation canon, capability status, validation debt, public claims, NEWS,
    and `validation_status()` wording.
- Local checks:
  - `air format . && Rscript -e "devtools::test(filter = 'julia-bridge|phase0-api')"`
  - Result: passed with `117 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `333 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`

## 2026-06-13 sparse REML likelihood validation atom

- Goal: mirror the Julia lane's sparse REML identity evidence in the R repo by
  adding a tiny supplied-variance fixture that compares Julia dense REML,
  sparse REML, and ML hand-check targets through the existing R bridge setup.
- Active lenses: Curie, Gauss, Fisher, Hopper, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added internal `hs_reml_likelihood_validation_fixture()`.
  - Added a pure R fixture test for payload IDs, all-founder parent indices,
    intercept-only `X`, identity `Z`, identity `Ainv`, beta target, and
    closed-form ML/REML log-likelihood values.
  - Added an optional live JuliaCall test that constructs the sibling
    `HSquared.jl` `animal_model_spec()`, calls `gaussian_loglik()` for ML and
    REML, calls `sparse_reml_loglik()`, and checks sparse REML equals dense
    REML at supplied variance components.
  - Updated `validation_status()`, README, NEWS, model-status article,
    capability status, validation debt register, and public claims register.
- Local checks:
  - `Rscript -e "devtools::test(filter = 'validation-fixtures|phase0-api')"`
  - Initial result: live Julia bridge executed, but two R-only expectations
    failed because they compared incidental matrix attributes and dimensions.
  - Fix: compare numeric values and matrix shape directly.
  - `Rscript -e "devtools::test(filter = 'validation-fixtures|phase0-api')"`
  - Result after fix: passed with `93 pass`, `0 fail`, `0 warnings`, and
    `0 skips`; live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test()"`
  - Result: docs updated, formatting completed, full tests passed with
    `428 pass`, `0 fail`, `0 warnings`, and `0 skips`; live Julia bridge
    activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors`, `0 warnings`, and `0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording boundary:
  - Allowed: tiny supplied-variance likelihood identity, dense-vs-sparse REML
    agreement, ML and REML hand-check targets.
  - Blocked: sparse optimizer, AI-REML, fitted Mrode output validation,
    production sparse fitting, general animal-model support, ASReml parity,
    GPU execution, or speedup.
- Remote checks for commit `49ce975`:
  - GitHub Actions R-CMD-check `27465915349`: passed in 1m38s.
  - GitHub Actions pkgdown `27465915342`: passed in 1m26s.
  - GitHub Pages build/deploy `27465944575`: passed.

## 2026-06-13 mission-control pkgdown article

- Goal: add an R-facing dashboard article matching the twin operating style
  without implying new modelling support.
- Active lenses: Ada, Shannon, Boole, Hopper, Emmy, Grace, Rose, Pat.
- Spawned subagents: none.
- Implementation evidence:
  - Added `vignettes/articles/mission-control.Rmd`.
  - Added the article to `_pkgdown.yml`.
  - Linked the dashboard from README and NEWS.
- Local checks:
  - `git diff --check`: clean.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`:
    articles rebuilt, including `articles/mission-control.html`; pkgdown
    reported `No problems found.`
  - Rendered article spot-check:
    `rg -n "Mission control|One R interface|&lt;article|<pre><code>&lt;article|Blocked Claims|Julia Engine Boundary" pkgdown-site/articles/mission-control.html`
    found the page title, menu link, dashboard content, and no escaped
    dashboard article block.
  - `Rscript -e "devtools::check()"`: passed with `0 errors`, `0 warnings`,
    and `0 notes`.
- Boundary:
  - Documentation dashboard only.
  - No new fitting, bridge, validation, backend, GPU, QTL/eQTL, GLLVM, or
    performance claim.
- Remote checks for commit `aca35df`:
  - GitHub Actions R-CMD-check `27466195166`: passed in 1m48s.
  - GitHub Actions pkgdown `27466195171`: passed in 1m54s.
  - GitHub Pages build/deploy `27466236586`: passed.
  - Pages emitted the upstream Node 20 actions deprecation annotation for
    `actions/checkout@v4` and `actions/upload-artifact@v4`; package checks and
    deployment succeeded.
- Live docs:
  - `https://itchyshin.github.io/hsquared/articles/mission-control.html`:
    HTTP 200 and contains the mission-control page title, Articles menu link,
    and blocked-claims dashboard section.
  - `https://itchyshin.github.io/HSquared.jl/dev/mission-control.html`:
    HTTP 200 and contains the Julia mission-control page title and
    blocked-claims dashboard section.

## 2026-06-13 Mrode-style supplied-variance fixture

- Goal: mirror the Julia twin's Mrode-style supplied-variance validation
  fixture on the R side without claiming general fitting, variance-component
  estimation, or ASReml parity.
- Active lenses: Ada, Shannon, Jason, Hopper, Lovelace, Curie, Fisher, Mrode,
  Rose, Grace.
- Spawned subagents: none.
- Scout evidence:
  - `HSquared.jl/test/runtests.jl` Phase 1 Mrode-style fixture.
  - `HSquared.jl/src/likelihood.jl` likelihood/MME boundaries.
  - `gllvmTMB/R/julia-bridge.R` R-to-Julia result-shape discipline.
  - `DRM.jl/src/comparison.jl` REML comparability guardrail.
- Implementation evidence:
  - Added internal `hs_mrode_supplied_variance_validation_fixture()`.
  - Added independent R reference helpers for MME PEV, reliability, and dense
    Gaussian ML/REML log-likelihood at supplied variance components.
  - Added pure R and optional live JuliaCall tests for Ainv, fixed effects,
    EBVs, fitted values, PEV, reliability, h2, ML logLik, and dense/sparse REML
    logLik.
  - Updated `validation_status()`, README, NEWS, model-status article,
    mission-control article, validation canon, capability status, validation
    debt register, and public claims register.
- Local checks:
  - `air format . && Rscript -e "devtools::test(filter = 'validation-fixtures|mrode-validation|phase0-api|julia-bridge')"`
  - Initial result: two failures from incidental row names inherited from named
    PEV/reliability vectors.
  - Fix: strip incidental names in the R reference helper.
  - Result after fix: passed with `192 pass`, `0 fail`, `0 warnings`, and
    `0 skips`; live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `460 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt, including `mission-control.html` and
    `model-status.html`; pkgdown reported `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors`, `0 warnings`, and `0 notes`.
  - `git diff --check`
  - Result: clean.
  - Rendered article spot-check:
    `rg -n "Mrode-style supplied-variance|estimated-variance Mrode|full Mrode" pkgdown-site/articles/model-status.html pkgdown-site/articles/mission-control.html`
  - Result: found the new model-status and mission-control wording plus the
    blocked estimated-variance Mrode claim.
  - Targeted Rose search:
    `rg -n "Mrode validation complete|animal-model fitting works|REML estimation works|ASReml parity is established|variance-component estimation is implemented|GPU execution is available|QTL/eQTL.*available" README.md NEWS.md docs/design vignettes || true`
  - Result: no matches.
- Rose wording boundary:
  - Allowed: Mrode-style supplied-variance validation fixture with pinned
    Ainv, fixed effects, EBVs, fitted values, PEV, reliability, h2, ML logLik,
    and dense/sparse REML logLik.
  - Blocked: general animal-model fitting, variance-component estimation,
    AI-REML, full Mrode fitted-output validation, ASReml parity, production
    sparse reliability, GPU execution, or speedup.
- Closeout verification (Claude, R lane), takeover of the sister-thread slice:
  - Independent pure-R re-derivation (pedigree -> A -> Ainv -> Henderson MME
    plus marginal-V ML/REML) reproduced every pinned value (Ainv, fixed
    effects, EBVs, fitted, PEV, reliability, h2, ML logLik, dense/sparse REML
    logLik) to machine precision: max abs diff approximately 1.8e-14;
    h2/ML/REML matched exactly.
  - `Rscript -e "rcmdcheck::rcmdcheck(args=c('--no-manual','--no-build-vignettes'))"`:
    `0 errors | 0 warnings | 0 notes`.
  - `air format --check .` and `git diff --check`: clean.
- Remote checks for commit `a437feb`:
  - GitHub Actions R-CMD-check `27467574922`: passed.
  - GitHub Actions pkgdown `27467574904`: passed.
  - GitHub Pages build/deploy `27467612204`: passed.

## 2026-06-13 Claude agent roster and readiness layer

- Goal: stand up the Claude-side operating layer for the R lane without forking
  the Codex instruction set: convert the 21 `.codex/agents/*.toml` review lenses
  to `.claude/agents/*.md`, add `CLAUDE.md` (imports `AGENTS.md`), and symlink
  the 11 `.agents/skills` into `.claude/skills`.
- Active lenses: Ada, Shannon, Grace, Rose. Spawned subagents: none (mechanical
  conversion done solo).
- Implementation evidence:
  - 21 `.claude/agents/*.md` generated from the TOML via tomllib; frontmatter
    `name` (kebab stem) + `description` preserved; `model_reasoning_effort=high`
    -> `model: opus` (11 opus / 10 inherit), else inherit; body =
    `developer_instructions`.
  - `CLAUDE.md` imports `@AGENTS.md` plus Claude-specific notes (lane boundary,
    rehydrate loop, lenses in `.claude/agents`, skills in `.claude/skills`,
    local-checks-over-CI, commit convention).
  - `.claude/skills/<name>` -> `../../.agents/skills/<name>` for all 11 skills
    (all resolve to a `SKILL.md`).
  - `.Rbuildignore` extended with `^\.claude$` and `^CLAUDE\.md$` so the new
    top-level files do not trigger an R CMD check note.
- Local checks:
  - `Rscript -e "rcmdcheck::rcmdcheck(args=c('--no-manual','--no-build-vignettes'))"`:
    `0 errors | 0 warnings | 0 notes` (confirms `.Rbuildignore` excludes the new
    files; no non-standard top-level files note).
  - `.claude/agents`: 21 files. `.claude/skills`: 11 resolving symlinks.
- Boundary: tooling/readiness only; no package code, R API, claims, or bridge
  contract changed. This is the R-lane twin of the Julia lane's agent roster
  (separate repo, no lane collision).
- Remote checks for commit `b43b682`:
  - GitHub Actions R-CMD-check `27467772941`: passed.
  - GitHub Actions pkgdown `27467772929`: passed.
  - GitHub Pages build/deploy `27467811302`: passed.

## 2026-06-13 Experimental sparse REML estimator bridge (B2)

- Goal: surface the twin's Julia-owned `HSquared.fit_sparse_reml()` REML-only
  sparse optimizer through a fenced, opt-in R bridge target
  `engine_control = list(target = "sparse_reml")`; default `hsquared()` still
  validates-and-stops.
- Active lenses: Jason, Hopper, Lovelace, Gauss, Fisher, Curie, Rose. Spawned
  subagents: B2 scout (Jason/Hopper/Curie) and B2 review (Hopper/Fisher/Rose) via
  Workflow.
- Reuse (license-clean): mirrored hsquared's own MIT `hs_fit_julia_payload()` /
  `henderson_mme` pattern and reused `hs_normalize_julia_result()`; adapted
  R-Julia bridge idioms (patterns only) from GPL-3 `gllvmTMB`/`drmTMB`
  `julia-bridge.R` — no GPL code copied into MIT hsquared.
- Implementation:
  - `hs_validate_julia_target()` now accepts `"sparse_reml"`.
  - new `hs_validate_iterations()` and `hs_fit_julia_sparse_reml_payload()`
    (builds a REML spec, calls `fit_sparse_reml(spec; initial, iterations)`,
    reuses the default normalizer, tags `spec$target = "sparse_reml"`).
  - dispatch branch in `hsquared.R`; `hs_control()` doc updated.
- Local checks:
  - `NOT_CRAN=true` `testthat::test_dir(filter = "julia-bridge")`: pass; the live
    sparse-REML test executed against the sibling `HSquared.jl`.
  - `devtools::test()` full: `473 pass`, `0 fail`, `0 warnings`, `0 skips`; live
    Julia bridge active.
  - `rcmdcheck::rcmdcheck()`: `0 errors`, `0 warnings`, `0 notes`.
  - `air format .` and `git diff --check`: clean.
- Multi-lens review (Workflow): Hopper (bridge parity), Fisher (claim/estimand),
  Rose (claim-vs-evidence) — all returned `clean`, no blocking/required findings.
- Boundary: experimental, opt-in, REML-only, Julia-owned estimator that R only
  surfaces; gated on the twin's green `validation_status()`; not the default, not
  variance-component estimation via the public R interface, not production sparse
  fitting, AI-REML, fitted-Mrode, or ASReml parity.
- Remote checks for commit `6add692` (+ `2dd436b`):
  - GitHub Actions R-CMD-check `27468442096`: passed.
  - GitHub Actions pkgdown `27468442094`: passed.
  - GitHub Pages build/deploy `27468475645`: passed.

## 2026-06-13 Estimated-vs-supplied variance provenance (B3)

- Goal: distinguish an estimated-variance fit from a supplied-variance fit. The
  sparse-REML path tags `variance_components = "estimated_sparse_reml"` (Henderson
  MME stays `"supplied"`); `fit_diagnostics()` surfaces `variance_components_source`.
  New `validation_status()` row "experimental sparse REML estimator (opt-in)"
  (Phase 1, partial); table now 13 rows.
- Active lenses: Emmy, Fisher, Rose, Pat. Spawned subagents: none.
- Local checks:
  - `devtools::test()` full: `476 pass`, `0 fail`, `0 warnings`, `0 skips`; live
    Julia bridge active (provenance assertions ran).
  - `rcmdcheck::rcmdcheck()`: `0 errors`, `0 warnings`, `0 notes`.
  - `air format .`: clean.
- Boundary: provenance labelling only; not an accuracy, recovery,
  production-fitting, or comparator claim.
- Remote checks for commit `503734e`:
  - GitHub Actions R-CMD-check `27468654232`: passed.
  - GitHub Actions pkgdown `27468654248`: passed.
  - GitHub Pages build/deploy `27468689299`: passed.

## 2026-06-13 Sparse REML estimate-recovery validation fixture (B4)

- Goal: first honest behavioural evidence for the opt-in sparse REML estimator
  without the comparator estimand trap — a start-independence check (same REML
  optimum from two different starts), not DGP/supplied-truth recovery.
- Active lenses: Curie, Gauss, Fisher, Mrode, Jason, Rose. Spawned subagents:
  none (B2 scout already covered sister comparator discipline).
- Local checks:
  - `devtools::test()` full: `481 pass`, `0 fail`, `0 warnings`, `0 skips`; live
    Julia bridge active (two-start test ran).
  - `rcmdcheck::rcmdcheck()`: `0 errors`, `0 warnings`, `0 notes`.
  - `air format .`: clean.
- Boundary: start-independence only; not DGP recovery, supplied-truth recovery,
  external-comparator parity, AI-REML, or production sparse fitting.
- Remote checks for commit `8a2009a`:
  - GitHub Actions R-CMD-check `27468842532`: passed.
  - GitHub Actions pkgdown `27468842514`: passed.
  - GitHub Pages build/deploy `27468886120`: passed.

## 2026-06-13 Sparse REML bridge contract memory (B5)

- Goal: record the sparse-REML bridge contract in `03-engine-contract.md`,
  closing the Phase B surfacing arc (B2 path -> B3 provenance -> B4
  estimate-recovery -> B5 contract memory).
- Active lenses: Shannon, Hopper, Lovelace, Rose, Pat. Spawned subagents: none.
- Local checks: `git diff --check` clean (documentation-only, coordinator lane).
- Boundary: documents the contract B2-B4 implement; no new capability or claim.
- Remote checks for commit `9e12821`:
  - GitHub Actions R-CMD-check `27468956169`: passed.
  - GitHub Actions pkgdown `27468956186`: passed.
  - GitHub Pages build/deploy `27468994647`: passed.

## 2026-06-13 Sparse-vs-dense REML optimizer agreement (B6, follow-on)

- Goal: cross-check the sparse REML optimizer against the dense REML optimizer
  on the same Mrode fixture (same estimand, different linear algebra).
- Active lenses: Curie, Gauss, Fisher, Hopper, Rose. Spawned subagents: none.
- Local checks:
  - `devtools::test()` full: `486 pass`, `0 fail`, `0 warnings`, `0 skips`; live
    Julia bridge active (both optimizers ran and agreed).
  - `rcmdcheck::rcmdcheck()`: `0 errors`, `0 warnings`, `0 notes`.
  - `air format .`: clean.
- Finding: sparse and dense REML optimizers reach the same REML optimum (matching
  logLik and variance estimates) on the Mrode fixture.
- Boundary: internal cross-check only; not an external comparator, DGP recovery,
  or production-fitting claim.
- Remote checks for commit `f84b959`:
  - GitHub Actions R-CMD-check `27469342270`: passed.
  - GitHub Actions pkgdown `27469342263`: passed.
  - GitHub Pages build/deploy `27469378298`: passed.

## 2026-06-13 Independent pure-R REML optimizer cross-check (B7, follow-on)

- Goal: a fully independent (non-Julia) check on the surfaced sparse REML
  estimator via a pure-R `optim()` over the dense REML objective (a clean
  external REML comparator is not installed; MCMCglmm is Bayesian, excluded).
- Active lenses: Curie, Gauss, Fisher, Rose. Spawned subagents: none.
- Local checks:
  - `devtools::test()` full: `490 pass`, `0 fail`, `0 warnings`, `0 skips`; live
    Julia bridge active (pure-R optimum and Julia estimate agreed).
  - `rcmdcheck::rcmdcheck()`: `0 errors`, `0 warnings`, `0 notes`.
  - `air format .`: clean.
- Finding: Julia `fit_sparse_reml()` estimate matches an independent pure-R REML
  optimum on the Mrode fixture. The pure-R optimizer test runs on CI (no Julia).
- Boundary: independent same-estimand cross-check only; not an external
  comparator, DGP recovery, or production-fitting claim.
- Remote checks for commit `1d576c8`:
  - GitHub Actions R-CMD-check `27469532263`: passed.
  - GitHub Actions pkgdown `27469532270`: passed.
  - GitHub Pages build/deploy `27469579694`: passed.

## 2026-06-13 External REML comparator: pedigreemm (B9, follow-on)

- Goal: first external comparator — `pedigreemm` (lme4-based REML animal model)
  vs hsquared's REML solution on a deterministic replicated dataset.
- Active lenses: Jason, Fisher, Curie, Gauss, Rose. Spawned subagents: none.
- Finding: hsquared/the pure-R reference reach the true REML optimum (verified by
  multi-start + grid on the common verified objective); `pedigreemm` lands
  slightly worse and cannot fit the saturated Mrode fixture. Honest claim:
  hsquared is at least as good as `pedigreemm` by REML logLik (not a tight
  point-estimate match; not ASReml parity; not DGP recovery).
- Local checks:
  - `devtools::test()` full: `492 pass`, `0 fail`, `0 warnings`, `0 skips`; live
    Julia + pedigreemm.
  - `rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))`: `0 errors`,
    `0 warnings`, `1 note` (benign new-submission/dev-version note).
- CI break + fix: first push `9b2af4e` FAILED R-CMD-check (`27470213036`) with
  `unstated dependencies in 'tests' ... WARNING: '::' import not declared from
  'lme4'` under `--as-cran` (workflow `error-on: "warning"`). My earlier local
  gate omitted `--as-cran` and missed it. Fix `dcef460`: declared `lme4` in
  Suggests; re-verified with `--as-cran` (0 warnings). LESSON: gate with
  `--as-cran` locally to match CI.
- Remote checks for commit `dcef460`:
  - GitHub Actions R-CMD-check `27470343823`: passed.
  - GitHub Actions pkgdown `27470343838`: passed.
  - GitHub Pages build/deploy `27470387166`: passed.

## 2026-06-13 User-docs honesty pass for the sparse REML path (B8)

- Goal: keep user-facing docs in sync with capability — surface the opt-in
  `target = "sparse_reml"` estimator path in the model-status article and refresh
  the vision "Current Status" (Pat/Rose lens).
- Active lenses: Pat, Rose, Grace. Spawned subagents: none.
- Local checks:
  - `pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()`:
    `model-status.html` rebuilt; "No problems found."
  - `rcmdcheck::rcmdcheck()`: `0 errors`, `0 warnings`, `0 notes`.
  - `air format .` + `git diff --check`: clean.
- Boundary: docs match capability; no new claim; default still validates-and-stops.
- Remote checks for commit `1e89593`:
  - GitHub Actions R-CMD-check `27469723178`: passed.
  - GitHub Actions pkgdown `27469723172`: passed.
  - GitHub Pages build/deploy `27469763549`: passed.

## 2026-06-13 Opt-in AI-REML estimator bridge (target = "ai_reml")

- Goal: surface the twin's average-information REML estimator
  (`HSquared.fit_ai_reml`) through R behind the existing opt-in fence, mirroring
  `target = "sparse_reml"`. Default still validates-and-stops; no new public
  claim. Serves the standing performance directive (fastest REML/ML).
- Active lenses: Hopper, Lovelace, Gauss, Fisher, Curie, Rose. Spawned
  subagents: none.
- TDD: RED (target rejected; `hs_fit_julia_ai_reml_payload` absent) → GREEN
  (four minimal edits: bridge fn, target validator, dispatch, control docs).
- Local checks:
  - `devtools::test()` full with the live Julia bridge (juliaup on PATH,
    `NOT_CRAN=true`): 508 pass, 0 fail, 0 warnings, 0 skips; the AI-REML live
    tests ran and passed.
  - `rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))`: 0 errors,
    0 warnings, 1 note (benign new-submission/dev-version). The first `--as-cran`
    run caught a stale `validation_status()` row-count assertion (13 → 14), fixed
    before commit. Lesson reaffirmed: gate with `--as-cran` locally to match CI.
  - `air format .`: clean.
- Finding: AI-REML and the sparse NelderMead REML optimizer reach the same REML
  optimum on the Mrode fixture (logLik diff 1.3e-8, variance components 2.7e-4).
- Boundary: experimental opt-in path; estimator is Julia-owned and R surfaces
  it; gated on twin `validation_status()`; not default/production/ASReml/DGP.
- Remote checks for commit `eba8711`:
  - GitHub Actions R-CMD-check `27473026734`: passed.
  - GitHub Actions pkgdown `27473026735`: passed.
  - GitHub Pages build/deploy `27473061867`: passed.

## 2026-06-13 Honesty pass + v0.1 promotion predicate

- Goal (autonomous run, user away): finish the packages honestly. A 6-agent
  audit found the v0.1 fit gate genuinely closed and not openable autonomously;
  the safe high-value work was an honesty pass + binding the gate. Edits made,
  then a 4-agent adversarial review (`safe_to_commit: false`) returned three
  must-fixes + medium predicate-rigor gaps, all applied before commit.
- Active lenses: Rose, Pat, Fisher (review workflow); Ada/Shannon. Spawned
  subagents: yes — workflows `twin-finish-audit` (6) and `honesty-slice-verify`
  (4); also `gate-source-scout` (4) for the maintainer decision menu.
- Files: README.md, vignettes/articles/mission-control.Rmd,
  vignettes/articles/model-status.Rmd, docs/design/01-v0.1-contract.md
  (V0.1 Promotion Predicate + Uncertainty Scope).
- Local checks:
  - `pkgdown::build_articles(lazy = FALSE)` + `pkgdown::check_pkgdown()`:
    rebuilt; "No problems found."
  - `rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))`: 0 errors,
    0 warnings, 1 note (benign new-submission/dev-version).
  - Docs-only; no R code changed.
- Twin-lane finding (verified, NOT fixed here — Julia lane owns it): the twin
  `V1-AI-REML` evidence string (`HSquared.jl/src/validation_status.jl:97`) cites
  a "250-animal simulation / observed-information ratio ~0.99" with no backing
  test (grep: `250` only in that string; real test is an 8-animal
  optimizer-agreement fixture). Must be fixed before any promotion cites that
  row. A GitHub issue on the twin repo was denied by the permission classifier;
  recorded on the coordination board + after-task report for the maintainer.
- Remote checks for commit `0565948`:
  - GitHub Actions R-CMD-check `27473795597`: passed.
  - GitHub Actions pkgdown `27473795603`: passed.
  - GitHub Pages build/deploy `27473836594`: passed.

## 2026-06-13 Gryphon external published-REML recovery atom

- Goal: first externally-anchored REML-recovery atom in the R lane —
  hsquared's pure-R REML reference recovers the published gryphon variance
  components/h2 (Wilson et al. 2010), optionally agreeing with sommer. Built
  under the standing finish-directive; mirrors the pedigreemm precedent.
- Active lenses: Curie, Fisher, Jason, Rose. Spawned subagents: none (built on
  scout `wo62dphp0` + local verification).
- Finding (triple agreement): published VA=3.3954/VE=3.8286/h2=0.470 ↔ sommer
  ↔ hsquared pure-R reference VA=3.3953/VE=3.8287/h2=0.4700 (~4 s).
- Files: `R/validation-fixtures.R` (`hs_gryphon_published_reml()`),
  `tests/testthat/test-validation-fixtures.R` (skip-guarded test),
  `DESCRIPTION` (Suggests: enhancer, sommer), `R/validation-status.R` +
  `test-phase0-api.R` (15 rows), capability-status + validation-debt registers.
- Local checks:
  - `devtools::test()` (NOT_CRAN): the gryphon test ran and passed.
  - `rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))`: 0 errors,
    0 warnings, 1 note (benign).
  - `air format .`: clean.
- Boundary: external-anchor cross-check of the R reference optimizer only; not
  the production fit path; does not satisfy the twin `V1-MRODE-FIT` gate;
  gryphon is teaching/simulated data. Autonomous-under-delegation; maintainer
  may re-point the anchor.
- Remote checks for commit `952075b`:
  - GitHub Actions R-CMD-check `27474821889`: passed (gryphon test ran on CI
    with sommer/enhancer installed).
  - GitHub Actions pkgdown `27474821893`: passed.
  - GitHub Pages build/deploy `27474859398`: passed.

## 2026-06-13 Known-truth DGP variance-component recovery study

- Goal: fill the v0.1 promotion-predicate item-3 gap (known-truth recovery, not
  optimizer reproducibility). ADEMP study (Morris 2019; Williams 2024):
  simulate a univariate Gaussian animal model with known VC over a clean
  pedigree, recover with the engine (ai_reml) + the pure-R reference.
- Active lenses: Curie, Fisher, Gauss, Rose. Spawned subagents: none (used the
  simulation-design skill).
- Result (n=420, 120 engine reps, 100% converged): bias s2a=-0.0000 (MCSE
  0.0090), s2e=+0.0057 (MCSE 0.0067), h2=-0.0049 (MCSE 0.0073) — 0 within
  bias +/- 2*MCSE for all three; EBV accuracy 0.737; engine matches the pure-R
  reference to machine precision (max |h2 diff| 0.0000 on shared reps).
- Files: `data-raw/dgp-recovery-study.R` (full study + ADEMP design, .Rbuildignore'd),
  `tests/testthat/helper-simulation.R`, skip-guarded pure-R regression test in
  `test-validation-fixtures.R`, `R/validation-status.R` (16 rows),
  capability-status + validation-debt registers, `test-phase0-api.R`.
- Local checks:
  - `devtools::test()` (NOT_CRAN): the pure-R regression test ran and passed.
  - `rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))`: 0 errors,
    0 warnings, 1 note (benign).
  - `air format .`: clean.
- Boundary: R-lane recovery evidence via the read-only bridge; does NOT flip the
  twin estimator gate row; single h2=0.4 setting; no boundary/interval/
  production-robustness or default-fit claim.
- Remote checks for commit `874bf07`:
  - GitHub Actions R-CMD-check `27475342941`: passed (DGP test ran on CI with nadiv).
  - GitHub Actions pkgdown `27475342963`: passed.
  - GitHub Pages build/deploy `27475387456`: passed.

## 2026-06-13 DGP generality grid + v0.1 identifiability statement

- Grid (`c15345c`): extended the recovery study with an h2 grid (0.1/0.2/0.4/0.6,
  100 engine reps/cell). Near-unbiased across the interior (0.2/0.4/0.6); the
  near-boundary cell (h2=0.1) shows mild upward bias, 94% convergence, and 5%
  boundary pinning (expected; informs predicate item 4). Updated the recovery
  atom evidence + `data-raw/dgp-recovery-study.R`. `rcmdcheck(--as-cran)`: 0/0/1.
  - Remote: R-CMD-check `27475621343`, Pages `27475670567`: passed.
- Identifiability (`564448a`): added the v0.1 estimable-quantities / identifiability
  statement to `01-v0.1-contract.md` (predicate item 4 docs half; textbook-grounded
  proposal). Docs only.
  - Remote: R-CMD-check `27475739750`, Pages `27475776217`: passed.

## 2026-06-13 Boundary/identifiability flag (predicate item 4 R-half)

- Goal: implement the R-side surfacing half of promotion-predicate item 4 -
  `fit_diagnostics()` + `summary()` flag a variance-component boundary so a
  boundary h2 is not read as ordinary. Engine boundary-stability stays twin work.
- Active lenses: Fisher, Emmy, Rose. Spawned subagents: none.
- Files: `R/extractors.R` (`hs_fit_boundary_flag()` + `at_boundary` row),
  `R/fit-object.R` (summary note), `test-fit-object.R` (metric set + detection
  test), `01-v0.1-contract.md` (predicate item 4), `capability-status.md`.
- Local checks: `devtools::test()` test-fit-object pass; `rcmdcheck(--as-cran)`
  0/0/1 (benign); `air format .` clean.
- Boundary: a diagnostic, not a fitting/default claim; capability stays partial.
- Remote checks for commit `c53f927`:
  - GitHub Actions R-CMD-check `27476005389`: passed.
  - GitHub Actions pkgdown: passed.
  - GitHub Pages build/deploy `27476045834`: passed.

## 2026-06-13 Fixed-effect DGP recovery (contract model)

- Goal: verify recovery holds for `y ~ x + animal(1|id, pedigree=ped)` (the v0.1
  contract structure with a fixed effect), exercising the multi-column X path.
- Result (100 reps, 100% converged): h2 near-unbiased (bias +0.0014, MCSE
  0.0081), EBV acc 0.74, fixed effect recovered (b_x 0.99 vs 1.0).
- `rcmdcheck(--as-cran)`: 0/0/1 (benign). `air format`: clean.
- Remote checks for commit `fdd8705`:
  - GitHub Actions R-CMD-check `27476335755`: passed.
  - GitHub Actions pkgdown `27476335754`: passed.
  - GitHub Pages build/deploy `27476377904`: passed.

## 2026-06-13 Maintainer v0.1 gate sign-off

- Recorded the maintainer sign-off (gryphon anchor + sommer comparator band +
  DGP thresholds) as binding targets in 01-v0.1-contract.md; tightened the
  gryphon comparator test to the signed-off band (VC ~1-2%, h2 ~0.01-0.02) +
  added an h2-agreement check; updated the gate handoff + board.
- Local checks: `air format` clean; live `test-validation-fixtures.R` (juliaup
  on PATH, NOT_CRAN) pass incl. the tightened gryphon band; `rcmdcheck(--as-cran)`
  0 errors, 0 warnings, 1 note (benign).
- Remote checks for commit `03bd62e`:
  - GitHub Actions R-CMD-check `27476877537`: passed.
  - GitHub Actions pkgdown: passed.
  - GitHub Pages build/deploy `27476923025`: passed.

## 2026-06-13 v0.1 default-fit flip (engine = "fit")

- Goal: flip the default `hsquared()` from validate-and-stop to a real REML fit
  of the v0.1 Gaussian animal model (`fit_ai_reml` through the bridge) and make
  every living public surface honest about it. Predicate SATISFIED + maintainer
  sign-off (2026-06-13); mirrors twin gates (V1-AI-REML covered, V1-MRODE-FIT /
  V1-COMPARATORS covered_external).
- Active lenses: Ada, Shannon, Boole, Fisher, Rose, Pat, Hopper. Spawned
  subagents: 5-agent adversarial honesty audit `wetqf4t9i` (3 lenses clean; 1
  confirmed blocker — `engine = "julia"`/`fit_animal_model` ran ML for
  `REML = FALSE` — fixed by an ML guard + regression test).
- ML is not implemented: `REML = FALSE` is rejected on every estimation path;
  the REML-only optimizers stamp `method = "REML"`. Promoted the default-fit,
  gryphon, and DGP validation_status rows to `covered`; corrected "exact" →
  signed-off band (machine precision reserved for engine-vs-pure-R).
- Files: `R/{hsquared,hs_control,julia-bridge,validation-status,formula-status,
  hsquared-package}.R`, `man/*`, `DESCRIPTION`, `README.md`, `vignettes/*`,
  `docs/design/{00-vision,01-v0.1-contract,06-public-claims-register,
  capability-status,validation-debt-register}.md`,
  `tests/testthat/{test-phase0-api,test-julia-bridge,test-bridge-payload,
  test-hs-data}.R`.
- Local checks: `air format .` clean; `devtools::document()`; full `testthat`
  suite with juliaup on PATH + `NOT_CRAN` + `sommer` + `enhancer` (live default
  fit, gryphon, DGP, sommer all run) — 0 failures, 0 warnings, 0 skipped;
  `rcmdcheck(--as-cran)` 0 errors, 0 warnings, 1 note (benign new-submission);
  both pkgdown articles render.
- Local commit `fd7975e` (flip) + `2437e09` (records), not yet pushed.
- Follow-on honesty sweep (separate commit): corrected the last stale
  "validates-and-stops" / "validation-only" claims in living surfaces that the
  flip should have touched — `ROADMAP.md` (Phase 1 status + frontier framing),
  `NEWS.md` (added the headline flip entry + fixed two now-false bullets),
  `docs/design/03-engine-contract.md`, and
  `vignettes/articles/formula-grammar.Rmd`. Repo-wide grep for stale pre-flip
  phrasing in living surfaces is clean; both edited articles render.
- Twin gate landed: `v01-gate-validation-status` (`100adbe`) fast-forwarded onto
  Julia `main` under maintainer authorization (`94e695b..100adbe`); `main` now
  reads V1-AI-REML covered, V1-MRODE-FIT / V1-COMPARATORS covered_external.
  Coordination issue `HSquared.jl#13` opened and closed. Then pushed the four R
  commits (`cd13551..b07bf58`).
- Remote checks for commit `b07bf58`:
  - GitHub Actions R-CMD-check `27482232390`: passed.
  - GitHub Actions pkgdown `27482232393`: passed.
  - GitHub Pages build/deploy `27482264882`: passed.

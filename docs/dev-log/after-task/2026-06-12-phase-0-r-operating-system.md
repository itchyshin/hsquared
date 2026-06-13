# Phase 0 R Operating System

## Task Goal

Install the R-side operating system for the `hsquared` / `HSquared.jl` twin
programme: team rules, repo-visible memory, local skills, launchable-agent
configs, honest Phase 0 R placeholders, tests, and coordination with the Julia
twin.

## Active Lenses And Spawned Agents

Active lenses: Ada, Shannon, Rose, Grace, Pat, Boole, Noether, Gauss, Curie,
Emmy, Hopper, Karpinski, Henderson, Falconer, Mrode.

Spawned subagents in this R thread: none. Coordination used the existing Julia
twin thread `019ebb88-ee69-7be2-850c-0e4840c34734`; the twin owns
`/Users/z3437171/Dropbox/Github Local/HSquared.jl`.

## Files Created Or Changed

- Added `AGENTS.md`, `ROADMAP.md`, design docs, dev-log files, capability
  status, validation debt, public claims register, and after-task protocol.
- Added project-local skills under `.agents/skills/`.
- Added launchable role configs under `.codex/agents/`.
- Updated `DESCRIPTION`, `README.md`, `.Rbuildignore`, package docs, and
  `NEWS.md`.
- Added honest Phase 0 R placeholders: `hsquared()` and `hs_control()`.
- Added tests and generated documentation for the placeholder API.

## Checks Run And Outcomes

- Skill validation:
  `for d in .agents/skills/*; do python3 /Users/z3437171/.codex/skills/.system/skill-creator/scripts/quick_validate.py "$d" || exit 1; done`
  passed for all project-local skills.
- Formatting: `air format .` completed.
- Documentation and tests:
  `Rscript -e 'devtools::document(); devtools::test()'` passed with
  `0 fails | 0 warnings | 12 pass` on the final run.
- Package check:
  `Rscript -e 'devtools::check(error_on = "warning")'` passed with
  `0 errors | 0 warnings | 0 notes`.
- After that clean check, Rose prompted prose-only wording changes that removed
  unsupported `fast` wording and changed one roxygen phrase from future
  `hsquared fits` to future `hsquared model calls`. The generated Rd file was
  kept in sync manually when the local `Rscript` startup probe became
  unresponsive.
- Julia twin verification:
  `HSquared.jl` is public at `https://github.com/itchyshin/HSquared.jl`,
  clean on `main`, latest commit `079dbf2`, and latest GitHub Actions CI
  passed.

## Public Claim Audit

Rose verdict: clean for Phase 0. README, DESCRIPTION, roadmap, and design docs
describe the R package as a scaffold and the animal-model syntax as planned.
No public-facing file claims that `hsquared()` fits animal models.

The claim register still marks sparse Ainv, Gaussian REML/ML, EBVs,
heritability extraction, multivariate G matrices, genomic/single-step models,
GLLVM animal models, and non-standard inheritance systems as planned.

## Tests Of The Tests

The tests check constructor validation, placeholder error behavior, and
snapshot wording. They are intentionally Phase 0 tests, not modelling tests.
There are no recovery, numerical, or bridge tests yet because no parser,
bridge, or engine implementation exists in the R repo.

## Coordination Notes

The R/coordinator lane explicitly instructed the Julia twin to own only
`HSquared.jl` and avoid R repo writes. Live verification shows the Julia twin
completed a public Julia scaffold and CI. The R repo is the only repo touched
by this lane.

## What Did Not Go Smoothly

One sibling-thread transcript read was too large to be useful as evidence, so
the final Julia status was verified from local git state and GitHub CLI
instead. The first R CMD check found a NEWS-format NOTE; `NEWS.md` was adjusted
and the check passed cleanly afterward. Later, after the clean check,
`Rscript --vanilla -e 'cat("R ok\n")'` became unresponsive and was interrupted,
so the next GitHub Actions run is the required post-push runtime verification.

## Known Limitations

- `hsquared()` is an honest placeholder and always errors before fitting.
- `animal()`, `fa()`, `lowrank()`, genomic, single-step, and inheritance
  helpers are not exported yet.
- No R-to-Julia bridge exists yet.
- No GitHub issue ledger has been created from the R lane yet.
- The R GitHub repo still needs push, remote CI, public visibility check, and
  final public-readiness confirmation.

## Next Actions

1. Commit and push the R Phase 0 scaffold.
2. Watch the R GitHub Actions run on the pushed commit.
3. Create labels, milestones, and initial issues.
4. Make `itchyshin/hsquared` public after Grace/Rose checks pass.
5. Start Phase 1 only after the R-Julia contract issue is open and assigned.

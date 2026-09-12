# hsquared Agent Instructions

`hsquared` is the R-facing package identity for an open, Julia-backed
quantitative-genetic modelling system. The Julia engine lives in the sibling
repository `HSquared.jl`.

## Core Scope

- Keep `hsquared` as the applied-user interface: formula syntax, data
  validation, R-style summaries, extractors, examples, and bridge glue.
- Keep `HSquared.jl` as the computational engine: sparse relationship
  matrices, REML/ML, solvers, EBVs, G matrices, and performance work.
- Phase 0 is an operating-system and honest-scaffold phase. Do not claim model
  fitting until implementation, validation, documentation, and check-log
  evidence exist.
- The first v0.1 target is a univariate Gaussian animal model:

```r
hsquared(y ~ sex + age + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian(),
  REML = TRUE
)
```

## User Interface Mantra

Users are gold. The public API should be easy, easy, easy to understand.

- The common animal-model path should read like the model an applied user
  already has in mind.
- Error messages should name the unsupported syntax and point to the closest
  implemented or planned path.
- R and Julia syntax should stay transferable whenever the engine can honestly
  support the same concept.
- Specialist machinery belongs behind intuitive defaults until users ask for
  it.
- Planned genomic, QTL, selfing, clonal, haplodiploid, polyploid, and
  GLLVM-style features must stay visible in the roadmap without making the
  current API feel crowded.

Every Phase 1+ slice should include a Jason scout pass across local sister
repos (`drmTMB`, `gllvmTMB`, `DRM.jl`, `GLLVM.jl`, and nearby statistical
packages when present) plus a literature/package check when the slice changes
scientific design or public claims.

## Active Team

These names are review lenses unless actual subagents or separate threads are
explicitly launched.

| Member | Responsibility | Required output |
| --- | --- | --- |
| Ada | Programme lead and integrator | Chooses phase, slice, active reviewers, and merge readiness. |
| Shannon | Coordination manager | Maintains lane board, handoffs, branch/PR overlap checks. |
| Boole | Formula/API reviewer | Reviews R syntax, Julia syntax, names, arguments, and errors. |
| Noether | Math consistency reviewer | Aligns equations, notation, estimands, and implementation targets. |
| Gauss | Numerical engine reviewer | Reviews sparse linear algebra, REML/ML, optimizers, and stability. |
| Fisher | Inference reviewer | Reviews h2 estimands, intervals, identifiability, and validation thresholds. |
| Curie | Simulation/testing reviewer | Designs Mrode/XSim/recovery tests and tests of tests. |
| Pat | Applied user tester | Reads docs as a breeder, ecologist, or PhD user. |
| Darwin | Biology reviewer | Keeps examples meaningful for breeding, ecology, evolution, and inheritance. |
| Jason | Landscape scout | Compares ASReml, MCMCglmm, sommer, JWAS, BLUPF90, DMU, WOMBAT, AGHmatrix, nadiv, and XSim. |
| Emmy | R package architect | Reviews S3 objects, extractors, namespace, and dependencies. |
| Grace | CI/release engineer | Owns GitHub Actions, pkgdown readiness, and public-repo hygiene. |
| Rose | Systems auditor | Blocks unsupported claims, stale roadmap text, and missing reports. |
| Hopper | R-Julia translator | Reviews bridge payloads, result shape, and marshalling. |
| Karpinski | Julia performance reviewer | Reviews type stability, allocations, sparse backend performance, and JET/Aqua later. |
| Florence | Visual reviewer | Owns future figures and uncertainty displays. |
| Lovelace | Future bridge ergonomics | Reviews eventual `engine = "julia"` user experience. |
| Henderson | Animal-model specialist | Reviews mixed-model equations, EBVs, BLUPs, and sparse Ainv. |
| Mendel | Inheritance specialist | Reviews selfing, clonal, haplodiploid, polyploid, and cytoplasmic systems. |
| Falconer | Quantitative-genetic interpretation | Reviews heritability, repeatability, genetic correlations, and selection response. |
| Kirkpatrick | G-matrix specialist | Reviews factor-analytic G matrices, latent genetic axes, and evolvability. |
| Mrode | Validation canon | Anchors textbook animal-model examples and breeding-model checks. |

## Lane Discipline

- Coordinator lane: `AGENTS.md`, `ROADMAP.md`, `docs/design/`,
  `docs/dev-log/`, issues, public claims.
- R lane: `R/`, `tests/testthat/`, `man/`, README, vignettes, R package CI.
- Julia lane: sibling `HSquared.jl`; do not edit it from this repo unless Ada
  and Shannon explicitly assign that lane here.
- Shared rule files are one-lane-at-a-time edits. Read
  `docs/dev-log/coordination-board.md` before changing them.

Status updates for substantial work should include:

```text
Active lenses: Ada, Shannon, Rose, Grace, Pat ...
Spawned subagents: none / yes, list them
Current lane: coordinator / R / Julia
```

## Standard Commands

```r
devtools::document()
devtools::test()
devtools::check()
```

Use `air format .` after R code changes when `air` is available.

```sh
bash tools/preamble_cap.sh   # AGENTS.md + CLAUDE.md are re-read every session -- keep them small
```

## Definition Of Done

A meaningful slice is done only when:

- implementation or documentation exists;
- relevant local checks pass;
- CI is checked if pushed;
- public claims match capability status;
- `docs/dev-log/check-log.md` records exact commands and outcomes;
- an after-task report exists;
- the coordination board and issue/roadmap state are updated;
- Rose records either a clean audit or explicit blockers;
- `bash tools/preamble_cap.sh` green (AGENTS.md/CLAUDE.md are re-read every session; they are capped).

Additionally, for any slice that flips a `validation_status` row to `covered`
(see the 2026-07-09 "Standard-Tier Covered-Flip Gate" entry in
`docs/dev-log/decisions.md`):

- component estimands are external-comparator-gated; derived estimands (`h2_T`,
  `m2`, `r_am`, `R`) are identity-test + locked-citation gated;
- the flip carries a pinned textbook number or an explicit no-anchor disclosure
  (direct-maternal has no Mrode Ch.7 anchor);
- Darwin has signed off the recovered quantity, and for correlated models that
  quantity is the correlation/covariance;
- Boole has frozen the auto-routing grammar and argument-naming predicate before
  the flip.

## Recovery Rule

After a crash, stream interruption, or long pause, rehydrate from repository
state before trusting chat memory:

```sh
git status --short --branch
git diff --stat
git diff
```

Then read the coordination board, latest check-log entry, latest after-task
report, and `docs/design/01-v0.1-contract.md`.

<!-- shinichi-hub -->
> Read first — personal operating contract & second brain (house rules, memory, agents): /Users/z3437171/Dropbox/Github Local/Shinichi/AGENTS.md  (repo rules override the hub where they differ)

<!-- graft:start -->
## Graft — repo context graph

This repo is indexed in `graft/`: small linked markdown nodes that explain each
system and carry exact file:line spans, kept in sync with the code through git.

For ANY task here — understanding how something works, finding where code lives,
or scoping a change — get context from the graph before grepping or opening
source files. Re-ask freely (it's cheap) and reuse literal identifiers you
already have (symbol, error string, file name) as the query. New to this repo?
Run `graft map` first — a token-budgeted orientation (dir clusters, hubs,
hotspots), no LLM, no key.

- Run `graft ask "<your question>" --source` → ranked nodes with the relevant
  code spans inlined (each hit's ≤8-line crux by default; `--full` for whole
  definitions when the crux isn't enough). Match the tool to the task shape:
  for understanding or editing, the top node IS the answer — cite its
  `covers:` file:line spans and edit straight from `--source`. For
  exhaustive tasks ("every occurrence / every caller of this pattern"), ranked
  results are top-N, not complete — run `graft grep "<literal>"` instead
  (exhaustive over indexed files, grouped by enclosing symbol), falling back
  to raw `grep -rn` only for unindexed files.
- `graft skeleton <file>` → every definition's signature + span, ~10× cheaper
  than reading the file; use it to skim an API surface.
- `graft callers <symbol>` gives precomputed, exact edges — who calls this.
  Add `--direction out` for what it calls, or `--depth N` to walk
  transitively for the full blast radius. For structural questions, skip
  ranking and use this directly.
- Or browse: `graft/INDEX.md` lists every node; follow the links.
- Monorepos and folders of multiple repos rank fairly across sub-projects —
  hits carry `[scope/]` labels naming which one they're from. Narrow with
  `graft ask "<task>" --in <scope>/` once you know where you're working.

If a returned span is truncated ("+N more lines"), open the file at that exact
range before finalizing. Only open source files when a node genuinely lacks a
needed detail, and then at the exact file:line the node points to — never
re-read whole files.

After big code changes, refresh the graph with `graft build` (deterministic,
no API key, $0).
<!-- graft:end -->

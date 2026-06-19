# Session handoff — hsquared R lane (2026-06-19)

**START HERE if you are a new session.** This is the single entry point. It
consolidates the plan, the current state, the live widget, and what is left.
Then run the rehydrate steps below to confirm against live repo state (live state
always wins over this doc).

---

## One-paragraph state

`hsquared` **v0.1.0 is RELEASED** — pushed to `origin/main` (release commit
`b0153aa`), CI green at that commit (R-CMD-check dispatch + pkgdown deploy +
Pages all success), site live (`https://itchyshin.github.io/hsquared/`, HTTP
200). The working tree is clean and synced with origin. The R lane has delivered
its entire v0.1 mission: the default `hsquared()` call fits the univariate
Gaussian animal model `y ~ fixed + animal(1 | id, pedigree = ped)` by AI-REML
through the `HSquared.jl` engine, validated by known-truth DGP recovery + the
published gryphon anchor + sommer agreement + the published Mrode Example 3.1
anchor. **There is no remaining R-safe code work that does not need either the
maintainer or the twin.**

---

## The widget — live mission centre (this is the durable memory)

Launch and open in a browser (it is gitignored / disposable, runs on a port that
does not collide with the user's other boards):

```sh
python3 .mission-control/serve.py     # serves http://127.0.0.1:8781/
open http://127.0.0.1:8781/           # macOS; or paste the URL into a browser
```

The board reads a curated `status.json` (phase ledger, headline metrics,
team-on-deck, activity feed, twin-bridge, "next up") **plus** a live git sweep of
both repos. It is the user's live memory of what is done / not done / planned —
keep `status.json` current as work progresses. It is safe to delete the
`.mission-control/` directory at any time; nothing in the package depends on it.

---

## Rehydrate (do this first, every session)

```sh
git status --short --branch
git log --oneline -5
gh run list --limit 5                      # CI state
```

Then read the durable memory (skill: `hsquared-rehydrate`):

- `AGENTS.md` (imported by `CLAUDE.md`) — team roster, lane discipline,
  Definition of Done, standard commands. Single source of truth.
- `ROADMAP.md` — the 8-phase grand plan (see condensed status below).
- `docs/design/capability-status.md` — per-capability covered/partial/planned.
- `docs/design/01-v0.1-contract.md` — the (satisfied) v0.1 promotion predicate.
- `docs/design/validation-debt-register.md` — validation atoms + gaps.
- `docs/dev-log/coordination-board.md` — newest rows are this session's work.
- `docs/dev-log/check-log.md` — exact commands + outcomes (release evidence at
  the tail).
- `docs/dev-log/2026-06-18-overnight-progress-report.md` — the full prior arc.

Live-state-wins rule: trust repo state over any prose memory, including this doc.

---

## The grand plan (8 phases) — condensed status

| Phase | What | Status |
| --- | --- | --- |
| 0 | Operating system & public scaffold | ✅ complete |
| 1 | Simple Gaussian animal model (v0.1) | ✅ **released v0.1.0**; large/real-pedigree engine hardening is twin-side |
| 2 | Standard QG models | partial: repeatability + two-effect opt-in/experimental; sire/UPG/inbreeding/random-regression/2×2-G planned |
| 3 | Multivariate Gaussian | partial (opt-in `target="multivariate"`); needs twin t≥2 known-truth recovery + comparator parity to promote |
| 4 | Factor-analytic G | **planned — the immediate unblock**; gated on twin PR #17; R slice ready |
| 5 | Genomic & single-step | started (opt-in GREML/single-step/SNP-BLUP); Hinv construction/APY/low-rank/marker-scan tower planned |
| 6 | Non-Gaussian & GLLVM (LA + VA) | planned; reuse `gllvmTMB`/`GLLVM.jl` + `drmTMB`/`DRM.jl` |
| 7 | Non-standard inheritance | planned |
| 8 | Huge-scale & accelerator | planned; + standing perf + missing-data (`mi()`) directives |

Read `ROADMAP.md` for the full text; it is authoritative.

---

## What is left to do (prioritised)

### Immediate, R-lane, one step each
1. ~~**Cut the `v0.1.0` git tag + GitHub release**~~ — **DONE 2026-06-19**
   (maintainer-authorized). Annotated tag `v0.1.0` at HEAD `6d25c7d`, pushed;
   GitHub release "hsquared 0.1.0" published from NEWS.md, marked `Latest`
   (https://github.com/itchyshin/hsquared/releases/tag/v0.1.0). The R-lane
   maintainer queue is now empty; everything below is twin-gated or Julia-lane.

### Handoffs (NOT R-lane — do not do from here)
2. **`HSquared.jl/docs/design/03-engine-contract.md:275-277` reword** (Julia
   lane). The R lane is **read-only on the twin** (harness-enforced) and a Julia
   session was active mid-edit, so this was not applied. The doc is **not** in the
   Documenter build (zero build impact). Exact one-line fix:
   - replace: `…its AI matrix matches the observed information (ratio ~0.99 on a 250-animal simulation), so it is…`
   - with: `…its AI matrix matches an independent finite-difference Hessian of the REML log-likelihood (observed information) to within ~8% on the committed tiny fixture (`test/runtests.jl`), so it is…`
   - backed by the **committed** test `test/runtests.jl:1814-1824`
     (`@test isapprox(Matrix(info), Hobs; rtol = 0.12)`, commented "~8%").

### Capability frontier (twin-gated; R surfaces after the twin lands)
3. **Phase 4 — land `HSquared.jl` PR #17** (`phase4b-factor-analytic-g`, still
   DRAFT). The single highest-leverage unblock: surfaces `cov = diag()/lowrank()/
   fa()` + `genetic_loadings()` / `specific_variance()` / `latent_breeding_values()`
   / `eigen_G()` (all already reserved in R). **R must not self-merge.**
4. **Phase 3** — twin adds t≥2 known-truth recovery + comparator parity → promote
   multivariate from partial.
5. **Phase 5** — twin GWAS/QTL/eQTL marker-scan tower (PRs #18–#35, draft/no-CI,
   not landable until restructured: split the fixed-effect single-marker GWAS
   path off first); plus Hinv construction, APY, low-rank m≫n, weighted markers,
   REML SNP-BLUP variance.
6. **Phases 6–8** — non-Gaussian/GLLVM (LA + VA), non-standard inheritance,
   huge-scale/accelerator + the standing perf and missing-data directives.

---

## Conventions / discipline (do not relearn the hard way)

- **Lane discipline.** This is the **R lane** (`R/`, `tests/`, `man/`, README,
  vignettes, R CI). `HSquared.jl` is the **twin** — **read-only** unless Ada/
  Shannon reassign; coordinate via the board / GitHub issues, not by editing it.
- **Local checks over CI.** Run `air format .`, `devtools::document()`,
  `devtools::test()`, `pkgdown::check_pkgdown()`, `devtools::check()` locally;
  record exact commands + outcomes in `check-log.md`. CI = `pull_request` +
  `workflow_dispatch`; pushing `main` deploys pkgdown only (R-CMD-check does NOT
  run on push — dispatch it for a release-commit green tick).
- **Commits.** Plain imperative subject, **no `Co-Authored-By` trailer**. After
  pushing, a `Record … CI evidence` follow-up.
- **Rscript.** `/Library/Frameworks/R.framework/Resources/bin/Rscript`, with
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools`
  for pkgdown/vignette rendering. Install the package locally before
  `pkgdown::build_article(...)` (it renders against the installed package).
- **Multi-lens reviews.** Substantive slices: implement → multi-lens review
  barrier (adversarially verify each finding) → Rose honesty audit → fold in
  confirmed findings → re-verify → commit. Team roster + named lenses in
  `AGENTS.md`; spawnable subagents in `.claude/agents/`.
- **Honesty gate.** Only `covered` capabilities may be described as working;
  `validation_status()` is the live source of truth. Never fabricate validation
  numbers.

---

## This session's deltas (for continuity)

- Shipped the honest **Validation evidence** article (fact-checked, Rose-audited,
  Pat-clarified) and fixed one real cross-doc drift (DGP row `partial`→`covered`).
- Ran an article-set honesty sweep (3 highest-risk articles) — clean.
- **Released v0.1.0**: version bump; `loadings()`→`genetic_loadings()` (#6);
  `engine="validate"` now returns `invisible(spec)` + message (#20); published
  **Mrode 3.1 EBV anchor** (#5, CI-runnable, 3 citable sources + independent
  re-solve). Each ran through a 5-lens adversarial review.
- Tests: 793 pass / 0 fail / 27 skip; `check(--no-manual)` 0/0/0; pushed; CI green.
- Could not apply the twin engine-contract reword (harness-enforced R-lane
  read-only + active Julia session) — handed off above.

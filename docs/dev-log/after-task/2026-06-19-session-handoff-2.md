# Session handoff — hsquared R lane (2026-06-19, session 2) — START HERE

**This is the single START-HERE entry point for the next session.** It consolidates the plan,
the current state, the live overview, and the one open hand-off. Then run the rehydrate steps to
confirm against live repo state — **live state always wins over this doc** (issue numbers/SHAs
below were captured mid-session; re-verify with `gh` + `git`).

---

## One-paragraph state

`hsquared` **v0.1.0 is released** (tag + GitHub release; dev line `0.1.0.9000` open). Working tree
**clean**, synced with `origin/main` at **`593c6b2`**. Tests **860 pass / 0 fail / 27 skip**;
`devtools::check(--no-manual)` **0/0/0**; `pkgdown` deploys green on push; site live
(`https://itchyshin.github.io/hsquared/`). The R-lane backlog of honesty-clean, R-buildable,
verifiable-now work is **drained** — every remaining frontier item is twin-gated or low-value.
A **live cross-lane collaboration** is running with the Julia engine twin on GitHub issue
**HSquared.jl#61** (the prioritized joint critical path); the R side just shipped the `:diagonal`
multivariate slice to the twin's posted payload contract.

---

## The one open hand-off (this is the live thread)

**Channel: `HSquared.jl#61`.** The R `:diagonal` multivariate half is built + green (commit
`593c6b2`): the guardrail accepts `genetic_structure = "diagonal"` (lowrank/fa stay gated on the
rotation convention), `genetic_structure` is threaded into `fit_multivariate_reml`,
`n_genetic_params` is read-from-payload-or-derived, and `covariance_structure_lrt(constrained,
full)` computes the diagonal-vs-unstructured LRT R-side (`2·Δloglik`, `df = t(t−1)/2`,
`boundary = false`, χ²). The **R unpack + LRT are fixture-verified; the live diagonal *fit* is
skip-guarded.**

**Waiting on the twin** (separate thread/session): land the diagonal payload +
`test/fixtures/structured_covariance_parity/` fixture + the `03-engine-contract.md` spec, then
post the fixture path on #61. **On that landing, the R next action is:** (1) confirm the exact
payload keys against `hs_normalize_multivariate_result()`, (2) wire a parity test against the
fixture, (3) verify the diagonal `fit` + the LRT end-to-end (drop the skip-guard for that leg).
Also pre-staged on the R side, fires on the matching twin landing: unconditional PEV/reliability
via `:selinv` (twin #43 → closes hsquared#21), the `gwas(fit, markers)` wrapper (twin #45),
non-Gaussian family acceptance (twin #44 + a committed validation row).

---

## Rehydrate first (every session)

```sh
git status --short --branch
git log --oneline -8
gh run list --limit 5                       # CI state
gh issue list --repo itchyshin/hsquared --state open
gh issue list --repo itchyshin/HSquared.jl --state open   # incl. #61 + the twin's reply
git -C ../HSquared.jl fetch origin && git -C ../HSquared.jl log origin/main --oneline -5
```

Then read (skill: `hsquared-rehydrate`): `AGENTS.md`, `ROADMAP.md`,
`docs/dev-log/coordination-board.md` (newest rows), `docs/dev-log/issue-map.md` (the live backlog
index), `docs/dev-log/2026-06-19-twin-coordination-report-v2.md` (the joint critical path),
`docs/design/capability-status.md`, `docs/design/19-on-main-bridge-gap.md`, and the latest
`docs/dev-log/check-log.md` entry. **The twin is fast-moving** (`origin/main` advanced several
times mid-session; was `6d14df5`) — always re-fetch.

## The live overview (widget)

```sh
python3 .mission-control/serve.py     # http://127.0.0.1:8781/
```
Reads `.mission-control/status.json` (kept current; gitignored/disposable) + a live git sweep of
both repos. Keep `status.json` current as work progresses.

---

## The grand plan (8 phases — ROADMAP.md is authoritative)

| Phase | What | Status |
| --- | --- | --- |
| 0 | Operating system / scaffold | ✅ complete |
| 1 | Gaussian animal model (v0.1) | ✅ **released v0.1.0**; now also experimental h² CI + SEs + `plot()` + `summary()` uncertainty |
| 2 | Standard QG | partial (repeatability/two-effect opt-in + experimental repeatability CI); sire/UPG/inbreeding/random-regression planned; published Mrode 3.1 + 3.2 sire anchors shipped |
| 3 | Multivariate Gaussian | partial (opt-in); **`:diagonal` structure + covariance SEs + structure LRT shipped (experimental)**; promotion needs the twin t≥2 recovery run (harness ready: `data-raw/multivariate-recovery-study.R`) + comparator parity |
| 4 | Factor-analytic G | **twin-gated** — V4-FA on main but calibration failed (8/10, 9/10) + loadings rotation undefined; lowrank/fa parked until the twin fixes calibration (em_fa.jl, HSquared.jl#37) + declares a rotation convention (#42) |
| 5 | Genomic & single-step | partial (opt-in); marker-scan tower twin-gated (post-fit scan payload HSquared.jl#45 + calibrated thresholds #48) |
| 6 | Non-Gaussian & GLLVM (LA+VA) | **twin-gated** — engine fns on main but no committed validation row to cite; needs a V6-LAPLACE row + MarginalMethod refactor (HSquared.jl#44) |
| 7 | Non-standard inheritance | planned |
| 8 | Huge-scale + perf + missing-data `mi()` | planned (design note `docs/design/08`; perf ideas HSquared.jl#58) |

---

## What's left / next R-buildable

The R-ownable verifiable-now backlog is essentially drained. Remaining R work is **reactive to
twin landings** (the #61 hand-off above). Standing R-buildable-with-care items if you want to push
without the twin:
- **hsquared#13** REML SNP-BLUP — **deferred** (honesty: would overclaim vs the stale twin
  V2-SNPBLUP row + a test regression; needs the twin row update first).
- **hsquared#21** PEV/reliability `:selinv` — pre-staged; fires when the twin promotes those into
  the standard payload (HSquared.jl#43).
- Innovation design notes exist (FA-G EM #17, LA/VA #18, mi() #19); the capabilities are
  twin-gated. Engine perf ideas filed (#24/#25 → HSquared.jl#58).
- The **recurring weekly scout** (`hsquared-innovation-scout`, Mondays 9am) keeps filing
  innovation issues; maintainer can "Run now" once to pre-approve its tools.

**Twin-side actions queued on #61 (R fires on each landing):** #47 row-refresh (the ~10-min top
action — the SE/LRT functions are exported+tested but the V4-MV-REML/V4-FA rows still say
"missing"); run the multivariate recovery harness; #43 PEV payload; #44 non-Gaussian V6 row;
#46/#49 fitted-Mrode + comparator fixtures; #45 post-fit scan payload; #37/#42 FA calibration +
rotation convention; #38 the 1-line "250-animal" doc reword.

---

## Conventions / discipline (do not relearn the hard way)

- **Lane discipline.** R lane edits only `R/`, `tests/`, `man/`, README, vignettes, R CI,
  `docs/` (R-side). `HSquared.jl` is **read-only** — coordinate via GitHub issues (the #61
  channel), never twin code edits.
- **Honesty gate.** Only `covered` capabilities are "working"; `validation_status()` is truth;
  never fabricate numbers. Only `V1-AI-REML` (+ `V1-AINV-MRODE9`/`V1-MRODE-FIT`/`V1-COMPARATORS`
  external) and the scaffold rows are covered; everything new is **experimental/partial**.
- **Per-slice loop.** implement → multi-lens/adversarial review (spawn lenses; adversarially
  verify findings) → Rose honesty audit → `air format .` · `devtools::document()` ·
  `devtools::test()` · `pkgdown::check_pkgdown()` · `devtools::check(--no-manual)` → after-task
  report → commit → push → record CI evidence.
- **Engine-coupled slices:** build to the twin's posted contract; the live-engine leg is
  skip-guarded (engine inactive in ordinary checks); the R-side logic is fixture-verified. This is
  the established pattern (#11/#26/#47-diagonal all done this way).
- **Commits.** Plain imperative subject, **no `Co-Authored-By` trailer**. CI = `pull_request` +
  `workflow_dispatch`; pushing `main` deploys pkgdown only (R-CMD-check does NOT run on push —
  dispatch it for a release-commit green tick).
- **Rscript:** `/Library/Frameworks/R.framework/Resources/bin/Rscript`; set
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools` for
  pkgdown/article rendering; `install` the package before `pkgdown::build_article(...)`.
- **Ultracode/workflows** are opt-in (the maintainer says "ultracode" / "use a workflow");
  otherwise default to parallel Agent subagents. Heavy fan-out was used this session for the
  WS2 spec/review wave and the twin-coordination briefs.

---

## This session's deltas (for continuity)

- v0.1.0 **tag + GitHub release** cut.
- **Program 1 (post-v0.1.0):** issue backbone on both repos (labels, epics, children, twin-advice
  issues), `issue-map.md`, WS2 on-main gap audit (`docs/design/19`), WS2 bridge slices
  (heritability CI #11, SEs, repeatability CI #12; `single_step` verified #14), WS3 innovation
  notes (`docs/design/20/21/22`) + literature scout + the standing weekly scout.
- **Ultracode WS2 wave:** specced+reviewed all 6 remaining bridge slices; shipped the safe ones,
  deferred #13, confirmed #22/#23/#18 blocked.
- **Program 2 ("next big 4"):** validation depth (#31 sommer/pedigreemm benchmark, #33
  comparator-policy doc, #32 Mrode 3.2 sire anchor) + UX/figures (#28 summary uncertainty, #30
  `plot.hsquared_fit`, #29 gryphon vignette) — **complete**; multivariate R-side (#26 covariance
  SEs, #34 recovery harness) — **complete**.
- **Cross-lane:** filed the prioritized joint critical path (`twin-coordination-report-v2.md`,
  HSquared.jl#61); the twin replied + cleared `:diagonal`; R shipped the **diagonal multivariate
  covariance + `covariance_structure_lrt`** to their contract.
- A **package-wide Rose honesty audit** confirmed zero overclaim and fixed 4 cross-doc
  under-claims (README + 3 articles + capability-status now say "no *validated* SE/CI; experimental
  surfaces exist").
- Tests 793 → 860; every slice green; all pushed; site live.

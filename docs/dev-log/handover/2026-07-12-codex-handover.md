# Session Handoff → Codex — 2026-07-12 (hsquared R lane)

**Meta:** 2026-07-12 · from **Claude** (Opus 4.8, R lane) · handing the **live
Julia/TMB toolchain** work to a fresh **Codex** session. This doc stands alone —
you (Codex) will not see the authoring chat. `AGENTS.md` is your native entry
point; read it first, then this doc.

**You are Codex, picking up the hsquared program after a clean merge day.** Your
job is the work that needs a live engine — real Julia fits, simulation campaigns,
`R CMD check` with compilation, rendering — which the Claude session could not
run. Nothing here is mid-flight or broken; `main` is clean and everything from
the session is landed. This is a *forward* handoff, not a rescue.

---

## Critical Context (read or you will go wrong)

1. **`main` is clean and fully landed.** hsquared `main` @ `280affc`, in sync with
   `origin`, **zero open PRs**. Today four PRs were assembled onto `main`
   (#131 planning docs 35–43 + decisions · #132 MV-4 auto-route + MV-1/2/3
   evidence + MV-5 driver · #133 doc-site quick wins · #124 CLAUDE.md tidy).
   **No covered flip in any of them**; `public_covered_count` unchanged;
   multivariate stays **partial/experimental**.
2. **Claude and Codex run SEQUENTIALLY, never concurrently** (Shinichi, 2026-07-11).
   You own the toolchain now; the Claude session is done. Do not assume a parallel
   Claude is doing anything. Land your work, then hand back.
3. **Twin-lane discipline.** The Julia engine is the sibling repo `../HSquared.jl`
   (present locally). Cross-reference it freely, but the **MV-5 simulation is
   engine-*use*, not engine-*edit*** — the doc-40 pre-declaration forbids editing
   `HSquared.jl/src` for MV-5 (fit only). Only touch the twin's `sim/` drivers.
4. **MV-5 is GATED ON MAINTAINER COMPUTE-GO.** `docs/design/40-mv-broadened-recovery-predeclaration.md`
   is committed (on `main`), but it says in bold: *"Nothing runs until the
   maintainer approves the Totoro compute."* You may **prepare** the threaded
   Julia sim now; you may **not** launch a Totoro/DRAC campaign until Shinichi
   gives the compute-go. This is a pre-registration — do **not** move the PASS
   numbers after seeing results.
5. **The 0.6 covered flip is a SEPARATE, multi-signature gate** — not something a
   sim result alone triggers. See "Not your call" below.

---

## What Was Accomplished (this session, all on `main`)

- Merged + verified the four PRs above onto `main` via ordered `--no-ff` merges;
  assembled tree checks: `devtools::document()` **zero-delta**, `devtools::test()`
  **FAIL 0 / WARN 0 / SKIP 66 / PASS 1740** (66 skips = live JuliaCall/Julia/
  `pedigreemm` absent on the Claude box — **these are exactly the tests you can
  now un-skip**). pkgdown deploy green.
- Closed PR #126 (superseded 2026-07-09 handover); deleted 5 stale remote branches.
- Filed a brain note (`projects/hsquared — 2026-07-12 PR assembly …`) recording the
  merge + the finding that the repo `CLAUDE.md` hub `@import` and the global one
  are the **same inode** (why #124 was safe).
- Full evidence: `docs/dev-log/check-log.md` (two 2026-07-12 entries) and
  `docs/dev-log/after-task/2026-07-12-docsite-quickwins.md`.

## Current Working State

- **Working:** entire R package; 1740 pure-R/logic tests green. `main` clean.
- **In progress:** nothing uncommitted. All session work landed.
- **Blocked / gated:** MV-5 campaign (maintainer compute-go); 0.6 flip (multi-sig
  gate); 0.5 release (maintainer decisions).

## Key Decisions & Rationale (must still hold)

- **First registration = 0.5.0, not 1.0**; releases decoupled from phases; 1.0 = a
  maturity milestone. (docs 35–36, 41; `docs/dev-log/decisions.md`.)
- **No covered flip without the Standard-Tier gate** (component estimands
  external-comparator-gated; derived estimands identity+citation-gated; Darwin
  sign-off; Boole grammar freeze). See `AGENTS.md` "Definition Of Done".
- **MV-5 pre-registration is frozen at its SHA** — no post-hoc relaxation
  (doc-40 + doc-34 no-post-hoc rule).
- **Sim parallelism = threaded Julia, NOT R `mclapply`** — the JuliaCall fork
  segfaults. Run `julia -t 96 -e … Threads.@threads`, `OPENBLAS_NUM_THREADS=1`.

## Landing State (git ledger)

| Artifact / branch | Committed | Pushed | PR | State |
|---|---|---|---|---|
| `hsquared` `main` `280affc` (all session work) | y | y | #131/#132/#133/#124 merged | **LANDED** |
| `hsquared` `handover/2026-07-12-codex` (this doc) | y | y | PR (see chat) | **LANDED** (docs-only; human merges) |
| `scratchpad/fa_discriminating_test.jl` (FA test) | **n** | **n** | none | **LOST — never committed** (see Gotchas) |

Manual landing check stands in for the gate script (which mis-resolves this repo's
path and false-negatives "not a git repo"): `git status` → `## main...origin/main`,
clean, zero open PRs. Everything real is on `origin`.

## Next Immediate Steps (ordered — LIVE TOOLCHAIN is yours)

1. **Un-skip the live tests first (fast confidence).** With Julia + `HSquared.jl`
   on PATH, run `devtools::test()` and confirm the 66 currently-skipped live
   JuliaCall/engine tests **pass**, not just skip. This validates your live env
   before any campaign. Record in `docs/dev-log/check-log.md`.
2. **Prepare the MV-5 threaded-Julia sim (do NOT launch the campaign yet).** Port
   the R DGP oracle `data-raw/multivariate-recovery-broadened-study.R` (on `main`)
   into a **threaded** Julia driver in the twin `../HSquared.jl/sim/` — extend
   `phase4_v5_mv_recovery_reseed.jl` / `phase4_multivariate_reml_recovery.jl`.
   Design is fixed in **doc-40**: t=3, **two** PD (G0,R0) truth points (low + high
   r_g), full-sib pedigree, cold-start, n≤~1000; estimands = 6 G0 + 6 R0 elements
   (component gate: every interior element `|bias| ≤ 2·MCSE` in **both** points),
   r_g + per-trait h² as identity-checked derived targets. The R driver is the
   **serial DGP oracle** the threaded Julia sim must match.
3. **`simulation-check` the two truth points** (ADEMP review) **before** any confirm
   tier — owed per the final handover.
4. **On maintainer compute-go only:** run the campaign on **Totoro**
   (`snakagaw@totoro.biology.ualberta.ca`, ≤100 cores, no queue) or DRAC; verify a
   REAL Julia exit (SLURM COMPLETED ≠ success); `seff` after one run; keep results
   LOCAL (never GitHub artifacts — D-50). Results feed the 0.6 flip *scope*, they
   do not flip anything by themselves.
5. **FA discriminating test** (doc-42): the turnkey script was lost with
   `scratchpad/` — **re-derive from `docs/design/42-fa-calibration-diagnosis.md`**
   (classifies Heywood vs optimizer vs sampling). Don't warm-start a Totoro FA run
   until it runs.

## Blockers / Open Questions

- **Compute-go for MV-5** — needs Shinichi's explicit Totoro/DRAC approval.
- **0.5 release decisions** (maintainer): twin `HSquared.jl#267/#268` parity,
  stale `v0.1.0` tag, `SystemRequirements` wording, `cran-comments.md`,
  Julia-registers-first sequencing. When greenlit, the 3-leg `--as-cran` on
  ubuntu/macOS/windows is **your** live job (load the `cran-release-gate` skill,
  default NOT READY).

## Not your call (planning-side / maintainer — leave for Claude or Shinichi)

- **0.6 covered flip:** even with MV-5 PASS, the flip needs MV-1✓ (in-suite
  full-unstructured sommer) + MV-2✓ (BLUPF90 cite) + MV-3✓ (derived identity) +
  Boole grammar freeze (doc-38, ratified) + **Darwin biology sign-off** + **Rose
  audit** + **maintainer G10**. MV-1/2/3 are already banked; do not self-authorise.
- **NG-1 §8 wording punch-list → Boole extractor-grammar freeze** (doc-37) —
  prose/grammar, Claude-side.
- **Doc-site positioning slice** (audit H1/H2/H3/H5) — prose/structure, Claude-side.

## Twin (`HSquared.jl`) Documenter items — separate Julia lane, also yours if tasked

From the 2026-07-11 doc-site audit (`docs/dev-log/2026-07-11-docsite-audit.md`),
owed on the **twin** repo (not editable from hsquared): **H4** auto-generate the
`validation-status.md` table from `VALIDATION_STATUS_DATA` (the one true honesty
defect — the static table drifts from the 55-row ledger); **M8** add 10 exported
symbols to `api.md`; **M9** scope `warnonly`; **M10/L10–L12** phase-board / GPU /
Start-Here reconciliations. These are Documenter/codegen tasks a live Codex session
can do on `../HSquared.jl`.

## Gotchas & Failed Approaches (do not retry)

- **R `mclapply` for the MV sim segfaults** (JuliaCall fork). Use threaded Julia.
- **`scratchpad/` is untracked and local-only** — never committed, never on
  `origin`. The FA discriminating test that once lived there is gone; re-derive
  from doc-42. Do **not** `git add scratchpad/`.
- **The `handoff_gate.sh` script false-negatives on this repo** ("not a git repo")
  — it resolves repos under a fixed parent. Trust `git status` directly.
- **GitHub Actions is package-checks + docs only** — never run sim/coverage/power
  campaigns on Actions, never store campaign output as Actions artifacts (D-50,
  hard 2 GB/mo cap). Campaigns → Totoro/DRAC; results stay local.
- **SLURM COMPLETED ≠ success** — always verify the real Julia process exit code.

## How to Resume (paste into a fresh Codex session at the repo root)

```
Rehydrate from docs/dev-log/handover/2026-07-12-codex-handover.md + AGENTS.md,
then continue with the Next Immediate Steps (start with step 1: un-skip the live
tests). Do NOT launch the MV-5 Totoro campaign until Shinichi gives compute-go.
```

**Live-env exports Codex needs (adjust paths to your box):**

```sh
export PATH="$HOME/.juliaup/bin:$PATH"          # or wherever julia lives
export HSQUARED_JULIA_PROJECT="$(cd ../HSquared.jl && pwd)"
export NOT_CRAN=true                            # let skip-guarded live tests run
export OPENBLAS_NUM_THREADS=1                    # pin BLAS before threaded sims
```

Read order: `AGENTS.md` → this doc → `docs/dev-log/check-log.md` (top two 2026-07-12
entries) → `docs/design/40-mv-broadened-recovery-predeclaration.md` (MV-5 ADEMP) →
`docs/design/36-phase3-6-execution-plan.md` (where MV-5 sits) →
`docs/dev-log/2026-07-11-docsite-audit.md` (twin Documenter items).
Team mirror: `.codex/agents/*.toml` (**Rose audit mandatory** before any public claim).

---

## Mission-control summary

| Repo | Branch / CI | What shipped (this session) | Plan by leverage (yours = live toolchain) |
|---|---|---|---|
| **hsquared** (R lane) | `main` @ `280affc`, in sync, **0 open PRs**; pkgdown green | #131/#132/#133/#124 merged — planning docs, MV-4 auto-route + MV-1/2/3 evidence + MV-5 driver, doc-site quick wins, CLAUDE.md tidy. No covered flip. `test()` 0-fail (1740 pass, 66 live-skips). | **1)** un-skip the 66 live tests · **2)** prepare threaded-Julia MV-5 sim (doc-40) · **3)** `simulation-check` the truth points · **4)** *on compute-go* run Totoro/DRAC · **5)** re-derive FA test (doc-42) |
| **HSquared.jl** (twin, Julia lane) | `../HSquared.jl` local; separate thread | engine `V4-MV-REML` covered at validation scale; not edited this session | If tasked: Documenter **H4** (validation-status codegen — real honesty defect), M8/M9/M10 |
| **Gated / not-yours** | — | — | 0.6 covered flip (multi-sig + G10); 0.5 release decisions; NG-1 §8 + doc-site positioning (Claude-side) |

**Authoritative copy of this handoff:** this committed doc. The chat note is a
convenience mirror.

# Session Handoff → Cursor — 2026-09-26 (hsquared program)

**Meta:** 2026-09-26 · from **Cursor** (this session) · to a fresh **Cursor** agent.
Context is ephemeral; this file on `origin` is authoritative.

**You are Cursor, picking up the twin-repo H2 campaign.** Read `AGENTS.md` first, then this doc,
then reconcile every item below against live `git` / `origin/main` before acting. Classify handoff
lines **`OWED` · `DONE` · `RETRACTED` · `PROTECTED`**; execute only **`OWED`**.

**Lane declaration (authoring session):** `PLATFORM: cursor` · `ON BRANCH: handover/2026-09-26-cursor`
(clean worktree at `~/local-scratch/lanes/handover-hsquared-20260926-cursor`) · `LANE: handover-coordinator`
· **OTHER LANES:** Codex (`#254` CRAN incoming, `#202` release candidate, cran-submit-090 stack);
Julia Codex `#322`/`#321`; two Cursor lanes on `HSquared.jl` (`cursor/366-n2000-*-20260926`).
Do **not** bleed into those lanes without Shinichi's call (D-87/D-88).

---

## Critical Context

1. **Post-#366 arc T1–T7 is DONE** on `origin/main` (honesty fences, loglik mirror, CRAN hygiene without
   upload, docs IA, twin authors). Fences: **experimental 0.9.0**, **`public_covered_count` 7**, **no covered
   flip**, **no 0.10 / no 1.0 without owner**.
2. **CRAN 0.9.0 is NOT submitted (`SUBMITTED=no`).** Frozen tarball SHA **`9bbd71871c4e20719d2dc9fc9fda375c56a3a1f6e0619350a08d45b722e3e5b3`** built from commit **`3ba07001dde23477086aa3380fab7518036f5d28`** remains the submit artifact until `DESCRIPTION` / shipped code changes force a rebuild. **`origin/main` @ `2e6b0af`** adds post-tarball doc/copy fixes (#251–#253, #248 cran-comments on `main`); see Codex scratch handoff for whether rebuild is required before upload.
3. **Codex owns live CRAN submit + Gmail** (win-builder mail, R-hub token, CRAN web upload). **Cursor has no Gmail** — do not attempt maintainer email or CRAN upload from Cursor.
4. **Julia General: NOT READY, `REGISTERED=no`** — do **not** `@JuliaRegistrator`. Advisory:
   `~/local-scratch/HSquared.jl-registry-readiness.md`.
5. **Dropbox working copies are stale/dirty** — do not trust them for `main`. Use **`origin/main`** or a
   fresh worktree. The authoring Dropbox tree was on `codex/2026-07-13-v07-performance-localization`
   (294 commits behind `origin/main`).

---

## What Was Accomplished (campaign truth on `origin/main`)

| Theme | Evidence |
| --- | --- |
| Post-#366 T1–T7 | Landed per `~/local-scratch/hsquared-post366-overnight-handoff.md` (#240–#245, JL #389–#390) |
| Docs IA / examples | **#246** @ `a343bb6`, Julia **#391–#392** — DONE (`~/local-scratch/hsquared-docs-examples-handoff.md`) |
| Twin authors ORCID | **#247** merged (tarball-source **`3ba0700`**), Julia **#393** |
| cran-comments | **#248** merged @ **`c35bbeb`** |
| CRAN incoming hygiene (no submit) | **#251–#253** on `main` @ **`2e6b0af`** (scope copy, native SHA-256, certutil) |
| Open Codex CRAN lane | **#254** `codex/cran-incoming-resubmit-090` (incoming NOTE repair) |

---


## Current Working State

- **Working:** R package on `origin/main`; docs/deploy IA live; 0.9.0 in `DESCRIPTION`; `v0.9.0` tag exists on remote history (submit tag policy: see Codex handoff).
- **In progress:** CRAN **submission-ready** rungs (consent, win-builder email, R-hub, Rose/Grace green, tag, Codex upload) — **Codex + owner**, not Cursor.
- **Not working / blocked:** Mission Control **`http://127.0.0.1:8823/status/H2.json`** returned **not found** at handover time (service down or path moved). Do not invent H2.json fields; refresh Mission Control when the daemon is up.
- **Protected:** Foreign Codex CRAN branches/PRs; Julia registry; covered-count/version fences.

---

## Key Decisions & Rationale

- **D-43 / Rose+Grace:** two NOT-READY votes → **no CRAN upload** until consent + platform rungs close (see Codex scratch handoff).
- **Tarball vs `main` tip:** `#248` and later merges may touch **`cran-comments.md` only** (not in tarball per `.gitignore`); frozen **`9bbd7187…`** tarball may still be valid — **reconcile with Codex handoff before any upload** (`~/local-scratch/hsquared-cran-codex-submit-handoff.md`).
- **Multi-lane snapshot:** Do **not** prepend a single-lane `AGENTS.md` snapshot on **`HSquared.jl`** from this doc (Codex/Julia/Cursor lanes run concurrently). **START HERE** for Cursor resume: **this file** + `docs/dev-log/coordination-board.md` + lane-specific scratch handoffs below.

---

## Landing State (git ledger)

FINDINGS-OF-RECORD: none

Gate: `bash ~/shinichi-brain/tools/handoff_gate.sh "<repo>"` (2026-09-26; Dropbox trees **fail** until declared).

| Artifact / branch | Committed | Pushed | PR | State |
| --- | --- | --- | --- | --- |
| `hsquared` `origin/main` @ `2e6b0af` (campaign merges through #253) | y | y | #246–#248, #251–#253 merged | **LANDED** |
| `hsquared` `docs/dev-log/handover/2026-09-26-cursor-handover.md` on `handover/2026-09-26-cursor` | pending | pending | open after push | **this commit** |
| `hsquared` Dropbox checkout `codex/2026-07-13-v07-performance-localization` | partial | n/a | n/a | **CARRIED-OVER** — stale v07 arc; **294 behind `origin/main`**. Resume: `git fetch origin && git worktree add … origin/main` or clone fresh; **do not** commit handover from Dropbox root without reset. |
| Dropbox untracked `graft/`, `.ignore`, `docs/dev-log/inbox/`, `.claude/agents/shannon.md` | n | n | none | **CARRIED-OVER** — local index/cache; **never `git add -A`**. Resume: ignore or `.gitignore` per owner; not on `origin`. |
| `HSquared.jl` `origin/main` (docs #391–#392, #393 authors, post-366 merges) | y | y | see twin PRs | **LANDED** (read `origin`; do not edit Julia from R lane unless reassigned) |
| `HSquared.jl` Dropbox `claude/h2-three-scale-naming-20260908` (+14/−3 vs origin) | y | partial | docs-only WIP | **CARRIED-OVER** — naming docs; resume on clean branch if OWED. |
| Codex CRAN submit lane | y | y | **#254** open | **CARRIED-OVER** to **Codex** — live toolchain + Gmail. Resume: Codex + `~/local-scratch/hsquared-cran-codex-submit-handoff.md`. |
| Frozen CRAN tarball `hsquared_0.9.0.tar.gz` SHA `9bbd7187…` | n/a | n/a | n/a | **PROTECTED artifact** @ `~/local-scratch/lanes/hsquared-cran-rebuild-20260925/` |

---

## Next Immediate Steps (Cursor — narrow)

1. **Rehydrate:** `~/shinichi-brain/tools/lane_preflight.sh "/path/to/hsquared"` · `git fetch origin` ·
   `git status` on **`origin/main`** (or this handover branch after merge).
2. **Classify** every row in **Landing State** and every bullet in Codex/Julia scratch handoffs.
3. **Default Cursor scope after rehydrate:** coordination/docs/PR assembly **not** owned by Codex CRAN submit
   (consent, R-hub, upload). Examples: Mission Control H2 refresh when daemon up; `#254` review-only if
   asked; deferred docs from docs-examples handoff (visualizing-models twin link, etc.).
4. **Do not:** Registrator; CRAN upload; covered flip; bump past **0.9.0** without owner; edit foreign Codex
   CRAN files without lease + owner.

**Codex / owner OWED (not Cursor):** Gate 1 Yefeng+Szymon `aut` consent; win-builder R-devel email for
tarball `9bbd7187…`; R-hub token + platforms; annotated **`v0.9.0`** tag policy; Rose/Grace green; upload.

---

## Blockers / Open Questions

- **Mission Control H2** offline at handover — refresh when `127.0.0.1:8823` serves `status/H2.json` again.
- **R-hub:** token blocked for `itchyshin@gmail.com` (Codex handoff).
- **Julia General:** owner gate + tag drift — see registry readiness scratch doc.
- **Foreign lanes active** — Shannon preflight **FOREIGN LANE ACTIVE (codex)** on both twins.

---

## Gotchas & Failed Approaches

- **`tools/handoff_gate.sh` missing inside repo** — use **`~/shinichi-brain/tools/handoff_gate.sh`**.
- **Handoff from Dropbox `main` checkout** without worktree → false sense of repo state (v07 branch).
- **Cursor Gmail:** no maintainer email; route submit to Codex.
- **Superseded tarball** SHA `29b31388…` (authors-orcid path) — do not use.

---

## Other lanes — carry-forward menu (do not drop)

| Lane | Pointer |
| --- | --- |
| Codex CRAN 0.9.0 submit | `~/local-scratch/hsquared-cran-codex-submit-handoff.md` |
| Docs IA (complete) | `~/local-scratch/hsquared-docs-examples-handoff.md` |
| Post-#366 T1–T7 (complete) | `~/local-scratch/hsquared-post366-overnight-handoff.md` |
| Julia registry advisory | `~/local-scratch/HSquared.jl-registry-readiness.md` |
| v0.7 performance/recovery (historical) | `docs/dev-log/coordination-board.md` rows; branch `codex/2026-07-13-v07-performance-localization` |

---

## Mission Control summary (in-doc table)

| Repo | Branch / tip | CI / shipped | Plan by leverage |
| --- | --- | --- | --- |
| `hsquared` | `origin/main` `2e6b0af` | T1–T7 + docs IA + authors + cran-comments + incoming NOTE fixes merged; **CRAN not submitted** | Codex: close submit rungs; Cursor: docs/coordination only unless owner expands |
| `HSquared.jl` | `origin/main` (verify `gh`) | Docs IA #391–#392; authors #393; **REGISTERED=no** | Owner-gated registry; no Registrator |
| Campaign | fences | `public_covered_count` **7**, **0.9.0** experimental | No covered flip; no 0.10 without owner |

---

## How to Resume (Cursor)

**Working directory:** clone or worktree at **`origin/main`** (recommended:
`~/local-scratch/lanes/handover-hsquared-20260926-cursor` until this PR merges).

**Environment:** R + `devtools`; Julia optional for skipped live tests; **do not** set `NOT_CRAN=true` for
CRAN-lane checks. Safe verification: `git fetch origin && git log -1 origin/main --oneline` ·
`pkgdown::check_pkgdown()` if editing docs.

**Never stage:** `graft/.cache/`, foreign lane WIP, `docs/dev-log/inbox/` unless explicitly OWED.

**Rehydrate file set:** `AGENTS.md` · this doc · `docs/dev-log/coordination-board.md` · tail of
`docs/dev-log/check-log.md` · Codex scratch handoff if touching CRAN narrative.

**Paste-ready prompt (human starts fresh Cursor agent in repo):**

```text
Read AGENTS.md and docs/dev-log/handover/2026-09-26-cursor-handover.md. Run the handover rehydration steps, reconcile them with the current git state, then continue only the OWED Next Immediate Steps.
```

---

## Authoring session notes

- `handoff_gate.sh` run on Dropbox paths: **FAIL** (uncommitted + unpushed branches) — declared above as **CARRIED-OVER**.
- **No `AGENTS.md` Live Phase Snapshot** in `hsquared` — snapshot pointer refresh **skipped**; multi-lane truth lives in this handover + coordination board + scratch paths.
- Handover committed from clean worktree **`handover/2026-09-26-cursor`**, not Dropbox default checkout.

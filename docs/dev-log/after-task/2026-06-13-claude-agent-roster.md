# Claude Agent Roster and Readiness Layer

Date: 2026-06-13

Active lenses: Ada, Shannon, Grace, Rose.

Spawned subagents: none (mechanical conversion done solo).

Current lane: R (coordinator/tooling).

## Goal

Stand up the Claude-side operating layer for the R lane so a Claude operator
behaves like the Codex operator, with a single shared source of truth and no
fork. This is the R-lane twin of the Julia lane's agent roster (a separate repo,
so no lane collision). Tooling/readiness only — no package code, public claims,
or bridge contract changed.

## Files Changed

- `.claude/agents/*.md` (21 new) — review-lens subagents.
- `.claude/skills/*` (11 new symlinks) -> `../../.agents/skills/*`.
- `CLAUDE.md` (new) — imports `@AGENTS.md` + Claude-specific notes.
- `.Rbuildignore` — added `^\.claude$` and `^CLAUDE\.md$`.

## Implementation

- Converted each `.codex/agents/<stem>.toml` to `.claude/agents/<stem>.md`:
  frontmatter `name` = kebab file stem, `description` preserved,
  `model_reasoning_effort = "high"` -> `model: opus` (11 opus / 10 inherit),
  otherwise inherit; body = `developer_instructions`. Conversion is mechanical
  and schema-preserving (one Read+Write per file via a tomllib script).
- `CLAUDE.md` is a thin pointer: `@AGENTS.md` import (single source of truth)
  plus Claude notes — lane boundary (do not edit `HSquared.jl`), rehydrate loop,
  lenses in `.claude/agents`, skills in `.claude/skills`, local-checks-over-CI,
  and the plain-subject + `Record … CI evidence` commit convention.
- 11 skills shared by relative symlink (matches the global `~/.claude ->
  ~/.agents` pattern; one canonical source for Codex and Claude).
- `.Rbuildignore` updated so the new top-level files mirror how `.codex` /
  `.agents` / `AGENTS.md` are already excluded from the package build.

## Public Claim Audit

Allowed wording:

- Claude can now operate the R lane with the same roster, skills, and guardrails
  as Codex, from a single shared instruction set.

Blocked wording:

- No new package capability, model fitting, or validation claim is introduced by
  this slice.

## Checks

- `Rscript -e "rcmdcheck::rcmdcheck(args=c('--no-manual','--no-build-vignettes'))"`:
  `0 errors | 0 warnings | 0 notes` (confirms the new top-level files are ignored
  by the build).
- `.claude/agents` = 21 files; `.claude/skills` = 11 symlinks that all resolve to
  a `SKILL.md`.
- Remote (commit `b43b682`): R-CMD-check `27467772941`, pkgdown `27467772929`,
  Pages `27467811302` all passed.

## Tests Of The Tests

- The conversion is verified field-by-field (frontmatter name/description/model
  mapping) and by count (21 agents, 11 skills); a single completeness pass, not a
  review panel, because there is no per-file design judgment.

## Known Limitations

- `lovelace` remains a perspective-only lens (no `.codex/agents` file), so it has
  no `.claude/agents` file either.
- Committed symlinks are macOS/Linux-friendly; switch to copies if Windows
  portability later matters.

## Next Actions

1. B1: record the Phase B frontier on the coordination board / registers.
2. B2: scout sister repos (gllvmTMB, drmTMB, GLLVM.jl, DRM.jl) for reusable
   R-Julia bridge code, then surface the twin's `fit_sparse_reml` through a
   fenced opt-in path — gated on the twin's green `validation_status()`.

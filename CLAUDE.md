# CLAUDE.md

Agent instructions for this project are shared with Codex. Read them
here:

@AGENTS.md

## Claude-specific notes

- **Lane.** This is the **R lane** (`hsquared`). The Julia engine
  `HSquared.jl` is the **twin lane** (a separate thread, in a local
  sibling checkout). Cross-reference it freely — read its exports,
  [`validation_status()`](https://itchyshin.github.io/hsquared/reference/validation_status.md),
  tests, and coordination board — but do **not** edit it from here
  unless Ada/Shannon reassign the lane. Coordinate through repo memory
  (coordination board, check-log, GitHub issues), not chat.
- **Rehydrate first** (recovery rule). Run
  `git status --short --branch`, `git diff --stat`, `git diff`, then
  read `docs/dev-log/coordination-board.md`, the latest
  `docs/dev-log/check-log.md` entry, the newest
  `docs/dev-log/after-task/*.md`, and `docs/design/01-v0.1-contract.md`.
  Live repo state wins over chat memory. (Skill: `hsquared-rehydrate`.)
- **Review lenses** live in `.claude/agents/` — 21 spawnable subagents
  (Lovelace is a perspective-only lens with no file). Spawn one with the
  Agent/Task tool when `AGENTS.md` routing calls for a named lens; state
  explicitly when a subagent is actually running vs. used as a review
  perspective. Substantive slices use the multi-lens review pattern
  (Implement → Review barrier → Rose audit).
- **Skills** live in `.claude/skills/` (symlinks into
  `.agents/skills/`). Invoke via the Skill tool. Operational loop:
  `hsquared-rehydrate`, `hsquared-team-dispatch`, `after-task-audit`,
  `rose-pre-public-audit`.
- **Local checks over CI** (global policy). Run `air format .`,
  `devtools::document()`, `devtools::test()`,
  [`pkgdown::check_pkgdown()`](https://pkgdown.r-lib.org/reference/check_pkgdown.html),
  and `devtools::check()` locally before pushing; record exact commands
  and outcomes in `docs/dev-log/check-log.md`. Commit to `main`, then a
  `Record … CI evidence` follow-up (repo convention: plain imperative
  subjects, no `Co-Authored-By` trailer).
- **Definition of Done**, lane discipline, standard commands, and the
  full team roster are in `AGENTS.md` (imported above) — the single
  source of truth shared with Codex.

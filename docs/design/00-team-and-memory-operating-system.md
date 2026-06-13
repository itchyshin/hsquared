# Team And Memory Operating System

The project uses named review lenses and durable repository memory.

## Rule

```text
Private memory routes us.
Repository memory governs us.
Live repo state verifies us.
```

## Required Rehydration

At the start of a substantial task, run:

```sh
git status --short --branch
git remote -v
git log --oneline --decorate -5
gh run list --limit 5
```

Then read:

- `AGENTS.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/check-log.md`
- newest `docs/dev-log/after-task/*.md`
- `docs/design/01-v0.1-contract.md`

## Team Reporting

Every substantial update names:

- active lenses;
- whether spawned subagents are actually running;
- the current lane;
- blockers and next action.

The names are stable review perspectives, not decorative aliases.

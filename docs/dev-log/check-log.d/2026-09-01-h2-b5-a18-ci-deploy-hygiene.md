# check-log — 2026-09-01 h2-b5 A18 CI/deploy hygiene (R)

**Arc:** A18 — split pkgdown build/deploy + hide internals + R-CMD-check on main  
**Lane:** `claude/lane-h2-twin-20260901` @ `~/local-scratch/lanes/hsquared-h2-twin-20260901`  
**Sister pattern:** gllvmTMB `.github/workflows/pkgdown.yaml`  
**Goal:** Make the docs build verifiable on any branch and stop shipping `AGENTS.md` /
`CLAUDE.md` / `ROADMAP.md` as public pkgdown pages.

## Changes

- `.github/workflows/pkgdown.yaml` — build/deploy split; hide-internal + verify steps;
  GitHub Pages artifact deploy (replaces `pkgdown::deploy_to_branch`);
  `workflow_run` after successful `R-CMD-check` on main/master.
- `.github/workflows/R-CMD-check.yaml` — add `push: [main, master]` so main merges
  still fire the check that pkgdown waits on; concurrency preserves main runs.

## Commands

```sh
cd ~/local-scratch/lanes/hsquared-h2-twin-20260901
Rscript -e 'pkgdown::check_pkgdown()'
python3 -c 'import yaml; yaml.safe_load(open(".github/workflows/pkgdown.yaml")); yaml.safe_load(open(".github/workflows/R-CMD-check.yaml")); print("yaml_ok")'
```

## Results

| Check | Outcome |
|-------|---------|
| `pkgdown::check_pkgdown()` | **PASS** — no problems found |
| workflow YAML parse | **PASS** — `yaml_ok` |

Full `devtools::test()` / `devtools::check()` were **not** re-run: no `R/`, `man/`,
or test changes in this slice. Prior pass-2 tip `e7ca2fd` already had
`check()` green (0/0/1 NOTE).

## Not done here (named)

- Live GitHub Pages environment protection / first post-merge deploy verification
  (requires push — prohibited this pass).
- Owner ask #1 (`validation_status()` rows for RR k=2 / direct–maternal) — Boole+Rose.
- A20 CRAN gate items (`cran-comments.md`, `inst/CITATION`, …).

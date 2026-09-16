# check-log — 2026-09-01 h2-b5 A17 pkgdown navbar (phase 2)

**Arc:** A17 Phase C (pkgdown IA shell)  
**Lane:** `claude/lane-h2-twin-20260901` @ `~/local-scratch/lanes/hsquared-h2-twin-20260901`  
**Goal:** Job-based pkgdown navbar, home sidebar D-41 channel, articles index buckets, ROADMAP redirect. Minimal vignette stubs for `current-limits` and `function-map-cheatsheet` so articles index mirrors navbar and `check_pkgdown()` passes.

## Commands

```sh
cd ~/local-scratch/lanes/hsquared-h2-twin-20260901

Rscript -e 'pkgdown::check_pkgdown()'
```

## Results

| Check | Outcome |
|-------|---------|
| `pkgdown::check_pkgdown()` | **PASS** — no problems found |

## Claim boundary

- Adds D-41 pkgdown home sidebar experimental component (channel 3).
- Restructures navbar: Get started / Model guides / Status / Comparators / Developer.
- Regroups articles index into five buckets matching navbar; `desc:` on experimental-route buckets.
- Adds `ROADMAP.html` → `articles/current-limits.html` redirect.
- **Stubs only:** `vignettes/articles/current-limits.Rmd` and `function-map-cheatsheet.Rmd` (full content in phase B / P1).
- Does **not** split reference extractor wall (deferred).
- Does **not** change README I2 examples (phase 3).
- Does **not** add capability ledger generator or full limits page content.

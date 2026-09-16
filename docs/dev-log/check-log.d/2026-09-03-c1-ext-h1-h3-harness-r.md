# 2026-09-03 — C1-ext H1/H3 R PATH_ONLY pointer (Julia #294 twin)

**Lane:** `cursor/09-h1-h3-harness-r-20260903`  
**Not a covered flip.** Count stays **7**. Version stays experimental **0.7.0**.  
No 2000-rep confirm. No `point` mapping. No H0 Layer B.

Worktree: `~/local-scratch/lanes/hsquared-09-h1-h3-20260903` off `origin/main`
`96318bf9`. Dropbox checkout was FOREIGN (Codex #137).

## Commands

```sh
Rscript -e 'devtools::test(filter = "c1-ext-h1-h3-harness")'

Rscript sim/phase1_interval_coverage_ext.R --mode=smoke \
  --out=/tmp/c1ext-r-smoke.tsv
```

## Outcomes (local, 2026-09-03)

- Focused testthat filter `c1-ext-h1-h3-harness`: **FAIL 0 / WARN 0 / SKIP 0 / PASS 36**.
- `--mode=smoke`: **exit 0**, `GATE PATH_ONLY  claim_eligible=false  campaigns=5 rows=7`.
- `--mode=confirm` / `--mode=screen` / `--mode=promote` rejected by the R parser
  (Julia-owned; not armed here).
- `devtools::check()` / full `devtools::test()` / CI were **not** run in this
  slice (new files only; no `R/` or man-page change). `document()` was not
  needed.

`tmp/` smoke output was written under `/tmp` so it is not staged.

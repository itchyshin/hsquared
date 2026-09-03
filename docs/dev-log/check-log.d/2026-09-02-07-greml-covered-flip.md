# 2026-09-02 — 0.7 genomic GREML covered flip (count 6→7, experimental 0.7.0)

**Owner #7 auto-flip** after Rose tip CLEAN (`~/local-scratch/h2-07-rose-preflip-2026-09-02.md`).
Darwin SIGN prior. Gap-clear R #154 / Julia #287 on main.

## Flip

| Surface | Change |
|---|---|
| R genomic GREML | `partial` → **`covered (validation-scale, opt-in)`** |
| `public_covered_count` | **6 → 7** |
| Version (both twins) | **0.7.0** experimental retained |
| Single-step / default activation | stay **partial** / held |

## Local checks (this PR)

```r
# after document()
devtools::test()   # expect FAIL 0
pkgdown::check_pkgdown()
```

Record outcomes in the PR check-log index entry when run.

# 2026-09-02 — Pat leftover: shrink noisy attach

**Lane:** R (`hsquared`). **Branch:** `claude/lane-h2-twin-20260901`.
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`.
**Lens:** Pat (applied-user first screen). **No covered flip.**
**No `validation_status()` row added.** `public_covered_count` stays 5.

## Goal

`.onAttach` was still one 50-word paragraph. Pat item 2 asked for two
sentences plus the limits URL. Boole leftover 7 said shrink only after
the RR / direct-maternal apology left attach — that already happened
(item 3). `?hsquared` stays long because Grace holds `R/hsquared.R`.

## Commands and outcomes

| Command | Result |
|---|---|
| `devtools::test(filter = "d41-experimental-honesty")` | **FAIL 0 / WARN 0 / SKIP 0 / PASS 35** |
| ASCII scan of `R/zzz.R` | no non-ASCII bytes |

`devtools::document()` / full `devtools::test()` / `devtools::check()`
not run: attach string plus one length assertion. Document would rewrite
dirty sibling Rd under the Grace lease.

## Claim boundary

- Attach still says experimental, CRAN target 0.5.0, Julia required,
  validate preview, report list is the limits article not
  `validation_status()`, intervals not coverage-calibrated.
- No capability, validation, or `public_covered_count` edit.
- `?hsquared` not shortened (lease `cursor:hsquared:grace-ascii-141`).

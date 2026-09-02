# 2026-09-02 — A31 `public_covered_count` honesty scrub (Rose)

**Arc:** A31, follow-through on the A29 finding that `public_covered_count` is
asserted on ~15 surfaces with inconsistent ordinals and is **derived nowhere**.
**Lane:** R (`hsquared`). **Branch:** `claude/lane-h2-twin-20260901`. **Not pushed.**
**The count itself did not change. No covered flip. No status word moved.**

## What the number actually counts (measured, then written down)

`public_covered_count` is **not** a variable — it is a prose assertion. Measured
against two independent existing enumerations that agree:

- R `docs/design/35-api-stability-contract.md` §STABLE — the default call plus
  "the four covered opt-in targets": `two_effect`, `multi_effect`,
  `random_regression`, `direct_maternal`.
- Julia `tools/gen_status_json.jl:16-26` — the same five, enumerated in full.

So **`public_covered_count` = 5 = 1 default path + 4 opt-in targets. VERIFIED.**

## Live counts measured this arc

| Ladder | Command | Result |
|---|---|---|
| R `validation_status()` | `pkgload::load_all(); validation_status()` | **21 rows — covered 4**, partial 10, planned 7 |
| Julia `validation_status()` | `julia --project=. -e 'using HSquared; …'` | **56 rows — covered 13**, covered_external 3, partial 39, planned 1 |
| `public_covered_count` | enumeration above | **5** |

These are three different quantities and the repo was already right to keep them
apart (`39-h0-univariate-coverage-flip.md` line 373 pins "`public_covered_count`
= 5 **and** `validation_status()` covered rows = 4"; Julia
`src/validation_status.jl` says "engine-covered ≠ R-public-covered").
`HSquared.jl/tools/status_cache.json` matches the live Julia ladder exactly, so
**no Julia-lane change was needed** — the Julia lane is already consistent.

## Defects found and fixed (R lane only)

| # | Surface | Was | Now |
|---|---|---|---|
| 1 | `tests/fixtures/emit_payload_v2_fixtures.R:17` | "`public_covered_count = 1` unchanged" — **stale by four**, a live script's CONTRACT header | "`public_covered_count` unchanged (5)" |
| 2 | `docs/design/capability-status.md:30` | "The 5th **opt-in** `public_covered_count`" — asserts a 5th opt-in target that does not exist | "the 5th `public_covered_count`, an opt-in target (the 4th of the four opt-in targets; there is no 5th opt-in)" |
| 3 | `docs/design/06-public-claims-register.md` direct–maternal row | "the 5th `public_covered_count` (opt-in)" — ambiguous, reads either way | same explicit wording as #2 |
| 4 | `vignettes/articles/multi-effect-comparator.Rmd:41` | "the 3rd `public_covered_count`" — true, but an ordinal with no referent for a reader | "capability 3 of the 5 `public_covered_count`" |

Defects 2 and 3 were **already reported and never actioned**: N3 in
`docs/dev-log/2026-07-11-docsite-audit.md`, whose recommended wording this arc
adopts. That row is now marked **RESOLVED 2026-09-02**.

## The derived source (cheap, correct, not computed)

`06-public-claims-register.md` gains a short **"What `public_covered_count`
counts"** section: the five capabilities with their routes, the flip-order
ordinal convention, the explicit "four of the five are opt-in; there is no 5th
opt-in" rule, and the separation from both ladder counts. Every "stays 5"
assertion elsewhere is now checkable against one list. This is a *definition*,
not a computation — no code derives the number, and this arc did not add code
that would.

## OPEN FINDING — not fixed here (needs an owner decision)

`R/zzz.R` tells every user at attach time: *"Report point estimates only for
covered rows in `validation_status()`."* But **capabilities 4 and 5
(`random_regression`, `direct_maternal`) have no `validation_status()` row at
all** — confirmed by reading all 21 rows and by grepping `R/validation-status.R`
(both appear only inside other rows' `claim_boundary` fences). Their covered
evidence lives in this register, `capability-status.md`, and the twin's
`V3-RR-REML` / `V4-DIRECT-MATERNAL` rows.

So a user who follows the attach-time instruction literally cannot verify two of
the five covered capabilities. Recorded as a disclosure in the register's new
section. **Not fixed here: adding covered rows to `validation_status()` is a
covered-status change, which this arc is explicitly forbidden to make.**

## Commands and outcomes

| Command | Result |
|---|---|
| `devtools::test()` | **FAIL 0 / WARN 0 / SKIP 73 / PASS 2386** |
| `devtools::check(document = FALSE, args = "--no-manual")` | **Status: OK — 0 errors / 0 warnings / 0 notes** (3m 7s) |
| `pkgdown::check_pkgdown()` | **No problems found** |
| `Rscript tools/write-capability-ledger-summary.R` | 156 lines, **zero diff** — the generated include was already in sync |
| R `validation_status()` re-read after edits | **21 rows / 4 covered — unchanged** |
| Julia `validation_status()` | **56 rows / 13 covered — unchanged** |

`air format tests/fixtures/emit_payload_v2_fixtures.R` reformatted **the whole
file** (~110 lines of alignment removal) for a one-line comment change. Reverted
with `git checkout --` and the comment reapplied by hand: the r-package rule
forbids widening a commit with drive-by reformatting. No formatter churn shipped.

## Fence

R multivariate **partial** · `public_covered_count` **5** (unchanged, and now
enumerated) · R `validation_status()` covered rows **4** (unchanged) · Julia
`V4-MV-REML` **covered** (unchanged) · Darwin ink **blank** · **no push** · no
covered flip · no status change · no G10 · no version bump · no CI enabled ·
no Totoro/DRAC compute.

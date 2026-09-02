# 2026-09-02 — A31 follow-through: the attach-time reporting rule was unverifiable

**Arc:** A31 (Rose), the OPEN FINDING left by
`2026-09-02-h2-a31-public-covered-count-scrub.md`. This also **closes A21
condition C7** (panel §3.4): "add the no-row disclosure clause to `.onAttach`
and the claims register". A31 had already done the register half; this does the
`.onAttach` half, plus four sites neither list named.
**Lane:** R (`hsquared`). **Branch:** `claude/lane-h2-twin-20260901`. **Not pushed.**
**Lens:** Boole (public wording, pointer contracts), reading Rose A31 and the
A21 estimand panel.

**No covered flip. No `validation_status()` row added. `public_covered_count`
stays 5. `validation_status()` still returns 21 rows / 4 covered.** This is a
wording-and-pointer change only; no estimand, number, status word, or return
value moved.

## The defect

`R/zzz.R` printed on every `library(hsquared)`:

> Report point estimates only for covered rows in `validation_status()`.

But `random_regression` and `direct_maternal` are 2 of the 5
`public_covered_count` capabilities and have **no `validation_status()` row**.
A user who follows the instruction literally **cannot verify two of the five
capabilities the package calls covered** — the rule points at a table that does
not contain them. Rose's characterisation holds: self-contradiction, not
concealment.

## Second defect, found on the same line (measured, not assumed)

The same message ended:

> See `?validation_status` and `vignette("model-status", package = "hsquared")`.

`vignettes/articles` is `.Rbuildignore`d, so **that vignette is not installed**
and the pointer is dead for every user. Verified by building the tarball rather
than reasoning from the ignore file:

```sh
R CMD build --no-build-vignettes --no-manual .
tar tzf hsquared_0.1.0.9000.tar.gz | rg vignettes
#   hsquared/vignettes/
#   hsquared/vignettes/hsquared.Rmd      <- the only one
```

`man/hsquared-package.Rd` carried the same dead pointer twice
(`model-status`, `validation-evidence`). A pointing-honesty fix that leaves the
pointer unresolvable is not a fix, so both were repointed at the published
website URLs, which do exist.

## Sites changed

The A21 panel §3.4 named two sites carrying the bare rule with no disclosure
(`R/zzz.R`, the register). Grepping the rule rather than trusting the list found
**four more**:

| # | Surface | Change |
|---|---|---|
| 1 | `R/zzz.R` `.onAttach` | rule now says `validation_status()` "is not a complete list of the covered routes", names `random_regression` (k = 2) and `direct_maternal`, and points at the live `current-limits` URL instead of an uninstalled vignette |
| 2 | `R/validation-status.R` roxygen | new section "This table is not the full list of covered routes": why the `covered` row count is not the number of covered routes, both routes with their formulas and targets, and "an absent row is not an absent capability" |
| 3 | `R/validation-status.R` `print.hs_validation_status` | the printed line "public claims: only `covered` rows may be advertised as working" was the same false implication **inside the object's own output**; now flags the gap and points at `?validation_status` |
| 4 | `DESCRIPTION` | `Description` is republished on CRAN mirrors, the pkgdown home page, and `packageDescription()` — the highest-reach copy of the rule |
| 5 | `man/hsquared-package.Rd` (via `R/hsquared-package.R`) | disclosure paragraph + the two dead vignette pointers repointed to website URLs |
| 6 | `README.md` | rule made honest; the duplicate `current-limits` link the edit would have created was collapsed into the existing one |

`README.md` has **no** `README.Rmd` in this repo (checked), so it is edited
directly and is not a generated artifact.

Sites deliberately **not** touched: `vignettes/articles/current-limits.Rmd` and
`vignettes/articles/model-status.Rmd` already disclose the gap correctly
(A21 §3.4 verified this), and `06-public-claims-register.md` was done by the A31
scrub. Nothing was rewritten that was already true.

## Tests

Four scoped tests added to `tests/testthat/test-d41-experimental-honesty.R`
(the existing D-41 honesty-channel file), each pinning both directions — the new
honest wording present **and** the old false wording absent:

- `.onAttach` names both routes, says "not a complete list", contains no
  `vignette(` call, and points at `current-limits`;
- `print(validation_status())` flags that it is not the full covered list;
- `DESCRIPTION` and `README.md` carry the disclosure and no longer carry the
  sole-authority phrasing.

The README assertion unwraps the blockquote (`sub("^>\\s?", ...)` + whitespace
collapse) so it pins the *claim*, not the line breaks — the previous
line-break-sensitive style in this file would have gone red on a re-wrap.

## Commands and outcomes

| Command | Result |
|---|---|
| `air format` (4 edited files) | clean; **no drive-by churn** — `git diff --stat` stayed at the 6 intended files |
| `devtools::document()` | OK; `hsquared-package.Rd` + `validation_status.Rd` regenerated, `\href{}` links render correctly |
| `devtools::test()` | **FAIL 0 / WARN 0 / SKIP 73 / PASS 2401** (was 2386; +15 assertions, same 73 pre-existing live-Julia/comparator skips) |
| `devtools::check(document = FALSE, args = "--no-manual")` | **Status: OK — 0 errors / 0 warnings / 0 notes** (3m 7s) |
| `pkgdown::check_pkgdown()` | **No problems found** |
| `R CMD build` + `tar tzf` | only `vignettes/hsquared.Rmd` ships (the dead-pointer evidence above) |
| live `validation_status()` | **21 rows / 4 covered — unchanged** |

## Lane notes

- `R/validation-status.R`: 5 refs carry work on this path. Read
  `claude/fix-validation-status-non-ascii` before writing, as instructed — it is
  **stale**, predating the `capability_label` work at this tip (its diff *deletes*
  `capability_label` and the label-override machinery). Not built on; not a
  forked second fix. Its existence is still informative, so **every line added
  here is ASCII** (`2x2`, `<=`), leaving the file's pre-existing em-dashes alone.
- `DESCRIPTION` / `README.md`: `origin/codex/2026-07-13-v07-performance-localization`
  conflicts here. This is the **already-escalated DP-8**, which A25 measured as
  *deleting* the D-41 honesty wording from `DESCRIPTION`. This commit adds more
  honesty text to the same field, so **DP-8's conflict surface grows slightly**.
  Still an owner decision, still unresolved, deliberately not resolved here.

## Owner-facing output

Draft `validation_status()` rows for both routes are written to
`~/local-scratch/h2-validation-status-rr-dm-row-drafts.md` as **OWNER-DRAFT,
not landed** (owner ask **G-AG-5**). It carries proposed stable ids, the
re-derived `rep()` arithmetic for a 23-row table, the covered-flip gate scored
item by item, and the 15 files that must change together. Two findings from it
belong in this log:

1. **Gate item 3 (Darwin sign-off) is not recorded in this repo** for either
   route. Grepped the whole `docs/` tree for `Darwin` near `direct.maternal` /
   `random.regression` / `reaction.norm` / `r_am`: the only hit is
   `validation-debt-register.md:15`, which lists `Boole/Darwin/Rose` as *assigned
   reviewers* — an assignment, not a signature. The twin repo and the mirrored
   ledger issues were **not** searched, so this is absence of evidence here, not
   proof of absence. Owner ask.
2. **The capability-ledger drift guard is forward-only.**
   `hs_check_routes()` walks the generator's route table demanding one matching
   `validation_status()` row each; there is no reverse check. So adding rows
   would **not** fail any test — the new routes would just be silently missing
   from the reader cards. That silence is the same failure mode this arc is
   about, and it is flagged in the draft as part of the same change.

## Fence

`public_covered_count` **5** (unchanged) · `validation_status()` **21 rows /
4 covered** (unchanged) · R multivariate **partial** (unchanged) · no covered
flip · no row added · no status word moved · Darwin ink **blank** · **no push**
· no version bump · no G10 · no CI enabled · no Totoro/DRAC compute.

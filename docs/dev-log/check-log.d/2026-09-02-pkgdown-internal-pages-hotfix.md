# 2026-09-02 — pkgdown internal-pages hotfix

**Lane:** `cursor/pkgdown-internal-pages-hotfix` @
`~/local-scratch/lanes/hsquared-pkgdown-hotfix-20260902`
**Base:** `origin/main` `efe4c476` (post-#141).
**No covered flip.** `public_covered_count` stays 5.

## Goal

Unblock `main` pkgdown after
[run 33653663313](https://github.com/itchyshin/hsquared/actions/runs/33653663313)
failed at “Verify internal pages are absent”.

## Root cause

`_pkgdown.yml` had `redirects: [["ROADMAP.html", "articles/current-limits.html"]]`.
The workflow already moves `ROADMAP.md` aside, but `pkgdown::build_redirects()`
recreates `ROADMAP.html` and indexes it. That trips:

```sh
test ! -e pkgdown-site/ROADMAP.html
! grep -E '(AGENTS|CLAUDE|ROADMAP)\.html' pkgdown-site/search.json pkgdown-site/sitemap.xml
```

## Commands and outcomes

| Command | Result |
|---|---|
| Hide internals + `pkgdown::build_redirects()` on `efe4c476` yml | **RED** — wrote `pkgdown-site/ROADMAP.html` (“Adding redirect from ROADMAP.html to articles/current-limits.html.”). AGENTS/CLAUDE absent. |
| Same after removing the redirect | **GREEN** — no `ROADMAP.html`. |
| `devtools::install(upgrade = FALSE, dependencies = FALSE)` then hide + `pkgdown::build_site(new_process = FALSE, install = FALSE)` | **PASS** (exit 0). |
| CI verify (`test ! -e` AGENTS/CLAUDE/ROADMAP.html; grep search.json + sitemap.xml) | **PASS** — pages absent; no `(AGENTS\|CLAUDE\|ROADMAP).html` in index. |

`devtools::test()` / `devtools::check()` not re-run: `_pkgdown.yml` only.

## Claim boundary

- Removes the A17 `ROADMAP.html` redirect. Navbar already points at
  `articles/current-limits.html`.
- Does not change capability, validation, version, or public-covered count.

# Mission-Control Pkgdown Article

Active lenses: Ada, Shannon, Boole, Hopper, Emmy, Grace, Rose, Pat.
Spawned subagents: none.

## Goal

Add an R-facing dashboard page for the `hsquared` / `HSquared.jl` twin project,
matching the mission-control style used by the Julia Documenter page while
keeping claim boundaries explicit.

## Files Changed

- `_pkgdown.yml`
- `README.md`
- `NEWS.md`
- `vignettes/articles/mission-control.Rmd`
- `docs/dev-log/check-log.md`
- `docs/dev-log/after-task/2026-06-13-mission-control-pkgdown-article.md`

## Implementation

The article summarizes:

- current R parser and data-container status;
- the Julia engine boundary;
- phase board;
- validation atoms;
- blocked claims;
- review lenses.

It is a static pkgdown article. It does not run checks, query GitHub, or fit
models.

## Public Claim Audit

Allowed wording:

- the pkgdown site includes a mission-control dashboard;
- the page separates implemented, experimental, and planned surfaces.

Blocked wording:

- general animal-model fitting is available;
- variance-component estimation is available through the public R interface;
- production sparse PEV/reliability is available;
- genomic prediction, marker scans, QTL/eQTL, GLLVM, or GPU execution is
  available.

## Checks

- `git diff --check`: clean.
- `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`:
  articles rebuilt and pkgdown reported `No problems found.`
- Rendered article spot-check:
  `rg -n "Mission control|One R interface|&lt;article|<pre><code>&lt;article|Blocked Claims|Julia Engine Boundary" pkgdown-site/articles/mission-control.html`
  confirmed the page/menu/dashboard content and found no escaped dashboard
  article block.
- `Rscript -e "devtools::check()"`: passed with `0 errors`, `0 warnings`, and
  `0 notes`.
- GitHub Actions R-CMD-check `27466195166`: passed in 1m48s for commit
  `aca35df`.
- GitHub Actions pkgdown `27466195171`: passed in 1m54s for commit `aca35df`.
- GitHub Pages build/deploy `27466236586`: passed. Pages emitted the upstream
  Node 20 actions deprecation annotation for `actions/checkout@v4` and
  `actions/upload-artifact@v4`; deployment still succeeded.
- `https://itchyshin.github.io/hsquared/articles/mission-control.html`:
  HTTP 200 and contains the mission-control page title, Articles menu link, and
  blocked-claims dashboard section.
- `https://itchyshin.github.io/HSquared.jl/dev/mission-control.html`: HTTP 200
  and contains the Julia mission-control page title and blocked-claims
  dashboard section.

## Next Actions

1. Keep the R and Julia mission-control pages aligned when capability status
   changes.
2. Choose the next Phase 1 validation or bridge atom.

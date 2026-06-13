# Expanded Genomics/QTL/GLLVM/GPU Plan

Date: 2026-06-13

Active lenses: Ada, Jason, Karpinski, Pat, Rose.

Spawned subagents: none.

## Scope

Convert the maintainer's extended prompt into durable repo memory for the two
package programme. The plan is strategic and technical; it does not implement
genomic, QTL/eQTL, GLLVM, GPU, or HPC fitting.

## Local Scout

Checked the local sibling landscape:

- `drmTMB`;
- `gllvmTMB`;
- `DRM.jl`;
- `GLLVM.jl`;
- GLLVM branch/worktree folders.

No `PMTMB` folder was found by name in the top two directory levels under
`/Users/z3437171/Dropbox/Github Local`.

Concrete lessons incorporated:

- `DRM.jl/src/takahashi_selinv.jl` is a local algorithm reference for selected
  inverse entries, PEV, and reliability after sparse factorization exists.
- `GLLVM.jl/src/fit.jl` supports the plan to profile nuisance variance and use
  low-rank/Woodbury structure for high-dimensional Gaussian paths.
- `GLLVM.jl/src/structured_schur.jl` supports the plan for matrix-free,
  low-rank structured precision work.
- `gllvmTMB/CLAUDE.md` supports status-separated grammar, long/wide example
  discipline, and explicit after-task reports.

## Implementation

Updated:

- `docs/design/07-genomics-qtl-gpu-plan.md`;
- `docs/design/00-ecosystem-lessons.md`;
- `vignettes/articles/genomics-gpu-roadmap.Rmd`;
- `NEWS.md`;
- `docs/dev-log/check-log.md`;
- `docs/dev-log/coordination-board.md`.

The main plan now has the requested sections for architecture, formula grammar,
data integration, inheritance modules, genomics, QTL/eQTL, multivariate G
matrices, GLLVMs, CPU/GPU backends, backend support by vendor, benchmarking,
HPC workflow, validation, output extractors, documentation, roadmap, risks, and
the first minimal implementation.

## Validation

Local checks:

- `git diff --check`: clean.
- `LC_ALL=C rg -n "[^\\x00-\\x7F]" ...`: no non-ASCII matches in edited
  files.
- `Rscript -e "pkgdown::check_pkgdown()"`: no problems found.
- `Rscript -e "devtools::check()"`: `0 errors | 0 warnings | 0 notes`.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- long-range roadmap;
- design target;
- source-backed backend and algorithm leads;
- syntax examples marked as planned or targets.

Blocked wording:

- genomic, QTL/eQTL, GLLVM, GPU, or HPC support is implemented;
- CPU/GPU speedup is known;
- ASReml-level performance exists;
- sibling code was copied without provenance and tests.

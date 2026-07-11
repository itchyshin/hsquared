# Handover to Claude — 2026-07-11 (end of day): full session + doc-site audit

From Claude (Opus 4.8) · everything committed + pushed · clean tree. Two earlier
handovers today: `2026-07-11-claude-handover.md` (AM) and
`-06-arc.md` (PM). This one adds the **doc-site audit** and is the resume point.

## 1. What shipped today (all on open PRs vs `main`)
- **0.2.0 honesty baseline MERGED to `main`** (#125/#127/#128/#129/#130).
- **PR #131** — planning/design: release-model decision (0.5.0-not-1.0, releases
  decoupled from phases, 1.0=maturity); docs 35 (API contract) · 36 (exec plan) ·
  41 (lane goal + autonomy boundary) · 37 (**NG-1 estimand contract, NG-2 SIGNED
  OFF**, logit primary=latent) · 38 (MV-4 grammar freeze RATIFIED) · 39 (H0) ·
  40 (MV-5 pre-decl) · 42 (FA calibration diagnosis) · 43 (genomic-GREML G0).
- **PR #132** — the 0.6 multivariate slice: **MV-4** (cbind auto-route, no flip) ·
  **MV-1** (in-suite full-unstructured sommer, off-diagonal R0) · **MV-2** (cited
  the verified BLUPF90+ 2nd comparator — discharged) · **MV-3** (r_g/h² identity
  gate + locked citation) · **MV-5 driver** (t=3, 2 truth points, full-sib;
  pre-declared). Tests 0-fail throughout; no covered flip anywhere.

## 2. Doc-site audit (NEW — first ever; see `docs/dev-log/2026-07-11-docsite-audit.md`)
7-lens panel (Grace/Pat/Emmy/Rose/Karpinski/Hopper/Jason/Florence) audited the
hsquared **pkgdown** site + the HSquared.jl **Documenter** site (doc-only, no
build). **0 blockers · 6 high · 16 medium · 14 low · 5 nice-to-have.** Top fixes:
1. **pkgdown getting-started is not runnable/self-contained** — the landing page +
   get-started path have no runnable, self-contained animal-model example.
2. **pkgdown landing buries "how do I fit an animal model"** — no `index.md`
   override; the core value is hidden. Add a crisp home + a 5-line worked example.
3. **17 articles dumped flat** in `_pkgdown.yml` `articles:` — group them
   (get-started / models / validation / roadmap).
4. **Documenter nav exposes the internal engine dashboard as the #2 item** — wrong
   first impression for a new user; demote it, lead with getting-started.
5. **Visualizing article overclaims** — promises the low-h² imprecision flag on the
   genetic-correlation heatmap that the figure/behaviour doesn't fully deliver
   (Florence — honesty).
6. **HSquared.jl Validation-Status doc contradicts its own source of truth** — the
   page's counts disagree with the live `validation_status.jl` ledger (Rose —
   honesty, engine lane; fix on the twin).
Detail (all 41 findings + quick-wins + best-practice gaps vs sommer/MCMCglmm/
ASReml/JWAS/brms + brain-recorded standards) is in the committed audit doc.

## 3. CARRIED OVER — resume here
- **Doc-site quick wins** (≤1 hr): add `index.md` + a runnable get-started example;
  group the pkgdown articles; demote the Documenter dashboard; fix the two honesty
  overclaims (visualizing article; twin validation-status page). See audit doc.
- **MV-5 run** — NOT via R `mclapply` (JuliaCall fork segfaults). Port the DGP to a
  **threaded Julia sim** in the twin (`julia -t 96` + `Threads.@threads`,
  OPENBLAS_NUM_THREADS=1); the R driver is the serial DGP oracle. **Julia lane →
  Codex/user run it, NEVER concurrent with Claude.** Also owed: `simulation-check`
  review of the 2 truth points before the confirm tier.
- **FA discriminating test** — turnkey script handed to the user (`scratchpad/
  fa_discriminating_test.jl`); classifies Heywood vs optimizer vs sampling. Don't
  launch a Totoro FA warm-start until it runs (doc 42).
- **NG-1 §8** wording punch-list → Boole extractor-grammar freeze → maintainer nod.
- **0.6 flip** — after MV-5 passes: Darwin biology sign-off + Rose + your G10.
- **Merge** PRs #131 / #132; settle the **0.5 release** decisions (twin #267/#268,
  stale-`v0.1.0`-tag, SystemRequirements, cran-comments, Julia-registers-first).

## 4. Durable rule recorded this session
**Claude and Codex run sequentially, NEVER concurrently** — hand-off, not parallel.
Claude prepares live-toolchain work turnkey and hands it to a later Codex/user
session. (Brain: `memory/Claude and Codex run sequentially, never concurrently.md`.)

## Resume
```sh
cd "/Users/z3437171/Dropbox/Github Local/hsquared"   # hsquared-rehydrate
cat docs/dev-log/2026-07-11-docsite-audit.md   # the audit findings + fixes
gh pr view 131; gh pr view 132
```

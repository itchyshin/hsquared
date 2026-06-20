# Session handoff — hsquared R lane (2026-06-20, session 3) — START HERE

**Single START-HERE entry point for the next session.** Then run `hsquared-rehydrate` and
**live state wins over this doc** (re-verify with `gh` + `git`; the twin moves fast).

---

## One-paragraph state

The R lane and the Julia engine twin ran a **live cross-lane collaboration** all session on
`HSquared.jl#61`: the twin races the engine, the R lane builds the bridge side of each landing
(different repos, no collision). **8 R-lane slices shipped**, every engine-coupled one
**live-verified against the real engine**. Working tree clean, synced with `origin/main`
(`95e598a`); tests **925 pass / 0 fail / 0 warn / 36 skip**; `devtools::check(--no-manual)`
**0/0/0**; `check_pkgdown` clean; pkgdown deploys on push.

---

## THE BIG UNLOCK (read this first)

**Julia was available all session — only off-PATH.** `~/.juliaup/bin/julia` is **1.10.0** (juliaup;
1.12.6 also installed). The bridge goes LIVE in a dev (`load_all`) session with:

```sh
export PATH="$HOME/.juliaup/bin:$PATH"
export HSQUARED_JULIA_PROJECT="/Users/z3437171/Dropbox/Github Local/HSquared.jl"
export NOT_CRAN=true
```

(Under `load_all`, `system.file()` mis-resolves the default project to `hsquared/HSquared.jl`; the
env var overrides it to the sibling. `NOT_CRAN=true` un-skips `skip_on_cran()`.) Then
`hs_julia_bridge_available()` → TRUE. **Do NOT assume skip-only — every engine-coupled slice can be
live-verified.** Run heavy live test files **one per process** (a known JuliaCall/Rcpp segfault at
teardown after many `julia_eval` calls; the assertions pass first).

---

## What shipped this session (all experimental/partial; nothing promoted to covered)

| # | Slice | Commit | Live-verified |
| --- | --- | --- | --- |
| 1 | **PEV/reliability bridge fix** — twin `a1521bf` put PEV/reliability into the standard `result_payload` via `:selinv`; the bridge was clobbering it with a redundant `:dense` re-merge. Guarded on `!hasproperty(result, :prediction_error_variance)`. Closes univariate #21. | `f38d7f4` | ✅ R PEV == `:selinv` |
| 2 | **Non-Gaussian (GLMM) bridge** — `family = poisson()/binomial()` via `target = "nongaussian"` → `fit_laplace_reml`; latent-scale variance + EBVs, **no heritability**. (#44) | `31f200c` | ✅ Poisson+Bernoulli |
| 3 | **Evolvability / G-geometry** — `eigen_G()` (reserved→implemented), `g_max()`, `mean_evolvability()`, `evolvability()`, `respondability()`, `conditional_evolvability()`, `autonomy()` (Hansen-Houle 2008), rotation-invariant. (#55) | `35bf92f` | ✅ engine parity |
| 4 | **`gwas(fit, markers)`** — post-fit relatedness-corrected mixed-model Wald scan reusing the fit's VCs + pedigree; **significance UNcalibrated** (gate #48). (#45/#23) | `23aab52` | ✅ engine parity |
| 5 | **Fitted estimated-VC fixture** — consumed the twin's `animal_model_fitted_target/` (#46); live reproduction of serialized REML estimates + an inbreeding-aware PEV/reliability consistency check. | `7761055` | ✅ reproduces |
| 6 | **`variance_along_gradient()`** — completes the evolvability set. (#55) | `95e598a` | ✅ engine parity |

(Plus the earlier autonomous gap-closing run: diagonal multivariate fixture parity, Phase 2 grammar
markers, gated-error sharpens, doc/status reconcile, review-barrier follow-ups — commits
`d1c1002`..`34f8a29`, all in `check-log.md`.)

## The cross-lane division of labour (active, on #61)

**Twin races the engine; R builds the bridge side + live-verifies.** Confirmed on #61. The Julia
thread paused ~08:00 (Handover v4, "overnight runway done"). Ratified jointly: the **FA rotation
convention** — bridge only **rotation-invariant** functionals of G (eigenstructure, evolvability),
**never the loadings** (Kirkpatrick & Meyer 2004 / WOMBAT `xfa` precedent).

## Next R actions (reactive to the twin resuming)

1. **FA structured payload (#42/#22):** twin will widen `multivariate_result_payload` to accept
   `:lowrank`/`:factor_analytic` emitting the **eigenbasis + invariants (NOT loadings)** + a
   `:lowrank`/`:fa` parity fixture. On that landing: wire the unpack so reduced-rank/FA fits report
   the same `eigen_G()`/evolvability geometry (the extractors already exist + are convention-clean).
2. **#54 random regression:** twin landed "slice 1: descriptors (supplied K_g)"
   (`legendre_basis`/`rr_genetic_variance`/`rr_*_surface`/`rr_heritability`); mid-build. Bridge the
   reaction-norm surfaces when the RR fit lands.
3. **#49 JWAS comparator:** scaffold only (no comparator evidence yet); run the confrontation when
   the twin posts target paths.
4. **Deferred R follow-ups:** non-Gaussian `marker_scan_result_payload` + a `marker_scan_parity`
   fixture (asked twin #45); `binomial`-with-`n_trials` grammar (asked twin #44); variational
   marginal (`marginal = "variational"`, engine supports it).

## Rehydrate

```sh
git status --short --branch; git log --oneline -10
gh issue list --repo itchyshin/hsquared --state open
gh issue list --repo itchyshin/HSquared.jl --state open   # incl. #61 channel
git -C ../HSquared.jl fetch origin && git -C ../HSquared.jl log origin/main --oneline -8
```
Then read `coordination-board.md` (newest rows), the latest `check-log.md` entry,
`docs/dev-log/2026-06-19-twin-coordination-report-v3.md`, and this doc. Widget:
`python3 .mission-control/serve.py` → http://127.0.0.1:8781/.

## Discipline (unchanged)

Lane discipline (R-lane only; coordinate via GitHub issues, never edit the twin). Honesty gate
(only `covered` is "working"; everything new is experimental/partial; carry the engine's caveats —
no-heritability, uncalibrated-significance, etc.). Per-slice loop: implement → live-verify (julia is
available!) → Rose audit → air/document/test/check_pkgdown/check → after-task → commit (plain
imperative, no `Co-Authored-By`) → push → record CI evidence.

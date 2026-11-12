# SE method: average information by default, observed on request

Date: 2026-11-09. Lane: R, plus the Julia engine change it needs. Szymek
assigned both for this slice in the session. Branches: hsquared
`claude/se-asreml-mcmcglmm-investigation`, HSquared.jl
`claude/se-information-switch`.

Active lenses: Ada, Gauss, Fisher, Boole, Hopper, Rose (perspectives, not
spawned). Spawned subagents: none.

## Question

On the great tit animal + permanent-environment model, why are `hsquared`'s
standard errors consistently wider than ASReml-R's?

## Answer

Neither package is wrong. They invert different matrices at the same REML
optimum. ASReml inverts the average information (AI), and `hsquared` inverted the
finite-difference observed information. For a covariance linear in the
components, `observed = 2 AI - expected`. All three are asymptotically equivalent
and differ on one dataset. Full evidence: `dev-test/se-investigation/RESULTS.md`.

- An independent base-R reference (sparse MME, no ASReml, no Julia) reproduces
  ASReml's SEs from inverse AI and `hsquared`'s from inverse observed, both to
  4-6 significant figures, on both traits.
- MCMCglmm (6 × 65k iterations): on clutch size the posterior SD agrees with the
  observed-information SEs within MC error (0.0-1.5 MCSE) and rejects AI (3.6-5.1
  MCSE). Laying date does not discriminate: AI and observed differ by ~1.5%, the
  chains mix poorly (ESS 400-500), and the V_PE posterior is skewed.
- Side finding: the engine already mixed the two conventions. The univariate
  animal model and genomic GREML used AI; the K-effect routes used observed.

## Change

- **R**: `hs_control(se_method = c("ai", "observed"))`, default `"ai"`. Threaded
  to the default animal model (`ai_reml`/`sparse_reml`), genomic GREML, and
  the sparse animal + PE route. The method actually used is stamped on
  `fit$result$se_method` and shown by `fit_diagnostics()`. Older engines without
  the keyword get their native method, recorded honestly. **Behaviour change:**
  the sparse animal + PE route's SEs move from observed to AI.
- **Julia**: `information = :ai | :observed` on `variance_component_covariance`,
  `variance_component_standard_errors`, `heritability_standard_error`,
  `heritability_interval` (delta), `variance_component_uncertainty`, and the
  five `multi_effect_*` SE functions. New `_multi_reml_ai_information!` (one
  factorisation, K + 1 solves) and `_univariate_observed_information`. Julia
  defaults are unchanged (univariate `:ai`, K-effect `:observed`), so no Julia
  caller moves.

## Result

`se_method = "ai"` equals ASReml-R's SEs to every printed digit (clutch size
SE(V_A) 0.0663271, SE(h²) 0.0255754; laying date 0.832305, 0.0215506).

Timing, idle machine, median of 7 warm runs: ASReml 0.71 / 0.65 s; hsquared
`"ai"` 0.77 / 0.90 s; `"observed"` 0.90 / 1.03 s (clutch size / laying date).

## Checks

See the 2026-11-09 entry in `docs/dev-log/check-log.md`.

## Not claimed / boundary

- No covered flip; `public_covered_count` stays 7. SEs remain asymptotic and not
  coverage-calibrated under either method.
- ASReml is still not a permitted covered comparator leg; this is development
  evidence on one dataset.
- Not threaded: two-effect, n-effect, direct-maternal, multivariate, dense
  repeatability. They keep their own method; the dense repeatability interval is
  observed-based.

## Follow-ups

- Merge order: HSquared.jl PR first, then hsquared (hsquared falls back safely
  on an engine without the keyword, but the default only takes effect with it).
- Genomic GREML is slow on the simulated n = 2,000 panel (130-140 s per fit);
  reported on HSquared.jl#420.
- Thread 2 (genomic simulation case study) is in progress: `dev-test/genomic-sim/`.

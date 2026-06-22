# After-task report — non-Gaussian bridge-gap sync

Date: 2026-06-21

Branch: `codex/nongaussian-bridge-gap-sync`

Active lenses: Ada, Shannon, Hopper, Boole, Fisher, Rose, Grace

## Scope

Reconciled R source documentation after HSquared.jl PR #153 (`c26ab48`) mirrored
the R PR #95 (`05fbdd3`) non-Gaussian fixture-consumption handoff.

This slice fixes a stale R-side WS2 bridge-gap table that still said R rejected
non-Gaussian families wholesale and still needed the `NonGaussianFit` payload
shape. That was true for the original snapshot but is stale after the opt-in
non-Gaussian bridge, VA marginal, binomial common-trial bridge, and PR #95
fixture mirror landed.

## Files changed

- `docs/design/19-on-main-bridge-gap.md`
  - updates the non-Gaussian row to current R main: opt-in
    `target = "nongaussian"` bridge is banked for Poisson/Bernoulli/Binomial
    common-trial cases, LA/VA marginal control, no-heritability result shape,
    and Julia-free `non_gaussian_parity` fixture consumption;
  - keeps per-record varying-trial formula activation, comparator/calibration,
    and promotion gates open.
- `docs/dev-log/issue-map.md`
  - records HSquared.jl PR #153 as a Julia status mirror of R PR #95, not a new
    capability.
- `docs/dev-log/coordination-board.md`
  - marks the PR #95 slice banked and adds this status-correction slice.
- `docs/dev-log/check-log.md`
  - records commands and boundaries.

## Checks

- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'`
- `git diff --check`
- stale wording audit over the reconciled bridge-gap/status files
- after-task validator

## Public claim audit

Clean. The corrected wording does not expand the R public API. The current R
state is:

- opt-in `poisson(log)` / `binomial(logit)` non-Gaussian bridge is banked;
- `cbind(successes, failures)` binomial counts are supported only when row
  totals are equal;
- serialized vector `n_trials` is consumed at the normalizer boundary from the
  Julia fixture, but per-record varying-trial R formula activation remains
  open;
- no external GLLVM/gllvmTMB/MCMCglmm-or-equivalent comparator evidence,
  interval calibration, public default, or covered-status promotion.

## Coordination notes

Julia issue #44 currently appears to describe all R non-Gaussian
formula/model-spec activation and live bridge fitting as still open. The R
source-of-truth status is narrower: the basic opt-in bridge is banked; the
remaining R-side bridge gap is per-record varying-trial activation plus broader
validation/comparator/calibration work.

## Known limitations

No behavior changed and no tests were added. This was a status/doc correction.

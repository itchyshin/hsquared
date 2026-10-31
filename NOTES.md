# NOTES: hsquared#266 (lazy PEV/reliability), question for Engine A

Status: the `relationship_diag` half of #266 is done (PR #335 for the
`ai_reml` and `sparse_reml` routes; this branch adds the dense
`fit_animal_model` route and the supplied-variance `henderson_mme` route).
The lazy PEV/reliability half is **not** done, by design: it hits the stop
condition.

## Why it stops here

Every pedigree Gaussian route returns `prediction_error_variance` and
`reliability` in the default fit object. On current HSquared.jl main they are
built inside the engine's `result_payload(fit)` (src/likelihood.jl,
`result_payload(fit::AnimalModelFit)` calls `prediction_error_variance(fit;
method = :auto)` and `reliability(fit; ...)`); the R bridge only adds them
for older engines that lack them, and the Henderson route attaches them
directly. Making them lazy means the default `hsquared()` object no longer
carries these slots, which changes the default fit return. The R side cannot
make this choice alone, because the eager cost sits in the engine.

## Question for Engine A (HSquared.jl owner)

1. Should `result_payload(fit)` gain a switch (for example
   `post_fit = (:pev, :reliability, :se)` or `pev = true`) so a caller can skip
   PEV/reliability? Default stays eager, or becomes lazy?
2. If lazy becomes the default: should `reliability(fit)` / `pev()` in R
   compute on demand from a fit that keeps a live Julia handle, or must the
   R object stay self-contained (current behaviour: no handle after the fit)?
   This decides whether lazy is possible at all after `save = "minimal"`.
3. If eager stays the default: is an R-side opt-out
   (`hs_control(engine_control = list(post_fit = ...))`) acceptable, with
   `reliability()` then erroring with a hint to refit?

Evidence for the cost: #266 comments (N = 5000: PEV + reliability 1.0 to
1.1 s of a 5.9 s warm call; N = 50000: 530 s of a 2009 s warm call).

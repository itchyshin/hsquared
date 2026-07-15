# Recovery checkpoint — Retry-6 post-run adjudicator route blocker

Date: 2026-07-15 MDT

## Terminal classification

Retry 6 is permanently
`UNADJUDICATED_POSTRUN_ADJUDICATOR_ROUTE_BLOCKER`.

All pre-RNG gates passed. The exact bound tuple was R deploy
`1766aeffe675cfed8547c3107ff1c7a32905210f`, R candidate
`8dea0ad9fb9b56ea4457bf9d1f25c7fa64af1570`, Julia deploy
`c418f50c8ffff871677cac04fca39d737b8021ca`, Julia candidate
`d19149514964ab58b26d4583ae170d477d8b3a45`, and doc-49 SHA-256
`9247d2ceed1d98f89767c367883cb899410e2b840a50dd2f8cc0cb9e3f75e00e`.

## Completed evidence

The Totoro root
`/home/snakagaw/hsq_work/v07-genomic-recovery-v3-d0f-retry-r6-1766aef-c418f50`
contains 576/576 successful converged official fits, 576/576 independent base-R
recomputations, and 576/576 exact Julia replays. All three design summaries are
192/192 converged and `COMPLETE`; there are 567 interior, eight lower, one
upper, and zero unresolved rows. Maximum attempt parity is
`3.1832314562052488e-12`; maximum summary parity is
`7.1054273576010019e-15`.

The official corpus-lock SHA-256 is
`61237d7ea583866fe1b52579a2a86439aebf2186e0c09bda5a9dee910d59190a`;
the base-R summary SHA-256 is
`a54f658d7e8981ea398b54e2827153d1f0c3f6610ffc38c5b4b36f51c1e3be9f`;
the Julia summary SHA-256 is
`33e1e81579c8b1d13fe6894b49f98eab15126361e704dbde1c5504eaffeaa749`.

## Blocker and freeze

The first canonical Fisher receipt writer stopped with `D0F successful result
has malformed scientific output` before writing a receipt. Julia rows were
correctly admitted as `julia_profile_replay`, then summary reconstruction
re-admitted them under the ordinary-R default. The same latent route drop
existed for D1. Exact field diagnostics found zero malformed official, base-R,
or Julia rows; this is infrastructure, not scientific evidence.

No post-run review receipt or adjudication receipt exists. D1/D2 never opened.
The root was frozen read-only at 9,248 files / 598 directories; its content
digest remained
`148da8ef212bb4a303b6d4223cc63dae6142531370770a432283d852334d754f`.
The freeze-log SHA-256 is
`f34da1d2c1906308967b9ff02527e8542ba0a06a9384bf83e837a5b6fe5a0255`.

Every Retry-6 phenotype seed under `2040000000` and bootstrap seed under
`2041000000` is retired. No successor base exists.

## Seed-free prospective repair

R commits `b8096e5` and `562b93e` thread `expected_route` through D0F and D1
summary reconstruction, explicitly bind Julia replay, keep the ordinary-R
default, test wrong-route/wrong-driver rejection, and move Retry-6 seeds into
the executable historical lock. They change no schema, estimator, estimand,
ridge, tolerance, threshold, denominator, or fitted output. They do not repair
or adjudicate Retry 6.

## Public boundary

The ordinary marker route remains held; `public_covered_count` remains 5; only
the validation-scale supplied-`Ginv` estimator remains covered. There is no
activation, promotion, merge, release, or G10 claim.

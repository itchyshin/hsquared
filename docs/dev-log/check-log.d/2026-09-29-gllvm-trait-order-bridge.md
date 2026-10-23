# GLLVM trait-order bridge follow-up, 2026-09-29

The live `gllvm-optin` bridge suite passed 87 assertions with zero failures,
warnings, or skips after adding numerical trait-permutation checks and strict
trait-name, correlation, and log-likelihood validation. The broader
`gllvm-optin|multivariate` filter completed with 320 passes and one existing
multivariate nonconvergence warning; its single GLLVM failure was the initial
1e-5 covariance tolerance. The measured difference was about 8e-5 relative
between two converged fits using the position-dependent default loading start.
With a 1e-4 relative comparison bound, the final focused live GLLVM filter
passed. The multivariate filter passed 101 assertions with one existing
nonconvergence warning, including the Unicode blank-name test. Julia's full
`Pkg.test()` passed before the final U+2028/U+2029 cases; the focused GLLVM
trait-effects suite passed after those cases. See
`docs/dev-log/after-task/2026-09-29-gllvm-trait-order-bridge.md`. Capability
status remains experimental and `public_covered_count` remains 7.

# 2026-11-04 PR 353 parity recheck

R source `d8275983a51804971366fa31793a15ac579b0986` was tested with Julia
source `8f58b13a616ef27a982bff4f2eff8f9558b39b86` and Julia 1.12.6.
With live bridge tests and bridge requirement enabled,
`testthat::test_local(filter = "^engine-parity-animal-model$", reporter =
"summary", stop_on_failure = TRUE)` passed 19 assertions with no skips.
The Julia manifest SHA-256 was
`f6d678a46c18c19345c151a4ea3c106e4c554db51a15ff8219d666acb70aef56`.
Hosted Ubuntu and Windows checks passed on the original PR head but skipped
the live test. New-head hosted checks remain pending.

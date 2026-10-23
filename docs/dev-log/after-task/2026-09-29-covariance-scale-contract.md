# FA/GLLVM scale-standardized covariance validation

## 1. Task goal

Prevent the R bridge from accepting invalid covariance payloads when trait
variances have very different units. Keep the existing FA/GLLVM scope and
public status unchanged.

## 2. Active lenses and agents

Noether provided the initial adversarial finding and independently reviewed
the fix. Rose checked whether result validation affected the public claim
boundary. No other subagent performed this slice.

## 3. Files changed

- `R/julia-bridge.R`
- `tests/testthat/test-gllvm-optin.R`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/check-log.d/2026-09-29-covariance-scale-contract.md`
- This report.

Other dirty candidate files were preserved. Exact R source hashes are in the
check shard.

## 4. Checks and outcomes

- Red focused `gllvm-optin` run: the two new negative tests failed because the
  old validator accepted both malformed covariance payloads.
- Green focused live `fa-optin|gllvm-optin`: 213 passed, 0 failed, 0 warnings,
  0 skips.
- `air format R/julia-bridge.R tests/testthat/test-gllvm-optin.R`: exit 0.
- `R CMD build --no-manual --no-resave-data .`: exit 0; vignettes built.
- Final `R CMD check --no-manual`: Status OK; testthat reported 3,768 passed,
  0 failed, 26 warnings, 47 skips. The warning and skip output reflects
  existing expected warnings and unavailable optional routes. CRAN and
  Bioconductor indexes were unreachable, but dependency checks completed from
  the installed library.
- `git diff --check`: exit 0.

Commands, platform details, archive hash, and exact source hashes are recorded
in the check shard.

## 5. Public claim audit

This change only tightens validation of Julia result payloads in the R bridge.
It does not add a fitting path or change user syntax. FA and GLLVM remain
partial/experimental; `public_covered_count` remains 7 and version remains
0.9.0. No release action occurred. Rose found no claim or status expansion.

## 6. Tests of the tests

Before implementation, both regression tests failed for the intended reason:
raw-scale covariance tolerances hid an indefinite standardized correlation
matrix and an asymmetric small-trait block. After the fix, both rejection
cases passed along with the live FA/GLLVM bridge suite and full package suite.

## 7. Coordination

Work was done on the existing R candidate branch. The lane preflight reported
a stale handover naming Cursor; the user-approved implementation plan and
existing scoped R lease authorize this Codex continuation. No files in the
Julia worktree were edited by this slice. The coordination board records this
local result and open review state.

## 8. What did not go smoothly

The initial validator used raw covariance scale for both symmetry and positive
semidefinite tolerances. Noether showed that one large trait variance could
mask defects among smaller traits. The first test run reproduced both
counterexamples. The validator now evaluates normalized covariance geometry.
Noether's independent review found no blocker and confirmed the semidefinite
GLLVM boundary remains supported.

## 9. Known limitations

This validates the shape and algebraic consistency of returned covariance and
correlation matrices. It does not establish statistical identifiability,
parameter recovery, calibrated inference, comparator equivalence, or broader
FA/GLLVM validation. Full hosted CI was not run. Optional dependency indexes
were unavailable. A dedicated mixed-scale underflow/overflow regression is
still absent.

## 10. Next actions

1. Continue the open FA/GLLVM acceptance gates and Julia engine review waves.
2. Keep automatic-rank selection as a separate usability follow-on; this slice
   retains the fixed-rank acceptance cells.

## 11. Goal status

This validation slice is locally verified. The overall HSquared twin
programme remains active and incomplete. No CRAN submission, Julia registry
submission, or public tag was created.

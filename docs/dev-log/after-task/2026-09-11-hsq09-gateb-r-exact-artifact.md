# After-task: 0.9 Gate-B R exact-artifact candidate

## 1. Goal

Freeze and independently verify one exact R 0.9.0 source artifact from the
assigned isolated candidate, without changing the public contract or executing
any Gate-B release action.

## 2. Implemented

The assigned clean source commit was frozen as `hsquared_0.9.0.tar.gz`, with a
retained SHA-256, size, and inventory. The package, reader site, as-CRAN source
artifact, and one exact R-to-Julia bridge parity cell were checked. Codex held
the narrow R lease; no subagents were used.

## 3a. Decisions and Rejected Alternatives

The source basis is `a1bd525e8594ccc346f43d7741eb37b1e7e112d2`. The rejected
alternative was rebuilding or replacing an artifact after a failed check. The
same frozen artifact was checked and its receipts retained; no seed, fixture,
or source was replaced.

## 4. Files Touched

Only evidence/check records and current-state documentation clarifications are
added to the isolated candidate. Package source, public API,
bridge fields, scientific fixtures, and rendered public files were not edited.

## 5. Checks Run

- `NOT_CRAN=false` local package tests: pass;
- exact R-to-Julia bridge parity cell against the fresh Julia candidate: pass;
- pkgdown check, build, and URL check: pass;
- frozen `R CMD check --as-cran --run-donttest`: pass with one expected
  new-submission NOTE;
- artifact hash, size, inventory, and forbidden-path scan: pass;
- Unlazy `G0`–`G8`: all pass;
- CRAN gate self-test/negative controls: pass.

## 7a. Issue Ledger

- `R-GATEB-SANDBOX-01` resolved: sandbox DNS and Julia-cache restrictions did
  not reflect package failures; the relevant checks were re-run with the
  documented local toolchain and retained logs.
- `R-GATEB-PORTABILITY-01` resolved: the final artifact-hash gate uses macOS
  `shasum -a 256`, not unavailable `sha256sum`.
- `R-GATEB-RELEASE-01` deferred: no external CRAN policy check, independent
  audit, fresh remote CI, PR replacement, merge, tag, registry action, or
  release occurred.

## 8. Consistency Audit

The candidate continues to describe 0.9.0 as an unreleased candidate. The
artifact evidence distinguishes local package correctness from CRAN acceptance
and from public release. No capability or coverage state was promoted.

## 6. Tests of the Tests

The artifact gate reconstructs the SHA-256, byte size, and tar inventory, then
rejects forbidden repository and local-state paths. The CRAN-gate self-test
exercises its fail-closed negative controls. The bridge check names the Julia
candidate explicitly instead of relying on a stale default project path.

## 9. What Did Not Go Smoothly

The sandbox initially blocked network-dependent package/cache operations, and
the macOS PATH lacks `sha256sum`. Re-running with the approved local toolchain
and using `shasum -a 256` resolved those environmental issues without changing
the source artifact.

## 10. Known Residuals

The one NOTE is a new-submission feasibility note. This is local/macOS evidence
only; it is not an external CRAN check, a fresh cross-platform CI result, a
Gate-B decision, or a release.

## 11. Team Learning

Freeze first, then make every subsequent check read and identify that exact
artifact. On macOS, use `shasum -a 256` in portable validation gates.

## 12. Cross-Product Coverage

The frozen artifact covers package tests, reader-site generation, a tarball
check, artifact integrity, and one live bridge cell. It does NOT cover a
scientific campaign, all R-to-Julia payloads, external CRAN infrastructure,
cross-platform CI, capability promotion, a PR merge, tag, registry action, or
public release.

## Next actions

Commit this local artifact receipt, then perform the independent paired
R–Julia public-claim audit. Only after that audit may replacement PRs be
considered; Gate B remains unexecuted.

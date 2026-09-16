# After-task — A21 C6 + r_am identity (A21 GAP)

**Date:** 2026-09-02
**Lane:** R (`claude/lane-h2-twin-20260901`)
**Active lenses:** Fisher, Noether, Falconer (perspectives)
**Spawned subagents:** none
**Checks:** `docs/dev-log/check-log.d/2026-09-02-h2-a21-c6-ram-identity.md`

## Goal

Close A21 C6 (name the two `m2` denominators; pin `direct_heritability()` to
`heritability()` `h2_direct`) and the A21 GAP (`r_am` identity test), without
touching the sibling-owned canon file or adding a `validation_status()` row.

## Files changed

- `docs/design/capability-status.md` — one sentence on each maternal fence
- `tests/testthat/test-direct-maternal.R` — fixture repair + three new tests +
  live identity assertion (skip-guarded)
- this report and the check-log shard

## Checks

`devtools::test(filter = "direct-maternal")` → **FAIL 0 / WARN 0 / SKIP 1 / PASS 67**.
Live `validation_status()` **21 / 4 covered**. Fence-prose guard proven to fail
when the two-effect sentence is stripped.

## Public-claim audit

No status word moved. `public_covered_count` stays **5**. The new sentences
distinguish two already-documented estimands; they do not promote the
experimental two-effect maternal leg.

## Tests of the tests

Mutation of `(no covariance)` → red on the prose guard; restored.

## Coordination

A4 (claims register) skipped — register treated as busy. C5
(`04-validation-canon.md`) landed on this branch as `529a5a2` by the sibling
and was not edited here. G-AG-5 still owner-gated.

## What did not go smoothly

The live identity assertion could not run here (no Julia project). It is
wired into the existing skip-guarded parity test.

## Known limitations

Julia-lane `r_am` identity still owed. Claims-register fences do not yet carry
the two-`m2` sentence.

## Next actions

Optional: copy the C6 sentence onto the register when A4 is free. Julia C4
identity test. No covered flip, no push from this slice.

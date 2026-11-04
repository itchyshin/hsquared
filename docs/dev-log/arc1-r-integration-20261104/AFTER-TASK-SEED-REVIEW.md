# Arc 1 seed-guard and evidence review

## 1. Goal

Review the outer32 and outer33 guard failures and prepare historical evidence
for private review by Szymek.

## 2. Implemented

Recovered the outer32 retained receipt and run files from Totoro, plus the
historical coordination board. Prepared and verified the v8 evidence bundle,
a portable no-fit replay, and the seed-guard review.

## 3a. Decisions and Rejected Alternatives

Leave both guards fail-closed until their source scope and consumed-key rules
are reviewed. Do not redact originals used for hash checks. Assumption: the
user's request to prepare sharing does not authorize sending the archive.

## 4. Files Touched

`CHECKPOINT.md`, `HANDOVER.md`, `SEED-GUARD-REVIEW.md`,
`portable_guard_replay.py`, and this report in
`docs/dev-log/arc1-r-integration-20261104/`. Local archives and replay receipts
are listed in the handover. No Julia guard code or retained source was edited.

## 5. Checks Run

The portable replay against Julia `927b8f11` reproduced the 8/9 outer33 guard
suite, passed its isolated positive control and observed outer32 collision
refusal. Tampered receipt and existing-output controls were rejected. The
v8 bundle and 1,000 retained audit-source hashes were independently verified.
The canonical outer32 admission hash matched its retained receipt. Exact
identities and commands are in the review and bundle.

## 6. Tests of the Tests

The positive fixture was verified before interpreting negative controls. A
changed receipt, duplicate context and tampered archive were tested as
rejections. The current outer33 different-key negative can be vacuous on
the failing full tree; the proposed rule requires a passing fixture first.

## 7a. Issue Ledger

Outer32 is a consumed failed attempt. Outer33 has five documentary mentions
where its historical guard pins one occurrence. A scanner currently counts
repeated literals on one line only once. These findings do not promote any
scientific gate.

## 8. Consistency Audit

The candidate audit's 1,001 hashes were checked against the recovered archive;
one is claimed for the remaining historical check log. The raw and canonical
admission hashes use different representations of the same recovered JSON.
Memory receipt: the hsquared route and lane preflight kept ownership and
R/Julia source identities separate. Golden Set: not run; no hub guard changed.

## 9. What Did Not Go Smoothly

The outer32 receipt and board were initially missing locally but were found on
Totoro. The admission file's raw hash initially appeared inconsistent until its
canonical JSON hash was independently verified. The original gate file is
still missing.

## 10. Known Residuals

The old whole check log, original Arc 1 gate file, original R maps and nine R
candidate paths remain unresolved. The full LOOP lane is not in the bundle.
The bundle contains machine paths and is not public or sent. Julia PR #498
still has failing checks and needs its own resolution.

## 11. Team Learning

A source-bound receipt can be valid even when later documentation invalidates
a strict occurrence guard. Preserve the evidence and use a non-vacuous
positive control before designing a narrow correction. Independent reviewers
checked outer32, outer33 and bundle integrity.

## 12. Cross-Product Coverage

Covered: no-fit guard replay, receipt identity and archive integrity. This does NOT cover fits, scientific gate admission, complete historical seed inventory,
merges, releases, or delivery of the private archive.

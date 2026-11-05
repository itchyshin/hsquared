# Arc 1 handover for Szymek

## Purpose and status

This is a review checkpoint for the Saturday discussion. The R work is a fresh
rebuild, not the original unpushed source identity. The branch is available at
`itchyshin/hsquared:codex/arc1-r-integration-20261104`. It is work in progress
and is not ready to merge. The Julia merge trial remains draft PR #498.

The reconstructed R source is based on R main `b68047717df1c88c8f943e19becc31e153896373`.
Julia transport checks use a clean export of trial commit
`927b8f11bba481e6d5adb6e65e6a1469b5dcd0ed`, with the copied Julia manifest
identified in `CHECKPOINT.md`. Current historical receipts do not validate the
rebuilt R source. Public covered count remains seven, v7 remains HOLD, and
G2–G8 remain open for these identities.

## Evidence available

The owner has a local portable evidence starter named
`arc1-szymek-evidence-20261104-v10.zip` under `~/local-scratch`.
Its SHA-256 is `3f39974db59873c1d6accc32fefe68d8b56b3b39e3ed9d6e6d5cecb39d120603`.
It contains the retained checkpoint and v29 Julia receipt, seven outer33 files
that match the trial branch's pinned hashes, and an archive of the source
files listed by the historical seed audit. The archive was verified on readback
against the candidate's SHA-256 `0efa941c2a6ae177012a03282bbeea03cd8bdd7dc8760165bcf23e7534324cd0`.
It contains 1,000 of 1,001 exact audit-listed files; the original whole-file
bytes of `docs/dev-log/check-log.md` remain unresolved. The original outer32
retained receipt and raw result were also recovered from Totoro. The copied
run-admission file has the canonical JSON hash named in the receipt; its
raw-byte hash is different because the encoding differs. The original Arc 1 `.unlazy` gate file is also missing.
The local ZIP has not been sent or published; it may contain machine paths.
The full LOOP evidence is not included.

The original v10/v11 R maps remain unavailable, and nine of their candidate
source paths remain unresolved. Matching the retained candidate comparison is
not proof of historical execution identity. The separate R preservation bundle
and its manifests remain on the owner's Mac.

## Seed-guard findings

A clean trial-source clone with the seven pinned outer33 files passed eight of
nine manifest-amendment tests. The positive exception test failed: its pinned
rule permits one source occurrence, but the current trial source has five
seed-context mentions. The pinned check-log line itself still matches. A
minimal positive control accepted the seven receipts and the pinned single
line, and the altered and duplicate controls were rejected. A replay script
and its receipt are included in the local evidence starter. The portable replay accepts a repository path and evidence archive path; it
requires a local Julia Git repository containing commit `927b8f11`. The
README in the bundle gives the command.
The current-source
guard therefore remains fail-closed.

The manifest validator also rejects a separate outer32 historical seed
collision. The outer33 evidence does not resolve that collision. Review the
outer32 receipt and the intended source scope before changing the policy; do
not remove historical records or broaden exceptions merely to make tests pass.

## Bridge checks and limitations

Profile transport and uncertainty error handling have passed focused no-fit
checks under Julia 1.10.12 and 1.12.6. A new no-fit test also checks selector
and bootstrap refusal paths that return before the Julia fitter is called.
The complete package suite, model-fit parity, Julia 1.12 fixture issue, and
scientific gates still require their own checks. Review the exposed
`__HSQ_NONE__` values in nested uncertainty attempts before changing sentinel
handling; this was observed in an unsupported-input probe.

## Landing state and next actions

CARRIED-OVER: `codex/arc1-r-integration-20261104`, because live-fit and
scientific checks remain open. Resume with this branch and the checklist in
`CHECKPOINT.md`; fetch the current remote head before deciding integration.
The source archives under `~/local-scratch` are local copies and must be
transferred by an approved route before Szymek can use them.

Other existing branches and the `.claude/settings.json` and `.cursor/hooks.json`
working-tree edits were not part of this handover. The landing gate reported
other unpushed branches; their owners and dispositions remain unchanged.
FINDINGS-OF-RECORD: historical seed-audit byte gaps and current seed-guard
conflicts are recorded in this handover and the branch checkpoint.

1. Review and safely transfer the evidence starter, then make the complete
   retained evidence accessible as appropriate.
2. Reconcile the outer32 and outer33 guard rules against the preserved records.
3. Review the R bridge and Julia trial together, address the known Julia 1.12
   fixture, then run authorized fit and full package checks on pinned sources.
4. Re-run any scientific gates only under their own approved protocol. Decide
   at the meeting whether Shinichi or Szymek continues each remaining part.

## PR #498 status

At trial head `927b8f11`, the Julia 1.10 Ubuntu and docs checks passed.
Julia 1.10 Windows failed in source-identity path handling, and the latest
Julia jobs on Ubuntu and Windows failed in the FA retry fixture. A focused
source-identity correction is pushed on
`codex/pr498-windows-identity-20261104`; its code change is commit
`db48d9754af1a6f9b06b304925a2022778e01174`. It passed no-fit source-identity
checks on macOS with Julia 1.10, 1.12 and 1.13 and still needs Windows CI.
The Julia 1.13 pass used a freshly resolved, version-matched manifest. The FA fixture and full fit-bearing checks remain open.

The reviewed source-identity and FA fixture corrections were subsequently
fast-forwarded into PR #498 at commit
`466053d24aa143f30caad97938eaea542de01a33`. The focused FA test file passed
249 assertions on Julia 1.10 and 1.13. The user authorized fit-bearing package
checks and the PR CI; the new CI result must be checked for that exact head.
The PR remains a draft and no scientific gate status changed.

A separate read-only CI review identified two additional Windows cross-drive
cases for review: the package-content symlink guard may fail to reject a
symlink to another drive, and the attempt runner may reject a legitimate
output directory on another drive. These are not confirmed causes of the
current CI failures. Native Windows symlink and cross-drive tests are still
needed before claiming complete Windows path containment.

The later trial head `976647b9ab7a666027a77f02e8f11aee838d9727` adds fixed
input data to the two version-sensitive optimizer tests, without changing
their assertions or thresholds. The full optimizer test file passed 668/668 on
Julia 1.10 and 1.13 locally. It also adds reviewed cross-drive path guards and
Windows CI regressions. The prior CI run had already failed on the optimizer
fixture and was superseded. Check CI for this new exact head before deciding
what remains. Native Windows symlink and real second-drive cases remain open.

A read-only Git comparison found no changes in `src/` or `Project.toml`
between the Julia source used for the earlier R transport checks
(`927b8f11`) and the current trial head (`976647b9`). Test and pipeline files
have changed; this comparison is not a rerun of the bridge or a gate pass.

The v10 bundle also contains the retained N80 profile input from Totoro and
the original export script. Independent readback verified all 16 bundle
manifest entries and the exported response, pedigree, design and row mappings
against the retained input. The input SHA-256 is
`95167a1e92d7dcadfa4b3fb5107d2ba6237e0cb85906091db7db89d263152377`.
This supports a portable test fixture, not a historical execution or gate claim.

PR #498 head `61d8a112de1d2e7f723017fe4718be4dbc449687` adds a
portable retained N80 profile fixture and a Windows line-ending fix in the
fake-engine test. The full profile test file passed 1,295 assertions on each
of Julia 1.10.12 and 1.13.3. Six line-ending and hook checks passed on Julia
1.10.12. The full local executor run exceeded its revised estimate and was stopped
without a result. PR CI was running at this checkpoint; check the current
exact head for its outcome. Windows symlinks and real
second-drive paths remain unverified. The PR is draft and scientific gates
remain open.

## Later PR and evidence update

Julia #494 and #485 have merged after focused checks and green PR CI. The
post-merge main checks passed for both. For #498,
CI passed at `61d8a112`, then preservation commit
`93fa199d64e8ceeec9160c5d29c9e07b3b961118` restored four original main
LOOP records, archived the exact original main gate index, corrected the gate
pointer, and made the Cursor hook path project-relative. The restored records
match their original Git blobs; new-head CI passed. The original ignored
Arc 1 ledger and v10/v11 R maps remain unavailable. The historical LOOP files
are not proof of the present Arc 1 state.

A synthetic no-fit probe also found that a prevalidated consumed key could be
started from two empty output roots. It mocked admission checks, so it does not
show that a historical candidate can run on the current source. See the local
`pr498-consumption-probe-20261104/REVIEW.md`; a shared, atomic spent-key fence
needs review before allowing further attempts. No historical identities, gates,
seeds or attempt counts were changed.

The local private evidence starter and the draft message have not been sent.

The v10 private bundle includes the synthetic consumed-key probe and its
review, with the mocked-admission limitation stated. Independent readback
verified all 16 members and archive paths. Its SHA-256 is
`3f39974db59873c1d6accc32fefe68d8b56b3b39e3ed9d6e6d5cecb39d120603`.
The bundle has not been sent.

Since that checkpoint, R #353 and Julia #495 have also merged; their
post-merge package checks passed. Julia #496 remains draft after its Windows
10-second performance check failed on both the original and corrected source
on fresh hosted runners. This establishes variability, not the cause of the
difference. The limit remains unchanged. Julia #488 remains reserved for
Shinichi's decision; its separate local decision brief records claim and
finite-objective review findings.

## Current Julia checks

Julia #496 now includes main through `c36c4f42` at PR head `5d21963a`.
A controlled Windows comparison with coverage and bounds checks took about
six seconds for both the original and corrected source, with one BLAS thread
and two Julia threads. It used direct project execution, not the full package
check, and does not establish why earlier Windows runs exceeded ten seconds.
The CI matrix now specifies those thread limits without changing the timing or
allocation assertions. Default Julia threads and multithreaded BLAS are not
covered by that matrix. Full CI is running on the updated PR. A small live
R–Julia Poisson bridge check passed on this head; this checks transport on one
fixture, not statistical calibration.

Julia #498 now includes the same main revision at `6e359c02`. Its package
configuration conflict was resolved by retaining the test dependencies from
both parents. Fresh CI is running on that head. The original source maps,
ignored Arc 1 gate ledger and authoritative spent-key mechanism remain open;
the earlier CI results do not establish the outcome for this new head.
Neither these updates nor the historical receipts grant scientific gate credit.

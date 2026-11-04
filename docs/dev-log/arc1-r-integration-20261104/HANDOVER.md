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
`arc1-szymek-evidence-20261104-v8.zip` under `~/local-scratch`.
Its SHA-256 is `63c951cb1b999eb21d57f3f0da96fbda9c340703f5091cbda357e9947f6ea229`.
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

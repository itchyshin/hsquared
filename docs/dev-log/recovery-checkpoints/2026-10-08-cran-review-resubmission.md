# CRAN resubmission checkpoint, 8 October 2026

## Scope

R hsquared only, version 0.9.0, public covered count 7. No numerical change,
capability flip, Julia edit or General registry action is authorized here.
User requested repair and resubmission after reading Konstanze Lauseker's review.

## Source and artifact

Generating clean source: 501c99c0ec6f9f8bb490590ca220eeb6cd3e34e6.
Branch: codex/cran-090-examples-review-20261008.
Worktree: /private/tmp/hsquared-cran-review-20261008.
Artifact:
/Users/z3437171/local-scratch/lanes/hsquared-cran-review-20261008-501c99c/artifacts/hsquared_0.9.0.tar.gz.
SHA-256: 850b36c3782c2af69412f620e14db3b087ba881e028374edf6c3b3bf0bdc8ecb.
Size: 919391 bytes. Entries: 278. Comments remain excluded.

Prior candidate 54c4c8a1 is superseded, even though its full local check passed.
Do not substitute an older tarball, including the September candidates.

## What changed

All three disabled extractor examples now run normally using labelled synthetic
result objects. DESCRIPTION now describes implemented Gaussian pedigree models,
with AI-REML attributed only to univariate fitting, and retains uncalibrated
interval warnings. Three metadata tests no longer require release bookkeeping
inside DESCRIPTION. Example regression checks execute the generated Rd blocks.
Pat's coefficient-format and return-type findings were repaired before refreeze.

## Review and maturity

Rose, Grace and Pat each approved the final archive's content. All three still
withhold overall readiness while platform and lineage gates remain open.
Do not assert that planned or partial public routes are fully developed.
The proposed CRAN response distinguishes implemented Gaussian interface scope
from future work and retains the documented experimental and inference limits.
CRAN decides whether this scope clarification meets its publication-quality bar.

## Open gates

The final local check passed with 0 errors, 0 warnings and 1 new-submission NOTE.
It recorded 2644 test passes, zero failures, 166 skips and five test warnings;
those test warnings are not R CMD check WARNINGs. Its log is in
/private/tmp/hsquared-cran-review-refrozen-20261008/hsquared.Rcheck/00check.log.
Its console log is /private/tmp/hsquared-cran-review-refrozen-check.log.
Win-builder R-devel accepted the exact 919391-byte file on 8 October at about
18:30 Edmonton time. The screenshot receipt is saved at
/Users/z3437171/.codex/visualizations/2026/09/25/01a0d9e6-3028-7e20-9ead-ac70cb98a8c2/hsquared-winbuilder-upload-20261008.png.
New exact-tarball Windows result evidence is not yet available. The public annotated
v0.9.0 still identifies prior submitted 0cdfb783. No tag movement occurred.
Current origin/main contains later features and must not replace this candidate.
The release-branch exception, updated comments attachment source, and retargeting
v0.9.0 require the maintainer's explicit decision before upload.

The original action-time Submit and email-confirmation gates remain in effect.
No CRAN upload, resubmission, confirmation or reply occurred in this repair run.

## Landing State

CARRIED-OVER: the implementation commits and later release-evidence records are local and unpushed on
codex/cran-090-examples-review-20261008. They are not on main. This preserves
the exact previous release scope without reverting main's post-release work.
Other branches and the dirty Dropbox checkout belong to other work and must
remain untouched. Handoff gate reported these unlanded states explicitly.

Resume: inspect git status in the worktree, verify the artifact checksum, read
the completed final check and new Win-builder email in Codex's in-app browser,
then obtain the source/tag decision. Refresh the exact-artifact readiness panel
and executable release ledger before preparing CRAN's form.

FINDINGS-OF-RECORD: none. This is a release repair, not new scientific evidence.

## Prose assessment

Self-review, 8 October 2026: 2/10 perceived AI-like style, moderate confidence.
Entire checkpoint reviewed. Facts and science limited to recorded checks and
the independent audits; reference identity is unchanged. No personal voice mode.

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
New exact-tarball Windows result evidence is not yet available as of 18:41
Edmonton time. On 8 October the maintainer explicitly approved the release-branch
exception, branch-sourced comments attachment, and retargeting v0.9.0 to 501c99c.
The public annotated tag is now 48a483f0991e52cbb3499998efed3d111d51d76c,
peeling to 501c99c0ec6f9f8bb490590ca220eeb6cd3e34e6. The replacement push used
an exact lease against prior annotated object 8a695074337a6d1cdee719a5594fe91028082b1e;
git ls-remote verified the published result. This is the R repository only.
Current origin/main contains later features and must not replace this candidate.
The source and tag approval gate is closed. The maintainer also authorizes a
factual reply to Konstanze after actual CRAN resubmission, not before it.

The original action-time Submit and email-confirmation gates remain in effect.
No CRAN upload, resubmission, confirmation or reply occurred in this repair run.

## Additional release checks

On 8 October pkgdown::check_pkgdown() completed with no problems found.
The first full local site build stopped because the sandbox could not resolve
cloud.r-project.org and denied the normal sass cache. The authorized rerun
completed with exit status 0 and finished its problems check. The repaired
random-regression page was visually inspected in Codex's browser; its synthetic
example output, coefficient labels, return types and limits render correctly.
Preview: /private/tmp/hsquared-cran-review-20261008/pkgdown-site.
Screenshot: /Users/z3437171/.codex/visualizations/2026/09/25/01a0d9e6-3028-7e20-9ead-ac70cb98a8c2/hsquared-release-preview-20261008.png.
No public site deployment was made. Pandoc printed deprecated math-option
notices, not package-check warnings. The frozen tarball checksum is unchanged.

Grace independently inspected the exact archive's installed test log and the
unchanged bridge and setup code. Executed tests cover unavailable local engine
errors, conservative availability checks, engine="validate", and required-bridge
failure handling. Julia setup disables automatic installation. The exact archive
installs, loads, and runs its examples without Julia. This is evidence for an
unavailable local backend only, not network isolation or live R-Julia fitting.
Evidence: artifacts/testthat-macos.Rout and artifacts/00check-macos.log in the
frozen artifact directory above. Live engine tests remain explicitly skipped.

## Landing State

CARRIED-OVER: the implementation commits and release-evidence records through
a18b6ec3a484e623045629b8e61c18d4759b9bd5 are pushed on
codex/cran-090-examples-review-20261008. They are not on main. This preserves
the exact previous release scope without reverting main's post-release work.
Other branches and the dirty Dropbox checkout belong to other work and must
remain untouched. Handoff gate reported these unlanded states explicitly.

Resume: inspect git status in the worktree, verify the artifact checksum, read
the completed final check and new Win-builder email in Codex's in-app browser,
then inspect the actual new Windows log. Refresh the exact-artifact readiness panel
and executable release ledger before preparing CRAN's form.

FINDINGS-OF-RECORD: none. This is a release repair, not new scientific evidence.

## Prose assessment

Self-review, 8 October 2026: 2/10 perceived AI-like style, moderate confidence.
Entire checkpoint reviewed. Facts and science limited to recorded checks and
the independent audits; reference identity is unchanged. No personal voice mode.

# Arc 1 R integration checkpoint

Status: work in progress. This branch is not ready to merge.

The R candidate is a fresh reconstruction, integrated onto R main at
`b68047717df1c88c8f943e19becc31e153896373`. It is a new source identity.
Nine original candidate-map files and both original maps remain unavailable.
The existing candidate maps are pending independent inventory review. Prior
G6/G7 receipts do not apply to this reconstruction.

The Julia Arc 1 engine remains on a draft branch. The combined bridge has not
been exercised with a model fit against it. R documentation generation and a package source
build succeeded. The focused reconstruction and Arc 1 control tests passed
without model fits. The full test suite, bridge tests, `devtools::check()`, and
scientific gates remain open. No covered status was changed.

An explicit `max_dense_cells` override is refused for Arc 1 FA selection:
the Julia handover branch accepts the keyword on its policy path but does not
use it. This refusal does not establish that the policy path has a default
dense allocation cap.

For Szymek: the remaining work includes reviewing the reconstructed R layer,
reconciling the Julia engine and its missing text evidence, running the full
bridge checks against the chosen engine identity, and rerunning G6/G7 on the
resulting source identities before making any gate claim. This checkpoint does
not ask you to merge or take over the work.

## Additional no-fit checks

`HSQUARED_JULIA_PROJECT=/nonexistent HSQUARED_AUTO_FA_REQUIRE_LIVE=false Rscript -e 'testthat::test_local(filter = "^arc1-uncertainty-controls$|^auto-fa-rank-optin$", reporter = "summary")'` passed after updating stale mocked profile evidence and expected error text. Three live Julia tests were skipped. The earlier run failed because the mocks targeted an older sink helper and used an incomplete profile record.

The original Julia checkpoint and its v29 Julia test log and receipt were found on the owner's Mac. Their archived bytes match their recorded SHA-256 values. This three-file local subset is not the complete LOOP evidence, and the historical receipt does not validate this R branch. The original Arc 1 `.unlazy` gate file was not found at the expected path.

## Live no-fit bridge checks and recovered outer33 files

On R commit `4bd90f8e1ab1b0413210252a5b1ee8720e1861c7`, two focused
`testthat::test_local()` runs passed against an exported Julia merge-trial
source at commit `927b8f11bba481e6d5adb6e65e6a1469b5dcd0ed`, under Julia
1.10.12. The filters were `^arc1-profile-v4-transport-isolation$` and
`^arc1-uncertainty-controls$`. They exercised JuliaCall transport and error
retention, not model fitting. The Julia project used a copied, previously
untracked Manifest.toml with SHA-256
`421dbda588a1ad70aa82c433fa97f172286d6f0da7076b5b9c5ac7638615e2ad`;
the source Project.toml hash is
`93422d9228f3e2d6c5170e2b6055bf8bccf6bef59f4189edfa9f68adbe32af5d`.
These are transport checks, not live-fit parity or G6/G7 evidence.

Seven outer33 evidence files missing from Szymek's checkout were located and
matched against the hashes pinned in the Julia merge-trial `arc1_manifest.py`.
They were packaged locally and read back successfully; the archive SHA-256 is
`1a29f5958d740149d2d68e4fd628741e7d16b033e59259559e49f3e6257934b8`.
They are a subset, not the complete LOOP archive or a fresh admission.
The original Arc 1 gate file remains missing.

The historical audit embedded in the recovered candidate lists 1,001 source
paths. A read-only byte comparison found 995 matches and six changed paths in
the handover checkout, and 992 matches and nine changed paths in the exported
merge trial; no listed paths were missing in either comparison. This compares
only the paths recorded by that historical audit. It does not reproduce the
audit, establish the full consumed-seed set, or authorize any new run.

A follow-up search of up to 200 all-ref commits per changed path found the
historical bytes for five of the nine changed merge-trial paths. They were
archived and independently read back; the archive SHA-256 is
`b363a8eeceb2e9bbd9023207cc7da921b8fbed475fdaae47ee3b68480fdac5b1`.
Four paths had no match within that bounded search: `docs/dev-log/check-log.md`,
`docs/dev-log/coordination-board.md`, `test/arc1_simulation_executor.jl`, and
`test/runtests.jl`. No claim is made about unsearched history or whether any
other local copy exists.

The same two no-fit test groups also passed under Julia 1.12.6 with the same
exported source and copied manifest. Julia reported that one dependency was
precompiled while a different version was loaded; the test process completed
successfully. This does not resolve the separate Julia 1.12 fit-fixture failure
reported in the handover.

A local portable evidence starter combines the verified subsets and search
reports. Its SHA-256 is
`41f9d59589502a71f8a801dc4f2cc18afb2002a25351bf70c2438d03f627c005`.
The complete LOOP records, original Arc 1 gate file, historical source gaps,
and current-source scientific checks remain open.

## Subsequent evidence and preflight checks

An additional source-archive search recovered the original `test/runtests.jl`
and `test/arc1_simulation_executor.jl`. The latest audit-source archive has
999 of 1,001 exact hashes; the remaining whole-file gaps are the historical
check log and coordination board. Its SHA-256 is
`061da2fa1c8be0d83b594e5b6fbcd097c2b74b178aa7e241eac713a4ee87fd07`.
The verifier and negative controls are in this directory.

The current Julia trial with seven matching outer33 receipts still fails one
of nine manifest-amendment tests because the pinned single seed occurrence is
now mentioned in five tracked contexts. An isolated positive control passed;
the validator independently refused an outer32 historical collision. The
replay and receipt are in the local v4 evidence starter. These findings leave
both guard policies open for review; no historical records were changed.

A no-fit live selector test exercises two policy refusals and the bootstrap
outer-selection failure under Julia 1.10.12 and 1.12.6. The Julia preflight
rejects those inputs before fitting. The bootstrap result contains one
`not_run_after_outer_selection_failure` record and zero usable bootstraps.
A review also observed `__HSQ_NONE__` values in nested attempt data; their
public presentation needs review before changing the transport encoding.

## Further recovery and guard review

The original outer32 retained receipt was recovered from Totoro and matches
SHA-256 `2a9e51019b10c1d72a3bbd642ec821a37abb40627f5b2f7f62d889edc1188cf4`.
The retained result and three other run files were also verified. The
historical coordination board was recovered, giving 1,000 of 1,001 exact
audit-listed files; the old whole check log remains missing. The updated
private evidence bundle is `arc1-szymek-evidence-20261104-v10.zip`, SHA-256
`3f39974db59873c1d6accc32fefe68d8b56b3b39e3ed9d6e6d5cecb39d120603`.
`SEED-GUARD-REVIEW.md` records the evidence and narrowly scoped correction
options. The portable replay reproduced the 8/9 guard result and positive
control without fits. Its negative controls rejected a tampered pinned receipt
and an existing output path. No guard policy was changed.

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

#494 and #485 merged. #494 post-merge main CI passed; #485 post-merge CI passed. #498 CI passed at `61d8a112`; its later preservation head is
`93fa199d64e8ceeec9160c5d29c9e07b3b961118`, whose CI passed. It restores
four main LOOP files and archives the prior main gate index byte for byte.
The original ignored Arc 1 ledger remains missing. A synthetic, mocked-admission
no-fit probe showed that the same key can be started from distinct empty output
roots; it does not establish historical re-execution. The local probe review
records the proposed fail-closed requirements. No gate, seed or attempt count
was changed.

The v10 private bundle includes the synthetic consumed-key probe and its
review, with the mocked-admission limitation stated. Independent readback
verified all 16 members and archive paths. Its SHA-256 is
`3f39974db59873c1d6accc32fefe68d8b56b3b39e3ed9d6e6d5cecb39d120603`.
The bundle has not been sent.

R #353 and Julia #495 have since merged and passed their post-merge package
checks. Julia #496 remains draft with its unchanged Windows timing check red;
the pre-fix source also failed that check on a fresh hosted runner. Julia
#488 remains held for Shinichi's decision.

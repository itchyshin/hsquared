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

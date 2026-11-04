# Arc 1 R integration checkpoint

Status: work in progress. This branch is not ready to merge.

The R candidate is a fresh reconstruction, integrated onto R main at
`b68047717df1c88c8f943e19becc31e153896373`. It is a new source identity.
Nine original candidate-map files and both original maps remain unavailable.
The existing candidate maps are pending independent inventory review. Prior
G6/G7 receipts do not apply to this reconstruction.

The Julia Arc 1 engine remains on a draft branch. The combined bridge has not
been exercised against it. R documentation generation and a package source
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

# Draft for Szymek

Hi Szymek,

I have recovered most of the Arc 1 evidence and prepared a private bundle for
us to review on Saturday. The bundle includes the retained outer32 and outer33
records and 1,000 of the 1,001 files listed in the historical seed audit. The
remaining whole-file check log, the original Arc 1 gate file, and the original
v10/v11 R maps are still missing.

Outer32 was a failed, consumed attempt and remains counted once with no gate
credit. Outer33's pinned receipts match, but the current guard sees five later
documentary mentions where its old rule expects one. I have left both guards
fail-closed and included a portable replay and suggested review points.

The rebuilt R layer is on `codex/arc1-r-integration-20261104`. It has a new
source identity and does not inherit the old G6/G7 results. For Julia
[PR #498](https://github.com/itchyshin/HSquared.jl/pull/498), I have updated
the Windows source-identity check and the FA retry fixture. The focused tests
pass locally on Julia 1.10 and 1.13; the new CI is running. The PR remains a
draft.

Let's review the remaining seed-guard rules, the evidence transfer, and who
continues each piece when we meet. No merge or scientific gate claim has been
made.

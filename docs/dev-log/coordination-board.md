# Coordination Board

| Date | Lane | Owner | Branch | Files / surface | Status | Blocker | Next action |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-06-12 | coordinator | Ada/Shannon | main | AGENTS, design docs, dev-log, GitHub ledger | complete | none | open Phase 1 contract work when ready |
| 2026-06-12 | R | Emmy/Boole/Hopper | main | R package placeholders/tests | complete | no fitted engine yet | start formula grammar issue #4 |
| 2026-06-12 | Julia | Gauss/Karpinski/Noether | twin thread | HSquared.jl package | complete on main | none | start sparse pedigree issue in Julia repo |
| 2026-06-13 | R | Emmy/Boole/Hopper/Grace/Rose | main | animal formula parser, pkgdown, genomics/GPU plan | partial | no fitted bridge yet | push Phase 1A and start bridge payload issue #6 |
| 2026-06-13 | Julia | Gauss/Karpinski/Noether/Grace | twin thread | pedigree inverse utilities, Documenter, genomics/GPU roadmap | active | R bridge payload pending | keep Julia docs and R contract mirrored |
| 2026-06-13 | R | Hopper/Lovelace/Emmy/Grace/Rose | main | internal bridge payload for issue #6 | pushed; CI/pkgdown/Pages passed | no live Julia execution | ask Julia twin to align `animal_model_spec()` docs/tests |
| 2026-06-13 | R | Emmy/Pat/Fisher/Rose/Grace | main | fitted object and extractor contract for issue #5 | local checks passed | no real Julia result yet | push extractor contract and watch CI |
| 2026-06-13 | R | Emmy/Jason/Darwin/Pat/Rose | main | `hs_data()` data container for issue #8 | local checks passed | no file-backed storage | push data container and watch CI |
| 2026-06-13 | R | Hopper/Lovelace/Grace/Rose/Pat | main | internal JuliaCall bridge smoke for issue #6 | local checks passed | not public fitting | push smoke path and watch CI/pkgdown |
| 2026-06-13 | R | Hopper/Lovelace/Emmy/Grace/Rose | main | opt-in `hs_control(engine = "julia")` for issue #6 | local checks passed | dense tiny path only | push opt-in engine and watch CI/pkgdown |
| 2026-06-13 | R | Fisher/Pat/Emmy/Hopper/Rose | main | PEV/reliability extractor contract for issues #5/#6 | local checks passed | not in live payload yet | push extractor contract and watch CI/pkgdown |
| 2026-06-13 | R | Hopper/Lovelace/Karpinski/Grace/Rose | main | sparse `Z` CSC marshalling for issue #6 | pushed; CI/pkgdown/Pages passed | production fitting still planned | start validation issue #7 |
| 2026-06-13 | R | Curie/Fisher/Gauss/Jason/Rose | main | tiny Ainv validation fixture for issue #7 | pushed; CI/pkgdown/Pages passed | Mrode/comparator validation still planned | hand off fixture to Julia twin |

Shared files are one-lane-at-a-time edits. The Julia twin should not edit this
R repository unless Ada/Shannon explicitly reassign the lane.

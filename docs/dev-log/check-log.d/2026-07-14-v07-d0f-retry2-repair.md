# 2026-07-14 — v0.7 D0F retry-2 blocker and prospective retry-3 repair

- Retry-2 is preserved as an unadjudicated replay-infrastructure blocker:
  576 official fits, 576 base-R recomputations, zero Julia replay rows.
- Repaired concrete Julia command typing and added the exact `SubString` root
  regression.
- Added a zero-seed `preflight` command that must execute the sealed-tree and
  exact Julia Git/blob checks before retry-3 smoke or official fitting.
- Retired both prior 576-seed D0F spaces and both bootstrap spaces; retry 3 is
  disjoint at phenotype/bootstrap bases `2034000000` / `2035000000`.
- Hardened the prospective D2-D4 contract across schemas, histories, counts,
  reviews, canonical paths, exact sidecars, Git blobs/HEAD/ancestry/cleanliness,
  and unchanged fitted implementation surfaces.
- Checks: R tooling 52, preseal 218, downstream 156 all PASS; standalone R and
  Julia selftests PASS; full Julia `Pkg.test()` PASS; built-package R check
  0 errors / 0 warnings / 0 notes; sidecars and diff checks PASS; Fisher,
  Grace, and Noether `CLEAN`.
- No recovery, routing activation, capability/count change, G10, release, or
  GitHub Actions campaign occurred.

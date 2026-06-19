# Overnight progress report — hsquared R lane (2026-06-18)

Autonomous session while the maintainer was away. Lane: **R** (`hsquared`);
`HSquared.jl` cross-referenced **read-only** (zero twin edits). Everything below
is verified green and **committed locally** — **nothing pushed** (your call;
with the new CI policy, pushing `main` triggers only the pkgdown deploy).

## Headline

Built a live mission-control board, ran the team through **five adversarial
review passes** (two broad + one deep + a validation-backbone numerical
cross-check + a cross-document consistency audit), fixed every R-safe finding in
parallel ultracode waves, shipped a fact-checked **honest validation-evidence
article**, and re-scouted the Julia twin to pin the single highest-leverage
unblock.

- **~35 review findings resolved** (12 first-pass + 10 second-pass + 8 deep-pass
  + 4 validation-backbone + 1 cross-doc contradiction) across **14 commits**;
  1 rejected as a false positive (#23 "dead code" is the live default-fit path),
  maintainer-call items left flagged-not-done (#6 `loadings()`, version bump,
  #20 `validate`-returns-spec).
- Package green throughout: `devtools::test()` **753 pass / 0 fail / 0 warn /
  32 skip**, `devtools::check(--no-manual)` **0/0/0**, `check_pkgdown()` clean.
- **New:** a `Validation evidence` pkgdown article — the honest, single-source
  answer to *"what does `hsquared` mean by validated, and what is the actual
  evidence?"* Every concrete number and test-name in it was independently
  fact-checked against source (all confirmed), Rose-audited for over-claims
  (clean), and Pat-clarified for the applied-scientist reader.
- **Breakthrough (still twin-gated):** **PR #17 (`phase4b-factor-analytic-g`)**
  remains the one move that unblocks genuinely-new R capability — the
  structured-covariance engine API the R lane reserves. Re-scouted at end of
  session: `HSquared.jl` `origin/main` is **unchanged at `abf777d`** and PR #17
  is **still DRAFT/unmerged**. R cannot self-merge; this waits on the Julia lane
  / maintainer.

## Commits on `main` (local, unpushed) — 14

1. `3eaaf08` Fix review honesty findings and surface engine setup in the fit error
2. `3aaa7cd` Add engine-setup onboarding docs and retire static mission-control article
3. `7c54e28` Align CI triggers with policy, clarify recovery-evidence locus, add negative controls
4. `53994f0` Document engine target menu and generalize the boundary flag
5. `e802536` Add overnight progress report
6. `cd5d660` Record twin coordination scout report and engine-contract honesty handoff
7. `0ffa4bd` Fix ten second-pass review findings (parser, multivariate, examples, docs)
8. `3399c4a` Finalize overnight progress report
9. `13b52aa` Harden parser, pedigree sort, and boundary diagnostics (deep-pass fixes)
10. `11114e6` Update overnight progress report after the deep-pass fixes
11. `bd53dad` Record clean adversarial self-review of the session fixes
12. `99e755e` Harden validation reference solver and add an independent pedigree MME anchor
13. `127ddf9` Add honest validation-evidence article and register it in pkgdown
14. `4e4d52d` Fix DGP recovery status drift and clarify the validation-evidence article

## What's better now (user-visible)

- **Onboarding works end-to-end**: README + Getting-started vignette show how to
  register `HSquared.jl`; the install error names `HSQUARED_JULIA_PROJECT` /
  `engine_control$julia_project` + the clone + the validate fallback; runnable
  Julia-free examples on the inspection functions.
- **Honest, robust diagnostics**: Julia fit-target reported from one source of
  truth; planned-marker error points to `formula_status()`; the boundary flag
  fires for genomic/single-step/residual/second-effect boundaries **and** now
  distinguishes a negative (inadmissible) variance from a benign near-zero one.
- **Parser hardened (deep pass)**: named errors instead of cryptic base-R leaks
  for single-level/zero-row factor fixed effects, `offset()`, a bare `.`, and
  derived `cbind()` columns (the last previously produced a *wrong* trait label);
  the pedigree topological sort is now iterative (deep pedigrees no longer
  stack-overflow or get misreported as cycles).
- **Honest claims**: package landing page / README / model-status no longer
  under-state the shipped opt-in multivariate/genomic paths; engine-recovery is
  attributed to local validation vs public CI; `?hs_control` documents the
  target menu.
- **Stronger validation**: negative-control test-of-tests, an independent
  hand-built MME PEV/reliability anchor, and dedicated parser/boundary edge-case
  suites. CI policy aligned to PR + workflow_dispatch; release hygiene done. The
  reference REML solver no longer crashes at the `h²→1` singular-V boundary
  (returns a non-converged code, not a raw `chol()` error); an independent
  hand-built lambda-form MME anchor on the real 12-animal pedigree closes the
  last self-generated-number circularity.
- **A canonical validation-evidence article**: `vignettes/articles/
  validation-evidence.Rmd` lays out the evidence weakest-to-strongest (gryphon
  anchor → known-truth DGP recovery → external-package agreement →
  supplied-variance Henderson/Mrode fixtures → independent hand-built MME anchors
  → nadiv pedigree-inverse comparator → negative controls), the public-CI-vs-local
  split, and an explicit "Honest boundaries" section. Every number was
  fact-checked against source and every cited test verified to exist.
- **Claim-surface consistency fixed**: the cross-document audit caught one real
  contradiction — `validation-debt-register.md` marked the known-truth DGP
  recovery `partial` while `validation_status()` (the named source of truth) and
  `capability-status.md` both mark it `covered`; the register also carried a
  stale "single h²=0.4 setting" note contradicting its own grid evidence. Both
  fixed toward the source of truth. No code change (status was already `covered`
  in `validation_status()`).

## Twin coordination (read-only) — see `2026-06-18-twin-coordination-report.md`

- `HSquared.jl` `origin/main` = `abf777d`; Phases 1-4 on main; the R surface is
  consistent with main (no overlap; the deep-fix wave left the pedigree
  parent-index semantics byte-identical, so the engine/bridge need no change).
- **PR #17 is the unblock** (clean FF, green). On landing, the ready R slice
  lifts the `genetic_structure` guardrail and surfaces `cov = diag()/lowrank()/
  fa()` + loadings/specific-variance/latent-BV/eigen-G. **R must not self-merge.**
  Re-scouted at end of session (`git fetch` only): `origin/main` still `abf777d`,
  PR #17 still DRAFT — no movement, nothing new to act on in the R lane.
- Phase 5 GWAS/QTL/eQTL tower (#18-#35): 16 stacked draft PRs, no CI, #28
  conflicting — **not landable** until restructured (split the fixed-effect
  single-marker GWAS path off first).
- `docs/design/03-engine-contract.md:277` "250-animal" claim — **handoff
  recorded** for the Julia lane (the validation ladder itself is already fixed
  on main). Twin multivariate recovery calibration unmet on predeclared seeds —
  R already labels multivariate `partial`, so the claim stays honest.

## Maintainer items — now DONE (authorized "do all these")

All five R-lane maintainer decisions were authorized and completed, each
implemented → 5-lens adversarially reviewed → verified green → pushed:

- **v0.1.0 cut** ✅ DESCRIPTION `0.0.0.9000` → `0.1.0`, NEWS heading, man/.
- **`engine = "validate"` returns the spec** ✅ (#20) messages + `invisible(spec)`
  (no longer `stop()`); the review caught and fixed a mis-pointed `model_spec()`
  hint.
- **`loadings()` → `genetic_loadings()`** ✅ (#6) `stats::loadings` shadow gone;
  aligns with the `genetic_*` family.
- **Mrode 3.1 published anchor** ✅ — research lens established (3 citable sources
  + independent re-solve) that the published EBVs are honestly pinnable, then a
  CI-runnable fixture + test pins the solver to Mrode 2014 p.39 digits (~5e-9).
- **Pushed** ✅ 18 commits `3666363..b0153aa`; **CI green at the release commit**
  (R-CMD-check dispatch success, pkgdown deploy success, site HTTP 200).

**Still needs you — the one item I could not do (harness-enforced):**

- **`03-engine-contract.md:277` twin doc fix.** The harness blocked the R lane
  from editing `HSquared.jl` (read-only boundary), and the twin has an **active
  Julia session mid-edit on a design doc** — so I did not push into it. The fix
  is ready to apply (one sentence; the doc is not in the Documenter build):
  replace `…matches the observed information (ratio ~0.99 on a 250-animal
  simulation), so…` with `…matches an independent finite-difference Hessian of
  the REML log-likelihood (observed information) to within ~8% on the committed
  tiny fixture (`test/runtests.jl`), so…` — backed by the committed
  `test/runtests.jl:1814-1824` (`isapprox(Matrix(info), Hobs; rtol = 0.12)`).

## How to resume (any session)

```sh
python3 .mission-control/serve.py   # live board at http://127.0.0.1:8781/
```

Durable memory: `docs/dev-log/coordination-board.md`, `check-log.md`,
`2026-06-18-finish-readiness-punchlist.md` (44 findings across three passes),
`2026-06-18-twin-coordination-report.md`, this report; `ROADMAP.md`,
`docs/design/capability-status.md`.

**Bottom line:** `hsquared` **v0.1.0 is released** — pushed, CI-green at the
release commit (`b0153aa`), site live. Every R-safe review finding (five passes)
is resolved, the honest validation-evidence article is shipped and audited
consistent, all five authorized maintainer items are done, and the external
Mrode-canon validation gap is closed. The only open item is the one I am
harness-blocked from doing (the `HSquared.jl` engine-contract doc reword — exact
fix above, for the Julia lane). Further *capability* remains gated on the twin
(land PR #17, factor-analytic G).

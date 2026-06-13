# Honesty pass + v0.1 promotion predicate

Date: 2026-06-13

Active lenses: Rose, Pat, Fisher (adversarial verification, run as a workflow);
Ada/Shannon coordinating. Spawned subagents: yes — two background workflows
(`twin-finish-audit`, 6 agents; `honesty-slice-verify`, 4 agents).

Current lane: R (hsquared) + coordinator (shared design doc).

## Goal

The user is away and asked the autonomous run to finish the packages honestly. A
6-agent audit of both repos found the v0.1 fit gate genuinely closed and not
openable autonomously (the two blocking items are twin-owned and need maintainer
decisions). The highest-value SAFE work it surfaced was an honesty pass plus
binding the gate — all R-lane / coordinator docs, no twin conflict, directly
serving "no unsupported claims."

## What changed

- `README.md` — reworded the fitted-object extractor-contract paragraph from
  present-tense "now includes ..." (a genuine skim-overclaim) to a
  future-contract framing, with "the default `hsquared()` call computes none of
  these: it validates and stops" as the closing beat; added a caveat that the
  validation atoms check engine arithmetic, not estimation.
- `vignettes/articles/mission-control.Rmd` — refreshed the stale validation-row
  metric (11 → 14); requalified the "0 ... AI-REML" metric card and the
  "Blocked Claims" bullet so they no longer contradict the live experimental
  opt-in `sparse_reml`/`ai_reml` bridges (capability-status rows 26–27).
- `vignettes/articles/model-status.Rmd` — front-loaded the "not general
  variance-component estimation" limit on the `sparse_reml` and `ai_reml`
  bullets; added a framing sentence under "Exists now" so the scaffold/opt-in
  surface cannot be skimmed as a current estimation capability.
- `docs/design/01-v0.1-contract.md` — added a binding **V0.1 Promotion
  Predicate** (default fit stays validate-and-stop until twin `V1-MRODE-FIT` and
  `V1-COMPARATORS` are covered/covered_external and an estimator row is covered
  with replicated DGP-recovery evidence, with a minimal-rigor floor and a
  boundary/identifiability clause), plus an **Uncertainty Scope** section
  (SE/intervals out of v0.1; `accuracy()` = sqrt(reliability); the item-3
  promotion accuracy is the simulation-only cor(EBV, true BV), distinct from the
  shipped `accuracy()`).

## Method

Audit workflow → honest backlog + minimal gate path. Edits implemented, then an
adversarial review workflow (Rose/Pat/Fisher) returned `safe_to_commit: false`
with three must-fixes (a self-contradiction the edits sharpened, two skim-overclaim
risks) plus medium predicate-rigor gaps. All were applied before commit.

## Verification

- `pkgdown::build_articles(lazy = FALSE)` + `pkgdown::check_pkgdown()`: rebuilt;
  "No problems found."
- `rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))`: 0 errors,
  0 warnings, 1 note (benign new-submission/dev-version).
- Docs-only slice; no R code changed.

## Twin-lane finding (BLOCKING for any future promotion; needs the Julia thread)

Independently verified (read-only grep of the twin): the twin's `V1-AI-REML`
evidence string at `HSquared.jl/src/validation_status.jl:97` claims "its AI
matrix matches the observed information (ratio ~0.99) on a 250-animal
simulation." No such test exists — `250` and any observed-information/ratio check
appear only inside that string. The actual AI-REML test
(`HSquared.jl/test/runtests.jl:1496-1530`) checks target/provenance/convergence
and that a second start reaches the same optimum (optimizer reproducibility) —
exactly the evidence the new predicate declares insufficient.

Action: the Julia lane (Gauss/Karpinski) should either add the real 250-animal
recovery test or downgrade the string to what the 8-animal test shows. Rose must
block any promotion that cites this row until resolved. (I attempted to file a
GitHub issue on `itchyshin/HSquared.jl`; the action was denied by the permission
classifier — not autonomously authorized to publish issues under the user's
identity. Recorded here and on the coordination board instead, for the
maintainer/twin thread to action.)

## Decisions waiting for the maintainer (do not pick silently)

A second workflow (`gate-source-scout`, 4 agents, web + local R) researched these
into a decision-ready menu. The headline finding: **no clean textbook
estimated-REML target exists** — every Mrode headline example (3.1, sire models)
is BLUP at a *supplied* variance ratio, the forbidden case; the only
textbook-lineage VC-estimation example (Mrode Ch. 11, 6-record variant) has only
third-party-reproduced numbers and EM-vs-AI divergence at n=6. So the realistic
anchor is a published-data + independent-software pairing.

1. **`V1-MRODE-FIT` anchor — recommended: the gryphon birth-weight univariate
   animal model.** Data via `sommer::DT_gryphon`/`A_gryphon`; published REML from
   Wilson et al. (2010, *J. Anim. Ecol.* 79:13–26): VA=3.3954, VE=3.8286,
   h2=0.470 (SE 0.0765). The scout **independently confirmed locally** that
   `sommer::mmes(BWT ~ 1, random = ~vsm(ism(ANIMAL), Gu = A_gryphon))` reproduces
   VA=3.395393, VE=3.828605, h2=0.4700 (4 dp). Caveats: gryphon is a
   teaching/simulated population and Wilson 2010 is paywalled — confirm the
   headline numbers against the paper/an ASReml run before promotion; do NOT use
   `pedigreemm::editPed` on the 1309-row pedigree (deep-recursion stack overflow)
   — use `A_gryphon` directly or `nadiv::makeAinv`. Keep Mrode 3.1 strictly for
   the supplied-variance `henderson_mme`/BLUP cross-check, never as estimation.
2. **`V1-COMPARATORS` comparator — recommended: sommer via `mmes()`** (
   `random = ~vsm(ism(animal), Gu = A)`) on the same normalized pedigree, gated
   behind a clean-convergence precondition; two-sided agreement, CRAN, no license
   gate. Keep ASReml's published gryphon numbers as a license-free cross-check;
   keep the existing pedigreemm logLik check as the one-sided floor only.
   Suggested band on a clean fixture: VC within ~1–2 % relative, h2 within
   ~0.01–0.02 absolute, EBV correlation > 0.999 (looser ~5 %/0.03 against
   optimizer-limited packages). Note sommer passes `A` directly while
   hsquared/Julia uses `Ainv` — a same-estimand parameterization difference.
3. **Item-3 DGP-recovery thresholds — recommended truth source:
   `nadiv::warcolak`** (6000 individuals, ships true breeding values) or a fresh
   fixed-seed additive-only DGP. Maintainer owns the replicate count, seed,
   relative-bias cap (or `0 ∈ bias ± 2·MCSE`), and the mean `cor(EBV, true BV)`
   floor; the contract fixes only the form.

These remain genuine maintainer calls (the autonomous run did NOT pick or
implement any of them). Next step once confirmed: add a sommer-gated agreement
fixture mirroring the existing pedigreemm one, record it as validation-canon
level 4, Rose audits, then the twin flips `V1-MRODE-FIT`/`V1-COMPARATORS`. Full
scout output: workflow `gate-source-scout` (run `wo62dphp0`).

## Public claim audit (Rose)

No new capability claimed. Public text now matches capability-status; the closed
gate is made explicit and binding. Status of the Gaussian animal model stays
planned/partial.

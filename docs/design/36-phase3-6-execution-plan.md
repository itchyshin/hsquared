# 36 — Phase 3→6 Execution Plan (0.6 → 1.0)

> Durable capture of the 2026-07-11 execution ultra-plan (five per-pillar planners
> + consolidation) for the capability arc to a capable 1.0. It implements — does
> not re-open — the release model in `docs/dev-log/decisions.md` ("2026-07-11:
> Release Model") and `ROADMAP.md`. Optimised for the **quickest path where
> accuracy and usability are non-negotiable**.

## Controlling insight

The **engine is already ahead of the R surface on every pillar except FA**. So
most release tags are **honest R-surface promotions gated by twin-discipline**,
not new estimators. The spine is therefore **tag-sequential but work-parallel**:
tags ship in order (Julia registers first, then R CRAN, each tag), but the work
for later tags starts now because each pillar's engine sits at a different
maturity.

## 1. Critical path

```
SPINE (sequential release tags — Julia-registers-first each tag):
  0.6.0 ──► 0.7.0 ──► 0.8.0 ─────► 0.9.0 ──────────► 1.0.0
   MV        Genomic   FA-G +       NG bundle 1        NG family set
   (Ph3)     GREML     single-step  (Poisson +         + production sparse
             (Ph5a)    (Ph4)        Binomial m>1)      + calibrated intervals
                                    + calibration      + API freeze
                                    line               + maintainer declaration

PARALLEL long-lead threads (start NOW, feed later tags, mostly off critical path):
  ├─ Interval-calibration campaign (horizontal) — banks 0.5→1.0
  ├─ Non-Gaussian estimand design (NG-1) — gates ALL of 0.9/1.0
  ├─ Single-step Mrode Ch.11 anchor — feeds 0.8
  ├─ WOMBAT build (FA comparator; longest tool-procurement lead) — gates 0.8 flip
  └─ NG-10 production sparse kernel (Julia, XL) — gates 1.0
```

| Tag | Pillar | Engine status | Critical R-lane work | Julia work | Compute |
|---|---|---|---|---|---|
| **0.6.0** | MV Gaussian | **covered** (V4-MV-REML) | MV-4 cbind auto-routing + Boole freeze *(critical)*; MV-1 in-suite sommer full-unstructured; MV-2/3/6 evidence + identity + Darwin | MV-5 recovery pre-declare parity | MV-5 Totoro (wall-clock bound) |
| **0.7.0** | Genomic GREML | **covered** (V2-GREML) | G0 grammar/scale freeze; G4 auto-route + R parity; G6 h2 identity + anchor | G5 recovery | Totoro screen → DRAC fir 2000-rep confirm |
| **0.8.0** | FA-G + single-step | **FA partial** (real engine fix) | S7 grammar freeze; S8 rotation-invariant bridge; single-step comparators | **S1 diagnose → S2 prereg → S3 reparam/EM warm-start → S4 run** | Totoro (only *after* S1 classifies failures) |
| **0.9.0** | NG bundle 1 + calibration | engine ahead; h2 QGglmm-validated ≤4.5e-6 | NG-1 estimand contract; NG-3 extractor; NG-7 flip; calibration H0/H1/H3 | NG-5 recovery; coverage drivers | Totoro/DRAC |
| **1.0.0** | NG family set + production + calibrated | needs sparse kernel | NG-9 family widening; NG-11 API freeze + maintainer declaration | **NG-10 sparse kernel (XL)**; NG-8 coverage | Totoro/DRAC |

**Adjudications:** single-step lands in the 0.8 bundle with FA (shared comparators
AGHmatrix::Hmatrix / BLUPF90 preGSf90 / Mrode Ch.11); 0.7 waits only on the 0.6
*tag*, not its work; NG-8 == the calibration campaign's non-Gaussian coverage
slice (counted once, owned by the 1.0 close-out).

## 2. Start-now long-lead items (off critical path; pull the end-date in)

1. **NG-1 — non-Gaussian heritability-scale estimand contract.** The single
   longest **non-compute** pole to 1.0. Pure design/symbolic-alignment: ratify
   which scales hsquared surfaces (latent / observation / liability), the
   per-family V_link table, the estimand per family, the honesty gates (Poisson
   latent = NaN; varying n_trials = NaN; single-trial Bernoulli
   information-limited), the extractor grammar, and locked citations
   (Nakagawa–Schielzeth 2017; de Villemereuil / QGglmm 2016; Dempster–Lerner
   1950). The engine math is done and QGglmm-validated; this ratification is what
   every downstream non-Gaussian R surface waits on. Pair with NG-2 (Fisher /
   Falconer / Darwin decomposition sign-off) and NG-6 (scarce-comparator honesty
   policy). **No compute, no code.**
2. **Interval-calibration campaign (horizontal).** (a) **H0** — bank the
   already-earned univariate C1 coverage promotion now (flip h2 legs + profile
   σ²a to *directional-conservative*, demote Wald σ²a to *experimental-only*) via
   Rose audit + maintainer ratification; zero compute; the reusable template for
   every later coverage flip. (b) Build **H1** (ratio-coverage: two_effect /
   multi_effect / repeatability) and **H3** (Fisher-z correlation-coverage: r_am,
   reused for r_g) — compute-free harness builds; write the symbolic-alignment
   table before either.
3. **MV-5 broadened recovery on Totoro** — wall-clock (not core) bound; kick
   first so it feeds MV-7's scope.
4. **Genomic G0** (grammar + genomic-scale estimand note) and **G2/G3** (sommer +
   AGHmatrix comparators — free, installed).
5. **Single-step Mrode Ch.11 anchor** (textbook; feeds 0.8).
6. **WOMBAT build** (free, not installed — canonical same-estimand FA-G
   comparator; longest external-tool lead; gates the 0.8 FA flip).
7. **NG-10 production sparse kernel** (Julia, XL) and provision a capable host for
   GCTA + BLUPF90 preGSf90.

## 3. Five non-negotiables (where quickest must NOT compromise)

1. **Undefined non-Gaussian estimand.** NG-1 must land before any non-Gaussian
   h2 surfaces; Poisson-latent and varying-n_trials h2 stay NaN, never averaged
   into a friendlier scalar. Compute on an undefined estimand yields a precise
   number for the wrong quantity.
2. **Interval coverage.** Pre-register the pass gate (committed SHA) before every
   run; no post-hoc threshold relaxation; pool by **summing counts, not averaging
   per-task coverage** (≈4.5× too wide otherwise); never relabel over-covering as
   "calibrated" — ship a maintainer-signed conservatism statement instead.
3. **Same-estimand comparator scarcity.** Never re-badge a Bayesian agreement leg
   (MCMCglmm/brms/INLA) as same-estimand parity. For the pedigree-A non-Gaussian
   animal model no free frequentist same-estimand tool exists → covered rests on
   the A=I same-estimand leg (glmmTMB / ordinal::clmm) + a recovery-substitution
   multi-seed gate, gap disclosed. Compare variance components on the same G/A,
   not just EBV correlations.
4. **Rotation-invariant-only FA.** `loadings()` display-only, no SE,
   rotation-warned; FA recovery + coverage measured only on rotation-invariant
   functionals (G entries, eigenvalues, evolvability), never on Λ. If fa resists
   but low-rank passes, ship low-rank covered and hold fa partial — do not relax
   the fa threshold.
5. **Twin-discipline: engine-covered ≠ R-public-covered.** An engine flip never
   auto-confers an R flip; each R promotion earns its own R-lane comparator +
   element-wise R↔engine parity + Rose audit. Julia registers first; never read a
   repo-internal "release" commit as proof of an external CRAN state.

## 4. Dispatch model

**Per-pillar just-in-time ultra-plans on the sequential spine**, not one
monolithic push (a big-bang plan bloats the orchestrator and forces premature FA
/ non-Gaussian grammar freezes). A fixed set of start-now parallel long-lead
threads (§2) fires immediately because they are design-bound or
compute-wall-clock-bound.

**First slice to dispatch: MV-4** (cbind auto-routing on the default `fit` path +
Boole grammar/argument freeze) — the only medium R slice on the 0.6 critical path
and gate item 4; R-lane, compute-free. Fire alongside three zero-marginal-cost
kicks: **MV-5 recovery on Totoro** (pre-declare the bias/MCSE gate first),
**NG-1 estimand contract** (design), **H0 calibration bank** (governance). DRAC
enters at 0.7 (G5 confirm tier) and scales for the 0.9/1.0 campaigns.

## 5. Longest-pole call

Non-Gaussian is genuinely last, for four reasons compute cannot fix: (1) the R
lane is furthest behind its engine (needs the NG-1 estimand ratification before
any surface work); (2) comparator scarcity (no free frequentist same-estimand
pedigree-A GLMM tool); (3) two un-fakeable 1.0 gates — interval-coverage
calibration and a production sparse kernel; (4) it sits behind the 0.8 FA engine
risk (the S1 diagnosis fork is the single most consequential uncertainty in the
arc — do not throw compute at an unclassified FA failure). 1.0 is paced by a
design ratification, a comparator that does not exist for free, and two
un-fakeable gates — budget against those, not core-hours.

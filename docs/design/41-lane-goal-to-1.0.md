# 41 — Lane Goal: hsquared / HSquared.jl through Phase 6 to a capable 1.0

> The standing goal for this lane. Any session or agent may execute against it
> without re-opening the strategy. It operationalises the release model
> (`docs/dev-log/decisions.md`, 2026-07-11) and the execution plan
> (`docs/design/36-phase3-6-execution-plan.md`). Progress is measured by the
> milestone ladder (§2) under the success gate (§3); the guardrails (§4) and the
> autonomy boundary (§5) are what make it safe to leave running.

**Current position (2026-09-04; R `origin/main` `08fa6f1`).** Live
experimental number is **0.8.0**; `public_covered_count` is **7**; the
experimental label is **retained**. That is the tip. It is **not** Phase 6
done and **not** 1.0. Block 1 / first-registration **0.5.0** / MV-4 evidence
assembly are historical or paused owner debt — they are **not** the active
spine. The north star below is unchanged.

## 1. The goal (north star)

**Finish the capability arc through Phase 6 to a capable, honest 1.0 of the
`hsquared` / `HSquared.jl` twin — a quantitative-genetics animal-model package a
breeder, ecologist, or PhD student can trust and read like the model already in
their head.** Register early and honestly at **0.5.0** under a prominent
experimental label; let the version number track *covered* capability; grow
pillar by pillar to a 1.0 where **every one of the six pillars is covered +
production + interval-coverage-calibrated behind a committed-stable public API**,
and lift the experimental label only by the maintainer's explicit maturity
declaration. **Never overclaim; honesty and usability are never traded for
speed.**

Two things this goal is NOT: it is not "reach Phase 6 fastest" (Phase 6 is the
longest, least-mature pillar and is sequenced last), and it is not "call it 1.0
when the code runs" (1.0 is the maturity milestone, materially later than Phase 6
complete).

## 2. Milestone ladder (each a shippable minor; the number tracks covered capability)

| Milestone | Pillar | State |
|---|---|---|
| **0.5.0** | Covered Gaussian core (Phase 1–2) — first registration, experimental label | historical first-registration rung — experimental number superseded by **0.8.0**; twin parity (#267/#268), CRAN decisions, and `cran-comments.md` remain paused owner debt, **not** the live tip |
| **0.6.0** | Multivariate Gaussian → R-public covered (Phase 3) | **landed 2026-09-02 (G10)** — experimental label retained; number superseded by **0.8.0** |
| **0.7.0** | Genomic GREML covered (Phase 5a) | **landed 2026-09-02** (engine + R-public at validation scale; G5 default-route later) — number superseded by **0.8.0** |
| **0.8.0** | Factor-analytic G + single-step (Phase 4) | **live tip** (experimental number; label retained) — engine FA + SS covered; R FA planned; R SS opt-in partial; count **7**. Not Phase 6. Not 1.0. |
| **0.9.0** | Non-Gaussian bundle 1 (Poisson/Binomial) + interval-coverage calibration across covered pillars (Phase 6a) | **planned** — next spine after 0.8.0; estimand ratified first (NG-1). Not claimed. |
| **1.0.0** | Non-Gaussian family set + production sparse + calibrated intervals + committed-stable API + **maintainer's maturity declaration** | the maturity milestone (**unchanged end state**) |

"Finished really well **up to Phase 6**" (this lane's headline target) = the
**0.6 → 0.9** rungs are all covered under §3, the interval-calibration campaign
has banked coverage for the covered pillars, and the non-Gaussian estimand is
ratified with its first families covered — leaving only the production sparse
kernel, the full family set, and the maturity declaration between the lane and
1.0. Today: 0.6 and 0.7 are covered at validation scale; the experimental
**number** is **0.8.0** with count **7**; 0.9 and 1.0 remain planned. Do not
read the live number as Phase 6 or 1.0.

## 3. Success gate (a pillar is "done well" only when ALL hold)

The Standard-Tier Covered-Flip Gate (`docs/dev-log/decisions.md`, 2026-07-09),
made concrete for this lane:

1. **Pre-declared recovery gate PASS** — bias/MCSE, the gate committed at a SHA
   *before* the run; a marginal fail is banked negative, never rescued (R4).
2. **External same-estimand comparator AGREE** on component estimands — or an
   explicitly disclosed recovery-substitution where no free same-estimand tool
   exists (never a Bayesian-agreement leg re-badged as parity).
3. **Derived estimands identity-tested + locked citation** (r_g, h²_T, m², r_am,
   scale-h²) — not flipped on component evidence alone.
4. **Textbook anchor or explicit no-anchor disclosure.**
5. **Darwin sign-off** on the biologically-meaningful recovered quantity (for
   correlated models, the covariance/correlation between effects).
6. **Boole grammar + argument-naming freeze BEFORE the flip** (not a follow-up).
7. **Interval coverage** pre-registered; and for the 1.0 gate, calibrated by a
   coverage simulation — not only point-estimate bias/MCSE.
8. **R↔engine element-wise parity + Rose clean audit + twin-discipline**
   (engine-covered ≠ R-public-covered). Parity is verified at a recorded
   commit with pre-declared tolerances; it is not implied by a Julia-free
   R-CMD-check.
9. **Definition of Done** (`AGENTS.md`): local checks pass; `check-log`,
   after-task report, and coordination board updated.

## 4. Guardrails (non-negotiable — never traded for speed)

1. **No non-Gaussian heritability surfaces before its estimand is defined**
   (NG-1); degenerate scales stay `NaN`, never averaged into a friendlier scalar.
2. **Interval coverage pre-registered** (committed SHA, no post-hoc relaxation,
   pool by summing counts); never relabel over-covering as "calibrated".
3. **Comparator honesty** — same-estimand means same-estimand; disclose the gap
   where no free tool exists.
4. **Factor-analytic** exposes rotation-invariant functionals only, never
   loadings.
5. **Twin-discipline** — an engine flip never auto-confers an R flip; Julia
   registers first; a repo-internal "release" signal is never proof of an
   external CRAN/registry state.
6. **Users are gold** — the covered public API reads like the model an applied
   user already has in mind; errors name the unsupported syntax and point to the
   closest planned path; specialist machinery stays behind intuitive defaults.

## 5. Autonomy boundary (what the lane runs unattended vs. what stops for the maintainer)

**The lane MAY, without asking:** implement slices; write recovery/comparator
drivers and tests; run local checks (`document`/`test`/`check`/`air`); draft
proposals, pre-declarations, and design docs; run the named review lenses
(Fisher/Falconer/Darwin/Boole/Rose/…); prepare and assemble covered-flip
evidence; keep every claim surface honest; open PRs.

**The lane MUST stop and get the maintainer for:**
- any **covered flip** (any `partial/planned → covered`, i.e. every G10 move);
- **ratifying a public-grammar / argument-name freeze** (Boole freeze sign-off);
- any **compute-go** on Totoro or DRAC (and committing a pre-declared gate SHA);
- any **version bump, git tag, or registration/CRAN/registry submission**;
- the **NG-2 scientific scale calls** (e.g. the logit primary scale) and other
  named-lens-plus-maintainer decisions;
- **lifting the experimental label** or making the **1.0 maturity declaration**;
- any **outward-facing action** (publishing, external compar-tool procurement
  that incurs cost/accounts).

This boundary is the whole point of "set it and leave it": the lane makes all the
reversible, in-lane progress on its own and queues the irreversible/outward
decisions for a single maintainer review pass.

## 6. How to run it (cadence)

Per-pillar **just-in-time execution on the sequential spine** (0.6 → 0.7 → 0.8 →
0.9), with the **start-now long-lead threads fired in parallel**: the NG-1
estimand contract (in NG-2 sign-off now), the interval-calibration campaign
(H0 bank → H1/H3 harness), the WOMBAT FA-comparator build, and the MV broadened
recovery. Each pillar closes with an after-task report + coordination-board row.
At every §5 boundary the lane pauses with a crisp decision packet for the
maintainer and continues once cleared.

**Current slice on the spine — honesty 2026-09-04.** This paragraph used to
present Block 1 / 0.5.0 registration or MV-4 evidence assembly as the live
tip. Those are done or paused. The live position is experimental **0.8.0** /
count **7**. Reversible next work is **0.9 prep** (NG-1 remaining
ratification; interval-calibration Layer B / H1–H3) under §5 — drafts and
inventories only. That is not a 0.9 claim, not a covered flip, and not a
smaller replacement for Phase 6 / 1.0.

## 7. Definition of done for this goal

The goal is met when the maintainer can, in one review pass, see that the six
pillars each clear §3 (covered + production + calibrated), the public API is
frozen-stable, the experimental label's conditions are satisfied — and make the
**1.0 maturity declaration**. "Up to Phase 6, done really well" is the penultimate
state: everything covered and calibrated except the production sparse kernel and
the full non-Gaussian family set, with the maturity declaration the only step
left.

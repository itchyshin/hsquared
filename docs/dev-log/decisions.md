# Decisions

## 2026-06-12: Two Repos, One Identity

`hsquared` is the R package identity and applied-user surface. `HSquared.jl` is
the Julia computational engine. The first phase installs the operating system
and honest placeholders before model fitting.

## 2026-06-12: Phase 0 Public Claims

Public text may describe planned syntax and roadmap, but it must not say that
animal models, Ainv construction, REML/ML, EBVs, G matrices, or Julia bridging
are implemented until there is code, tests, documentation, and check-log
evidence.

## 2026-06-12: Thread Coordination

The R/coordinator thread owns the R repository. The Julia twin thread owns
`HSquared.jl`. Coordination happens through explicit thread messages and
repo-visible design/check-log files.

## 2026-07-09: Ledger Accessor Is the Sole Count Source

All covered/partial/planned counts on every public and internal surface derive
from a single named `validation_status()` accessor; no surface hard-codes a
count. Ground truth on 2026-07-09 is the twin engine ledger
`HSquared.jl/src/validation_status.jl`: 55 rows = 13 `covered` + 3
`covered_external` + 38 `partial` + 1 `planned`. The covered figure is reported
as both 13 (`covered`) and 16 (`covered` including `covered_external`); surfaces
expose both and do not silently pick one. Exposing both is a maintainer
decision. Open reconciliation (maintainer-gated): the R-side
`validation_status()` is a different 21-row / 8-covered capability ledger (see
the coordination board 2026-07-02 row); this decision must name the twin 55-row
accessor as canonical for headline counts and state how the R 21-row ledger maps
to it, or the two will drift.

## 2026-07-09: payload_v2 Frozen for the 0.1 Window

The bridge payload schema `payload_v2` is frozen for the duration of the 0.1
release window. Track B bridge work lands strictly before the SHA-pin or after
the tag, never inside the frozen window. No payload-shape change ships between
the SHA-pin and the 0.1 tag.

## 2026-07-09: Migrate First, Then Flip

Any covered flip that changes a payload, schema, or accessor migrates every
consumer surface to the new shape first, and flips the claim only after
migration is complete and Rose has audited the migrated surfaces. No surface may
read the new claim before the migration that supports it has landed.

## 2026-07-09: Three Claim Levels for Intervals and Coverage

Uncertainty claims are tiered. (i) POINT requires roughly 2000 reps per cell.
(ii) DIRECTIONAL-CONSERVATIVE is licensed by the committed 500-rep univariate
evidence (HSquared.jl DRAC job 46853279;
`sim/drac/results/cov_delta_profile_46853279.tsv`;
`docs/dev-log/recovery-checkpoints/2026-07-03-interval-coverage.md`) and is
printed with the measured direction ("conservative / not coverage-calibrated").
(iii) EXPERIMENTAL is clearly labelled, not suppressed. The committed univariate
evidence licenses only the DIRECTIONAL tier; no surface may state
point-calibrated coverage. The ~2000-rep POINT threshold is maintainer-owned.
This decision depends on the amended v0.1 Uncertainty Scope that permits the
labelled experimental interval (tracked in the separate Uncertainty-Scope
workstream) and must not ship ahead of that amendment.

## 2026-07-09: Julia Registration Precedes R CRAN

HSquared.jl General-registry registration lands before the hsquared R-package
CRAN submission; the engine gate promotes before the R surface. The R CRAN
submission may not precede a registered, tagged engine version.

## 2026-07-09: Standard-Tier Covered-Flip Gate

This gate is binding for any flip of a Standard-tier row (multivariate,
genomic-to-R, hardened bridge) from `partial`/`planned` to `covered`. It extends,
and does not replace, the V0.1 Promotion Predicate in
`docs/design/01-v0.1-contract.md`. The forms below are non-optional; the numeric
thresholds and pinned citations are maintainer-owned — mirroring V0.1 Promotion
Predicate item 3 (`docs/design/01-v0.1-contract.md:146`), where the form is
fixed but the numbers are maintainer-owned. No Standard-tier flip lands until
every item holds and Rose records the audit.

First, component-versus-derived estimand split: component estimands (variance
components `sigma_a2`, `sigma_e2`, and multivariate covariance-matrix entries)
are gated by an external same-estimand comparator per the comparator policy
(`docs/design/12-multivariate-comparator-plan.md`,
`docs/design/23-comparator-policy.md`); derived estimands — `h2_T`, `m2`, `r_am`,
`R` — are not separately comparator-gated but are each gated by a within-package
identity test asserting the derived quantity equals its defining function of the
covered components and by a locked, pinned citation for that identity, and may
not be flipped `covered` on component comparator evidence alone. Second,
textbook-anchor sub-gate: every covered flip carries either a pinned textbook
number (named source, edition, example/equation number, reproduced value) or an
explicit in-surface no-anchor disclosure; the direct-maternal model has no Mrode
Ch.7 anchor, so a covered flip of any direct-maternal quantity must carry the
explicit no-anchor disclosure, never an implied anchor. Third, Darwin biology
sign-off: Darwin records which quantity the recovery study actually recovers and
confirms it is the biologically meaningful one; for correlated models
(direct-maternal, multivariate) that quantity is the correlation/covariance
between effects, not a per-effect variance read in isolation. Fourth, Boole
grammar and argument-naming freeze: before any Standard-tier flip, Boole freezes
the auto-routing grammar (how a formula auto-selects the engine target) and the
argument-naming predicate (the names/spellings of the user-facing arguments for
the flipped surface) as a precondition of the flip, not a follow-up.

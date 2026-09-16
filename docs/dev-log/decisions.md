# Decisions

## 2026-09-02: DP-10 C — recorded-commit A26 parity honesty (0.6)

**DP-10 C (2026-09-02):** Criterion 8’s R↔engine parity conjunct for 0.6 is
satisfied by locally verified A26 element-wise parity at a named SHA with
pre-declared tolerances; CI is **not** required for that conjunct. A Julia-free
R-CMD-check must not be read as A26 parity. Tier-1 enablement remains optional
owner path **B** and is not authorized by this decision. Named A26 SHAs:
tolerance predeclaration `0ec917f`; measure `37843d8` (receipt: 44 live PASS /
0 fail). Owner ink: Shinichi (Darwin); source: chat "go ahead" (Shinichi, 2026-09-02). No covered flip; count stays **5**.


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

## 2026-07-11: Release Model — First Registration is 0.5.0, Decoupled From Phases

The first public registration of the twin (`hsquared` to CRAN, `HSquared.jl` to
the Julia General registry) is numbered **0.5.0**, **not 1.0.0**, and ships with a
prominent **experimental** label. This mirrors the sibling-package doctrine —
drmTMB (hub D-40) and gllvmTMB (hub D-42) both take their first CRAN release at
0.5.0 — and the standing rule that every lab package ships experimental on first
CRAN until the maintainer personally declares maturity (hub D-41, which names
`hsquared`/`HSquared.jl` explicitly). The R+Julia twin is one data-publication
under one DOI (hub D-23).

**Releases are decoupled from roadmap phases.** The version number tracks
`covered` capability, not surfaced-but-experimental capability, and advances on
its own cadence. 0.5.0 ships on the current covered surface — the five
recovery-gated Gaussian models (v0.1 univariate animal model + common-env
`two_effect`, arbitrary-N `multi_effect`, `random_regression` k=2, and
`direct_maternal` 2×2 G) — and does **not** wait on Phase 6. Roadmap Phases 3–6
land afterwards as post-0.5 minors, each promoted only when its pillar's
pre-declared recovery gate + external same-estimand comparator goes green under
the Standard-Tier Covered-Flip Gate (above):

- `0.5.0` — first registration, covered Gaussian surface, experimental banner.
- `0.6.0` — multivariate promoted to R-public-covered (Phase 3).
- `0.7.0` — genomic GREML leg covered (Phase 5, first leg).
- `0.8.0` — factor-analytic G + single-step (Phase 4).
- `0.9.0` — interval-coverage calibration across covered pillars; non-Gaussian
  approaching covered once its scale-estimand is resolved.
- `1.0.0` — the maturity milestone (below).

**1.0 is the maturity milestone, and 1.0 ≠ "Phase 6 done."** Every pillar must
clear three axes — **covered** (recovery-gated + external same-estimand
comparator + R-public-exported), **production** (lifts the dense, n≤~1000 ceiling;
sparse kernels; real pedigrees), and **calibrated** (interval coverage validated
by a coverage simulation, not only point-estimate bias/MCSE) — plus a
committed-stable public API and the maintainer's explicit maturity declaration.
Interval-coverage calibration currently exists for no model in either lane, so 1.0
is materially later than Phase 6. Phase 6 (non-Gaussian) is the longest pole and
is blocked on a not-yet-defined heritability estimand on the non-Gaussian scale
and on same-estimand comparator scarcity — neither of which is compute-bound — so
non-Gaussian is sequenced last and kept off the release critical path; no
heritability is reported for non-Gaussian fits until the scale note and a
same-estimand comparator exist.

**Reserved formula-marker verbs stay exported.** The inert reserved verbs
(`epistasis`, `imprinting`, `cytoplasmic`, `qtl_scan`, `marker_scan`,
`dominance`) remain exported and lifecycle-badged (experimental/planned), not
removed from the namespace. Their export is what lets `y ~ epistasis(...)` raise
the helpful `hsquared_unsupported_syntax` parser error that names the unsupported
syntax and points to the closest planned path (the User Interface Mantra);
de-exporting them would replace that with a bare "could not find function" error
and break four test files. This considered a proposal to shrink the committed
public surface by de-exporting them and rejected it.

**Julia registers first**, then R CRAN (2026-07-09 decision above). Provenance:
grounded in the sibling-package versioning doctrine (hub D-40/D-42/D-41/D-23), a
five-lens release-strategy panel (unanimous "execute-with-deltas": keep the
technical Phase 1→6 ladder, fix only the release trigger), and the per-pillar
registration-runway map (2026-07-11). The API-stability contract that scopes the
stable-vs-experimental surface for 0.5.0 is proposed in
`docs/design/35-api-stability-contract.md` (awaiting maintainer ratification).

## 2026-09-02: Capability Ids Are Historical; Labels Carry Current Wording

`validation_status()$capability` is a **stable identifier**, not a description
that is kept current. Dated evidence records — comparator-run reports under
`docs/dev-log/comparator-runs/` and `docs/dev-log/check-log.d/` entries — cite
these strings verbatim to name the row they report against. Once evidence points
at an id, the id is not rewritten. When its wording is overtaken by a later
change, the correction is recorded as a **display alias** in
`hs_validation_status_label_overrides()`, and reader-facing surfaces print the
new `capability_label` column instead.

**The case that forced the decision.** MV-4 made a `cbind()` Gaussian response
with an `animal()` term auto-route to the multivariate fitter on the default
path, so "(opt-in)" in the id
`"experimental multivariate REML estimator (opt-in)"` stopped being true. Three
dated records already cite that id verbatim:
`comparator-runs/2026-06-21-multivariate-tool-availability.md`,
`comparator-runs/2026-09-01-blupf90-tool-unavailability.md`, and
`check-log.d/2026-09-01-h2-a24-mv4-claim-surface-honesty.md`. A rename would have
left those three records naming a row that no longer exists; editing dated
records to match a later rename would be worse, because it destroys the
traceability that makes them evidence at all.

**Rejected alternatives.** (i) Rename the id and update the three dated records —
rejected: dated evidence is append-only. (ii) Rename the id and leave the records
stale — rejected: it breaks evidence-to-row lookup silently. (iii) Repurpose
`capability` as the label and add a separate id column — rejected: it breaks
every existing `status$capability == "..."` lookup, including two in
`test-phase0-api.R` and the whole route table in
`tools/write-capability-ledger-summary.R`.

**Precedent, not invention.** `tools/write-capability-ledger-summary.R` already
splits these two roles: it joins to `validation_status()` on `key` (the id) and
shows the reader a separate `title`. Its generated include never contained the
"(opt-in)" string, which is why regenerating it after this change produced no
diff. The alias applies the same split inside the package.

**Guards.** A test asserts every override names a live capability id, so renaming
an id cannot silently strand its alias; another asserts the historical id still
resolves to exactly one row, and that the label drops "opt-in" while the id keeps
it. Rows without an override have `capability_label` identical to `capability`.

**Not in scope.** This is a vocabulary and display decision only. No status
changed, no `partial → covered` flip, and `public_covered_count` stays 5.

## 2026-09-02: Block 1 check-log substitution (Option B)

For Block 1 arcs B0–B3, B5–B6, and the Julia pass-3 cluster, the dated
`docs/dev-log/check-log.d/` shards **are** the after-task record. Writing
reflective summaries after the fact would manufacture narrative the Definition of
Done is meant to prevent. Canonical decision text lives on the twin:
`HSquared.jl/docs/dev-log/decisions/2026-09-02-block1-check-log-substitution.md`
(A23, ADOPTED). B4 already has a real after-task report. **From A24 onward**,
standard after-task reports are required again (see
`docs/dev-log/after-task/2026-09-02-h2-a24-a29-mv-prep-after-task.md`).

Does not authorise covered flips, G10, registry, version bumps, or push.
`public_covered_count` stays 5.

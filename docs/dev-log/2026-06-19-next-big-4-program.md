# Next big 4 — program plan (post-program-1)

The first post-v0.1.0 program (issues backbone → WS2 bridge → WS3 innovation + scout) is
**finished**. This is the next program, maintainer-confirmed: run all four, issues-first.

The biggest *engine* leaps (factor-analytic, non-Gaussian, marker scans) are **twin-gated** — the
R lane advances them only via issues. So the next big 4 deliberately pairs **R-ownable** work
(so the R lane keeps shipping) with the **twin-unblock** that most advances the 8-phase vision.

| # | Big item | Lane | Epic / issues | What "done" looks like |
| --- | --- | --- | --- | --- |
| 1 | **Validation depth — make v0.1 unimpeachable** | R-ownable | #7 + children #31 (sommer/pedigreemm benchmark), #32 (Mrode beyond 3.1), #33 (comparator policy) | A documented, reproducible benchmark + ≥1 new published Mrode anchor + a comparator-policy doc; the covered v0.1 claim is textbook-bulletproof. |
| 2 | **Applied-user experience + figures** | R-ownable | #27 epic + #28 (summary CI/SEs), #29 (gryphon vignette), #30 (Florence figures) | summary()/print() shows the experimental CIs/SEs; an end-to-end gryphon vignette; first Florence uncertainty figures. "Users are gold." |
| 3 | **Phase 3 multivariate → covered** | R harness + twin gate | #10 + #34 (t≥2 recovery harness) + #26 (covariance SEs); twin HSquared.jl#41 | R ships the comparator-parity harness + covariance-SE surface + a t≥2 recovery fixture; twin runs recovery → V4-MULTIVARIATE/V4-MV-REML partial → covered. |
| 4 | **Phase 4 factor-analytic unblock** | twin-led, R-prepared | R mirror #22; twin HSquared.jl#37 (em_fa.jl calibration) + #42 (FA payload) | Twin lands the FA payload + a passing calibration; R fires the prepared `cov = fa()/lowrank()` slice + loadings/eigen-G extractors on landing. |

## Sequencing

Issues-first (done: #27–#34 filed + issue-map updated). Then #1 and #2 (R-ownable) execute now in
the per-slice loop; #3 and #4 are joint — R builds the harness/prepared slice, the twin runs the
gate via the cross-lane issues. The recurring weekly scout keeps feeding innovation issues.

## Discipline (unchanged)

Honesty gate (only `covered` → works; everything new experimental/partial until its
`validation_status()` row says otherwise); lane discipline (twin = issues only); per-slice
implement → multi-lens/adversarial review → Rose audit → local checks (air/document/test/
check_pkgdown/check) → after-task → commit → record CI evidence; pkgdown auto-deploys each push.

## First slice (shipped in this program)

#28 — `summary()`/`print()` now surface the experimental heritability CI, variance-component +
heritability SEs, and the repeatability CI when a fit carries them (the surfaces shipped in the
ultracode WS2 wave), labelled experimental/asymptotic. Fixture-tested.

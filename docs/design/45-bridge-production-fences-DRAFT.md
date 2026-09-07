# 45 — Bridge production fences (DRAFT / UNRATIFIED)

**Status:** a current, public-source-backed boundary record; it is not a
ratified release checklist or evidence of production readiness.

**Pins:** experimental version **0.8.0** · `public_covered_count` **7** · no
package-number or release authorization. This document neither promotes a
bridge row nor changes FA/SS status.

## Scope

The R-to-Julia bridge is live at documented validation scale. Its public
surface is defined by the R capability ledger and the Julia compatibility
matrix, not by an accepted target string alone. In particular,
`hs_validate_julia_target()` validates an explicit opt-in target; it does not
make every listed target covered, production-scale, or a default route.

| Boundary | Current record | Not established here |
| --- | --- | --- |
| Default R fit | `engine = "fit"` retains its separately documented narrow animal, genomic, and `cbind()` routes. | Production-scale sparse fitting or a general bridge guarantee. |
| Explicit Julia target | `hs_validate_julia_target()` accepts the documented opt-in target vocabulary. Each target keeps the status in `docs/design/capability-status.md`. | A claim that all accepted targets are fitted, covered, or interchangeable. |
| `payload_v2` | The current R bridge uses the versioned block contract for `direct_maternal` and `multi_effect`; the Julia matrix records the plain-data/result contract and fixtures. | Universal `payload_v2` coverage or an undocumented result shape. |
| Structured covariance | R rejects `factor_analytic` and `lowrank`; Julia FA evidence remains engine-only and rotation-invariant. | R `cov = fa()` activation, loading payloads, or structured-fit intervals. |
| Single-step | R single-step routes remain opt-in partial despite the narrow engine cell. | Ordinary default ssGBLUP or fitted same-estimand comparator parity. |
| PATH_ONLY interval smoke | C1-ext is an evidence harness, not a fit target. | A bridge capability or claim-eligible fit. |

## Pending release-specific review

The following checklist is **PENDING**. No Hopper sign-off is asserted, and it
cannot authorize a release by itself.

1. Recheck each accepted R target against its actual dispatch and its
   capability-status boundary, including the genomic default route versus held
   ordinary routes.
2. Recheck the `payload_v2` R scope (`direct_maternal`, `multi_effect`) and
   result-shape fixtures against the Julia compatibility matrix.
3. Recheck the FA rotation fence, the SS engine-versus-R-public boundary, and
   PATH_ONLY isolation.
4. Record which live JuliaCall checks are skip-guarded and why; a skipped live
   test is not positive bridge evidence.
5. Record any future review against public repository evidence before it is
   used in a package-number or release decision.

Unrelated optional carry-over: [Julia PR #267](https://github.com/itchyshin/HSquared.jl/pull/267)
remains outside this checklist and the release critical path. Its existing PR
tracks that work; no new maintainer decision about it is required here.

## Cross-links

- R capability ledger: [capability-status.md](capability-status.md)
- R validation-status documentation: [`R/validation-status.R`](../../R/validation-status.R)
- Target validator and dispatch boundary: [`R/julia-bridge.R`](../../R/julia-bridge.R)
- Julia compatibility matrix: [12-bridge-compatibility.md](https://github.com/itchyshin/HSquared.jl/blob/main/docs/design/12-bridge-compatibility.md)
- Release boundary decision: [2026-09-07 record](../dev-log/decisions/2026-09-07-documentation-milestone-release-boundary.md)

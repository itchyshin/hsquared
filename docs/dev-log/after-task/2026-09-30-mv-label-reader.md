## 1. Goal

Integrate independently reviewed label guards for the dedicated multivariate repeatability result reader. Require returned trait and effect labels to agree with the request and normalized pedigree order.

## 2. Implemented

Applied the prepared reader patch and new package regression. Five label fields are required: traits, breeding_ids, pe_ids, breeding_traits and pe_traits. Empty, missing, duplicate, reordered or conflicting labels now produce an error before attaching values. The current Julia producer supplies all five. Optional component names and status fields retain their existing behavior.

## 3a. Decisions and Rejected Alternatives

Use request metadata trait names, then Y column names, then generated trait names. Match both effect-ID vectors to payload IDs, including pedigree ancestors. Reject inconsistent labels instead of silently permuting values. Preserve the existing maternal reader correction and the result body after the new opening guards. Julia schema wording is being composed separately with its coefficient parser update.

## 4. Files Touched

R/julia-bridge.R, tests/testthat/test-multivariate-repeatability-labels.R, this report and its check-log entry/artifacts, plus the two FA articles. Existing intentional dirty changes remain. The independently reviewed R/schema patch and receipt are retained in the Julia twin's prepared-fix folder.

## 5. Checks Run

Builder red controls: 22 of 67 assertions passed, with 45 expected failures. Prepared and independent scratch checks: 67 of 67 passed. Parent actual package check used pkgload::load_all followed by testthat::test_file with stop_on_failure=TRUE; it exited zero and passed all 67 assertions. It performed no Julia fit. The result reader SHA-256 is f3d2bbc80ea659c239906e3c60d4604c1b114a4e957a1cd0f1ff753bca8634e0. The original active reader pin was 4cb8074949c8b843727cd4d6acf8ef720113967e5820f135c5170bc3496e24c2. Apply check passed before mutation.

Both candidate FA articles now expose the complete200-seed recovery results and limitations. Curie independently checked the source wording against the primary artifacts. The two articles rendered locally; an HTML text check confirms the counts and uncertainty, and the teaching SVG target exists after a targeted reference-assets build with examples disabled. Rendered HTML/source pins and raw logs are retained in the artifact folder. These are local candidate previews, with no deployment claim.

## 6. Tests of the Tests

Malformed result labels fail against a positive producer-shaped payload. Distinct numerical values detect accidental relabeling. A payload with an unobserved ancestor checks full pedigree IDs rather than observed-only IDs. All optional metadata and request trait-name fallbacks have positive controls. Independent application reproduced exact result hashes. Prefix, suffix, body from G0 and maternal2090–2103 were byte-identical in the prepared review.

## 7a. Issue Ledger

BP02 is repaired in the active reader. BP03–04 schema wording is prepared and independently approved, but its composed Julia documentation integration remains pending. BP01 coefficient metadata repair and generic bridge production ratification are separate. No full E1 or V3 gate is closed by this package regression.

## 8. Consistency Audit

The labels now follow the actual dedicated producer contract. The generic v2 multi-response route and dedicated repeatability reader are distinct contracts. This repair does not open unsupported formula grammar or add model fitting. Existing paired direct-maternal effects remain unchanged.

## 9. What Did Not Go Smoothly

Preflight surfaced historical divergent refs. The current dedicated lane retains its own later implementation and existing dirty corrections. No live foreign lease owns these paths. Exact reader and test paths were leased before mutation. No branch switch or other lane's edit was overwritten. Initial selective-render attempts used an unsupported argument and then an incomplete article name; both failed before article execution. A temporary teaching-image approach was rejected after its asset path failed. The original renderer was restored and its required reference assets built with examples disabled; the final local target is present. All failed logs were retained. No biological fit was run by rendering.

## 10. Known Residuals

Whole package checks, integrated Julia schema/parser verification, remaining source review and final claims audit are pending. The frozen FA campaign and its failure counts remain separate evidence. No public covered promotion, release, submission or tag.

## 11. Team Learning

Check labels before reshaping and attaching numerical values. Payload pedigree IDs can include unobserved ancestors. Golden Set: a small producer-shaped fixture with distinct values exercised the malformed-label contract. No Codex memory was updated.

## 12. Cross-Product Coverage

This repair covers the dedicated multivariate repeatability reader's ordered result labels and its actual package regression. It does NOT cover whole R–Julia transport parity, generic multi-response production, inference calibration, the whole source panel or release readiness.

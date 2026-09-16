#!/usr/bin/env python3
"""Validate hsquared bridge dashboard TSV ledgers (A14 phase 1).

Pattern donor: drmTMB tools/validate-mission-control.py (bridge-payload-schema,
bridge-parity-smoke-status, bridge-boundary sections only).
"""

from __future__ import annotations

import csv
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
DASHBOARD = ROOT / "docs" / "dev-log" / "dashboard"

BRIDGE_PAYLOAD_SCHEMA = DASHBOARD / "bridge-payload-schema.tsv"
BRIDGE_PARITY_SMOKE_STATUS = DASHBOARD / "bridge-parity-smoke-status.tsv"
BRIDGE_BOUNDARY = DASHBOARD / "bridge-boundary.tsv"

BRIDGE_PAYLOAD_SCHEMA_FIELDS = (
    "schema_id",
    "route",
    "r_target",
    "julia_dispatch",
    "estimator",
    "payload_fields",
    "relinv_builder",
    "r_bridge_status",
    "julia_status",
    "claim_boundary",
    "evidence_url",
    "next_gate",
)

BRIDGE_PARITY_SMOKE_STATUS_FIELDS = (
    "smoke_id",
    "schema_id",
    "model_cell",
    "r_path",
    "julia_path",
    "parity_target",
    "tolerance_rule",
    "parity_status",
    "test_status",
    "bridge_status",
    "evidence_url",
    "claim_boundary",
    "next_gate",
)

BRIDGE_BOUNDARY_FIELDS = (
    "boundary_id",
    "target",
    "smoke_status",
    "parity_required",
    "bridge_status",
    "boundary_doc_status",
    "evidence_url",
    "claim_boundary",
    "next_gate",
)

SCHEMA_ROUTES = {
    "default_fit",
    "explicit_julia",
    "payload_v2",
    "relinv_builder",
}

BRIDGE_STATUSES = {
    "covered",
    "experimental",
    "partial",
    "planned",
    "intentional_error",
    "unsupported",
    "not_applicable",
}

PARITY_STATUSES = {
    "covered",
    "blocked",
    "skipped",
    "skipped_guarded",
    "partial",
    "planned",
    "not_required",
}

TEST_STATUSES = {
    "covered",
    "skipped",
    "skipped_guarded",
    "partial",
    "planned",
}

SMOKE_STATUSES = {
    "live_skip_guarded",
    "emitter_only",
    "no_smoke",
    "calibrated_point_parity",
}

# Deliberately disjoint from BRIDGE_STATUSES: this column records whether the
# boundary itself is written down, never whether the capability is covered.
BOUNDARY_DOC_STATUSES = {
    "documented",
    "partial",
    "planned",
}

GITHUB_EVIDENCE = re.compile(
    r"^https://github\.com/[^/]+/[^/]+/(issues|pull)/[0-9]+"
)


def read_tsv(path: pathlib.Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))


def evidence_reference_exists(reference: str) -> bool:
    if reference in {"", "planned", "none"}:
        return False
    if GITHUB_EVIDENCE.match(reference):
        return True
    path = pathlib.Path(reference)
    if path.is_absolute():
        return path.exists()
    if (ROOT / reference).exists():
        return True
    # Twin sibling checkout (local dev only).
    sibling = ROOT.parent / "HSquared.jl" / reference.removeprefix("HSquared.jl/")
    if reference.startswith("HSquared.jl/") and sibling.exists():
        return True
    return False


def require_non_empty(errors: list[str], row_id: str, field: str, value: str) -> None:
    if not (value or "").strip():
        errors.append(f"{row_id}: {field} is empty")


def validate_schema_rows(errors: list[str]) -> set[str]:
    if not BRIDGE_PAYLOAD_SCHEMA.exists():
        errors.append(f"missing dashboard file: {BRIDGE_PAYLOAD_SCHEMA.relative_to(ROOT)}")
        return set()

    rows = read_tsv(BRIDGE_PAYLOAD_SCHEMA)
    if not rows:
        errors.append("bridge-payload-schema.tsv has no schema rows")
        return set()

    schema_ids: set[str] = set()
    for row in rows:
        row_id = row.get("schema_id", "<bridge payload schema row>")
        if set(row.keys()) != set(BRIDGE_PAYLOAD_SCHEMA_FIELDS):
            errors.append(
                f"{row_id}: bridge-payload-schema.tsv fields do not match the schema contract"
            )
        if not row.get("schema_id"):
            errors.append("bridge-payload-schema.tsv row lacks schema_id")
            continue
        if row_id in schema_ids:
            errors.append(f"duplicate bridge payload-schema id: {row_id}")
        schema_ids.add(row_id)

        for field in BRIDGE_PAYLOAD_SCHEMA_FIELDS:
            require_non_empty(errors, row_id, field, row.get(field, ""))

        if row.get("route") not in SCHEMA_ROUTES:
            errors.append(f"{row_id}: invalid route {row.get('route')!r}")
        for field in ("r_bridge_status", "julia_status"):
            if row.get(field) not in BRIDGE_STATUSES:
                errors.append(f"{row_id}: invalid {field} {row.get(field)!r}")
        if ";" not in row.get("payload_fields", ""):
            errors.append(
                f"{row_id}: payload_fields should list multiple semicolon-separated fields"
            )
        if row.get("r_bridge_status") == "covered" and not evidence_reference_exists(
            row.get("evidence_url", "")
        ):
            errors.append(
                f"{row_id}: covered row evidence_url does not resolve to local evidence"
            )

    return schema_ids


def validate_parity_rows(errors: list[str], schema_ids: set[str]) -> None:
    if not BRIDGE_PARITY_SMOKE_STATUS.exists():
        errors.append(
            f"missing dashboard file: {BRIDGE_PARITY_SMOKE_STATUS.relative_to(ROOT)}"
        )
        return

    rows = read_tsv(BRIDGE_PARITY_SMOKE_STATUS)
    if not rows:
        errors.append("bridge-parity-smoke-status.tsv has no parity smoke rows")
        return

    smoke_ids: set[str] = set()
    for row in rows:
        row_id = row.get("smoke_id", "<bridge parity smoke row>")
        if set(row.keys()) != set(BRIDGE_PARITY_SMOKE_STATUS_FIELDS):
            errors.append(
                f"{row_id}: bridge-parity-smoke-status.tsv fields do not match the parity smoke contract"
            )
        if not row.get("smoke_id"):
            errors.append("bridge-parity-smoke-status.tsv row lacks smoke_id")
            continue
        if row_id in smoke_ids:
            errors.append(f"duplicate bridge parity smoke id: {row_id}")
        smoke_ids.add(row_id)

        for field in BRIDGE_PARITY_SMOKE_STATUS_FIELDS:
            require_non_empty(errors, row_id, field, row.get(field, ""))

        schema_id = row.get("schema_id", "")
        if schema_id not in schema_ids:
            errors.append(f"{row_id}: schema_id {schema_id!r} is not in bridge-payload-schema.tsv")

        for field in ("parity_status",):
            if row.get(field) not in PARITY_STATUSES:
                errors.append(f"{row_id}: invalid {field} {row.get(field)!r}")
        if row.get("test_status") not in TEST_STATUSES:
            errors.append(f"{row_id}: invalid test_status {row.get('test_status')!r}")
        if row.get("bridge_status") not in BRIDGE_STATUSES:
            errors.append(f"{row_id}: invalid bridge_status {row.get('bridge_status')!r}")
        if row.get("bridge_status") == "covered" and not evidence_reference_exists(
            row.get("evidence_url", "")
        ):
            errors.append(
                f"{row_id}: covered row evidence_url does not resolve to local evidence"
            )


def validate_boundary_rows(errors: list[str]) -> None:
    if not BRIDGE_BOUNDARY.exists():
        errors.append(f"missing dashboard file: {BRIDGE_BOUNDARY.relative_to(ROOT)}")
        return

    rows = read_tsv(BRIDGE_BOUNDARY)
    if not rows:
        errors.append("bridge-boundary.tsv has no boundary rows")
        return

    boundary_ids: set[str] = set()
    for row in rows:
        row_id = row.get("boundary_id", "<bridge boundary row>")
        if set(row.keys()) != set(BRIDGE_BOUNDARY_FIELDS):
            errors.append(
                f"{row_id}: bridge-boundary.tsv fields do not match the boundary contract"
            )
        if not row.get("boundary_id"):
            errors.append("bridge-boundary.tsv row lacks boundary_id")
            continue
        if row_id in boundary_ids:
            errors.append(f"duplicate bridge boundary id: {row_id}")
        boundary_ids.add(row_id)

        for field in BRIDGE_BOUNDARY_FIELDS:
            require_non_empty(errors, row_id, field, row.get(field, ""))

        if row.get("smoke_status") not in SMOKE_STATUSES:
            errors.append(f"{row_id}: invalid smoke_status {row.get('smoke_status')!r}")
        if row.get("bridge_status") not in BRIDGE_STATUSES:
            errors.append(f"{row_id}: invalid bridge_status {row.get('bridge_status')!r}")
        if row.get("boundary_doc_status") not in BOUNDARY_DOC_STATUSES:
            errors.append(
                f"{row_id}: invalid boundary_doc_status {row.get('boundary_doc_status')!r}"
            )
        if row.get("boundary_doc_status") == "documented" and not evidence_reference_exists(
            row.get("evidence_url", "")
        ):
            errors.append(
                f"{row_id}: documented row evidence_url does not resolve to local evidence"
            )
        if row.get("smoke_status") == "no_smoke" and row.get("bridge_status") == "covered":
            errors.append(
                f"{row_id}: bridge_status covered requires a smoke, but smoke_status is no_smoke"
            )


def main() -> int:
    errors: list[str] = []
    schema_ids = validate_schema_rows(errors)
    validate_parity_rows(errors, schema_ids)
    validate_boundary_rows(errors)

    if errors:
        print("bridge_dashboard_validation_failed", file=sys.stderr)
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    schema_count = len(read_tsv(BRIDGE_PAYLOAD_SCHEMA)) if BRIDGE_PAYLOAD_SCHEMA.exists() else 0
    smoke_count = (
        len(read_tsv(BRIDGE_PARITY_SMOKE_STATUS))
        if BRIDGE_PARITY_SMOKE_STATUS.exists()
        else 0
    )
    boundary_count = len(read_tsv(BRIDGE_BOUNDARY)) if BRIDGE_BOUNDARY.exists() else 0
    print(
        "bridge_dashboard_ok "
        f"schema_rows={schema_count} "
        f"parity_smoke_rows={smoke_count} "
        f"boundary_rows={boundary_count}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())

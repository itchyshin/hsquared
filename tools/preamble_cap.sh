#!/usr/bin/env bash
# preamble_cap.sh -- guard the ALWAYS-LOADED preamble against the accretion ratchet.
#
# Provenance: adapted from HSquared.jl/tools/preamble_cap.sh
# (MIT License, Copyright (c) 2026 Shinichi Nakagawa). Same programme; R-lane
# targets. The Julia source comments that this twin "carries the same doctrine
# in 6,000 B" — that number is stale (origin/main AGENTS.md was 6,657 B on
# 2026-09-03). Measure here; do not inherit the comment as a cap.
#
# WHY THIS EXISTS
#   `CLAUDE.md` @imports `AGENTS.md`, so every byte of both files is re-read at
#   the front of every Claude session. The Julia twin's `## Live Phase Snapshot`
#   reached 31 dated entries and 690 lines because the block said "refresh" and
#   agents prepended. This R twin has no snapshot block yet, but it is unguarded,
#   and the counterexample is next door: drmTMB/AGENTS.md ~97 kB. A prose rule
#   already lost once in this programme. A merge can duplicate a snapshot entry
#   without git noticing. This script is the check that cannot be merged away.
#
# WHY A SCRIPT AND NOT A RULE
#   Because the rule already existed on the Julia twin and lost. A prose
#   instruction cannot survive a merge; this can.
#
# WHAT IT CHECKS
#   1. AGENTS.md and CLAUDE.md are present and readable
#        -> else UNKNOWN (exit 2), never a silent pass
#   2. AGENTS.md exactly <=1 `- **As of` snapshot entry
#        -> else exit 1 (archive the rest, verbatim)
#   3. AGENTS.md <= CAP_BYTES / CAP_LINES
#   4. CLAUDE.md <= CLAUDE_CAP_BYTES / CLAUDE_CAP_LINES
#        -> else exit 1 (evict / demote / mechanise)
#
#   Deliberately NOT checked: whether the durable sections make stale phase
#   claims. ROADMAP.md and docs/design/capability-status.md are the ledgers.
#
# Usage:  tools/preamble_cap.sh [repo_root]        (default: the directory above this script)
#         CAP_BYTES=12000 tools/preamble_cap.sh    (override the AGENTS.md byte cap)
# Exit:   0 = within cap · 1 = OVER, act before committing · 2 = could not verify (UNKNOWN)

set -uo pipefail

ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
CAP_BYTES="${CAP_BYTES:-10000}"           # ~2,500 tok. Measured 6,657 B on origin/main 2026-09-03.
CAP_LINES="${CAP_LINES:-200}"
CLAUDE_CAP_BYTES="${CLAUDE_CAP_BYTES:-4000}"
CLAUDE_CAP_LINES="${CLAUDE_CAP_LINES:-80}"
MAX_ENTRIES=1

A="$ROOT/AGENTS.md"
C="$ROOT/CLAUDE.md"

# (1) UNKNOWN over silently-clean. A check that cannot read its target has not passed.
for f in "$A" "$C"; do
  if [ ! -f "$f" ] || [ ! -r "$f" ] || [ ! -s "$f" ]; then
    echo "PREAMBLE CAP: cannot read $f -- state UNKNOWN, not clean." >&2
    echo "  (a 0-byte file here usually means a Dropbox online-only placeholder; hydrate it)" >&2
    exit 2
  fi
done

a_bytes=$(wc -c < "$A" | tr -d ' ')
a_lines=$(wc -l < "$A" | tr -d ' ')
c_bytes=$(wc -c < "$C" | tr -d ' ')
c_lines=$(wc -l < "$C" | tr -d ' ')
entries=$(grep -c '^- \*\*As of' "$A" || true)

echo "PREAMBLE CAP -- AGENTS.md is @imported by CLAUDE.md, so both are paid every session."
printf '  AGENTS.md  size : %6d B  (~%d tok)   cap %d B\n' "$a_bytes" "$((a_bytes / 4))" "$CAP_BYTES"
printf '  AGENTS.md  lines: %6d               cap %d\n' "$a_lines" "$CAP_LINES"
printf '  CLAUDE.md  size : %6d B  (~%d tok)   cap %d B\n' "$c_bytes" "$((c_bytes / 4))" "$CLAUDE_CAP_BYTES"
printf '  CLAUDE.md  lines: %6d               cap %d\n' "$c_lines" "$CLAUDE_CAP_LINES"
printf '  snapshot entries: %6d               cap %d\n' "$entries" "$MAX_ENTRIES"

fail=0

if [ "$entries" -gt "$MAX_ENTRIES" ]; then
  fail=1
  echo
  echo "OVER -- $entries snapshot entries; the cap is $MAX_ENTRIES."
  grep -n '^- \*\*As of' "$A" | cut -c1-100 | sed 's/^/    /'
  cat <<'EOF'

    Move every entry but the newest, VERBATIM, to docs/dev-log/phase-snapshot-archive.md.
    Do not summarise them: brevity bias erases exactly the detail that made them worth keeping.
    This most often fires after merging a branch that prepended an entry -- git merges that
    cleanly and says nothing.
EOF
fi

if [ "$a_bytes" -gt "$CAP_BYTES" ]; then
  fail=1
  echo
  printf 'OVER -- AGENTS.md is %d B, cap %d (over by %d).\n' "$a_bytes" "$CAP_BYTES" "$((a_bytes - CAP_BYTES))"
  cat <<'EOF'

    Do ONE of these. Do NOT simply raise the cap -- the cap is the forcing function.
      (a) EVICT     -- history belongs in docs/dev-log/, not in a preamble. Journal it, delete it.
      (b) DEMOTE    -- detail an agent needs only sometimes belongs in a file it reads ON DEMAND
                       (a subdirectory CLAUDE.md, a skill, .claude/agents/*.md).
      (c) MECHANISE -- a rule a script can enforce should be a script. Scripts cost zero preamble.
EOF
fi

if [ "$a_lines" -gt "$CAP_LINES" ]; then
  fail=1
  echo
  printf 'OVER -- AGENTS.md is %d lines, cap %d (over by %d).\n' "$a_lines" "$CAP_LINES" "$((a_lines - CAP_LINES))"
fi

if [ "$c_bytes" -gt "$CLAUDE_CAP_BYTES" ]; then
  fail=1
  echo
  printf 'OVER -- CLAUDE.md is %d B, cap %d (over by %d).\n' "$c_bytes" "$CLAUDE_CAP_BYTES" "$((c_bytes - CLAUDE_CAP_BYTES))"
  cat <<'EOF'

    CLAUDE.md is the thin Claude wrapper (@import AGENTS.md + lane notes). Keep it thin.
    Do NOT raise the cap to absorb a roster or a phase log -- those belong in AGENTS.md
    (and AGENTS.md has its own cap) or in an on-demand file.
EOF
fi

if [ "$c_lines" -gt "$CLAUDE_CAP_LINES" ]; then
  fail=1
  echo
  printf 'OVER -- CLAUDE.md is %d lines, cap %d (over by %d).\n' "$c_lines" "$CLAUDE_CAP_LINES" "$((c_lines - CLAUDE_CAP_LINES))"
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "CAP OK -- preamble within budget."
  exit 0
fi
echo "PREAMBLE CAP FAILED. This is a Definition-of-Done item; fix before committing."
exit 1

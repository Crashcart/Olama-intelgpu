#!/usr/bin/env bash
# Checks ai-rules (origin) for rule version updates and ticket resolutions.
# Called from other Crashcart repos via their .claude/settings.json PreToolUse hook.
# Usage: check-rules-updates.sh <ai-rules-repo-url> <this-repo-ai-id>
#
# Outputs:
#   "Rules updated to vX.Y.Z — re-read rules/ before continuing." if version changed
#   "Ticket TICK-NNN resolved: <title>" for any tickets opened by this AI that are now archived
set -euo pipefail

AI_RULES_URL="${1:-}"
AI_ID="${2:-claude}"
CACHE_DIR="${HOME}/.cache/crashcart-ai-rules"
CACHE_FILE="${CACHE_DIR}/last-check.json"
CHECK_INTERVAL=3600  # seconds between checks (1 hour)

if [[ -z "${AI_RULES_URL}" ]]; then
  exit 0
fi

mkdir -p "${CACHE_DIR}"

# Rate-limit: only check once per CHECK_INTERVAL seconds
NOW=$(date +%s)
if [[ -f "${CACHE_FILE}" ]]; then
  LAST_CHECK=$(jq -r '.last_check // 0' "${CACHE_FILE}" 2>/dev/null || echo "0")
  ELAPSED=$(( NOW - LAST_CHECK ))
  if [[ "${ELAPSED}" -lt "${CHECK_INTERVAL}" ]]; then
    exit 0
  fi
fi

WORK_DIR=$(mktemp -d)
trap 'rm -rf "${WORK_DIR}"' EXIT

# Build the clone URL — supports public repos, private HTTPS (PAT), and SSH
CLONE_URL="${AI_RULES_URL}"
if [[ "${AI_RULES_URL}" == https://* && -n "${AI_RULES_TOKEN:-}" ]]; then
  # Inject PAT for private HTTPS repos: https://TOKEN@github.com/...
  CLONE_URL="${AI_RULES_URL/https:\/\//https://${AI_RULES_TOKEN}@}"
fi
# SSH URLs (git@github.com:...) pass through unchanged — uses machine SSH key

git clone --depth 1 --quiet "${CLONE_URL}" "${WORK_DIR}" 2>/dev/null || {
  echo "Warning: could not reach ai-rules repo — skipping update check"
  exit 0
}

# Check rule version
REMOTE_VERSION=$(jq -r '.version // ""' "${WORK_DIR}/version.json" 2>/dev/null || echo "")
LAST_VERSION=$(jq -r '.last_version // ""' "${CACHE_FILE}" 2>/dev/null || echo "")

if [[ -n "${REMOTE_VERSION}" && "${REMOTE_VERSION}" != "${LAST_VERSION}" ]]; then
  echo "Rules updated to v${REMOTE_VERSION} — re-read rules/ before continuing."
fi

# Check for resolved tickets opened by this AI (files in tickets/archive/ matching requesting-ai)
REPORTED_IDS=$(jq -r '.reported_tickets // [] | .[]' "${CACHE_FILE}" 2>/dev/null || true)
NEW_REPORTED=()
if [[ -d "${WORK_DIR}/tickets/archive" ]]; then
  while IFS= read -r -d '' ticket; do
    TICKET_AI=$(grep -i "^\*\*Opened by\*\*:" "${ticket}" 2>/dev/null | sed 's/.*: *//' | tr -d '[:space:]' || echo "")
    if [[ "${TICKET_AI}" == "${AI_ID}" ]]; then
      TICKET_ID=$(grep -i "^\*\*ID\*\*:" "${ticket}" 2>/dev/null | sed 's/.*: *//' | tr -d '[:space:]' || echo "")
      if [[ -n "${TICKET_ID}" ]] && ! echo "${REPORTED_IDS}" | grep -qx "${TICKET_ID}"; then
        RESOLUTION=$(grep -i "^\*\*Resolution\*\*:" "${ticket}" 2>/dev/null | sed 's/\*\*Resolution\*\*:[[:space:]]*//' || echo "see ticket")
        echo "Ticket ${TICKET_ID} resolved: ${RESOLUTION}"
        NEW_REPORTED+=("${TICKET_ID}")
      fi
    fi
  done < <(find "${WORK_DIR}/tickets/archive" -name "*.md" -print0 2>/dev/null)
fi

# Update cache — persist version and all previously-reported ticket IDs
ALL_REPORTED=$(jq -r '.reported_tickets // []' "${CACHE_FILE}" 2>/dev/null || echo "[]")
for id in "${NEW_REPORTED[@]+"${NEW_REPORTED[@]}"}"; do
  ALL_REPORTED=$(echo "${ALL_REPORTED}" | jq --arg id "${id}" '. + [$id] | unique')
done
jq -n \
  --argjson now "${NOW}" \
  --arg version "${REMOTE_VERSION}" \
  --argjson reported "${ALL_REPORTED}" \
  '{"last_check": $now, "last_version": $version, "reported_tickets": $reported}' > "${CACHE_FILE}"

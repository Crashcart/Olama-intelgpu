#!/usr/bin/env bash
# pull-model.sh — Download an LLM model into the running Ollama container
# Usage: bash pull-model.sh [MODEL_NAME]
# Examples:
#   bash pull-model.sh                  # interactive menu
#   bash pull-model.sh llama3.2         # pull specific model
#   bash pull-model.sh llama3.2:1b      # pull specific tag
#   OLLAMA_PORT=11434 bash pull-model.sh mistral

set -euo pipefail

OLLAMA_PORT="${OLLAMA_PORT:-11434}"
OLLAMA_API="http://localhost:${OLLAMA_PORT}"
CONTAINER_NAME="ollama-intel"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}[pull-model]${NC} $*"; }
success() { echo -e "${GREEN}[pull-model]${NC} $*"; }
warn()    { echo -e "${YELLOW}[pull-model]${NC} $*"; }
error()   { echo -e "${RED}[pull-model]${NC} $*" >&2; exit 1; }

# ── Popular models menu ───────────────────────────────────────────────────────
show_menu() {
  echo ""
  echo "  Popular models (sorted by size — smallest first):"
  echo "  ─────────────────────────────────────────────────"
  echo "  1) llama3.2:1b       ~770 MB  — Very fast, basic tasks"
  echo "  2) llama3.2:3b       ~2.0 GB  — Good balance (default)"
  echo "  3) llama3.2          ~2.0 GB  — Llama 3.2 3B (alias)"
  echo "  4) mistral           ~4.1 GB  — Strong general model"
  echo "  5) llama3.1:8b       ~4.7 GB  — High quality, 8B params"
  echo "  6) llama3.1:70b      ~40 GB   — Very large, needs lots of VRAM"
  echo "  7) codellama:7b      ~3.8 GB  — Code-focused model"
  echo "  8) phi3:mini         ~2.3 GB  — Microsoft Phi-3 mini"
  echo "  9) gemma2:2b         ~1.6 GB  — Google Gemma 2 2B"
  echo "  0) Enter custom model name"
  echo ""
  read -rp "  Select [1-9, 0]: " CHOICE
  case "$CHOICE" in
    1) MODEL="llama3.2:1b" ;;
    2) MODEL="llama3.2:3b" ;;
    3) MODEL="llama3.2" ;;
    4) MODEL="mistral" ;;
    5) MODEL="llama3.1:8b" ;;
    6) MODEL="llama3.1:70b" ;;
    7) MODEL="codellama:7b" ;;
    8) MODEL="phi3:mini" ;;
    9) MODEL="gemma2:2b" ;;
    0)
      read -rp "  Enter model name (e.g. llama3.2:1b): " MODEL
      [[ -z "$MODEL" ]] && error "No model name entered."
      ;;
    *) error "Invalid choice: $CHOICE" ;;
  esac
}

# ── Check Ollama is reachable ─────────────────────────────────────────────────
if ! curl -sf "${OLLAMA_API}/api/tags" &>/dev/null; then
  error "Ollama is not running at ${OLLAMA_API}. Start it first with install.sh"
fi

# ── Determine model to pull ───────────────────────────────────────────────────
MODEL="${1:-}"
if [[ -z "$MODEL" ]]; then
  show_menu
fi

info "Pulling model: ${MODEL}"
info "This may take several minutes depending on model size and connection speed."
echo ""

# Pull via docker exec (streams progress to terminal)
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
  docker exec -it "${CONTAINER_NAME}" ollama pull "${MODEL}"
else
  # Fallback: use REST API directly (no docker exec needed)
  warn "Container '${CONTAINER_NAME}' not found, falling back to API pull..."
  curl -X POST "${OLLAMA_API}/api/pull" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"${MODEL}\"}" \
    --no-buffer \
    | while IFS= read -r line; do
        STATUS=$(echo "$line" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('status',''))" 2>/dev/null || echo "")
        [[ -n "$STATUS" ]] && echo "  $STATUS"
      done
fi

echo ""
success "Model '${MODEL}' is ready."
echo ""
echo "  Start a chat:"
echo "    docker exec -it ${CONTAINER_NAME} ollama run ${MODEL}"
echo ""
echo "  Or via API:"
echo "    curl http://localhost:${OLLAMA_PORT}/api/generate \\"
echo "      -d '{\"model\":\"${MODEL}\",\"prompt\":\"Hello!\",\"stream\":false}'"

"""
Web Search Filter Pipeline for Open WebUI.

Intercepts incoming chat messages and, when a question appears to need
current/external information, queries SearXNG and prepends the top results
as context before the request reaches the model.

Works with ALL models — including MedGemma — because it operates as a
request filter, not a tool-call mechanism.  No native tool_calls support
required from the model.

Installation (automatic via install.sh):
  Copy this file to ${DATA_DIR}/pipelines/
  Restart the pipelines container, then enable the pipeline in
  Open WebUI → Settings → Pipelines.
"""

import re
from typing import List, Optional

import requests
from pydantic import BaseModel


# ── Heuristics for deciding when to trigger a web search ──────────────────────

_QUESTION_WORDS = re.compile(
    r"\b(who|what|when|where|why|how|which|whose|whom)\b",
    re.IGNORECASE,
)

_SEARCH_TRIGGERS = re.compile(
    r"\b(search|find|look up|google|latest|recent|current|news|today|"
    r"right now|as of|update|price|stock|weather|score|result|release|"
    r"available|exist|happened|announce|just|new)\b",
    re.IGNORECASE,
)

_CONVERSATIONAL = re.compile(
    r"^\s*(hi|hello|hey|thanks|thank you|ok|okay|yes|no|sure|"
    r"good|great|cool|got it|sounds good|bye|goodbye)[.!?]?\s*$",
    re.IGNORECASE,
)

MAX_QUERY_LEN = 120


def _should_search(text: str) -> bool:
    if _CONVERSATIONAL.match(text):
        return False
    if len(text.split()) < 3:
        return False
    return bool(_QUESTION_WORDS.search(text) or _SEARCH_TRIGGERS.search(text))


def _trim_query(text: str) -> str:
    """Shorten a long user message into a compact search query."""
    text = text.strip()
    if len(text) <= MAX_QUERY_LEN:
        return text
    # Use just the first sentence if the message is long
    first = re.split(r"[.!?\n]", text)[0].strip()
    return first[:MAX_QUERY_LEN] if first else text[:MAX_QUERY_LEN]


# ── Pipeline class ─────────────────────────────────────────────────────────────

class Pipeline:
    class Valves(BaseModel):
        # Filter-pipeline contract fields (required by the pipelines framework):
        # target model ids this filter attaches to ("*" = all) and its run order.
        pipelines: List[str] = ["*"]
        priority: int = 0
        searxng_url: str = "http://searxng:8080"
        max_results: int = 3
        timeout_seconds: int = 6
        enabled: bool = True

    def __init__(self):
        self.name = "Web Search (SearXNG)"
        self.type = "filter"
        self.valves = self.Valves()

    async def on_startup(self):
        pass

    async def on_shutdown(self):
        pass

    async def inlet(self, body: dict, user: Optional[dict] = None) -> dict:
        """Called before the request reaches the model (must be async — the
        pipelines framework awaits it unconditionally)."""
        if not self.valves.enabled:
            return body

        messages = body.get("messages", [])
        if not messages:
            return body

        # Find the last user message
        last_user_idx = None
        for i in range(len(messages) - 1, -1, -1):
            if messages[i].get("role") == "user":
                last_user_idx = i
                break

        if last_user_idx is None:
            return body

        user_text = messages[last_user_idx].get("content", "")
        if not isinstance(user_text, str):
            return body

        if not _should_search(user_text):
            return body

        query = _trim_query(user_text)
        results = self._search(query)
        if not results:
            return body

        context_block = self._format_results(results, query)
        messages[last_user_idx]["content"] = context_block + "\n\n" + user_text
        body["messages"] = messages
        return body

    def _search(self, query: str) -> list[dict]:
        try:
            resp = requests.get(
                f"{self.valves.searxng_url}/search",
                params={"q": query, "format": "json"},
                timeout=self.valves.timeout_seconds,
            )
            resp.raise_for_status()
            data = resp.json()
            return data.get("results", [])[: self.valves.max_results]
        except Exception:
            return []

    @staticmethod
    def _format_results(results: list[dict], query: str) -> str:
        lines = [f"[Web Search Results for: {query}]"]
        for i, r in enumerate(results, 1):
            title = r.get("title", "").strip()
            url = r.get("url", "").strip()
            snippet = r.get("content", "").strip()
            lines.append(f"\n{i}. {title}")
            if url:
                lines.append(f"   Source: {url}")
            if snippet:
                lines.append(f"   {snippet}")
        lines.append("\nUse the above search results to inform your answer where relevant.")
        return "\n".join(lines)

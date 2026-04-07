"""
Shared pytest fixtures and hooks for all microservice tests.

Key design decisions:
  1. StaticFiles is patched at collection time (pytest_configure) so that no
     'static/' directory needs to exist when importing the app modules.
  2. Each service main.py is loaded via importlib under a unique module alias
     to avoid sys.modules collisions (all five files are literally called main).
"""

import importlib.util
import sys
import types

import pytest


# ---------------------------------------------------------------------------
# Patch StaticFiles before any test module is imported
# ---------------------------------------------------------------------------

class _FakeStaticFiles:
    """Drop-in stub for starlette.staticfiles.StaticFiles."""

    def __init__(self, *args, **kwargs):
        pass

    async def __call__(self, scope, receive, send):  # noqa: D401
        pass


def pytest_configure(config):
    """Replace StaticFiles globally before collection begins."""
    import starlette.staticfiles as _sf
    _sf.StaticFiles = _FakeStaticFiles  # type: ignore[attr-defined]
    # Also patch the symbol in fastapi.staticfiles if already imported
    try:
        import fastapi.staticfiles as _ffs
        _ffs.StaticFiles = _FakeStaticFiles  # type: ignore[attr-defined]
    except ImportError:
        pass


# ---------------------------------------------------------------------------
# Helper: load a service main.py under a unique alias
# ---------------------------------------------------------------------------

def load_service(path: str, alias: str):
    """
    Import *path* as a fresh module named *alias*.

    Using a unique alias per service prevents name collisions in sys.modules
    when multiple services share the same filename ('main').
    """
    if alias in sys.modules:
        return sys.modules[alias]
    spec = importlib.util.spec_from_file_location(alias, path)
    mod = importlib.util.module_from_spec(spec)
    sys.modules[alias] = mod
    spec.loader.exec_module(mod)
    return mod

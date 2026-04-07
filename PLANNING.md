# 🗺️ Session Planning
**Date**: 2026-04-07
**Issue**: #— — Add comprehensive test coverage
**Branch**: copilot/analyze-test-coverage

## Approach
1. Write pytest suites for all 5 Python microservices (zero tests existed)
2. Fix a critical bug found in file-catalog during test authoring
3. Use conftest.py with StaticFiles patch + importlib module loader for isolation

## Decisions Log
- [2026-04-07] Use importlib.util.spec_from_file_location to load each main.py under a unique alias — avoids sys.modules collisions across services
- [2026-04-07] Patch starlette.staticfiles.StaticFiles via pytest_configure hook — no static/ dirs needed in test environment
- [2026-04-07] Use plain async helper classes (not AsyncMock) for httpx mocking — simpler for nested async context managers
- [2026-04-07] tmp_path fixture for all SQLite DBs — full test isolation, no shared state
- [2026-04-07] asyncio.run = _noop_run in proxy test to suppress module-level asyncio.run(main()) call

## Open Questions
- [ ] None — all tasks complete

## Files Created
- tests/conftest.py
- tests/test_memory_browser.py (15 tests)
- tests/test_model_manager.py (13 tests)
- tests/test_ghost_runner.py (14 tests)
- tests/test_file_catalog.py (15 tests)
- tests/test_uds_proxy.py (7 tests)
- pytest.ini
- requirements-test.txt
- .gitignore (updated)

"""Regression tests for the V9 Supabase workbook importer."""

from __future__ import annotations

import importlib.util
import json
import sys
import types
import unittest
from pathlib import Path
from unittest.mock import patch


MODULE_PATH = Path(__file__).with_name("import_81il_master.py")
SPEC = importlib.util.spec_from_file_location("import_81il_master", MODULE_PATH)
assert SPEC and SPEC.loader
IMPORTER = importlib.util.module_from_spec(SPEC)
_OPENPYXL_STUB = types.ModuleType("openpyxl")
_OPENPYXL_STUB.load_workbook = None
with patch.dict(sys.modules, {"openpyxl": _OPENPYXL_STUB, "import_81il_master": IMPORTER}):
    SPEC.loader.exec_module(IMPORTER)


class FakeResponse:
    def __init__(self, payload: bytes) -> None:
        self.payload = payload

    def __enter__(self) -> "FakeResponse":
        return self

    def __exit__(self, exc_type, exc, traceback) -> None:
        return None

    def read(self) -> bytes:
        return self.payload


class ManagementQueryTests(unittest.TestCase):
    def test_query_explicitly_requests_a_writable_transaction(self) -> None:
        captured = {}

        def fake_urlopen(request, timeout):
            captured["request"] = request
            return FakeResponse(b'[{"id": 1, "name": "Test"}]')

        with patch.object(IMPORTER.urllib.request, "urlopen", fake_urlopen):
            result = IMPORTER.query("test-token", "select id, name from public.categories")

        self.assertEqual(result, [{"id": 1, "name": "Test"}])
        request_body = json.loads(captured["request"].data.decode())
        self.assertEqual(request_body["query"], "select id, name from public.categories")
        self.assertIs(request_body["read_only"], False)


if __name__ == "__main__":
    unittest.main()

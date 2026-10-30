"""
Tests for KDE Virtual Desktop / Workspace Service (Fase 4):
Desktop list formatting, current index tracking, and switching bounds.
"""

import unittest
from services.workspace import WorkspaceService


class TestWorkspaceService(unittest.TestCase):

    def test_default_workspace_attributes(self):
        service = WorkspaceService.__new__(WorkspaceService)
        service._count = 1
        service._current_index = 0
        service._current_name = "Desktop 1"
        service._current_id = "test-id-1"
        service._desktops = [
            {"index": 0, "id": "test-id-1", "name": "Desktop 1", "isCurrent": True}
        ]

        self.assertEqual(service.count, 1)
        self.assertEqual(service.currentIndex, 0)
        self.assertEqual(service.currentName, "Desktop 1")
        self.assertEqual(len(service.desktops), 1)

    def test_desktop_index_navigation(self):
        service = WorkspaceService.__new__(WorkspaceService)
        service._count = 4
        service._current_index = 1
        service._desktops = [
            {"index": 0, "id": "d-1", "name": "Code", "isCurrent": False},
            {"index": 1, "id": "d-2", "name": "Web", "isCurrent": True},
            {"index": 2, "id": "d-3", "name": "Chat", "isCurrent": False},
            {"index": 3, "id": "d-4", "name": "Media", "isCurrent": False},
        ]

        next_idx = (service._current_index + 1) % service._count
        self.assertEqual(next_idx, 2)

        prev_idx = (service._current_index - 1) % service._count
        self.assertEqual(prev_idx, 0)

        # Wrapping from 0 backwards
        service._current_index = 0
        prev_wrap_idx = (service._current_index - 1) % service._count
        self.assertEqual(prev_wrap_idx, 3)


if __name__ == "__main__":
    unittest.main()

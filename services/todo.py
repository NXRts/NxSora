"""
To-Do Service
Manages quick checklists and daily task reminders persistently in ~/.config/dynamic_island/tasks.json
"""

import json
import os
from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot


class TodoService(QObject):
    tasksChanged = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._config_dir = os.path.expanduser("~/.config/dynamic_island")
        self._config_file = os.path.join(self._config_dir, "tasks.json")
        os.makedirs(self._config_dir, exist_ok=True)

        self._tasks = [
            {"id": 1, "text": "Cek email & notifikasi", "done": True},
            {"id": 2, "text": "Review pull request kode", "done": True},
            {"id": 3, "text": "Setup Dynamic Island CachyOS", "done": True},
            {"id": 4, "text": "Minum air 2 Liter & istirahat", "done": False},
        ]
        self._load_tasks()

    def _load_tasks(self):
        if os.path.exists(self._config_file):
            try:
                with open(self._config_file, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    if isinstance(data, list) and data:
                        self._tasks = data
            except Exception as e:
                print(f"[TodoService] Error loading tasks.json: {e}")

    def _save_tasks(self):
        try:
            with open(self._config_file, "w", encoding="utf-8") as f:
                json.dump(self._tasks, f, indent=2)
        except Exception as e:
            print(f"[TodoService] Error saving tasks.json: {e}")

    @pyqtProperty(list, notify=tasksChanged)
    def tasks(self):
        return self._tasks

    @pyqtProperty(int, notify=tasksChanged)
    def totalCount(self):
        return len(self._tasks)

    @pyqtProperty(int, notify=tasksChanged)
    def doneCount(self):
        return sum(1 for t in self._tasks if t.get("done", False))

    @pyqtProperty(str, notify=tasksChanged)
    def summaryText(self):
        return f"{self.doneCount}/{self.totalCount}"

    @pyqtSlot(str)
    def addTask(self, text):
        clean_text = text.strip()
        if not clean_text:
            return
        new_id = (max([t.get("id", 0) for t in self._tasks], default=0) + 1)
        self._tasks.append({"id": new_id, "text": clean_text, "done": False})
        self._save_tasks()
        self.tasksChanged.emit()

    @pyqtSlot(int)
    def toggleTask(self, index):
        if 0 <= index < len(self._tasks):
            self._tasks[index]["done"] = not self._tasks[index].get("done", False)
            self._save_tasks()
            self.tasksChanged.emit()

    @pyqtSlot(int)
    def removeTask(self, index):
        if 0 <= index < len(self._tasks):
            self._tasks.pop(index)
            self._save_tasks()
            self.tasksChanged.emit()

    @pyqtSlot()
    def clearCompleted(self):
        self._tasks = [t for t in self._tasks if not t.get("done", False)]
        self._save_tasks()
        self.tasksChanged.emit()

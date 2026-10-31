"""
To-Do Service
Manages quick checklists, task editing, and due time reminders persistently in $XDG_CONFIG_HOME/nxsora/tasks.json
"""

import json
import os
from datetime import datetime
from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot, QTimer
import config


class TodoService(QObject):
    tasksChanged = pyqtSignal()
    taskDueReminder = pyqtSignal(str, str)  # task_text, due_time

    def __init__(self, parent=None):
        super().__init__(parent)
        self._config_file = str(config.CONFIG_DIR / "tasks.json")

        self._tasks = [
            {"id": 1, "text": "Cek email & notifikasi", "done": True, "due": ""},
            {"id": 2, "text": "Review pull request kode", "done": True, "due": ""},
            {"id": 3, "text": "Setup Dynamic Island CachyOS", "done": True, "due": ""},
            {"id": 4, "text": "Minum air 2 Liter & istirahat", "done": False, "due": "16:00"},
        ]
        self._alerted_tasks = set()
        self._load_tasks()

        # Check due time reminders every 30 seconds
        self._reminder_timer = QTimer(self)
        self._reminder_timer.setInterval(30000)
        self._reminder_timer.timeout.connect(self._check_due_reminders)
        self._reminder_timer.start()

    def _load_tasks(self):
        if os.path.exists(self._config_file):
            try:
                with open(self._config_file, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    if isinstance(data, list) and data:
                        # Ensure 'due' key exists
                        for t in data:
                            if "due" not in t:
                                t["due"] = ""
                        self._tasks = data
            except Exception as e:
                print(f"[TodoService] Error loading tasks.json: {e}")

    def _save_tasks(self):
        config.safe_write_private_json(self._config_file, self._tasks)

    def _check_due_reminders(self):
        now_str = datetime.now().strftime("%H:%M")
        for t in self._tasks:
            if not t.get("done", False) and t.get("due"):
                due_time = t.get("due")
                task_id = t.get("id")
                if due_time == now_str and task_id not in self._alerted_tasks:
                    self._alerted_tasks.add(task_id)
                    self.taskDueReminder.emit(t.get("text", "Tugas"), due_time)

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
    @pyqtSlot(str, str)
    def addTask(self, text, due=""):
        clean_text = text.strip()
        if not clean_text:
            return
        new_id = (max([t.get("id", 0) for t in self._tasks], default=0) + 1)
        self._tasks.append({"id": new_id, "text": clean_text, "done": False, "due": due.strip()})
        self._save_tasks()
        self.tasksChanged.emit()

    @pyqtSlot(int, str)
    def editTask(self, index, new_text):
        if 0 <= index < len(self._tasks):
            clean = new_text.strip()
            if clean:
                self._tasks[index]["text"] = clean
                self._save_tasks()
                self.tasksChanged.emit()

    @pyqtSlot(int, str)
    def setDueTime(self, index, due_time):
        if 0 <= index < len(self._tasks):
            self._tasks[index]["due"] = due_time.strip()
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

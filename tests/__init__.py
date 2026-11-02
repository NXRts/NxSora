"""NxSora Unit Tests Suite"""

import os
import sys

# Ensure offscreen platform is configured for headless CI/test environments
os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

from PyQt6.QtWidgets import QApplication

# Centralized QApplication instance for all unit tests
if not QApplication.instance():
    _test_app = QApplication(sys.argv if sys.argv else ["nxsora-tests"])


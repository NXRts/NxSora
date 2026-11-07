# -*- mode: python ; coding: utf-8 -*-
"""
PyInstaller Specification for NxSora (Nx空) — The Living Sky-Notch
Builds standalone zero-console executable (NxSora.exe) for Windows 10/11.
"""

import os
import sys
from pathlib import Path

block_cipher = None
BASE_DIR = Path(os.getcwd())

datas = [
    ('qml', 'qml'),
    ('assets', 'assets'),
    ('services', 'services'),
    ('config.py', '.'),
]

hiddenimports = [
    'PyQt6.QtCore',
    'PyQt6.QtGui',
    'PyQt6.QtWidgets',
    'PyQt6.QtQml',
    'PyQt6.QtQuick',
    'PyQt6.QtNetwork',
    'PyQt6.QtSvg',
    'psutil',
    'services',
    'services.windows_adapter',
    'services.process_utils',
    'services.color_extractor',
    'services.controller',
    'services.mpris',
    'services.volume',
    'services.system',
    'services.notifications',
    'services.timer',
    'services.health',
    'services.todo',
    'services.shelf',
    'services.bluetooth',
    'services.hardware_hud',
    'services.privacy',
    'services.network',
    'services.workspace',
    'services.weather',
    'services.kdeconnect',
    'services.prayer',
    'services.visualizer',
    'services.clipboard',
    'services.audio_devices',
    'services.voicenote',
    'services.colorpicker',
    'services.location',
    'services.screen_manager',
]

# Optional Windows-specific modules
if sys.platform == 'win32':
    hiddenimports += [
        'winsdk',
        'pycaw',
        'screen_brightness_control',
        'wmi',
        'winreg',
    ]

a = Analysis(
    ['main.py'],
    pathex=[str(BASE_DIR)],
    binaries=[],
    datas=datas,
    hiddenimports=hiddenimports,
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        'tkinter',
        'unittest',
        'pydoc',
        'sqlite3',
        'numpy',
        'scipy',
        'matplotlib',
        'pandas',
        'IPython',
        'PIL',
        'Pillow',
        'PyQt6.QtPdf',
        'PyQt6.QtPdfWidgets',
        'PyQt6.QtQuick3D',
        'PyQt6.QtSensors',
        'PyQt6.QtSerialPort',
        'PyQt6.QtSql',
        'PyQt6.QtTest',
        'PyQt6.QtXml',
        'PyQt6.QtBluetooth',
        'PyQt6.QtDesigner',
        'PyQt6.QtHelp',
        'PyQt6.QtMultimediaWidgets',
        'PyQt6.QtNfc',
        'PyQt6.QtPositioning',
        'PyQt6.QtRemoteObjects',
        'PyQt6.QtSpatialAudio',
        'PyQt6.QtWebChannel',
        'PyQt6.QtWebSockets',
        'PyQt6.QtOpenGLWidgets',
        'PyQt6.QtPrintSupport',
    ],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='NxSora',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon='assets/logo.ico',
)


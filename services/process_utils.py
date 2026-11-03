"""
Process Utilities for NxSora
Provides centralized subprocess execution with hidden console window creation on Windows.
Prevents annoying CMD / PowerShell window flickering/flashing when background
diagnostics or command-line tools (e.g. netsh, powercfg, powershell) are executed.
"""

import sys
import subprocess

IS_WINDOWS = (sys.platform == "win32")

# Windows Win32 Process Creation Flag (0x08000000)
CREATE_NO_WINDOW = getattr(subprocess, "CREATE_NO_WINDOW", 0x08000000)


def get_hidden_subprocess_kwargs(**kwargs) -> dict:
    """
    Enriches kwargs for subprocess functions with Windows hidden-console settings:
    1. Sets creationflags |= CREATE_NO_WINDOW
    2. Configures STARTUPINFO with STARTF_USESHOWWINDOW and SW_HIDE
    Preserves all other kwargs, custom pipes, timeouts, and env settings.
    """
    if IS_WINDOWS:
        # Merge creationflags
        existing_flags = kwargs.get("creationflags", 0)
        kwargs["creationflags"] = existing_flags | CREATE_NO_WINDOW

        # Configure STARTUPINFO to hide child console windows if supported
        startupinfo_cls = getattr(subprocess, "STARTUPINFO", None)
        if startupinfo_cls is not None:
            if "startupinfo" in kwargs and kwargs["startupinfo"] is not None:
                si = kwargs["startupinfo"]
            else:
                si = startupinfo_cls()

            startf_useshowwindow = getattr(subprocess, "STARTF_USESHOWWINDOW", 1)
            sw_hide = getattr(subprocess, "SW_HIDE", 0)
            si.dwFlags |= startf_useshowwindow
            si.wShowWindow = sw_hide
            kwargs["startupinfo"] = si

    return kwargs


def run_hidden(command, **kwargs) -> subprocess.CompletedProcess:
    """Executes subprocess.run while suppressing console windows on Windows."""
    kwargs = get_hidden_subprocess_kwargs(**kwargs)
    return subprocess.run(command, **kwargs)


def check_output_hidden(command, **kwargs):
    """Executes subprocess.check_output while suppressing console windows on Windows."""
    kwargs = get_hidden_subprocess_kwargs(**kwargs)
    return subprocess.check_output(command, **kwargs)


def popen_hidden(command, **kwargs) -> subprocess.Popen:
    """Executes subprocess.Popen while suppressing console windows on Windows."""
    kwargs = get_hidden_subprocess_kwargs(**kwargs)
    return subprocess.Popen(command, **kwargs)

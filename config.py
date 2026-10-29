"""
Configuration for NxSora (Dynamic Island for KDE Plasma 6 Wayland)
Standardized XDG Base Directory Support with Auto-Migration & Security
"""

import os
import json
import shutil
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
QML_DIR = BASE_DIR / "qml"
ASSETS_DIR = BASE_DIR / "assets"

# ==============================================================================
# XDG Base Directory Specification
# ==============================================================================
def _resolve_xdg_dirs():
    home = Path.home()
    
    # 1. Configuration: $XDG_CONFIG_HOME/nxsora (default: ~/.config/nxsora)
    xdg_config = os.environ.get("XDG_CONFIG_HOME")
    config_dir = Path(xdg_config) / "nxsora" if xdg_config else home / ".config" / "nxsora"
    
    # 2. Cache: $XDG_CACHE_HOME/nxsora (default: ~/.cache/nxsora)
    xdg_cache = os.environ.get("XDG_CACHE_HOME")
    cache_dir = Path(xdg_cache) / "nxsora" if xdg_cache else home / ".cache" / "nxsora"
    
    # 3. State: $XDG_STATE_HOME/nxsora (default: ~/.local/state/nxsora)
    xdg_state = os.environ.get("XDG_STATE_HOME")
    state_dir = Path(xdg_state) / "nxsora" if xdg_state else home / ".local" / "state" / "nxsora"
    
    # 4. Runtime: $XDG_RUNTIME_DIR/nxsora
    xdg_runtime = os.environ.get("XDG_RUNTIME_DIR")
    if xdg_runtime:
        runtime_dir = Path(xdg_runtime) / "nxsora"
    else:
        runtime_dir = Path(f"/tmp/nxsora-{os.getuid()}")
        
    config_dir.mkdir(parents=True, exist_ok=True)
    cache_dir.mkdir(parents=True, exist_ok=True)
    state_dir.mkdir(parents=True, exist_ok=True)
    runtime_dir.mkdir(parents=True, exist_ok=True)
    
    # Backward compatibility: migrate legacy directories if present
    _migrate_legacy_paths(config_dir, cache_dir)
    
    return config_dir, cache_dir, state_dir, runtime_dir


def _migrate_legacy_paths(new_config_dir: Path, new_cache_dir: Path):
    home = Path.home()
    legacy_config_dirs = [
        home / ".config" / "dynamic_island",
        home / ".config" / "dynamic-island",
    ]
    legacy_cache_dirs = [
        home / ".cache" / "dynamic_island",
        home / ".cache" / "dynamic-island",
    ]
    
    # Migrate config files (tasks.json, health.json, shelf.json, notifications.json)
    for leg_cfg in legacy_config_dirs:
        if leg_cfg.exists() and leg_cfg.is_dir():
            for item in leg_cfg.iterdir():
                target = new_config_dir / item.name
                if not target.exists():
                    try:
                        shutil.copy2(item, target)
                        os.chmod(target, 0o600)
                    except Exception:
                        pass
                        
    # Migrate cache (lyrics)
    for leg_cache in legacy_cache_dirs:
        if leg_cache.exists() and leg_cache.is_dir():
            leg_lyrics = leg_cache / "lyrics"
            target_lyrics = new_cache_dir / "lyrics"
            if leg_lyrics.exists() and not target_lyrics.exists():
                try:
                    shutil.copytree(leg_lyrics, target_lyrics, dirs_exist_ok=True)
                except Exception:
                    pass


CONFIG_DIR, CACHE_DIR, STATE_DIR, RUNTIME_DIR = _resolve_xdg_dirs()
USER_CONFIG_FILE = CONFIG_DIR / "config.json"


def safe_write_private_json(filepath: Path | str, data: dict | list) -> bool:
    """Write data to JSON and enforce POSIX 0600 (read/write by owner only) for privacy."""
    try:
        p = Path(filepath)
        p.parent.mkdir(parents=True, exist_ok=True)
        temp_file = p.parent / f".tmp_{p.name}_{os.getpid()}"
        with open(temp_file, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        os.chmod(temp_file, 0o600)
        temp_file.replace(p)
        os.chmod(p, 0o600)
        return True
    except Exception as e:
        print(f"[NxSora Config] Error writing private file {filepath}: {e}")
        return False


DEFAULT_CONFIG = {
    # Position and Margins (0 for flush attachment to top panel)
    "top_margin": 0,
    
    # Pill Dimensions (Compact Notch)
    "idle_width": 140,
    "idle_height": 28,
    
    "music_compact_width": 230,
    "music_compact_height": 30,
    
    "hud_width": 230,
    "hud_height": 32,
    
    "notification_width": 330,
    "notification_height": 56,
    
    # Card Dimensions (Expanded)
    "expanded_music_width": 420,
    "expanded_music_height": 245,
    
    "expanded_hub_width": 420,
    "expanded_hub_height": 245,
    
    # Auto-collapse timeouts in milliseconds
    "hud_volume_timeout": 2200,
    "hud_battery_timeout": 3000,
    "hud_notification_timeout": 5000,
    "auto_collapse_on_leave": True,          # Auto-close expanded hub when mouse leaves
    "auto_collapse_leave_timeout": 3500,     # Delay (ms) before closing after mouse leaves
    
    # Feature Toggles
    "hud_volume_enabled": True,
    "hud_battery_enabled": True,
    "hud_bluetooth_enabled": True,
    "hud_hardware_enabled": True,            # Brightness & CapsLock HUD
    "hud_notification_enabled": True,
    "fullscreen_autohide_enabled": True,     # Auto-hide when a fullscreen game/video is running
    "privacy_dots_enabled": True,            # Show Mic (orange) & Camera (green) active dots
    "eye_tracking_enabled": True,            # Mascot eyes look at cursor
    
    # Notification Lifecycle & Storage
    "persist_notifications": True,            # Simpan riwayat notifikasi ke disk
    "notification_auto_expire_hours": 48,      # Otomatis hapus notifikasi lebih dari 48 jam (0 = nonaktif)
    
    # Theme colors
    "bg_color": "#07070a",
    "border_color": "#26262e",
    "accent_blue": "#38bdf8",
    "accent_green": "#22c55e",
    "accent_purple": "#818cf8",
}


def load_user_config() -> dict:
    cfg = DEFAULT_CONFIG.copy()
    if USER_CONFIG_FILE.exists():
        try:
            with open(USER_CONFIG_FILE, "r", encoding="utf-8") as f:
                saved = json.load(f)
                if isinstance(saved, dict):
                    cfg.update(saved)
        except Exception as e:
            print(f"[NxSora Config] Warning loading user config: {e}")
    return cfg


def save_user_config(cfg: dict) -> bool:
    return safe_write_private_json(USER_CONFIG_FILE, cfg)


CONFIG = load_user_config()

"""
Configuration for Dynamic Island
"""

import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
QML_DIR = BASE_DIR / "qml"
ASSETS_DIR = BASE_DIR / "assets"

CONFIG = {
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
    
    # Theme colors
    "bg_color": "#07070a",
    "border_color": "#26262e",
    "accent_blue": "#38bdf8",
    "accent_green": "#22c55e",
    "accent_purple": "#818cf8",
}

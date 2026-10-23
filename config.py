"""
Configuration for Dynamic Island
"""

import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
QML_DIR = BASE_DIR / "qml"
ASSETS_DIR = BASE_DIR / "assets"

CONFIG = {
    # Position and Margins
    "top_margin": 10,
    
    # Pill Dimensions (Compact)
    "idle_width": 150,
    "idle_height": 34,
    
    "music_compact_width": 240,
    "music_compact_height": 36,
    
    "hud_width": 240,
    "hud_height": 40,
    
    "notification_width": 340,
    "notification_height": 66,
    
    # Card Dimensions (Expanded)
    "expanded_music_width": 390,
    "expanded_music_height": 185,
    
    "expanded_hub_width": 400,
    "expanded_hub_height": 235,
    
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

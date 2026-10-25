"""
Color Extractor Service
Extracts dominant vibrant colors from album artwork for adaptive dynamic glow.
"""

import os
import colorsys
from urllib.parse import urlparse, unquote
from PIL import Image


class ColorExtractor:
    _cache = {}

    @classmethod
    def get_accent_color(cls, art_url: str, default_color: str = "#38bdf8") -> str:
        if not art_url:
            return default_color

        if art_url in cls._cache:
            return cls._cache[art_url]

        local_path = art_url
        if art_url.startswith("file://"):
            local_path = unquote(urlparse(art_url).path)

        if not os.path.exists(local_path):
            return default_color

        try:
            img = Image.open(local_path).convert("RGB")
            img = img.resize((32, 32))
            colors = img.getcolors(maxcolors=1024)
            if not colors:
                return default_color

            best_color = None
            best_score = -1.0

            for count, (r, g, b) in colors:
                h, s, v = colorsys.rgb_to_hsv(r / 255.0, g / 255.0, b / 255.0)
                # Filter out pure blacks, harsh whites, and low saturation grays
                if v < 0.25 or v > 0.98 or s < 0.28:
                    continue
                # Boost colors that are vivid and pleasant for UI glow
                score = count * (s ** 1.6) * (v ** 0.8)
                if score > best_score:
                    best_score = score
                    best_color = (r, g, b)

            if not best_color:
                colors.sort(reverse=True, key=lambda x: x[0])
                for count, (r, g, b) in colors:
                    h, s, v = colorsys.rgb_to_hsv(r / 255.0, g / 255.0, b / 255.0)
                    if v > 0.15:
                        best_color = (r, g, b)
                        break

            if best_color:
                hex_color = f"#{best_color[0]:02x}{best_color[1]:02x}{best_color[2]:02x}"
                cls._cache[art_url] = hex_color
                return hex_color

        except Exception as e:
            print(f"[ColorExtractor] Error extracting color: {e}")

        return default_color

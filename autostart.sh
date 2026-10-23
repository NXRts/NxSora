#!/usr/bin/env bash
# ==============================================================================
# Script untuk Mengaktifkan / Menonaktifkan Autostart Dynamic Island di KDE
# ==============================================================================

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_FILE="$AUTOSTART_DIR/dynamic-island.desktop"

case "$1" in
    --enable|-e)
        mkdir -p "$AUTOSTART_DIR"
        cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Type=Application
Name=Dynamic Island
Comment=Dynamic Island Overlay for KDE Plasma 6 Wayland
Exec=$DIR/run.sh --daemon
Icon=preferences-desktop-notification
Terminal=false
Categories=Utility;KDE;
X-KDE-autostart-phase=2
StartupNotify=false
EOF
        echo "Autostart berhasil diaktifkan!"
        echo "File desktop dibuat di: $DESKTOP_FILE"
        ;;
    --disable|-d)
        if [ -f "$DESKTOP_FILE" ]; then
            rm -f "$DESKTOP_FILE"
            echo "Autostart berhasil dinonaktifkan."
        else
            echo "Autostart belum diaktifkan."
        fi
        ;;
    --status|-s)
        if [ -f "$DESKTOP_FILE" ]; then
            echo "Status: Autostart AKTIF ($DESKTOP_FILE)"
        else
            echo "Status: Autostart TIDAK AKTIF"
        fi
        ;;
    *)
        echo "Penggunaan: ./autostart.sh [--enable | --disable | --status]"
        ;;
esac

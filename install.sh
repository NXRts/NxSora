#!/usr/bin/env bash
# ==============================================================================
# NxSora (Nx空) — Automated Local Installer for KDE Plasma 6 Wayland
# ==============================================================================

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
AUTOSTART_DIR="$HOME/.config/autostart"
ICON_DIR="$HOME/.local/share/icons/hicolor/scalable/apps"

echo "🌌 Memulai pemasangan NxSora (Nx空)..."
echo "--------------------------------------------------"

# 1. Jalankan pemeriksaan dependensi
"$DIR/run.sh" --check || {
    echo ""
    echo "⚠️ Beberapa dependensi belum terpasang."
    echo "Untuk Arch / CachyOS, Anda dapat memasangnya dengan:"
    echo "  sudo pacman -S python-pyqt6 layer-shell-qt wireplumber bluez-utils power-profiles-daemon wl-clipboard python-psutil"
    echo ""
    read -p "Lanjutkan pemasangan tetap? (y/N): " -r choice
    if [[ ! "$choice" =~ ^[Yy]$ ]]; then
        echo "Pemasangan dibatalkan."
        exit 1
    fi
}

# 2. Buat direktori target
mkdir -p "$BIN_DIR" "$APP_DIR" "$AUTOSTART_DIR" "$ICON_DIR"

# 3. Buat symlink CLI launcher 'nxsora'
echo "🔗 Mendaftarkan perintah CLI: $BIN_DIR/nxsora"
ln -sf "$DIR/run.sh" "$BIN_DIR/nxsora"
chmod +x "$BIN_DIR/nxsora"

# 4. Salin icon aplikasi
if [ -f "$DIR/assets/logo.svg" ]; then
    cp "$DIR/assets/logo.svg" "$ICON_DIR/nxsora.svg"
elif [ -f "$DIR/assets/icon.svg" ]; then
    cp "$DIR/assets/icon.svg" "$ICON_DIR/nxsora.svg"
fi

# 5. Pasang Desktop Entry
echo "🖥️ Memasang menu aplikasi desktop..."
cat <<EOF > "$APP_DIR/nxsora.desktop"
[Desktop Entry]
Name=NxSora
GenericName=The Living Sky-Notch
Comment=The Living Sky-Notch for Linux Desktop (KDE Plasma 6 Wayland)
Exec=$BIN_DIR/nxsora --daemon
Icon=nxsora
Terminal=false
Type=Application
Categories=Utility;System;
StartupNotify=false
X-KDE-autostart-phase=2
EOF

chmod +x "$APP_DIR/nxsora.desktop"

# 6. Pasang autostart saat login (opsional)
cat <<EOF > "$AUTOSTART_DIR/nxsora.desktop"
[Desktop Entry]
Name=NxSora
Comment=The Living Sky-Notch for Linux Desktop
Exec=$BIN_DIR/nxsora --daemon
Icon=nxsora
Terminal=false
Type=Application
Categories=Utility;System;
X-KDE-autostart-phase=2
EOF

echo "--------------------------------------------------"
echo "✨ NxSora berhasil dipasang!"
echo "• Perintah Terminal:  nxsora --daemon (atau nxsora --restart)"
echo "• Peluncur Desktop:   Tersedia di Menu Aplikasi KDE Plasma"
echo "• Mulai Otomatis:     Aktif saat login ke desktop"
echo ""
echo "Jalankan sekarang dengan:"
echo "  $BIN_DIR/nxsora --restart"


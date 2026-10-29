#!/usr/bin/env bash
# ==============================================================================
# NxSora (Nx空) — The Living Sky-Notch for KDE Plasma 6 Wayland
# Runner, Lifecycle, Health-Check & Service Manager
# ==============================================================================

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Standardized XDG paths
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

STATE_DIR="$XDG_STATE_HOME/nxsora"
RUNTIME_DIR="$XDG_RUNTIME_DIR/nxsora"
mkdir -p "$STATE_DIR" "$RUNTIME_DIR" 2>/dev/null || true

PID_FILE="$RUNTIME_DIR/nxsora.pid"
LOCK_FILE="$RUNTIME_DIR/nxsora.lock"
LOG_FILE="$STATE_DIR/nxsora.log"
UNIT_NAME="nxsora"
LEGACY_UNIT="dynamic-island"

export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"
export XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR"
export QT_QPA_PLATFORM="wayland"

is_running() {
    if command -v systemctl >/dev/null 2>&1; then
        if systemctl --user is-active --quiet "$UNIT_NAME" 2>/dev/null || systemctl --user is-active --quiet "$LEGACY_UNIT" 2>/dev/null; then
            return 0
        fi
    fi
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        return 0
    fi
    if [ -f "/tmp/dynamic_island_kde.pid" ] && kill -0 "$(cat "/tmp/dynamic_island_kde.pid")" 2>/dev/null; then
        return 0
    fi
    if pgrep -f "python3.*$DIR/main.py" >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

get_pid() {
    if command -v systemctl >/dev/null 2>&1; then
        if systemctl --user is-active --quiet "$UNIT_NAME" 2>/dev/null; then
            systemctl --user show "$UNIT_NAME" --property=MainPID --value 2>/dev/null
            return
        elif systemctl --user is-active --quiet "$LEGACY_UNIT" 2>/dev/null; then
            systemctl --user show "$LEGACY_UNIT" --property=MainPID --value 2>/dev/null
            return
        fi
    fi
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        cat "$PID_FILE"
        return
    fi
    if [ -f "/tmp/dynamic_island_kde.pid" ] && kill -0 "$(cat "/tmp/dynamic_island_kde.pid")" 2>/dev/null; then
        cat "/tmp/dynamic_island_kde.pid"
        return
    fi
    pgrep -f "python3.*$DIR/main.py" | head -n 1
}

check_dependencies() {
    echo "🔍 Memeriksa dependensi sistem untuk NxSora (Nx空)..."
    echo "--------------------------------------------------------"
    local has_error=0

    # 1. Wayland Session
    if [ -n "$WAYLAND_DISPLAY" ]; then
        echo -e "  \033[32m✔\033[0m Sesi Wayland aktif ($WAYLAND_DISPLAY)"
    else
        echo -e "  \033[31m✘\033[0m Sesi Wayland TIDAK terdeteksi! (NxSora dirancang khusus untuk Wayland)"
        has_error=1
    fi

    # 2. Python3 & PyQt6
    if command -v python3 >/dev/null 2>&1; then
        local py_ver=$(python3 --version 2>&1)
        echo -e "  \033[32m✔\033[0m Python 3 ($py_ver)"
    else
        echo -e "  \033[31m✘\033[0m Python 3 tidak ditemukan"
        has_error=1
    fi

    if python3 -c "import PyQt6" >/dev/null 2>&1; then
        echo -e "  \033[32m✔\033[0m PyQt6 terpasang"
    else
        echo -e "  \033[31m✘\033[0m PyQt6 tidak ditemukan (sudo pacman -S python-pyqt6)"
        has_error=1
    fi

    if python3 -c "import psutil" >/dev/null 2>&1; then
        echo -e "  \033[32m✔\033[0m psutil terpasang (telemetri hardware)"
    else
        echo -e "  \033[31m✘\033[0m psutil tidak ditemukan (sudo pacman -S python-psutil)"
        has_error=1
    fi

    # 3. Layer-Shell-Qt
    if python3 -c '
import sys, os
os.environ["QT_QPA_PLATFORM"] = "offscreen"
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlApplicationEngine
a = QGuiApplication(sys.argv)
e = QQmlApplicationEngine()
e.loadData(b"import QtQuick 2.15\nimport org.kde.layershell 1.0\nItem{}")
sys.exit(0 if e.rootObjects() else 1)
' >/dev/null 2>&1; then
        echo -e "  \033[32m✔\033[0m layer-shell-qt terpasang & dapat dimuat"
    else
        echo -e "  \033[33m▲\033[0m layer-shell-qt belum lengkap (disarankan: sudo pacman -S layer-shell-qt)"
    fi

    # 4. Command Line Utilities
    local tools=(
        "wpctl:PipeWire Volume & Mic control"
        "bluetoothctl:BlueZ Bluetooth peripheral manager"
        "powerprofilesctl:CPU Power Profiles switcher"
        "dbus-monitor:Desktop notifications watcher"
        "wl-copy:Wayland clipboard utility"
        "paplay:PulseAudio/PipeWire soft sound chimes"
    )

    for item in "${tools[@]}"; do
        local cmd="${item%%:*}"
        local desc="${item#*:}"
        if command -v "$cmd" >/dev/null 2>&1; then
            echo -e "  \033[32m✔\033[0m $cmd ($desc)"
        else
            echo -e "  \033[33m▲\033[0m $cmd ($desc) - opsional / tidak ditemukan"
        fi
    done

    echo "--------------------------------------------------------"
    if [ "$has_error" -eq 0 ]; then
        echo -e "✨ \033[32mSeluruh dependensi utama siap! NxSora siap dijalankan.\033[0m"
        return 0
    else
        echo -e "⚠️ \033[31mBeberapa dependensi inti belum terpenuhi.\033[0m"
        return 1
    fi
}

case "$1" in
    --check|-c)
        check_dependencies
        exit $?
        ;;
    --daemon|-d)
        if is_running; then
            PID=$(get_pid)
            echo "NxSora sudah berjalan (PID: ${PID:-unknown})."
            exit 0
        fi
        rm -f "$LOCK_FILE" "/tmp/dynamic_island_kde.lock" 2>/dev/null || true

        # Prioritaskan systemd-run --user agar proses terisolasi di luar cgroup terminal.
        if command -v systemd-run >/dev/null 2>&1 && systemctl --user status basic.target >/dev/null 2>&1; then
            systemctl --user reset-failed "$UNIT_NAME" 2>/dev/null || true
            systemd-run --user \
                --unit="$UNIT_NAME" \
                --description="NxSora The Living Sky-Notch" \
                --setenv=WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
                --setenv=XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
                --setenv=QT_QPA_PLATFORM="wayland" \
                --setenv=PYTHONUNBUFFERED=1 \
                --working-directory="$DIR" \
                -p StandardOutput=append:"$LOG_FILE" \
                -p StandardError=append:"$LOG_FILE" \
                python3 "$DIR/main.py" >/dev/null 2>&1

            sleep 0.4
            if systemctl --user is-active --quiet "$UNIT_NAME"; then
                MAIN_PID=$(systemctl --user show "$UNIT_NAME" --property=MainPID --value 2>/dev/null)
                [ -n "$MAIN_PID" ] && [ "$MAIN_PID" != "0" ] && echo "$MAIN_PID" > "$PID_FILE"
                echo "NxSora berjalan di background (PID: ${MAIN_PID:-systemd})."
                echo "Terminal aman ditutup sekarang! (Proses terisolasi di luar terminal)"
                echo "Log tersimpan di: $LOG_FILE"
                exit 0
            fi
        fi

        # Fallback nohup jika systemd --user tidak tersedia:
        PYTHONUNBUFFERED=1 nohup python3 "$DIR/main.py" < /dev/null >> "$LOG_FILE" 2>&1 &
        PID=$!
        disown "$PID" 2>/dev/null || true
        echo "$PID" > "$PID_FILE"
        echo "NxSora berjalan di background (PID: $PID)."
        echo "Log tersimpan di: $LOG_FILE"
        ;;
    --stop|-s)
        if command -v systemctl >/dev/null 2>&1; then
            systemctl --user stop "$UNIT_NAME" 2>/dev/null || true
            systemctl --user stop "$LEGACY_UNIT" 2>/dev/null || true
        fi
        pkill -f "python3.*$DIR/main.py" 2>/dev/null || true
        rm -f "$PID_FILE" "$LOCK_FILE" "/tmp/dynamic_island_kde.pid" "/tmp/dynamic_island_kde.lock" 2>/dev/null || true
        echo "NxSora dihentikan."
        ;;
    --restart|-r)
        "$0" --stop
        sleep 0.5
        "$0" --daemon
        ;;
    --status)
        if is_running; then
            PID=$(get_pid)
            echo "NxSora sedang berjalan (PID: ${PID:-unknown})."
            if command -v systemctl >/dev/null 2>&1 && systemctl --user is-active --quiet "$UNIT_NAME" 2>/dev/null; then
                systemctl --user status "$UNIT_NAME" --no-pager -n 3
            elif command -v systemctl >/dev/null 2>&1 && systemctl --user is-active --quiet "$LEGACY_UNIT" 2>/dev/null; then
                systemctl --user status "$LEGACY_UNIT" --no-pager -n 3
            fi
        else
            echo "NxSora TIDAK sedang berjalan."
        fi
        ;;
    --test-notif|-t)
        notify-send "NxSora" "Notifikasi uji coba berhasil diterima di Wayland!"
        ;;
    --help|-h)
        echo "Penggunaan: ./run.sh [opsi]"
        echo ""
        echo "Opsi:"
        echo "  (tanpa argumen)  Jalankan di foreground (output di terminal)"
        echo "  --daemon, -d     Jalankan di background (terminal bebas ditutup)"
        echo "  --check, -c      Periksa dependensi sistem dan lingkungan Wayland"
        echo "  --status         Periksa status aplikasi apakah sedang berjalan"
        echo "  --stop, -s       Hentikan instance yang sedang berjalan"
        echo "  --restart, -r    Restart aplikasi"
        echo "  --test-notif, -t Kirim notifikasi uji coba ke NxSora"
        echo "  --help, -h       Tampilkan bantuan ini"
        ;;
    *)
        rm -f "$LOCK_FILE" 2>/dev/null || true
        exec python3 "$DIR/main.py"
        ;;
esac

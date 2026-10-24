#!/usr/bin/env bash
# ==============================================================================
# Dynamic Island for KDE Plasma 6 (Wayland) - Runner Script
# ==============================================================================

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="/tmp/dynamic_island_kde.pid"
LOCK_FILE="/tmp/dynamic_island_kde.lock"

export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export QT_QPA_PLATFORM="wayland"

case "$1" in
    --daemon|-d)
        if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            echo "Dynamic Island sudah berjalan (PID: $(cat "$PID_FILE"))."
            exit 0
        fi
        rm -f "$LOCK_FILE"
        PYTHONUNBUFFERED=1 nohup python3 "$DIR/main.py" >> /tmp/dynamic_island_kde.log 2>&1 &
        PID=$!
        echo $PID > "$PID_FILE"
        echo "Dynamic Island berjalan di background (PID: $PID)."
        echo "Log tersimpan di: /tmp/dynamic_island_kde.log"
        ;;
    --stop|-s)
        pkill -f "python3.*$DIR/main.py" 2>/dev/null || true
        rm -f "$PID_FILE" "$LOCK_FILE"
        echo "Dynamic Island dihentikan."
        ;;
    --restart|-r)
        "$0" --stop
        sleep 0.5
        "$0" --daemon
        ;;
    --test-notif|-t)
        notify-send "Dynamic Island KDE" "Notifikasi uji coba berhasil diterima di Wayland!"
        ;;
    --help|-h)
        echo "Penggunaan: ./run.sh [opsi]"
        echo ""
        echo "Opsi:"
        echo "  (tanpa argumen)  Jalankan di foreground (output di terminal)"
        echo "  --daemon, -d     Jalankan di background"
        echo "  --stop, -s       Hentikan instance yang sedang berjalan"
        echo "  --restart, -r    Restart aplikasi"
        echo "  --test-notif, -t Kirim notifikasi uji coba ke Dynamic Island"
        echo "  --help, -h       Tampilkan bantuan ini"
        ;;
    *)
        rm -f "$LOCK_FILE"
        exec python3 "$DIR/main.py"
        ;;
esac

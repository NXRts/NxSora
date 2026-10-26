#!/usr/bin/env bash
# ==============================================================================
# Dynamic Island for KDE Plasma 6 (Wayland) - Runner Script
# ==============================================================================

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="/tmp/dynamic_island_kde.pid"
LOCK_FILE="/tmp/dynamic_island_kde.lock"
LOG_FILE="/tmp/dynamic_island_kde.log"
UNIT_NAME="dynamic-island"

export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export QT_QPA_PLATFORM="wayland"

is_running() {
    if command -v systemctl >/dev/null 2>&1 && systemctl --user is-active --quiet "$UNIT_NAME" 2>/dev/null; then
        return 0
    fi
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        return 0
    fi
    if pgrep -f "python3.*$DIR/main.py" >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

get_pid() {
    if command -v systemctl >/dev/null 2>&1 && systemctl --user is-active --quiet "$UNIT_NAME" 2>/dev/null; then
        systemctl --user show "$UNIT_NAME" --property=MainPID --value 2>/dev/null
        return
    fi
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        cat "$PID_FILE"
        return
    fi
    pgrep -f "python3.*$DIR/main.py" | head -n 1
}

case "$1" in
    --daemon|-d)
        if is_running; then
            PID=$(get_pid)
            echo "Dynamic Island sudah berjalan (PID: ${PID:-unknown})."
            exit 0
        fi
        rm -f "$LOCK_FILE"

        # Prioritaskan systemd-run --user agar proses terisolasi di luar cgroup terminal.
        # Hal ini mencegah aplikasi tertutup otomatis saat terminal/Konsole ditutup.
        if command -v systemd-run >/dev/null 2>&1 && systemctl --user status basic.target >/dev/null 2>&1; then
            systemctl --user reset-failed "$UNIT_NAME" 2>/dev/null || true
            systemd-run --user \
                --unit="$UNIT_NAME" \
                --description="Dynamic Island for KDE Plasma 6" \
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
                echo "Dynamic Island berjalan di background (PID: ${MAIN_PID:-systemd})."
                echo "Terminal aman ditutup sekarang! (Proses terisolasi di luar terminal)"
                echo "Log tersimpan di: $LOG_FILE"
                exit 0
            fi
        fi

        # Fallback jika systemd --user tidak tersedia:
        # Gunakan nohup dengan stdin tertutup (/dev/null) dan disown agar terlepas dari shell
        PYTHONUNBUFFERED=1 nohup python3 "$DIR/main.py" < /dev/null >> "$LOG_FILE" 2>&1 &
        PID=$!
        disown "$PID" 2>/dev/null || true
        echo "$PID" > "$PID_FILE"
        echo "Dynamic Island berjalan di background (PID: $PID)."
        echo "Terminal aman ditutup sekarang!"
        echo "Log tersimpan di: $LOG_FILE"
        ;;
    --stop|-s)
        if command -v systemctl >/dev/null 2>&1 && systemctl --user is-active --quiet "$UNIT_NAME" 2>/dev/null; then
            systemctl --user stop "$UNIT_NAME" 2>/dev/null || true
        fi
        pkill -f "python3.*$DIR/main.py" 2>/dev/null || true
        rm -f "$PID_FILE" "$LOCK_FILE"
        echo "Dynamic Island dihentikan."
        ;;
    --restart|-r)
        "$0" --stop
        sleep 0.5
        "$0" --daemon
        ;;
    --status)
        if is_running; then
            PID=$(get_pid)
            echo "Dynamic Island sedang berjalan (PID: ${PID:-unknown})."
            if command -v systemctl >/dev/null 2>&1 && systemctl --user is-active --quiet "$UNIT_NAME" 2>/dev/null; then
                systemctl --user status "$UNIT_NAME" --no-pager -n 3
            fi
        else
            echo "Dynamic Island TIDAK sedang berjalan."
        fi
        ;;
    --test-notif|-t)
        notify-send "Dynamic Island KDE" "Notifikasi uji coba berhasil diterima di Wayland!"
        ;;
    --help|-h)
        echo "Penggunaan: ./run.sh [opsi]"
        echo ""
        echo "Opsi:"
        echo "  (tanpa argumen)  Jalankan di foreground (output di terminal)"
        echo "  --daemon, -d     Jalankan di background (terminal bebas ditutup)"
        echo "  --status         Periksa status aplikasi apakah sedang berjalan"
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

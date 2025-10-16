#!/bin/bash

# Prevent multiple instances
if pgrep -f "$(basename "$0")" | grep -v $$ > /dev/null; then
    echo "Script already running. Exiting."
    exit 1
fi


# ===== CONFIGURATION =====
TARGET_HOUR=02   # 24-hour format
TARGET_MIN=30    # minutes
WARNING_SECONDS=300  # 5 minutes before shutdown
LOG_FILE="/home/YOUR_USERNAME/sys_file/daily_autoshutdown/shutdown.log"

# ===== FUNCTIONS =====
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

notify() {
    kdialog --title "Auto Shutdown Started" --passivepopup "$1" 5
}

schedule_next_shutdown() {
    local now_sec=$(date +%s)
    local today_target=$(date -d "$(date +%F) $TARGET_HOUR:$TARGET_MIN" +%s)

    if (( now_sec >= today_target )); then
        today_target=$(date -d "tomorrow $TARGET_HOUR:$TARGET_MIN" +%s)
    fi

    SHUTDOWN_TIME=$today_target
    log "Scheduled shutdown at $(date -d @$SHUTDOWN_TIME)"
    notify "Shutdown scheduled for $(date -d @$SHUTDOWN_TIME '+%H:%M')"
}

show_postpone_dialog() {
    paplay /home/YOUR_USERNAME/sys_file/daily_autoshutdown/service-login.oga &

    postpone=$(kdialog --title "Daily Auto Shutdown" \
        --radiolist "System will shutdown in 5 minutes.\nSelect a postpone option or cancel:" \
        "1min" "Postpone 1 minute (test)" on \
        "30min" "Postpone 30 minutes" off \
        "1hr" "Postpone 1 hour" off \
        "2hr" "Postpone 2 hours" off \
        "4hr" "Postpone 4 hours" off \
        "cancel" "Cancel Today" off)

    case $postpone in
        "1min") SHUTDOWN_TIME=$(( $(date +%s) + 60 + WARNING_SECONDS )) ; log "Postponed 1 minute" ;;
        "30min") SHUTDOWN_TIME=$(( $(date +%s) + 1800 + WARNING_SECONDS )) ; log "Postponed 30 minutes" ;;
        "1hr")   SHUTDOWN_TIME=$(( $(date +%s) + 3600 + WARNING_SECONDS )) ; log "Postponed 1 hour" ;;
        "2hr")   SHUTDOWN_TIME=$(( $(date +%s) + 7200 + WARNING_SECONDS )) ; log "Postponed 2 hours" ;;
        "4hr")   SHUTDOWN_TIME=$(( $(date +%s) + 14400 + WARNING_SECONDS )) ; log "Postponed 4 hours" ;;
        "cancel") log "Shutdown canceled by user" ; exit ;;
        "") log "No selection made. Proceeding with shutdown." ;;
        *) log "Unexpected input. Proceeding with shutdown." ;;
    esac
}

# ===== MAIN LOOP =====
log "Auto-shutdown script started"
schedule_next_shutdown

while true; do
    now=$(date +%s)
    remaining=$((SHUTDOWN_TIME - now))

    if (( remaining <= WARNING_SECONDS && remaining > 0 )); then
        show_postpone_dialog
    elif (( remaining <= 0 )); then
        log "Shutdown triggered"
        shutdown now
        exit
    fi
    sleep 10
done

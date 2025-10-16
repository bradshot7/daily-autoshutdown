# daily-autoshutdown
Daily auto shutdown script for Linux with KDialog warning (Fedora KDE Plasma + KDialog)


# 🕒 Daily Auto Shutdown (KDialog Edition)

This script automatically shuts down your Linux system every day at a specific time. Five minutes before shutdown, it displays a popup with options to postpone or cancel the shutdown.

----------------------------NOTE:You can change the file location as per your liking----------------------------

## ✅ Features

- ⏰ Daily shutdown at a configurable time (default: 02:30)
- 🔔 5-minute warning with a popup dialog
- 💤 Postpone options: 1 min (test), 30 min, 1 hr, 2 hr, 4 hr
- ❌ "Cancel Today" option to skip shutdown
- 🔊 Sound alert before popup
- 📝 Logging of all actions
- 🖥️ Designed for KDE (uses `kdialog`)

---

1. Files location
## 📁 File Structure

/home/your_username/sys_file/daily_autoshutdown/ 
├── daily_autoshutdown.sh # Main script 
├── shutdown.log # Log file (auto-created) 
└── alert.wav # Sound played before popup (Just copy any soundtrack here in the main folder and then add that in daily_autoshutdown.sh file as paplay "/home/your_username/sys_file/daily_autoshutdown/alert.wav &")

---

## 🛠 Setup Instructions

### 1. Install Requirements

Make sure `kdialog` and `paplay` are installed:

```bash
sudo dnf install kdialog pulseaudio-utils

2. Place Files
Put the script and sound file in:
/home/your_username/sys_file/daily_autoshutdown/


##############################################



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
LOG_FILE="/home/your_username/sys_file/daily_autoshutdown/shutdown.log"

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
    paplay /home/your_username/sys_file/daily_autoshutdown/service-login.oga &

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

#########################################################################


Make the script executable:
chmod +x /home/your_username/sys_file/daily_autoshutdown/daily_autoshutdown.sh

3. Run Manually (for testing)
/home/your_username/sys_file/daily_autoshutdown/daily_autoshutdown.sh &


#####🚀 Auto-Start at Login (Optional)
To run the script automatically at login using systemd:

Create a user service:
# ~/.config/systemd/user/daily_autoshutdown.service

[Unit]
Description=Daily Auto Shutdown Script
After=graphical-session.target

[Service]
ExecStart=/home/your_username/sys_file/daily_autoshutdown/daily_autoshutdown.sh
Restart=always
RestartSec=10
Environment=DISPLAY=:0
Environment=XAUTHORITY=%h/.Xauthority

[Install]
WantedBy=default.target

##################################################################

Start or Enable the service:
systemctl --user daemon-reload
systemctl --user enable --now daily_autoshutdown.service

Stop or disable if needed
systemctl --user stop daily_autoshutdown.service
systemctl --user disable daily_autoshutdown.service


📓 Notes
If no option is selected in the popup, shutdown proceeds automatically.

All actions are logged to shutdown.log.

You can customize the shutdown time by editing TARGET_HOUR and TARGET_MIN in the script.

🧪 Testing Tip
Set TARGET_HOUR and TARGET_MIN to a few minutes from now and use the 1-minute postpone option to test behavior quickly.

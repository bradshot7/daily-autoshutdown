# 🕒 Daily Auto Shutdown (KDialog Edition)

This script automatically shuts down your Linux system every day at a specific time. Five minutes before shutdown, it displays a popup with options to postpone or cancel the shutdown.

---

## ✅ Features

- ⏰ Daily shutdown at a configurable time (default: 02:30)
- 🔔 5-minute warning with a popup dialog
- 💤 Postpone options: 1 min (test), 30 min, 1 hr, 2 hr, 4 hr
- ❌ "Cancel Today" option to skip shutdown
- 🔊 Sound alert before popup
- 📝 Logging of all actions
- 🖥️ Designed for KDE (uses `kdialog`)

---

1. Files
## 📁 File Structure

/home/YOUR_USERNAME/sys_file/daily_autoshutdown/ 
├── daily_autoshutdown.sh # Main script 
├── shutdown.log # Log file (auto-created) 
└── alert.wav # Sound played before popup

---

## 🛠 Setup Instructions

### 1. Install Requirements

Make sure `kdialog` and `paplay` are installed:

```bash
sudo dnf install kdialog pulseaudio-utils

2. Place Files
Put the script and sound file in:
/home/YOUR_USERNAME/sys_file/daily_autoshutdown/
Make the script executable:
chmod +x /home/YOUR_USERNAME/sys_file/daily_autoshutdown/daily_autoshutdown.sh

3. Run Manually (for testing)
/home/YOUR_USERNAME/sys_file/daily_autoshutdown/daily_autoshutdown.sh &


####################################################
#####🚀 Auto-Start at Login (Optional)
To run the script automatically at login using systemd:

Create a user service:
# ~/.config/systemd/user/daily_autoshutdown.service

[Unit]
Description=Daily Auto Shutdown Script
After=graphical-session.target

[Service]
ExecStart=/home/YOUR_USERNAME/sys_file/daily_autoshutdown/daily_autoshutdown.sh
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

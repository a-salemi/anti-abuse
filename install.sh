#!/bin/bash
# ==========================================
# Anti-Abuse & Firewall Auto-Installer
# Developer: Amir Salemi
# ==========================================

# ۱. بررسی دسترسی روت
if [ "$EUID" -ne 0 ]; then
  echo -e "\e[31m[-] Please run this script as root.\e[0m"
  exit 1
fi

echo -e "\e[36m"
echo "=================================================="
echo "      Anti-Abuse System 1-Click Installer         "
echo "      Developed by: Amir Salemi                   "
echo "=================================================="
echo -e "\e[0m"

# ۲. نصب پیش‌نیازها
echo "[+] Installing dependencies (iproute2, iptables)..."
apt-get update -y -qq > /dev/null
apt-get install -y iproute2 iptables -qq > /dev/null

# ۳. ساخت دایرکتوری مورد نیاز
echo "[+] Creating directories..."
mkdir -p /opt/anti-abuse

# ۴. تولید خودکار فایل دیمن مانیتورینگ در سرور
echo "[+] Generating core daemon script..."
cat << 'EOF' > /opt/anti-abuse/anti_abuse.sh
#!/bin/bash
# Core Monitoring Daemon by Amir Salemi
SENSITIVE_PORTS="25 137 138 139 445 1900"
CONNECTION_THRESHOLD=15
LOG_FILE="/var/log/anti_abuse.log"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Anti-Abuse Daemon started by Amir Salemi." >> $LOG_FILE

while true; do
    for PORT in $SENSITIVE_PORTS; do
        SUSPICIOUS_IPS=$(ss -ntu state established state syn-sent | grep ":$PORT " | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | awk -v limit=$CONNECTION_THRESHOLD '$1 > limit {print $2}')
        for IP in $SUSPICIOUS_IPS; do
            iptables -C OUTPUT -d "$IP" -j DROP &> /dev/null
            if [ $? -ne 0 ]; then
                iptables -I OUTPUT -d "$IP" -j DROP
                echo "$(date '+%Y-%m-%d %H:%M:%S') - [ALERT] Blocked outbound traffic to $IP on port $PORT." >> $LOG_FILE
            fi
        done
    done
    sleep 10
done
EOF

# دادن دسترسی اجرایی به فایل ساخته شده
chmod +x /opt/anti-abuse/anti_abuse.sh

# ۵. تولید خودکار فایل سرویس Systemd
echo "[+] Generating systemd service file..."
cat << 'EOF' > /etc/systemd/system/anti-abuse.service
[Unit]
Description=Amir Salemi's Anti-Abuse and Firewall Configurator
After=network.target

[Service]
Type=simple
ExecStart=/opt/anti-abuse/anti_abuse.sh
Restart=on-failure
RestartSec=5
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=anti-abuse-daemon

[Install]
WantedBy=multi-user.target
EOF

# ۶. فعال‌سازی و استارت سرویس
echo "[+] Reloading systemd and starting the service..."
systemctl daemon-reload
systemctl enable anti-abuse.service
systemctl restart anti-abuse.service

echo -e "\e[32m[+] Installation completed successfully!\e[0m"
echo "[i] The Anti-Abuse daemon is now running in the background."
echo "[i] Check logs: tail -f /var/log/anti_abuse.log"
echo "[i] Check status: systemctl status anti-abuse.service"

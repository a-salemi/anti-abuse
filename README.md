# 🛡️ Anti-Abuse & Firewall Auto-Config Daemon

![Bash](https://img.shields.io/badge/Script-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Linux](https://img.shields.io/badge/OS-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

A lightweight, autonomous background daemon designed to protect Linux servers from outbound abuse (spamming, port scanning, DDoS amplification). It constantly monitors outbound traffic and automatically updates `iptables` rules to block suspicious connections before your hosting provider (e.g., Hetzner, OVH) sends an abuse report or suspends your server.

Developed with ❤️ by **Amir Salemi**.

---

## ✨ Key Features

- **🚀 1-Click Installation:** Fully automated setup process. No manual configuration required.
- **🕵️ Real-time Monitoring:** Uses the ultra-fast `ss` utility to track established connections.
- **🧱 Auto-Blocking:** Instantly drops outbound connections to malicious IPs via `iptables`.
- **🪶 Ultra-Lightweight:** Runs quietly in the background with near-zero CPU/RAM footprint.
- **📝 Detailed Auditing:** Logs every blocked IP, timestamp, and port for your review.
- **⚙️ Systemd Integration:** Fully managed as a native Linux service (auto-starts on boot).

---

## 🚀 Quick Installation

You can install and start the Anti-Abuse daemon with a single command. Run the following as `root`:

```bash
bash <(curl -Ls (https://raw.githubusercontent.com/a-salemi/anti-abuse/main/install.sh)
```
---

## 🛠️ Commands & Usage

Once installed, the system runs automatically as a `systemd` service. You can manage it using standard Linux commands:

| Action | Command |
| :--- | :--- |
| **Check Status** | `systemctl status anti-abuse.service` |
| **View Live Logs** | `tail -f /var/log/anti_abuse.log` |
| **Stop Daemon** | `systemctl stop anti-abuse.service` |
| **Restart Daemon** | `systemctl restart anti-abuse.service` |

---

## ⚙️ Customization (Advanced)

If you need to change the sensitive ports or the connection threshold, you can easily edit the core script:

1. Open the script:
   ```bash
   nano /opt/anti-abuse/anti_abuse.sh
   ```
2. Modify these variables at the top of the file:
   ```bash
   SENSITIVE_PORTS="25 137 138 139 445 1900" # Add or remove ports
   CONNECTION_THRESHOLD=15                   # Max allowed connections per IP
   ```
3. Restart the service to apply changes:
   ```bash
   systemctl restart anti-abuse.service
   ```

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

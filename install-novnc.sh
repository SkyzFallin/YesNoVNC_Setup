#!/usr/bin/env bash
set -euo pipefail

# Install and configure noVNC + VNC server on Kali/Debian/Ubuntu
# Usage: sudo ./install-novnc.sh

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (use sudo)." >&2
    exit 1
fi

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo "~$REAL_USER")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Install dependencies ---
echo "[*] Installing dependencies..."
apt update -qq
apt install -y tightvncserver git xfce4 xfce4-goodies dbus-x11

# --- Set up VNC password ---
echo "[*] Setting up VNC password..."
sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.vnc"
echo "password" | sudo -u "$REAL_USER" vncpasswd -f > "$REAL_HOME/.vnc/passwd"
chmod 600 "$REAL_HOME/.vnc/passwd"
chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.vnc/passwd"

echo "[!] VNC password set to 'password' -- change this with: vncpasswd"

# --- Create VNC xstartup ---
echo "[*] Creating VNC xstartup script..."
cat > "$REAL_HOME/.vnc/xstartup" << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
EOF
chmod +x "$REAL_HOME/.vnc/xstartup"
chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.vnc/xstartup"

# --- Clone noVNC ---
if [[ -d /opt/noVNC ]]; then
    echo "[*] noVNC already installed at /opt/noVNC, skipping clone."
else
    echo "[*] Cloning noVNC to /opt/noVNC..."
    git clone https://github.com/novnc/noVNC.git /opt/noVNC
fi

# --- Install start/stop scripts ---
echo "[*] Installing start/stop scripts to /usr/local/bin..."
cp "$SCRIPT_DIR/start_novnc.sh" /usr/local/bin/start-novnc
cp "$SCRIPT_DIR/stop_novnc.sh" /usr/local/bin/stop-novnc

# Update the noVNC path from /tmp to /opt in the start script
sed -i 's|/tmp/noVNC/utils/novnc_proxy|/opt/noVNC/utils/novnc_proxy|g' /usr/local/bin/start-novnc

chmod +x /usr/local/bin/start-novnc /usr/local/bin/stop-novnc

# --- Done ---
echo ""
echo "[+] Installation complete."
echo ""
echo "    Commands:"
echo "      start-novnc    Start VNC server + noVNC proxy"
echo "      stop-novnc     Stop everything"
echo ""
echo "    Access: http://localhost:6080/vnc.html"
echo "    VNC Password: password (change with: vncpasswd)"
echo ""

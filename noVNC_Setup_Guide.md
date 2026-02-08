# noVNC Setup Guide for Kali Linux

This guide will help you set up noVNC on a fresh Kali Linux box for remote desktop access via web browser.

## Prerequisites
- Fresh Kali Linux installation
- Root or sudo access
- Network access for downloading dependencies

---

## Part 1: VNC Server Setup

### Set VNC Password
```bash
mkdir -p ~/.vnc
echo "password" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd
```

**VNC Password:** `password` (change this for production use)

### Create VNC Startup Script
```bash
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
EOF

chmod +x ~/.vnc/xstartup
```

**Important Fix:** The `unset` commands prevent session manager conflicts that cause blank screens.

### Start VNC Server
```bash
vncserver :1 -geometry 1920x1080 -depth 24
```

**VNC Details:**
- Display: `:1`
- Port: `5901`
- Resolution: `1920x1080`
- Color Depth: `24-bit`

---

## Part 2: noVNC Installation and Setup

### Install noVNC
```bash
# Clone noVNC repository
cd /tmp
git clone https://github.com/novnc/noVNC.git
```

### Start noVNC Proxy
```bash
nohup /tmp/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080 > /tmp/novnc.log 2>&1 &
```

### Verify noVNC is Running
```bash
# Check if ports are listening
ss -tlnp | grep -E "(5901|6080)"

# Should show:
# LISTEN 0      100          0.0.0.0:6080       0.0.0.0:*    users:(("websockify",pid=XXXX,fd=6))
# LISTEN 0      5            0.0.0.0:5901       0.0.0.0:*    users:(("Xtightvnc",pid=XXXX,fd=3))
```

---

## Part 3: Access the Desktop

### Web Browser Access
Open a web browser and navigate to:
```
http://<kali-ip-address>:6080/vnc.html
```

Or if accessing locally:
```
http://localhost:6080/vnc.html
```

**Login:** Enter password `password` when prompted

---

## Part 4: Management Commands

### VNC Server Management
```bash
# List running VNC servers
vncserver -list

# Kill VNC server
vncserver -kill :1

# Restart VNC server
vncserver :1 -geometry 1920x1080 -depth 24
```

### noVNC Management
```bash
# Check if noVNC/websockify is running
ps aux | grep websockify | grep -v grep

# Stop noVNC
pkill -f novnc_proxy

# Restart noVNC
nohup /tmp/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080 > /tmp/novnc.log 2>&1 &
```

### Port Verification
```bash
# Check all listening ports
ss -tlnp

# Check specific ports
ss -tlnp | grep -E "(5901|6080)"
```

---

## Part 5: Troubleshooting

### Blank Screen in noVNC
**Problem:** Connected to noVNC but screen is blank

**Solution:**
1. Kill VNC server: `vncserver -kill :1`
2. Verify xstartup has the unset commands:
```bash
cat ~/.vnc/xstartup
```
Should contain:
```bash
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
```
3. Restart VNC: `vncserver :1 -geometry 1920x1080 -depth 24`
4. Restart noVNC proxy if needed
5. Hard refresh browser (Ctrl+F5 or Cmd+Shift+R)

### Can't Connect to noVNC
**Problem:** Browser can't reach port 6080

**Solution:**
1. Verify websockify is running: `ps aux | grep websockify`
2. Check firewall rules: `iptables -L -n`
3. Verify port is listening: `ss -tlnp | grep 6080`
4. Check logs: `tail /tmp/novnc.log`
5. Restart noVNC proxy:
```bash
pkill -f novnc_proxy
nohup /tmp/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080 > /tmp/novnc.log 2>&1 &
```

### VNC Password Issues
**Problem:** Password not working or being rejected

**Solution:**
```bash
# Reset password
rm ~/.vnc/passwd
echo "password" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# Restart VNC server
vncserver -kill :1
vncserver :1 -geometry 1920x1080 -depth 24
```

---

## Part 6: Startup Script

Save this as `~/start_novnc.sh` for quick setup:

```bash
#!/bin/bash

echo "[+] Starting noVNC Environment..."

# Start VNC Server
echo "[+] Starting VNC server..."
vncserver :1 -geometry 1920x1080 -depth 24

sleep 3

# Start noVNC
echo "[+] Starting noVNC proxy..."
pkill -f novnc_proxy 2>/dev/null
nohup /tmp/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080 > /tmp/novnc.log 2>&1 &

sleep 2

# Verify everything is running
echo ""
echo "[+] Status Check:"
echo "-------------------"

if ss -tlnp | grep -q 5901; then
    echo "✓ VNC Server: Running on port 5901"
else
    echo "✗ VNC Server: NOT running"
fi

if ss -tlnp | grep -q 6080; then
    echo "✓ noVNC Proxy: Running on port 6080"
else
    echo "✗ noVNC Proxy: NOT running"
fi

echo ""
echo "[+] Access noVNC at: http://localhost:6080/vnc.html"
echo "[+] VNC Password: password"
echo ""
```

Make it executable:
```bash
chmod +x ~/start_novnc.sh
```

Run it:
```bash
~/start_novnc.sh
```

---

## Part 7: Shutdown Script

Save this as `~/stop_novnc.sh`:

```bash
#!/bin/bash

echo "[+] Stopping noVNC Environment..."

# Stop noVNC
echo "[+] Stopping noVNC proxy..."
pkill -f novnc_proxy

# Stop VNC
echo "[+] Stopping VNC server..."
vncserver -kill :1

echo "[+] noVNC Environment stopped."
```

Make it executable:
```bash
chmod +x ~/stop_novnc.sh
```

---

## Part 8: Advanced Configuration

### Change VNC Resolution
```bash
vncserver -kill :1
vncserver :1 -geometry 2560x1440 -depth 24
```

Common resolutions:
- 1920x1080 (Full HD)
- 2560x1440 (2K)
- 3840x2160 (4K)
- 1280x720 (HD)

### Change VNC Password
```bash
vncpasswd
# Enter new password when prompted

# Restart VNC for changes to take effect
vncserver -kill :1
vncserver :1 -geometry 1920x1080 -depth 24
```

### Change noVNC Port
```bash
pkill -f novnc_proxy
nohup /tmp/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 8080 > /tmp/novnc.log 2>&1 &
```

Then access at: `http://<ip>:8080/vnc.html`

### Use Different Display Number
```bash
# Start on display :2 (port 5902)
vncserver :2 -geometry 1920x1080 -depth 24

# Update noVNC to connect to it
pkill -f novnc_proxy
nohup /tmp/noVNC/utils/novnc_proxy --vnc localhost:5902 --listen 6080 > /tmp/novnc.log 2>&1 &
```

---

## Summary

**Access Points:**
- noVNC Web Interface: `http://<ip>:6080/vnc.html`
- VNC Direct: `<ip>:5901` (password: password)

**Key Ports:**
- 5901 - VNC server
- 6080 - noVNC web proxy

**Critical Fix:**
The blank screen issue is resolved by adding these lines to `~/.vnc/xstartup`:
```bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
```

This prevents XFCE session manager conflicts that cause the desktop not to load properly.

**Quick Start:**
```bash
# Setup (one time)
mkdir -p ~/.vnc
echo "password" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
EOF
chmod +x ~/.vnc/xstartup
cd /tmp && git clone https://github.com/novnc/noVNC.git

# Start services
vncserver :1 -geometry 1920x1080 -depth 24
nohup /tmp/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080 > /tmp/novnc.log 2>&1 &

# Access
# Open browser to http://localhost:6080/vnc.html
```

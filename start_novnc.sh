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

#!/bin/bash

echo "[+] Stopping noVNC Environment..."

# Stop noVNC
echo "[+] Stopping noVNC proxy..."
pkill -f novnc_proxy

# Stop VNC
echo "[+] Stopping VNC server..."
vncserver -kill :1

echo "[+] noVNC Environment stopped."

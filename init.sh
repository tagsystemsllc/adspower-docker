#!/bin/bash
set -e

# Clean up stale X locks from previous runs
rm -f /tmp/.X99-lock /tmp/.X11-unix/X99 2>/dev/null || true

# Start dbus
if [ ! -d /run/dbus ]; then
    sudo mkdir -p /run/dbus
fi
sudo dbus-daemon --system --fork 2>/dev/null || true

# Set display
export DISPLAY=:99

# Start Xvfb
Xvfb :99 -screen 0 1920x1080x24 &
sleep 1

# Start LXDE
startlxde &
sleep 2

# Start x11vnc (no password, listening on all interfaces)
x11vnc -display :99 -forever -shared -rfbport 5900 &

echo "VNC server started on port 5900"

# Start AdsPower
adspower_global \
    --headless=true \
    --api-key=f9ba2f7b76829f32b15a6a7cecfee3f1223a47afe70b7c65 \
    --api-port=50325 &

echo "AdsPower started on port 50325"

# Keep container running
wait


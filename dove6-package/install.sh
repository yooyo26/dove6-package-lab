#!/bin/sh
set -eu

echo "Installing Dove6 package..."

if ! id dove6 >/dev/null 2>&1; then
  echo "Creating dove6 user..."
  sudo useradd --system --home /opt/dove6 --shell /usr/sbin/nologin dove6
fi

echo "Copying application files..."
sudo mkdir -p /opt/dove6
sudo cp -r rootfs/opt/dove6/* /opt/dove6/

echo "Copying systemd service..."
sudo cp rootfs/etc/systemd/system/dove6.service /etc/systemd/system/dove6.service

echo "Setting ownership..."
sudo chown -R dove6:dove6 /opt/dove6

echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "Dove6 package installed."
echo "Next commands:"
echo "  sudo systemctl enable dove6"
echo "  sudo systemctl start dove6"
echo "  journalctl -u dove6 -f"

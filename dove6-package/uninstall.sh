#!/bin/sh
set -eu

echo "Uninstalling Dove6 package..."

if systemctl list-unit-files | grep -q '^dove6.service'; then
  echo "Stopping Dove6 service..."
  sudo systemctl stop dove6 || true

  echo "Disabling Dove6 service..."
  sudo systemctl disable dove6 || true
fi

echo "Removing systemd service..."
sudo rm -f /etc/systemd/system/dove6.service

echo "Reloading systemd..."
sudo systemctl daemon-reload
sudo systemctl reset-failed dove6 || true

echo "Removing application files..."
sudo rm -rf /opt/dove6

echo "Dove6 package uninstalled."
echo "Note: the dove6 system user was not removed."

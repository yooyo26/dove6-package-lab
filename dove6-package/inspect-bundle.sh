#!/bin/sh
set -eu

BUNDLE_DIR="./flutter-bundle"

echo "Inspecting Flutter bundle staging area..."

if [ ! -d "$BUNDLE_DIR" ]; then
  echo "FAIL: $BUNDLE_DIR does not exist"
  exit 1
fi

echo "Bundle directory: $BUNDLE_DIR"
echo

echo "Top-level contents:"
find "$BUNDLE_DIR" -maxdepth 2 -print

echo
echo "Expected future Flutter bundle files:"
echo "  $BUNDLE_DIR/dove6_client"
echo "  $BUNDLE_DIR/lib/"
echo "  $BUNDLE_DIR/data/"

echo
echo "Current status: staging area only"

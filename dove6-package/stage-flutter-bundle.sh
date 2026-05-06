#!/bin/sh
set -eu

BUNDLE_DIR="./flutter-bundle"
TARGET_APP="./rootfs/opt/dove6/app"
APPLY="false"

if [ "${1:-}" = "--apply" ]; then
  APPLY="true"
fi

echo "Preparing to stage Flutter bundle..."
echo "Bundle source: $BUNDLE_DIR"
echo "Target app directory: $TARGET_APP"
echo "Apply mode: $APPLY"
echo

fail() {
  echo "FAIL: $1"
  exit 1
}

[ -d "$BUNDLE_DIR" ] || fail "$BUNDLE_DIR does not exist"
[ -d "./rootfs/opt/dove6" ] || fail "./rootfs/opt/dove6 does not exist"

echo "Checking expected Flutter bundle files..."

[ -f "$BUNDLE_DIR/dove6_client" ] || fail "$BUNDLE_DIR/dove6_client missing"
echo "FOUND: $BUNDLE_DIR/dove6_client"

[ -d "$BUNDLE_DIR/lib" ] || fail "$BUNDLE_DIR/lib/ missing"
echo "FOUND: $BUNDLE_DIR/lib/"

[ -d "$BUNDLE_DIR/data" ] || fail "$BUNDLE_DIR/data/ missing"
echo "FOUND: $BUNDLE_DIR/data/"

echo
echo "Copy plan:"
echo "  $BUNDLE_DIR/dove6_client  ->  $TARGET_APP/dove6_client"
echo "  $BUNDLE_DIR/lib/          ->  $TARGET_APP/lib/"
echo "  $BUNDLE_DIR/data/         ->  $TARGET_APP/data/"
echo

if [ "$APPLY" != "true" ]; then
  echo "Dry-run only. No files were copied."
  echo "Run with --apply to copy the bundle into rootfs."
  exit 0
fi

echo "Applying Flutter bundle into package rootfs app directory..."

rm -rf "$TARGET_APP"
mkdir -p "$TARGET_APP"

cp "$BUNDLE_DIR/dove6_client" "$TARGET_APP/dove6_client"
cp -r "$BUNDLE_DIR/lib" "$TARGET_APP/lib"
cp -r "$BUNDLE_DIR/data" "$TARGET_APP/data"

chmod +x "$TARGET_APP/dove6_client"

echo "Flutter bundle staged successfully into $TARGET_APP."

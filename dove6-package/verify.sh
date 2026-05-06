#!/bin/sh
set -eu

echo "Verifying Dove6 package installation..."

fail() {
  echo "FAIL: $1"
  exit 1
}

pass() {
  echo "PASS: $1"
}

[ -d /opt/dove6 ] || fail "/opt/dove6 directory missing"
pass "/opt/dove6 directory exists"

[ -f /opt/dove6/VERSION ] || fail "/opt/dove6/VERSION missing"
pass "VERSION file exists"

[ -d /opt/dove6/app ] || fail "/opt/dove6/app directory missing"
pass "/opt/dove6/app directory exists"

[ -f /opt/dove6/app/dove6_client ] || fail "app/dove6_client missing"
pass "app/dove6_client exists"

[ -x /opt/dove6/app/dove6_client ] || fail "app/dove6_client is not executable"
pass "app/dove6_client is executable"

[ -d /opt/dove6/app/lib ] || fail "/opt/dove6/app/lib directory missing"
pass "/opt/dove6/app/lib directory exists"

[ -d /opt/dove6/app/data ] || fail "/opt/dove6/app/data directory missing"
pass "/opt/dove6/app/data directory exists"

[ -d /opt/dove6/app/data/flutter_assets ] || fail "/opt/dove6/app/data/flutter_assets directory missing"
pass "app flutter_assets directory exists"
[ -f /opt/dove6/app/lib/libapp.so ] || fail "libapp.so missing"
pass "libapp.so exists"

[ -f /opt/dove6/app/lib/libflutter_linux_gtk.so ] || fail "libflutter_linux_gtk.so missing"
pass "libflutter_linux_gtk.so exists"

[ -f /opt/dove6/app/data/icudtl.dat ] || fail "icudtl.dat missing"
pass "icudtl.dat exists"




[ -f /opt/dove6/bin/start-dove6 ] || fail "start-dove6 missing"
pass "start-dove6 exists"

[ -x /opt/dove6/bin/start-dove6 ] || fail "start-dove6 is not executable"
pass "start-dove6 is executable"

[ -f /opt/dove6/config/deployment.json ] || fail "deployment.json missing"
pass "deployment.json exists"

[ -f /opt/dove6/config/screen.json ] || fail "screen.json missing"
pass "screen.json exists"

[ -f /etc/systemd/system/dove6.service ] || fail "dove6.service missing"
pass "dove6.service exists"

systemctl list-unit-files | grep -q '^dove6.service' || fail "dove6.service not registered with systemd"
pass "dove6.service registered with systemd"

echo "Dove6 package verification passed."

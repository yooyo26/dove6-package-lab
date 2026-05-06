# Dove6 Package v0.5

This package is the Linux deployment package for the Dove6 Passenger Information Display application.

It prepares Dove6 to run like an embedded Linux appliance:

- installed under `/opt/dove6`
- managed by `systemd`
- run by a dedicated `dove6` system user
- restarted automatically if it crashes
- started automatically after boot
- logged through `journalctl`
- structured so it can later become a Yocto recipe

This package is not the final Yocto image yet.  
It is the packaging foundation that will later be converted into a custom embedded Linux image.

---

## Current milestone

Package v0.5 packages the real Dove6 Flutter Linux release bundle under `/opt/dove6/app`. Package v0.4 previously proved that the real debug app can launch through `systemd` on a real Ubuntu Linux machine.

Validated startup flow:

```text
systemd
  ↓
/opt/dove6/bin/start-dove6
  ↓
/opt/dove6/app/dove6_client
  ↓
real Dove6 Flutter app opens
```

---

## Installed layout

```text
/opt/dove6/
├── VERSION
├── app/
│   ├── dove6_client
│   ├── data/
│   │   ├── flutter_assets/
│   │   └── icudtl.dat
│   └── lib/
│       ├── libflutter_linux_gtk.so
│       ├── libscreen_retriever_plugin.so
│       └── libwindow_manager_plugin.so
├── bin/
│   └── start-dove6
└── config/
    ├── deployment.json
    └── screen.json
```

Systemd service:

```text
/etc/systemd/system/dove6.service
```

---

## Why the Flutter bundle lives in `/opt/dove6/app`

Flutter Linux bundles must stay together.

The executable expects its runtime folders to be nearby:

```text
dove6_client
data/
lib/
```

An earlier layout moved the executable into:

```text
/opt/dove6/bin/dove6_client
```

while keeping `data/` and `lib/` elsewhere. That caused Flutter to fail with:

```text
Not running in AOT mode but could not resolve the kernel binary.
Failed to start Flutter engine.
```

Package v0.4 fixes this by preserving the bundle under:

```text
/opt/dove6/app/
```

---

## Startup flow

Dove6 is started through a launcher script:

```text
systemd
  ↓
/opt/dove6/bin/start-dove6
  ↓
/opt/dove6/app/dove6_client
```

The `start-dove6` script is the stable entrypoint for the service.

It currently:

- sets the Dove6 home directory
- enters the Flutter app directory
- checks that the executable exists
- checks that the library directory exists
- sets `LD_LIBRARY_PATH`
- exports temporary lab display variables
- starts the Flutter app

---

## Current `start-dove6` purpose

The launcher exists so that `dove6.service` does not need to change every time startup logic changes.

Future startup needs can be added inside:

```text
/opt/dove6/bin/start-dove6
```

Examples:

- graphical session setup
- kiosk startup
- display environment variables
- config validation
- release/debug mode handling
- diagnostics
- safer production runtime checks

---

## Temporary lab display settings

The current `start-dove6` includes temporary display variables for Ayoub's Ubuntu Wayland desktop session:

```bash
DISPLAY=:0
WAYLAND_DISPLAY=wayland-0
XDG_SESSION_TYPE=wayland
XDG_RUNTIME_DIR=/run/user/1000
XAUTHORITY=/run/user/1000/.mutter-Xwaylandauth.NKDKO3
```

This was needed because `dove6.service` is a system service running as the `dove6` user, while the graphical desktop session belongs to Ayoub's normal user.

The lab also used:

```bash
xhost +SI:localuser:dove6
```

This allowed the `dove6` user to access the current desktop display.

Important:

```text
This is a lab solution, not the final kiosk/security design.
```

A future kiosk design should replace this with a clean graphical session model.

---

## Package directory layout

```text
~/dove6-package/
├── README.md
├── install.sh
├── uninstall.sh
├── verify.sh
├── inspect-bundle.sh
├── stage-flutter-bundle.sh
├── flutter-bundle/
│   ├── README.md
│   ├── dove6_client
│   ├── data/
│   └── lib/
└── rootfs/
    ├── etc/
    │   └── systemd/
    │       └── system/
    │           └── dove6.service
    └── opt/
        └── dove6/
            ├── VERSION
            ├── app/
            │   ├── dove6_client
            │   ├── data/
            │   └── lib/
            ├── bin/
            │   └── start-dove6
            └── config/
                ├── deployment.json
                └── screen.json
```

---

## Flutter bundle staging area

The staging folder is:

```text
~/dove6-package/flutter-bundle/
```

It is used to hold the Flutter Linux bundle before copying it into the package rootfs.

Expected Flutter bundle shape:

```text
flutter-bundle/
├── dove6_client
├── data/
└── lib/
```

Current real release bundle source used for v0.5:

```text
~/PIS/client/dove6_client/build/linux/x64/release/bundle/
```

Observed structure:

```text
bundle/
├── data/
│   ├── flutter_assets/
│   └── icudtl.dat
├── dove6_client
└── lib/
    ├── libflutter_linux_gtk.so
    ├── libscreen_retriever_plugin.so
    └── libwindow_manager_plugin.so
```

---

## Inspect Flutter bundle

Run:

```bash
cd ~/dove6-package
./inspect-bundle.sh
```

This prints the current contents of:

```text
./flutter-bundle
```

---

## Stage Flutter bundle into rootfs

Dry-run:

```bash
cd ~/dove6-package
./stage-flutter-bundle.sh
```

Expected copy plan:

```text
./flutter-bundle/dove6_client  ->  ./rootfs/opt/dove6/app/dove6_client
./flutter-bundle/lib/          ->  ./rootfs/opt/dove6/app/lib/
./flutter-bundle/data/         ->  ./rootfs/opt/dove6/app/data/
```

Apply:

```bash
./stage-flutter-bundle.sh --apply
```

This copies the bundle into:

```text
rootfs/opt/dove6/app/
```

---

## Install

From inside the package directory:

```bash
cd ~/dove6-package
./install.sh
```

The installer:

1. creates the `dove6` system user if missing
2. copies files to `/opt/dove6`
3. installs the systemd service
4. sets ownership to `dove6:dove6`
5. reloads systemd

---

## Verify installation

After installing, run:

```bash
cd ~/dove6-package
./verify.sh
```

Expected result:

```text
PASS: /opt/dove6 directory exists
PASS: VERSION file exists
PASS: /opt/dove6/app directory exists
PASS: app/dove6_client exists
PASS: app/dove6_client is executable
PASS: /opt/dove6/app/lib directory exists
PASS: /opt/dove6/app/data directory exists
PASS: app flutter_assets directory exists
PASS: start-dove6 exists
PASS: start-dove6 is executable
PASS: deployment.json exists
PASS: screen.json exists
PASS: dove6.service exists
PASS: dove6.service registered with systemd
Dove6 package verification passed.
```

---

## Start service

```bash
sudo systemctl start dove6
```

Check status:

```bash
systemctl status dove6 --no-pager
```

---

## Restart service

After reinstalling or changing package files:

```bash
sudo systemctl restart dove6
```

Check logs:

```bash
journalctl -u dove6 -n 50 --no-pager
```

Expected startup line:

```text
Starting Dove6 from /opt/dove6/app
```

On the validated Ubuntu laptop, the real Dove6 app opened successfully after this.

---

## Stop service

Stop current service:

```bash
sudo systemctl stop dove6
```

Stop and disable boot auto-start:

```bash
sudo systemctl disable --now dove6
```

Check status:

```bash
systemctl status dove6 --no-pager
```

Expected:

```text
Active: inactive (dead)
```

---

## View logs

Show recent logs:

```bash
journalctl -u dove6 -n 50 --no-pager
```

Follow live logs:

```bash
journalctl -u dove6 -f
```

---

## Test restart behavior

Kill the service process:

```bash
sudo systemctl kill dove6
```

Then check that systemd restarted it:

```bash
systemctl status dove6 --no-pager
journalctl -u dove6 -n 30 --no-pager
```

Expected behavior:

```text
systemd schedules restart
dove6.service starts again
start-dove6 runs again
```

---

## Enable startup on boot

```bash
sudo systemctl enable dove6
```

Verify:

```bash
systemctl is-enabled dove6
```

Expected:

```text
enabled
```

---

## Reboot test

```bash
sudo reboot
```

After reboot:

```bash
systemctl status dove6 --no-pager
journalctl -u dove6 -n 50 --no-pager
```

Expected:

```text
dove6.service starts automatically
start-dove6 runs
Dove6 app opens
```

This was validated earlier with the dummy client. Real-app boot behavior still needs future kiosk/session cleanup before final validation.

---

## Current validation status

Validated on a real Ubuntu Linux machine:

- package installs into `/opt/dove6`
- service installs into `/etc/systemd/system/dove6.service`
- service runs as `dove6` user
- service starts through `/opt/dove6/bin/start-dove6`
- Flutter bundle is preserved under `/opt/dove6/app`
- shared library issue fixed with `LD_LIBRARY_PATH`
- display authorization issue solved for lab using `xhost +SI:localuser:dove6`
- real Dove6 Flutter debug app opened successfully
- logs visible through `journalctl`
- service can be stopped with `systemctl stop dove6`

Validated on WSL:

- package files transferred successfully
- `rootfs/opt/dove6/app` layout is intact
- scripts are executable
- `stage-flutter-bundle.sh` corrected to stage into `rootfs/opt/dove6/app`
- WSL copy is suitable for package editing and documentation

---

## Package v0.4 changes historical 

Package v0.4 added/fixed:

- real Dove6 Flutter debug bundle was staged
- `/opt/dove6/app` layout introduced
- Flutter executable, `data/`, and `lib/` kept together
- `start-dove6` updated to run `/opt/dove6/app/dove6_client`
- `LD_LIBRARY_PATH` added for `/opt/dove6/app/lib`
- temporary lab display variables added
- `verify.sh` updated for `/opt/dove6/app`
- `stage-flutter-bundle.sh` corrected to stage into `rootfs/opt/dove6/app`
- real Flutter app successfully launched through systemd on Ubuntu

Validated end-to-end flow:

```text
real Flutter debug bundle
  ↓
flutter-bundle/
  ↓ stage-flutter-bundle.sh --apply
rootfs/opt/dove6/app/
  ↓ install.sh
/opt/dove6/app/
  ↓ systemd
/opt/dove6/bin/start-dove6
  ↓
/opt/dove6/app/dove6_client
  ↓
real Dove6 app opens
```

---
---

## Package v0.5 changes

Package v0.5 replaced the debug Flutter bundle with the release Flutter Linux bundle.

Release bundle source:

```text
~/PIS/client/dove6_client/build/linux/x64/release/bundle/
## Known limitations7

### Debug bundle

Current real app bundle is a debug build:

```text
/home/ayoub-nahji/PIS/build/linux/x64/debug/bundle
```

Package v0.5 now uses the release bundle. Future production work should validate this release bundle on the real Ubuntu machine or target hardware.

### Temporary graphical session access

Current display access is hardcoded for one Ubuntu desktop session. This is not production-ready.

Future work must design a proper kiosk/display session.

### WSL limitation

WSL is useful for:

- editing scripts
- documentation
- package structure
- Yocto preparation
- non-graphical checks

WSL should not be used as the final proof for:

- graphical app launch
- kiosk mode
- display lock-down
- boot/reboot behavior
- hardware display behavior

---

## Next milestones


### Package v0.6 — kiosk mode

- decide proper graphical session model
- remove personal hardcoded display variables
- avoid insecure lab-only `xhost` workflow
- full-screen startup
- hide mouse cursor
- disable screen sleep
- prevent desktop exposure

### Package v0.7 — hardening

- improve systemd hardening
- add restart limits
- improve logging
- review permissions
- reduce unnecessary access
- prepare for production-like deployment

### Yocto later

After package and kiosk behavior are stable:

- create `meta-dove6`
- write recipe to install `/opt/dove6`
- install `dove6.service`
- enable service in image
- test image with dummy/fake app first
- then test image with real release Dove6 app

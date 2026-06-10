#!/usr/bin/env bash
# Fix emulator-5554 "offline" / slow boot — Git Bash
set -e

export ANDROID_AVD_HOME="/d/Android/avd"
export ANDROID_SDK_ROOT="/d/Android/Sdk"
export ANDROID_HOME="/d/Android/Sdk"
export PATH="/d/Android/Sdk/platform-tools:/d/Android/Sdk/emulator:$PATH"

ADB="/d/Android/Sdk/platform-tools/adb.exe"
EMU="/d/Android/Sdk/emulator/emulator.exe"
AVD_DIR="/d/Android/avd/flutter_emulator.avd"

is_booted() {
  local id="$1"
  local boot
  boot=$("$ADB" -s "$id" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r\n')
  [ "$boot" = "1" ] && "$ADB" -s "$id" shell pm path android >/dev/null 2>&1
}

wake_device() {
  local id="$1"
  # Input service is not ready until boot finishes — failures here are normal.
  "$ADB" -s "$id" shell cmd input keyevent KEYCODE_WAKEUP >/dev/null 2>&1 \
    || "$ADB" -s "$id" shell input keyevent KEYCODE_WAKEUP >/dev/null 2>&1 \
    || true
}

echo "==> Stopping duplicate emulators..."
taskkill //F //IM qemu-system-x86_64.exe //IM emulator.exe 2>/dev/null || true
sleep 3

echo "==> Clearing AVD locks..."
rm -f "$AVD_DIR"/*.lock "$AVD_DIR"/hardware-qemu.ini.lock "$AVD_DIR"/multiinstance.lock 2>/dev/null || true
rm -rf "$AVD_DIR/snapshots" 2>/dev/null || true

echo "==> Resetting adb..."
"$ADB" kill-server 2>/dev/null || true
sleep 2
"$ADB" start-server

if ! tasklist.exe 2>/dev/null | grep -qi qemu-system-x86_64; then
  echo "==> Starting emulator..."
  "$EMU" -avd flutter_emulator -gpu swiftshader_indirect -no-snapshot-load -no-boot-anim -no-audio -no-metrics &
  sleep 12
fi

echo "==> Waiting for device (boot can take 3–8 min on low RAM/disk)..."
DEVICE=""
for i in $(seq 1 96); do
  LINE=$("$ADB" devices | grep -E 'emulator-[0-9]+' | head -1 || true)
  if echo "$LINE" | grep -q offline; then
    echo "  [$i] offline — reconnecting adb..."
    "$ADB" kill-server 2>/dev/null || true
    sleep 2
    "$ADB" start-server
    "$ADB" reconnect offline 2>/dev/null || true
    "$ADB" reconnect 2>/dev/null || true
    sleep 5
    continue
  fi
  if echo "$LINE" | grep -qw device; then
    DEVICE=$(echo "$LINE" | awk '{print $1}')
    if is_booted "$DEVICE"; then
      wake_device "$DEVICE"
      echo ""
      echo "OK: $DEVICE is online."
      "$ADB" devices -l
      echo ""
      echo "Run: flutter run -d $DEVICE"
      exit 0
    fi
    BOOT=$("$ADB" -s "$DEVICE" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r\n')
    ANIM=$("$ADB" -s "$DEVICE" shell getprop init.svc.bootanim 2>/dev/null | tr -d '\r\n')
    echo "  [$i] boot_completed=$BOOT bootanim=$ANIM"
  else
    echo "  [$i] waiting for emulator in adb..."
  fi
  sleep 5
done

echo "ERROR: emulator did not finish boot. Free disk on C: and D: (need 2+ GB each), then run: .\\fix-emulator.ps1"
exit 1

#!/usr/bin/env bash
# Auto-configure Android emulator TTS (Git Bash).
set -e
ADB="/d/Android/Sdk/platform-tools/adb.exe"
DEVICE=$("$ADB" devices | grep -E 'emulator-[0-9]+' | grep -w device | head -1 | awk '{print $1}')
if [ -z "$DEVICE" ]; then
  echo "No emulator online. Start emulator first."
  exit 1
fi
echo "==> TTS setup on $DEVICE ..."
"$ADB" -s "$DEVICE" shell media volume --stream 3 --set 15 2>/dev/null || true
for _ in 1 2 3 4 5 6 7 8; do
  "$ADB" -s "$DEVICE" shell input keyevent KEYCODE_VOLUME_UP 2>/dev/null || true
done
for pkg in com.google.android.tts com.google.android.apps.speechservices; do
  if "$ADB" -s "$DEVICE" shell pm list packages "$pkg" 2>/dev/null | grep -q "$pkg"; then
    echo "==> Default engine: $pkg"
    "$ADB" -s "$DEVICE" shell settings put secure tts_default_synth "$pkg" 2>/dev/null || true
    break
  fi
done
"$ADB" -s "$DEVICE" shell am start -a android.speech.tts.engine.INSTALL_TTS_DATA 2>/dev/null || true
echo "==> TTS setup done."

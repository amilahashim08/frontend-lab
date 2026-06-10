#!/usr/bin/env bash
# Run Frontend Lab on Android emulator (Git Bash)
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"
mkdir -p "$GRADLE_USER_HOME" "$PUB_CACHE"

# Git Bash / profile may set GRADLE_USER_HOME=D:\gradle — causes JVM OOM crashes
if [ -n "${GRADLE_USER_HOME_OLD:-}" ] || [ "$GRADLE_USER_HOME" = "/d/gradle" ] || [ -d "/d/gradle/daemon" ]; then
  echo "==> Stopping old Gradle (wrong folder D:/gradle)..."
  taskkill //F //IM java.exe 2>/dev/null || true
  sleep 2
fi
export GRADLE_USER_HOME="/d/gradle-home"
# SDK adb MUST be first (before WinGet platform-tools)
export PATH="/d/Android/Sdk/platform-tools:/d/Android/Sdk/emulator:$PATH"

PROJECT_DIR="$SCRIPT_DIR"
cd "$PROJECT_DIR"

ADB="/d/Android/Sdk/platform-tools/adb.exe"

is_online() {
  local line id boot anim
  line=$("$ADB" devices | grep -E 'emulator-[0-9]+' | grep -w device | head -1 || true)
  [ -z "$line" ] && return 1
  id=$(echo "$line" | awk '{print $1}')
  boot=$("$ADB" -s "$id" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r\n')
  [ "$boot" = "1" ] && return 0
  [ "$boot" = "1" ] && "$ADB" -s "$id" shell pm path android >/dev/null 2>&1
}

# Start emulator when none is running (plain "flutter run" only sees Windows/Chrome otherwise)
if ! "$ADB" devices | grep -qE 'emulator-[0-9]+'; then
  echo "==> No emulator detected — starting flutter_emulator..."
  "/d/Android/Sdk/emulator/emulator.exe" -avd flutter_emulator -gpu swiftshader_indirect -no-snapshot-load -no-boot-anim -no-audio -no-metrics &
  sleep 10
fi

if "$ADB" devices | grep -qE 'emulator-[0-9]+[[:space:]]+offline' || ! is_online; then
  echo "==> Fixing emulator / adb..."
  bash "$PROJECT_DIR/fix-emulator.sh"
fi

flutter config --no-enable-native-assets 2>/dev/null || true
flutter pub get

DEVICE=$("$ADB" devices | grep -E 'emulator-[0-9]+' | grep -w device | head -1 | awk '{print $1}')
if [ -z "$DEVICE" ]; then
  echo "ERROR: No online emulator. Run: bash fix-emulator.sh"
  exit 1
fi

APK="$PROJECT_DIR/android/app/build/outputs/flutter-apk/app-debug.apk"
APK_BACKUP="$PROJECT_DIR/build/app/outputs/flutter-apk/app-debug.apk"

if [ ! -f "$APK" ] && [ -f "$APK_BACKUP" ]; then
  mkdir -p "$(dirname "$APK")"
  cp "$APK_BACKUP" "$APK"
fi

if [ ! -f "$APK" ]; then
  echo "==> No APK yet. Building (emulator will stop during build to save RAM)..."
  powershell.exe -ExecutionPolicy Bypass -File "$PROJECT_DIR/build-and-run.ps1"
  exit $?
fi

echo "==> Installing APK on $DEVICE (do not use plain flutter run + Windows)..."
"$ADB" -s "$DEVICE" install -r "$APK"
echo "==> Auto TTS setup (volume + Google voice engine)..."
bash "$PROJECT_DIR/setup-tts.sh" || true
"$ADB" -s "$DEVICE" shell am start -n com.interactivefrontendlab.interactive_frontend_lab/.MainActivity
echo ""
echo "App is running on $DEVICE"
echo "Hot reload: flutter attach -d $DEVICE"

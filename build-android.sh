#!/usr/bin/env bash
# Build APK without emulator (saves RAM). Then install with: bash run.sh
set -e

export JAVA_HOME="/c/Program Files/Android/Android Studio/jbr"
export ANDROID_AVD_HOME="/d/Android/avd"
export ANDROID_SDK_ROOT="/d/Android/Sdk"
export ANDROID_HOME="/d/Android/Sdk"
export GRADLE_USER_HOME="/d/gradle-home"
export PUB_CACHE="/d/pub-cache"
export JAVA_TOOL_OPTIONS="-Xmx768m -XX:MaxMetaspaceSize=512m"
export GRADLE_OPTS="-Xmx768m -XX:MaxMetaspaceSize=512m"
export PATH="/d/Android/Sdk/platform-tools:/d/Android/Sdk/emulator:$PATH"

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "==> Stopping emulator + Java (frees RAM for Gradle)..."
taskkill //F //IM java.exe //IM qemu-system-x86_64.exe //IM emulator.exe 2>/dev/null || true
sleep 3

FREE_KB=$(wmic logicaldisk where "name='D:'" get freespace 2>/dev/null | tail -1 | tr -d ' \r')
if [ -n "$FREE_KB" ] && [ "$FREE_KB" -lt 3000000000 ] 2>/dev/null; then
  echo "==> Low disk on D: — cleaning Gradle caches..."
  rm -rf "/d/gradle-home/caches" "$PROJECT_DIR/android/app/build" "$PROJECT_DIR/build" 2>/dev/null || true
fi

flutter pub get
flutter build apk --debug
echo "==> APK ready. Start emulator and run: bash run.sh"

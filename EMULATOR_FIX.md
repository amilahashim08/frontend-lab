# Android emulator troubleshooting

## `adb devices` shows `offline`

1. **Run only one emulator** — duplicates cause offline:
   `taskkill /F /IM qemu-system-x86_64.exe /IM emulator.exe`
2. **Use SDK adb** (put `D:\Android\Sdk\platform-tools` first on PATH; avoid WinGet `adb`).
3. **Wait 1–2 minutes** after the emulator window opens — `offline` often becomes `device` during first boot.
4. **Do not** start Android Studio emulator and `emulator.exe` at the same time.

```bash
export PATH="/d/Android/Sdk/platform-tools:/d/Android/Sdk/emulator:$PATH"
adb devices
flutter run -d emulator-5554
```

Use `.\run.ps1` on PowerShell. Do **not** use `--target-platform` with `flutter run`.

---

# Why the emulator “blinks” and closes

## What you see

1. Emulator window **flashes** for 1–2 seconds, then **disappears**.
2. `flutter run` only lists **Windows / Chrome / Edge** (no Android).
3. If you pick **Windows**, you get: *Unable to find suitable Visual Studio toolchain*.

That is **not** your app crashing — the **Android emulator never fully starts**.

## Root cause

Your emulator (`flutter_emulator`) is configured to create a **~7.3 GB** virtual phone data partition on **D:**.

Right now **D:** has only about **~6.8 GB free**, so the emulator logs:

```text
FATAL | Not enough space to create userdata partition.
      Available: ~6794 MB, need 7372.80 MB
```

Then it **exits immediately** → looks like a “blink”.

## Fix (pick one)

### Option A — Android Studio (recommended)

1. Open **Android Studio** → **Device Manager** (phone icon).
2. Click **⋮** on **flutter_emulator** → **Edit**.
3. Show **Advanced Settings**.
4. Set **Internal Storage** to **2048 MB** (2 GB), not 6 GB.
5. Click **Finish**, then **▶ Play** to start the emulator.
6. Wait until the Android home screen appears.
7. In Git Bash:

```bash
adb devices
# must show: emulator-5554   device

cd "/d/react-native-project/interactive frontend lab"
flutter run -d emulator-5554 --target-platform android-x64
```

Use the id from `adb devices` if different.

### Option B — Free more space on D:

Free at least **2 GB more** on **D:** (delete old `node_modules`, `build` folders, or move projects).

Then run:

```bash
./run.sh
```

### Option C — Run in Chrome now (works without emulator)

```bash
cd "/d/react-native-project/interactive frontend lab"
flutter run -d chrome
```

## Important: do not pick Windows

When `flutter run` asks:

```text
[1]: Windows  [2]: Chrome  [3]: Edge
```

**Do not choose 1** unless Visual Studio C++ tools are installed.

For Android, the emulator must be running first, then:

```bash
flutter run -d emulator-5554
```

Never run plain `flutter run` without `-d` if you want the emulator.

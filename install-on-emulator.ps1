# Install and open the app on emulator-5554 (use when APK already built).
$ErrorActionPreference = "Stop"
$env:Path = "D:\Android\Sdk\platform-tools;" + $env:Path
$adb = "D:\Android\Sdk\platform-tools\adb.exe"

$apk = Join-Path $PSScriptRoot "android\app\build\outputs\flutter-apk\app-debug.apk"
if (-not (Test-Path $apk)) {
    $apk = Join-Path $PSScriptRoot "build\app\outputs\flutter-apk\app-debug.apk"
}
if (-not (Test-Path $apk)) {
    Write-Host "APK not found. Run: .\build-and-open.ps1"
    exit 1
}

$device = (& $adb devices | Select-String "emulator-\d+\s+device" | ForEach-Object { ($_ -split "\s+")[0] } | Select-Object -First 1)
if (-not $device) { throw "No emulator online. Check Android Emulator is running." }

& $adb -s $device install -r $apk
& $adb -s $device shell am start -n "com.interactivefrontendlab.interactive_frontend_lab/.MainActivity"
Write-Host "App launched on $device"

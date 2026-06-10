# Safe run on emulator: build WITHOUT emulator, then install + attach.
# Use this instead of "flutter run" (which OOMs when emulator + Gradle run together).
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$apk = "android\app\build\outputs\flutter-apk\app-debug.apk"
if (-not (Test-Path $apk)) {
    Write-Host "No APK yet — building first (stops emulator to free RAM)..."
    & "$PSScriptRoot\build-and-run.ps1"
    exit $LASTEXITCODE
}

$env:Path = "D:\Android\Sdk\platform-tools;D:\Android\Sdk\emulator;" + $env:Path
$adb = "D:\Android\Sdk\platform-tools\adb.exe"

$device = & $adb devices | Select-String "emulator-\d+\s+device" | ForEach-Object { ($_ -split "\s+")[0] } | Select-Object -First 1
if (-not $device) {
    Write-Host "Starting emulator..."
    & "$PSScriptRoot\build-and-run.ps1"
    exit $LASTEXITCODE
}

Write-Host "Installing on $device ..."
& $adb -s $device install -r $apk
& $adb -s $device shell am start -n com.interactivefrontendlab.interactive_frontend_lab/.MainActivity
Write-Host ""
Write-Host "App launched. For hot reload: flutter attach -d $device"

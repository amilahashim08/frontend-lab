# Quick run: install existing APK if present, else use build-and-run.ps1
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$apk = "android\app\build\outputs\flutter-apk\app-debug.apk"
if (Test-Path $apk) {
    & "$PSScriptRoot\install-on-emulator.ps1"
    Write-Host ""
    Write-Host "Tip: After changing Dart code, run: flutter attach -d emulator-5554"
    exit 0
}

Write-Host "No APK found — running full build (stops emulator during Gradle)..."
& "$PSScriptRoot\build-and-run.ps1"

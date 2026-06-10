# Build and launch Interactive Frontend Lab on the Android emulator.
$ErrorActionPreference = "Stop"

$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:ANDROID_AVD_HOME = "D:\Android\avd"
$env:ANDROID_SDK_ROOT = "D:\Android\Sdk"
$env:ANDROID_HOME = "D:\Android\Sdk"
$env:PUB_CACHE = "D:\pub-cache"
$env:GRADLE_USER_HOME = "D:\gradle-home"
$env:Path = "D:\Android\Sdk\platform-tools;D:\Android\Sdk\emulator;" + $env:Path

$adb = "D:\Android\Sdk\platform-tools\adb.exe"
Set-Location $PSScriptRoot

# Need ~1.5 GB free on D: for Gradle + APK
$freeGb = (Get-PSDrive D).Free / 1GB
if ($freeGb -lt 1.2) {
    Write-Host "Low disk on D: ($([math]::Round($freeGb,2)) GB). Cleaning Gradle caches..."
    Remove-Item "$env:GRADLE_USER_HOME\caches", "$env:GRADLE_USER_HOME\daemon" -Recurse -Force -ErrorAction SilentlyContinue
}

$device = (& $adb devices | Select-String "emulator-\d+\s+device" | ForEach-Object { ($_ -split "\s+")[0] } | Select-Object -First 1)
if (-not $device) {
    Write-Host "Starting emulator..."
    if (Get-Process qemu-system-x86_64 -ErrorAction SilentlyContinue) {
        & $adb kill-server; Start-Sleep 2; & $adb start-server
    } else {
        Start-Process "D:\Android\Sdk\emulator\emulator.exe" -ArgumentList "-avd","flutter_emulator","-gpu","swiftshader_indirect","-no-snapshot-load","-no-audio","-no-metrics"
    }
    $deadline = (Get-Date).AddMinutes(5)
    do {
        Start-Sleep 5
        $device = (& $adb devices | Select-String "emulator-\d+\s+device" | ForEach-Object { ($_ -split "\s+")[0] } | Select-Object -First 1)
    } while (-not $device -and (Get-Date) -lt $deadline)
}
if (-not $device) { throw "No emulator online. Run: adb devices" }

Write-Host "Device: $device"
flutter pub get
flutter run -d $device

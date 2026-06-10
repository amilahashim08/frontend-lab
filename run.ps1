# Run Frontend Lab on Android emulator (PowerShell)
$ErrorActionPreference = "Stop"

$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:ANDROID_AVD_HOME = "D:\Android\avd"
$env:ANDROID_SDK_ROOT = "D:\Android\Sdk"
$env:ANDROID_HOME = "D:\Android\Sdk"
$env:GRADLE_USER_HOME = "D:\gradle-home"
$env:PUB_CACHE = "D:\pub-cache"
$env:JAVA_TOOL_OPTIONS = "-Xmx768m -XX:MaxMetaspaceSize=512m"
$env:GRADLE_OPTS = "-Xmx768m -XX:MaxMetaspaceSize=512m"
$env:Path = "D:\Android\Sdk\platform-tools;D:\Android\Sdk\emulator;" + $env:Path
New-Item -ItemType Directory -Force -Path $env:PUB_CACHE, $env:GRADLE_USER_HOME | Out-Null

Set-Location $PSScriptRoot

& "$PSScriptRoot\kill-gradle-lock.ps1" | Out-Null

$adb = "D:\Android\Sdk\platform-tools\adb.exe"

function Test-EmulatorDevice {
    $line = (& $adb devices 2>&1) | Where-Object { $_ -match 'emulator-\d+\s+device' } | Select-Object -First 1
    if (-not $line) { return $null }
    $id = ($line -split '\s+')[0]
    $boot = (& $adb -s $id shell getprop sys.boot_completed 2>&1).Trim()
    if ($boot -eq '1') { return $id }
    return $null
}

$offline = (& $adb devices 2>&1) | Where-Object { $_ -match 'emulator-\d+\s+offline' }
$device = Test-EmulatorDevice

if ($offline -or -not $device) {
    Write-Host "==> Fixing emulator / adb (offline or not booted)..."
    & "$PSScriptRoot\fix-emulator.ps1"
    $device = Test-EmulatorDevice
}

if (-not $device) {
    Write-Host "ERROR: Emulator still not online. Run: .\fix-emulator.ps1"
    exit 1
}

$apk = Join-Path $PSScriptRoot "android\app\build\outputs\flutter-apk\app-debug.apk"
if ((Get-PSDrive D).Free / 1GB -lt 0.8) {
    Remove-Item "$env:GRADLE_USER_HOME\caches" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "==> Getting dependencies..."
flutter pub get

if (Test-Path $apk) {
    $dest = Join-Path $PSScriptRoot "build\app\outputs\flutter-apk"
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Copy-Item $apk (Join-Path $dest "app-debug.apk") -Force
}

Write-Host "==> Running on $device ..."
flutter run -d $device

# Build APK on D: (needs ~2 GB free on D:). Fixes Kotlin cross-drive + repo errors.
$ErrorActionPreference = "Stop"

$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:PUB_CACHE = "D:\pub-cache"
$env:GRADLE_USER_HOME = "D:\gradle-home"
$env:ANDROID_SDK_ROOT = "D:\Android\Sdk"
$env:ANDROID_HOME = "D:\Android\Sdk"
$env:Path = "D:\Android\Sdk\platform-tools;D:\Android\Sdk\emulator;" + $env:Path

New-Item -ItemType Directory -Force -Path $env:PUB_CACHE, $env:GRADLE_USER_HOME | Out-Null

$freeGb = (Get-PSDrive D).Free / 1GB
if ($freeGb -lt 1.5) {
    Write-Host "ERROR: D: drive needs at least 1.5 GB free (has $([math]::Round($freeGb,2)) GB)."
    Write-Host "Delete D:\gradle-home\caches or old projects, then retry."
    exit 1
}

Set-Location $PSScriptRoot

Write-Host "==> Cleaning old builds..."
flutter clean | Out-Null
Remove-Item "$env:PUB_CACHE\hosted\pub.dev\shared_preferences_android-*\android\build" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "==> pub get (PUB_CACHE on D:)..."
flutter pub get

Write-Host "==> Building debug APK..."
flutter build apk --debug

$apk = Get-ChildItem -Path "build\app\outputs\flutter-apk\app-debug.apk" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($apk) {
    Write-Host "OK: $($apk.FullName)"
} else {
    Write-Host "Build finished but APK path not found. Check build\app\outputs\flutter-apk\"
}

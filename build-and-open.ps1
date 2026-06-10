# Build APK, install, and open on emulator (avoids Gradle lock / path issues).
$ErrorActionPreference = "Stop"

& "$PSScriptRoot\kill-gradle-lock.ps1"

$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:ANDROID_SDK_ROOT = "D:\Android\Sdk"
$env:PUB_CACHE = "D:\pub-cache"
$env:GRADLE_USER_HOME = "D:\gradle-home"
$env:Path = "D:\Android\Sdk\platform-tools;D:\Android\Sdk\emulator;" + $env:Path

Set-Location $PSScriptRoot

# Need free space on D: for packaging (~500 MB)
$freeGb = (Get-PSDrive D).Free / 1GB
if ($freeGb -lt 0.8) {
    Write-Host "Low disk on D:. Removing Gradle caches..."
    Remove-Item "$env:GRADLE_USER_HOME\caches" -Recurse -Force -ErrorAction SilentlyContinue
}

flutter pub get

$apkOut = "android\app\build\outputs\flutter-apk\app-debug.apk"
if (-not (Test-Path $apkOut)) {
    flutter build apk --debug
}

# Flutter looks for APK under build/ — copy so `flutter run` works later
$flutterApkDir = "build\app\outputs\flutter-apk"
New-Item -ItemType Directory -Force -Path $flutterApkDir | Out-Null
Copy-Item $apkOut "$flutterApkDir\app-debug.apk" -Force

& "$PSScriptRoot\install-on-emulator.ps1"

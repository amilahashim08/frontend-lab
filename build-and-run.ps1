# Reliable build + run on emulator (low RAM). Stops emulator during Gradle to avoid OOM.
$ErrorActionPreference = "Stop"

$ProjectRoot = $PSScriptRoot
$adb = "D:\Android\Sdk\platform-tools\adb.exe"
$emu = "D:\Android\Sdk\emulator\emulator.exe"
$apk = Join-Path $ProjectRoot "android\app\build\outputs\flutter-apk\app-debug.apk"

$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:GRADLE_USER_HOME = "D:\gradle-home"
$env:ANDROID_SDK_ROOT = "D:\Android\Sdk"
$env:ANDROID_HOME = "D:\Android\Sdk"
$env:ANDROID_AVD_HOME = "D:\Android\avd"
$env:PUB_CACHE = "D:\pub-cache"
# Do NOT set JAVA_TOOL_OPTIONS globally (also affects other JVMs). Gradle heap only:
$env:JAVA_TOOL_OPTIONS = ""
$env:GRADLE_OPTS = "-Xmx512m -XX:MaxMetaspaceSize=384m -XX:+UseSerialGC"
$env:Path = "D:\Android\Sdk\platform-tools;D:\Android\Sdk\emulator;" + $env:Path
# C: is often full — use D: for temp so shader/Gradle writes do not fail
New-Item -ItemType Directory -Force -Path "D:\temp" | Out-Null
$env:TEMP = "D:\temp"
$env:TMP = "D:\temp"

Set-Location $ProjectRoot

function Stop-BuildProcesses {
    Write-Host "==> Freeing RAM (emulator + Java + Dart must be OFF during build)..."
    Get-Process java, dart, dartaotruntime, qemu-system-x86_64, emulator -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep 3
    cmd /c "taskkill /F /IM java.exe /IM dart.exe /IM dartaotruntime.exe /IM qemu-system-x86_64.exe /IM emulator.exe 2>nul" | Out-Null
    Start-Sleep 3
    Remove-Item "$ProjectRoot\android\.gradle\8.14\fileHashes\fileHashes.lock" -Force -ErrorAction SilentlyContinue
    Remove-Item "$ProjectRoot\android\hs_err_pid*.log", "$ProjectRoot\android\replay_pid*.log" -Force -ErrorAction SilentlyContinue
}

function Test-AndroidBooted {
    param([string]$Id)
    $boot = (& $adb -s $Id shell getprop sys.boot_completed 2>&1).ToString().Trim()
    if ($boot -eq "1") { return $true }
    $anim = (& $adb -s $Id shell getprop init.svc.bootanim 2>&1).ToString().Trim()
    if ($anim -eq "stopped") {
        $pm = & $adb -s $Id shell pm path android 2>&1
        if ($LASTEXITCODE -eq 0 -and "$pm" -match "package:") { return $true }
    }
    return $false
}

function Start-EmulatorAndWait {
    $existing = & $adb devices | Select-String "emulator-\d+\s+device" | ForEach-Object { ($_ -split "\s+")[0] } | Select-Object -First 1
    if ($existing -and (Test-AndroidBooted $existing)) { return $existing }
    if (-not (Get-Process qemu-system-x86_64 -ErrorAction SilentlyContinue)) {
    Write-Host "==> Starting emulator..."
    Start-Process $emu -ArgumentList "-avd","flutter_emulator","-gpu","swiftshader_indirect","-no-snapshot-load","-no-boot-anim","-no-audio","-no-metrics"
    }
    $deadline = (Get-Date).AddMinutes(5)
    do {
        Start-Sleep 6
        $d = & $adb devices | Select-String "emulator-\d+\s+device" | ForEach-Object { ($_ -split "\s+")[0] } | Select-Object -First 1
        if ($d -and (Test-AndroidBooted $d)) { return $d }
        if ($d) { Write-Host "  waiting for Android boot on $d..." }
    } while ((Get-Date) -lt $deadline)
    throw "Emulator did not come online."
}

# --- 1) Build without emulator running ---
Stop-BuildProcesses

$freeGb = [math]::Round((Get-PSDrive D).Free / 1GB, 2)
if ($freeGb -lt 2) {
    Write-Host "==> Low disk on D: ($freeGb GB). Running free-disk-space.ps1 ..."
    & "$PSScriptRoot\free-disk-space.ps1"
    if ($LASTEXITCODE -ne 0) { exit 1 }
}

Write-Host "==> Building APK (emulator STOPPED; needs ~4 GB free RAM and ~3 GB disk)..."
flutter pub get
# Single ABI = less RAM during compile than universal APK
flutter build apk --debug --target-platform android-x64
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Copy-Item $apk (Join-Path $ProjectRoot "build\app\outputs\flutter-apk\app-debug.apk") -Force
Write-Host "==> Build OK: $apk"

# --- 2) Start emulator and install ---
$device = Start-EmulatorAndWait
Write-Host "==> Installing on $device ..."
& $adb -s $device install -r $apk
Write-Host "==> Auto TTS setup (volume + voice engine)..."
& "$ProjectRoot\setup-tts.ps1"
& $adb -s $device shell am start -n com.interactivefrontendlab.interactive_frontend_lab/.MainActivity
Write-Host ""
Write-Host "App is running on $device"
Write-Host "For hot reload after edits: flutter attach -d $device"

# Fix emulator-5554 "offline" and start a single clean emulator instance.
$ErrorActionPreference = "Continue"

$SdkAdb = "D:\Android\Sdk\platform-tools\adb.exe"
$WinGetAdb = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools\adb.exe"
$Emulator = "D:\Android\Sdk\emulator\emulator.exe"
$AvdDir = "D:\Android\avd\flutter_emulator.avd"

$env:ANDROID_AVD_HOME = "D:\Android\avd"
$env:ANDROID_SDK_ROOT = "D:\Android\Sdk"
$env:ANDROID_HOME = "D:\Android\Sdk"
$env:Path = "D:\Android\Sdk\platform-tools;D:\Android\Sdk\emulator;" + $env:Path

function Stop-AllEmulators {
    Get-Process qemu-system-x86_64, emulator -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep 3
    cmd /c "taskkill /F /IM qemu-system-x86_64.exe /IM emulator.exe 2>nul" | Out-Null
    Start-Sleep 2
}

function Reset-Adb {
    & $SdkAdb kill-server 2>$null
    if (Test-Path $WinGetAdb) { & $WinGetAdb kill-server 2>$null }
    Start-Sleep 2
    & $SdkAdb start-server | Out-Null
}

function Test-AndroidBooted {
    param([string]$Id)
    $boot = (& $SdkAdb -s $Id shell getprop sys.boot_completed 2>&1).ToString().Trim()
    if ($boot -ne "1") { return $false }
    $pm = (& $SdkAdb -s $Id shell pm path android 2>&1).ToString()
    return ($pm -match "package:")
}

function Wake-Device {
    param([string]$Id)
    & $SdkAdb -s $Id shell cmd input keyevent KEYCODE_WAKEUP 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        & $SdkAdb -s $Id shell input keyevent KEYCODE_WAKEUP 2>$null | Out-Null
    }
}

function Wait-EmulatorOnline {
    param([int]$TimeoutMinutes = 10)
    $deadline = (Get-Date).AddMinutes($TimeoutMinutes)
    while ((Get-Date) -lt $deadline) {
        if (-not (Get-Process qemu-system-x86_64 -ErrorAction SilentlyContinue)) {
            throw "Emulator process exited before adb came online."
        }
        $line = (& $SdkAdb devices 2>$null) | Where-Object {
            $_ -match '^\s*emulator-\d+\s+(device|offline)\s*$'
        } | Select-Object -First 1
        if ($line -match 'emulator-(\d+)\s+offline') {
            Write-Host "  adb offline - reconnecting..."
            & $SdkAdb kill-server 2>$null
            Start-Sleep 2
            & $SdkAdb start-server | Out-Null
            & $SdkAdb reconnect offline 2>$null | Out-Null
            & $SdkAdb reconnect 2>$null | Out-Null
            Start-Sleep 5
            continue
        }
        if ($line -match 'emulator-(\d+)\s+device') {
            $id = "emulator-$($Matches[1])"
            if (Test-AndroidBooted $id) {
                Wake-Device $id
                return ,$id
            }
            $boot = (& $SdkAdb -s $id shell getprop sys.boot_completed 2>&1).ToString().Trim()
            $anim = (& $SdkAdb -s $id shell getprop init.svc.bootanim 2>&1).ToString().Trim()
            Write-Host "  boot_completed=$boot bootanim=$anim"
        } else {
            Write-Host "  waiting for emulator in adb..."
        }
        Start-Sleep 5
    }
    throw "Timed out waiting for emulator to finish boot. Free 2+ GB on C: and D:."
}

Write-Host "==> Stopping duplicate emulators..."
Stop-AllEmulators

Write-Host "==> Clearing AVD locks..."
foreach ($lock in @(
    "$AvdDir\hardware-qemu.ini.lock",
    "$AvdDir\multiinstance.lock",
    "$AvdDir\cache.img.lock"
)) {
    if (Test-Path $lock) { Remove-Item $lock -Force -ErrorAction SilentlyContinue }
}
if (Test-Path "$AvdDir\snapshots") {
    Remove-Item "$AvdDir\snapshots" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "==> Resetting adb (SDK only)..."
Reset-Adb

$running = Get-Process qemu-system-x86_64 -ErrorAction SilentlyContinue
if (-not $running) {
    Write-Host "==> Starting emulator (single instance)..."
    Start-Process $Emulator -ArgumentList @(
        "-avd", "flutter_emulator",
        "-gpu", "swiftshader_indirect",
        "-no-snapshot-load",
        "-no-boot-anim",
        "-no-audio",
        "-no-metrics"
    ) -WindowStyle Normal
    Start-Sleep 8
} else {
    Write-Host "==> Emulator already running; fixing adb only..."
}

Write-Host "==> Waiting until adb reports 'device' and boot completes..."
$device = Wait-EmulatorOnline
Write-Host ""
Write-Host "OK: $device is online."
& $SdkAdb devices -l
Write-Host ""
Write-Host "Run the app: flutter run -d $device"

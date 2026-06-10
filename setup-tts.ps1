# Auto-configure Android emulator/device for TTS (run after emulator is online).
$ErrorActionPreference = "Continue"
$adb = "D:\Android\Sdk\platform-tools\adb.exe"

function Get-Device {
    $line = & $adb devices | Select-String "emulator-\d+\s+device" | Select-Object -First 1
    if (-not $line) { return $null }
    return ($line -split "\s+")[0]
}

$device = Get-Device
if (-not $device) {
    Write-Host 'No emulator online. Start emulator first, then re-run setup-tts.ps1'
    exit 1
}

Write-Host "==> TTS setup on $device ..."

& $adb -s $device shell media volume --stream 3 --set 15 2>$null
& $adb -s $device shell media volume --stream 5 --set 15 2>$null
1..8 | ForEach-Object { & $adb -s $device shell input keyevent KEYCODE_VOLUME_UP 2>$null }

$engines = & $adb -s $device shell pm list packages 2>$null | Select-String "tts|speech"
Write-Host "TTS packages: $engines"

foreach ($pkg in @("com.google.android.tts", "com.google.android.apps.speechservices")) {
    $found = & $adb -s $device shell pm list packages $pkg 2>$null
    if ($found -match $pkg) {
        Write-Host "==> Setting default engine: $pkg"
        & $adb -s $device shell settings put secure tts_default_synth $pkg 2>$null
        break
    }
}

Write-Host '==> Triggering voice data install intent...'
& $adb -s $device shell am start -a android.speech.tts.engine.INSTALL_TTS_DATA 2>$null

Write-Host '==> TTS setup done. Reopen the app and tap the speaker icon.'
exit 0

# Fix: "Timeout waiting to lock file hash cache" — stop stuck Gradle/Java processes.
$ErrorActionPreference = "SilentlyContinue"
Set-Location $PSScriptRoot

Write-Host "Stopping Gradle daemons..."
if (Test-Path "android\gradlew.bat") {
    $env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
    Push-Location android
    .\gradlew.bat --stop 2>$null
    Pop-Location
}
Get-Process java -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 2
Remove-Item "android\.gradle\8.14\fileHashes\fileHashes.lock" -Force
Remove-Item "android\.gradle\8.14\checksums\*.lock" -Force
Write-Host "Done. You can run: flutter run -d emulator-5554"

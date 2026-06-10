# Frees space on D: before Gradle builds (needs ~3 GB free).
$ErrorActionPreference = "Continue"
$ProjectRoot = $PSScriptRoot

function Get-FreeGb([string]$Drive) {
    $d = Get-PSDrive -Name $Drive.TrimEnd(':') -ErrorAction SilentlyContinue
    if ($d) { return [math]::Round($d.Free / 1GB, 2) }
    return 0
}

Write-Host "D: free before cleanup: $(Get-FreeGb D) GB"

Get-Process java,qemu-system-x86_64,emulator -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 2

$apk = "$ProjectRoot\android\app\build\outputs\flutter-apk\app-debug.apk"
$apkBackup = "$ProjectRoot\build\app\outputs\flutter-apk\app-debug.apk"
if (Test-Path $apk) {
    New-Item -ItemType Directory -Force -Path (Split-Path $apkBackup) | Out-Null
    Copy-Item $apk $apkBackup -Force
}

$targets = @(
    "D:\gradle-home\caches",
    "$ProjectRoot\android\app\build\intermediates",
    "$ProjectRoot\android\app\build\tmp",
    "$ProjectRoot\android\app\build\kotlin",
    "$ProjectRoot\build",
    "$ProjectRoot\android\.gradle\8.14\fileHashes\fileHashes.lock"
)
foreach ($t in $targets) {
    if (Test-Path $t) {
        Write-Host "Removing $t ..."
        Remove-Item $t -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$free = Get-FreeGb D
Write-Host "D: free after cleanup: $free GB"
if ($free -lt 2) {
    Write-Host "WARNING: Less than 2 GB free on D:. Build may fail."
    Write-Host "Delete large folders manually or move GRADLE_USER_HOME to another drive."
    exit 1
}
exit 0

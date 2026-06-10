@echo off
REM Use this instead of plain "flutter run" — targets Android emulator.
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "%~dp0\run.ps1"

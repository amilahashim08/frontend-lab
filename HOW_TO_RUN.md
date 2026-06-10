# How to run this app

## Do not use plain `flutter run`

If no Android emulator is running, Flutter only lists **Windows**, **Chrome**, and **Edge**.  
Choosing **Windows** fails with:

> Unable to find suitable Visual Studio toolchain

This project targets **Android** (or **Chrome** for quick testing). You do not need Visual Studio unless you want a Windows desktop build.

## Recommended commands

| Goal | Git Bash | PowerShell |
|------|----------|------------|
| **Android** (emulator + run) | `bash run.sh` | `.\run.ps1` |
| **Android** (build + install, low RAM) | — | `.\build-and-run.ps1` |
| **Chrome** (fast, no emulator) | `flutter run -d chrome` | `flutter run -d chrome` |
| Fix offline emulator | `bash fix-emulator.sh` | `.\fix-emulator.ps1` |

## Android setup (one-time)

- SDK: `D:\Android\Sdk`
- AVD: `flutter_emulator` in `D:\Android\avd`
- Keep **≥ 3 GB free** on `D:` before Gradle builds

## App features (per unit)

- **Learn** — animated diagram, step chips, summary, **Listen** (text-to-speech)
- **Activity** — drag-and-drop practice (toast feedback on Check)
- **Quiz** — topic-specific questions inline (not generic React questions)

## If Gradle fails

1. `.\free-disk-space.ps1`
2. `.\build-and-run.ps1` (stops emulator during build)
3. `.\install-on-emulator.ps1` (if APK already exists)

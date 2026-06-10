#!/usr/bin/env bash
# Use this instead of plain "flutter run" — targets Android, not Windows.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec bash "$SCRIPT_DIR/run.sh"

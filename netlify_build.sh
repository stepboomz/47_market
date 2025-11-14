#!/usr/bin/env bash
set -e

# ไปที่โฟลเดอร์โปรเจกต์ (ที่เดียวกับสคริปต์)
cd "$(dirname "$0")"

FLUTTER_VERSION="${FLUTTER_VERSION:-stable}"

git clone --depth 1 -b "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$HOME/flutter"
export PATH="$HOME/flutter/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get

flutter build web --release

echo "=== LIST build/web ==="
ls -R build/web

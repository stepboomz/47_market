#!/usr/bin/env bash
set -e

# เลือกเวอร์ชันได้ตามที่ใช้งาน
FLUTTER_VERSION="${FLUTTER_VERSION:-stable}"

# ดึง Flutter มาไว้ในโฮมของ build machine
git clone --depth 1 -b "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$HOME/flutter"
export PATH="$HOME/flutter/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get


flutter build web --release

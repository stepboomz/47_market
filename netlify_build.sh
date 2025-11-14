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

# Clean previous builds to ensure fresh assets
flutter clean

# Build web with proper font rendering
flutter build web --release --web-renderer html --csp

# Ensure fonts are accessible
mkdir -p build/web/assets/fonts
cp -r assets/fonts/* build/web/assets/fonts/ 2>/dev/null || echo "No custom fonts found to copy"

echo "Build completed successfully"

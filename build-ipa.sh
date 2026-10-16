#!/usr/bin/env bash
# Builds an unsigned Voltex.ipa on a Mac (needs Xcode / Command Line Tools).
set -euo pipefail

cd "$(dirname "$0")"

echo "==> Building Voltex (Release, unsigned)…"
xcodebuild \
  -project Voltex.xcodeproj \
  -scheme Voltex \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  build

APP="build/Build/Products/Release-iphoneos/Voltex.app"
test -d "$APP" || { echo "Build product missing: $APP"; exit 1; }

echo "==> Packaging Voltex.ipa…"
rm -rf Payload Voltex.ipa
mkdir -p Payload
cp -R "$APP" Payload/
zip -qry Voltex.ipa Payload
rm -rf Payload

echo "==> Done: $(pwd)/Voltex.ipa"

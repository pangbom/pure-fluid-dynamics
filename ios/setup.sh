#!/bin/bash
# Arranges the flat files in this folder into the layout XcodeGen expects.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p Sources web/fonts Assets.xcassets/AppIcon.appiconset Assets.xcassets/LaunchBackground.colorset
cp App.swift Sources/
cp index.html web/
cp ./*.woff2 web/fonts/
cp AppIcon-1024.png Assets.xcassets/AppIcon.appiconset/
cat > Assets.xcassets/Contents.json <<'J'
{ "info": { "author": "xcode", "version": 1 } }
J
cat > Assets.xcassets/AppIcon.appiconset/Contents.json <<'J'
{ "images": [ { "filename": "AppIcon-1024.png", "idiom": "universal", "platform": "ios", "size": "1024x1024" } ],
  "info": { "author": "xcode", "version": 1 } }
J
cat > Assets.xcassets/LaunchBackground.colorset/Contents.json <<'J'
{ "colors": [ { "color": { "color-space": "srgb", "components": { "alpha": "1.000", "red": "0.027", "green": "0.035", "blue": "0.047" } }, "idiom": "universal" } ],
  "info": { "author": "xcode", "version": 1 } }
J

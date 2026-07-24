#!/usr/bin/env bash
set -euo pipefail

FLUTTER_BIN="${FLUTTER_BIN:-/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin/flutter}"

echo "== Flutter doctor =="
"$FLUTTER_BIN" doctor -v

echo
echo "== Tests =="
"$FLUTTER_BIN" test

echo
echo "== Analyzer =="
"$FLUTTER_BIN" analyze

echo
echo "== Android debug build =="
"$FLUTTER_BIN" build apk --debug

echo
echo "== iOS debug build, no codesign =="
"$FLUTTER_BIN" build ios --debug --no-codesign

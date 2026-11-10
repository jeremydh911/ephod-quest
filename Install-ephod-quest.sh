#!/bin/sh
# Install ephod-quest — Linux and macOS. Copies this tree and records the publisher.
set -e
ROOT="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
DEST="${INSTALL_HOME:-$HOME/ephod-quest}"
mkdir -p "$DEST"
cp -a "$ROOT"/. "$DEST"/
rm -rf "$DEST/.git"
chmod +x "$DEST/Install-ephod-quest.sh" "$DEST/Install-ephod-quest.command" 2>/dev/null || true
if [ "$(uname -s 2>/dev/null || echo)" = "Darwin" ]; then
  xattr -dr com.apple.quarantine "$DEST" 2>/dev/null || true
fi
if [ -f "$DEST/Makefile" ] && command -v make >/dev/null 2>&1; then
  (cd "$DEST" && make) || echo "Build did not finish. The publisher record is installed."
fi
echo "Install ephod-quest → $DEST"
echo "Publisher: Ahanaai Company"
echo "DUNS: 149970889"
echo "Record: $DEST/PUBLISHER.txt"

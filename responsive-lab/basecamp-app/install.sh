#!/usr/bin/env bash
# Install the Responsive Lab into a Basecamp profile as a QML-only app (ui_qml, no backend).
# Shares the lab's pages (../qml/pages); Logos.* resolves from Basecamp's design system.
#   install.sh <basecamp user dir>     e.g. ~/.local/share/Logos/LogosBasecamp, or a --user-dir
# Restart Basecamp afterwards; the app appears as "Responsive Lab".
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
[ $# -eq 1 ] && [ -d "$1" ] || { echo "usage: $0 <basecamp user dir>" >&2; exit 2; }
dest="$1/plugins/responsive_lab"
rm -rf "$dest"; mkdir -p "$dest/qml"
cp "$here/manifest.json" "$here/icon.png" "$dest/"
cp "$here/Main.qml" "$dest/qml/Main.qml"
cp -r "$here/../qml/pages" "$dest/qml/pages"
printf 'linux-amd64' > "$dest/variant"
echo "installed: $dest"

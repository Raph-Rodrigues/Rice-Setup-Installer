#!/bin/bash

echo -e "\033[1;35m[ CURSORS ]\033[0m Installing Bibata Modern Classic cursor..."

CURSOR_DIR="$HOME/.local/share/icons"
mkdir -p "$CURSOR_DIR"
TEMP_DIR=$(mktemp -d)

echo "Downloading Bibata-Modern-Classic..."
wget -qO "$TEMP_DIR/Bibata.tar.gz" "https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Classic.tar.gz"

echo "Extracting cursors..."
tar -xf "$TEMP_DIR/Bibata.tar.gz" -C "$CURSOR_DIR/"
rm -rf "$TEMP_DIR"

# Set for GTK/Gnome
echo "Applying to the system..."
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'

# Set for QT / Plasma (Adds to local index.theme)
mkdir -p "$HOME/.icons/default"
cat <<EOF >"$HOME/.icons/default/index.theme"
[Icon Theme]
Inherits=Bibata-Modern-Classic
EOF

# Apply permissions/overrides for Flatpak to recognize the theme
if command -v flatpak >/dev/null 2>&1; then
  echo "Granting cursor permissions to Flatpaks..."
  flatpak override --user --filesystem="$HOME/.local/share/icons/:ro"
  flatpak override --user --filesystem="$HOME/.icons/:ro"
  flatpak override --user --env=XCURSOR_THEME="Bibata-Modern-Classic"
fi

echo -e "\033[1;32m[ OK ]\033[0m Bibata cursor theme configured successfully!"

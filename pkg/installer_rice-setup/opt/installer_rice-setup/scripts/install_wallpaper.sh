#!/bin/bash

echo -e "\033[1;35m[ WALLPAPER ]\033[0m Configuring Wallpapers..."

# Locates the user's Pictures folder (independent of the system language)
PICTURES_DIR=$(xdg-user-dir PICTURES 2>/dev/null)
if [ -z "$PICTURES_DIR" ]; then
  PICTURES_DIR="$HOME/Pictures"
fi

DEST_DIR="$PICTURES_DIR/wallpaper"
mkdir -p "$DEST_DIR"

# Temporary directory for cloning
TEMP_DIR=$(mktemp -d)
echo "Cloning repository..."
git clone --depth=1 https://github.com/Raph-Rodrigues/one-dev-click.git "$TEMP_DIR"

if [ -d "$TEMP_DIR/Wallpapers" ]; then
  echo "Copying wallpapers to $DEST_DIR..."
  cp -r "$TEMP_DIR/Wallpapers/"* "$DEST_DIR/"
  echo -e "\033[1;32m[ OK ]\033[0m Wallpapers installed successfully!"
else
  echo -e "\033[1;31m[ ERROR ]\033[0m 'Wallpapers' folder not found in the repository."
fi

rm -rf "$TEMP_DIR"

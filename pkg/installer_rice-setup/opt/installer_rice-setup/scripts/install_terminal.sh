#!/bin/bash

echo -e "\033[1;35m[ TERMINAL ]\033[0m Installing Kitty and JetBrainsMono Nerd Font..."

# 1. Install Kitty via the system package manager
if command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --needed --noconfirm kitty unzip wget fontconfig
elif command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y kitty unzip wget fontconfig
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y kitty unzip wget fontconfig
elif command -v xbps-install >/dev/null 2>&1; then
  sudo xbps-install -Sy kitty unzip wget fontconfig
else
  echo -e "\033[1;31m[ ERROR ]\033[0m Unsupported package manager."
  exit 1
fi

# 2. Install Iosevka Nerd Font (Universal Method)
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
TEMP_FONT_DIR=$(mktemp -d)

echo "Downloading Iosevka Nerd Font (Latest Release)..."
wget -qO "$TEMP_FONT_DIR/Iosevka.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Iosevka.zip"

echo "Extracting the font..."
mkdir -p "$FONT_DIR/Iosevka"
unzip -qo "$TEMP_FONT_DIR/Iosevka.zip" -d "$FONT_DIR/Iosevka"

echo "Downloading JetBrainsMono Nerd Font (Latest Release)..."
wget -qO "$TEMP_FONT_DIR/JetBrainsMono.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

echo "Extracting the font..."
mkdir -p "$FONT_DIR/JetBrainsMono"
unzip -qo "$TEMP_FONT_DIR/JetBrainsMono.zip" -d "$FONT_DIR/JetBrainsMono"

# Update the system font cache to recognize the new font
echo "Updating font cache (fc-cache)..."
fc-cache -fv "$FONT_DIR" >/dev/null

rm -rf "$TEMP_FONT_DIR"

# 3. Configure Kitty with your "Rice" (one-dev-click)
echo "Configuring Kitty..."
TEMP_REPO=$(mktemp -d)
git clone --depth=1 https://github.com/Raph-Rodrigues/one-dev-click.git "$TEMP_REPO"

KITTY_CONFIG_DIR="$HOME/.config/kitty"

# Back up the user's current configuration (if it exists)
if [ -d "$KITTY_CONFIG_DIR" ]; then
  echo "Backing up old Kitty configuration to ~/.config/kitty.bak"
  rm -rf "${KITTY_CONFIG_DIR}.bak"
  mv "$KITTY_CONFIG_DIR" "${KITTY_CONFIG_DIR}.bak"
fi

mkdir -p "$HOME/.config"

# Checks if the folder exists in config/kitty or in the kitty root
if [ -d "$TEMP_REPO/config/kitty" ]; then
  cp -r "$TEMP_REPO/config/kitty" "$KITTY_CONFIG_DIR"
  echo -e "\033[1;32m[ OK ]\033[0m Kitty configurations applied!"
elif [ -d "$TEMP_REPO/kitty" ]; then
  cp -r "$TEMP_REPO/kitty" "$KITTY_CONFIG_DIR"
  echo -e "\033[1;32m[ OK ]\033[0m Kitty configurations applied!"
else
  echo -e "\033[1;33m[ WARNING ]\033[0m No Kitty configuration ('config/kitty' or 'kitty') found in the repository. Kitty will use the default theme."
fi

rm -rf "$TEMP_REPO"

echo -e "\033[1;32m[ OK ]\033[0m Installation of Kitty and Font finished successfully!"

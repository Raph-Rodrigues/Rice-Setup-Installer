#!/bin/bash

echo -e "\033[1;35m[ ICONS ]\033[0m Installing Papirus icon theme and utilities..."

# Detect distros and install dependencies
if command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --needed --noconfirm papirus-icon-theme kvantum qt5ct qt6ct

  # AUR packages (using paru or yay if available)
  if command -v paru >/dev/null; then
    paru -S --noconfirm papirus-folders nwg-look
  elif command -v yay >/dev/null; then
    yay -S --noconfirm papirus-folders nwg-look
  else
    echo "Warning: paru or yay not found. Could not install papirus-folders and nwg-look."
  fi
elif command -v apt-get >/dev/null 2>&1; then
  sudo add-apt-repository -y ppa:papirus/papirus
  sudo apt-get update
  sudo apt-get install -y papirus-icon-theme papirus-folders qt5ct qt6ct kvantum
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y papirus-icon-theme papirus-folders kvantum qt5ct qt6ct
elif command -v xbps-install >/dev/null 2>&1; then
  sudo xbps-install -Sy papirus-icon-theme papirus-folders kvantum qt5ct qt6ct
fi

# Set Papirus as default in GTK (Gnome/XFCE/etc)
echo "Configuring GTK..."
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

# Apply Papirus folder colors if the utility was installed
if command -v papirus-folders >/dev/null; then
  papirus-folders -C blue --theme Papirus-Dark
fi

echo -e "\033[1;32m[ OK ]\033[0m Icons configuration finished!"

#!/bin/bash

echo -e "\033[1;35m[ FILES ]\033[0m Installing Thunar, Yazi, and essential Plugins..."

install_yazi_binary() {
  echo "Yazi not found in the package manager. Downloading official binary..."
  TEMP_YAZI=$(mktemp -d)
  wget -qO "$TEMP_YAZI/yazi.zip" "https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip"
  unzip -qo "$TEMP_YAZI/yazi.zip" -d "$TEMP_YAZI/"
  sudo mv "$TEMP_YAZI"/yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/
  sudo mv "$TEMP_YAZI"/yazi-x86_64-unknown-linux-gnu/ya /usr/local/bin/
  rm -rf "$TEMP_YAZI"
}

# 1. Install via pacman (Arch Linux)
if command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --needed --noconfirm \
    thunar thunar-archive-plugin thunar-volman thunar-media-tags-plugin thunar-shares-plugin thunar-vcs-plugin \
    tumbler gvfs gvfs-mtp xarchiver \
    yazi ffmpegthumbnailer p7zip jq poppler fd ripgrep fzf zoxide imagemagick

# 2. Install via apt (Debian / Ubuntu / Mint)
elif command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y \
    thunar thunar-archive-plugin thunar-volman thunar-media-tags-plugin thunar-shares-plugin thunar-vcs-plugin \
    tumbler gvfs-backends file-roller \
    ffmpegthumbnailer p7zip-full jq poppler-utils fd-find ripgrep fzf zoxide imagemagick unzip wget

  # Try installing yazi via apt (Available in Debian Trixie/Ubuntu 24.04+)
  if apt-cache show yazi >/dev/null 2>&1; then
    sudo apt-get install -y yazi
  else
    install_yazi_binary
  fi

# 3. Install via dnf (Fedora)
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y \
    thunar thunar-archive-plugin thunar-volman thunar-media-tags-plugin thunar-shares-plugin thunar-vcs-plugin \ 
  tumbler gvfs file-roller \
    ffmpegthumbnailer p7zip p7zip-plugins jq poppler-utils fd-find ripgrep fzf zoxide ImageMagick unzip wget

  if dnf info yazi >/dev/null 2>&1; then
    sudo dnf install -y yazi
  else
    install_yazi_binary
  fi

# 4. Install via xbps (Void Linux)
elif command -v xbps-install >/dev/null 2>&1; then
  sudo xbps-install -Sy \
    Thunar thunar-archive-plugin thunar-volman thunar-media-tags-plugin tumbler gvfs file-roller \
    yazi ffmpegthumbnailer p7zip jq poppler fd ripgrep fzf zoxide ImageMagick unzip wget

else
  echo -e "\033[1;31m[ ERROR ]\033[0m Unsupported package manager."
  exit 1
fi

echo -e "\033[1;32m[ OK ]\033[0m File managers and plugins installed successfully!"

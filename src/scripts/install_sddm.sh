#!/bin/bash

echo -e "\033[1;35m[ LOGIN ]\033[0m Installing SDDM and configuring theme..."

config_sddm() {
  echo "Configuring SDDM..."
  # Clone the repository into a temporary directory
  TEMP_DIR=$(mktemp -d)
  echo "Cloning the one-dev-click repository..."
  git clone --depth=1 https://github.com/Raph-Rodrigues/one-dev-click.git "$TEMP_DIR"

  # Configure the theme
  if [ -d "$TEMP_DIR/config/sddm" ]; then
    THEME_SRC="$TEMP_DIR/config/sddm"
  elif [ -d "$TEMP_DIR/sddm" ]; then
    THEME_SRC="$TEMP_DIR/sddm"
  else
    THEME_SRC=""
  fi

  if [ -n "$THEME_SRC" ]; then
    THEME_NAME="sddm-astronout-theme"

    echo "Copying theme to /usr/share/sddm/themes/..."
    sudo mkdir -p /usr/share/sddm/themes/
    # Remove if it already exists to avoid conflicts
    sudo rm -rf "/usr/share/sddm/themes/$THEME_NAME"
    sudo cp -r "$THEME_SRC" "/usr/share/sddm/themes/$THEME_NAME"

    echo "Setting the theme as the system default..."
    sudo mkdir -p /etc/sddm.conf.d

    # Creates/Overwrites the configuration file to point to the new theme
    cat <<EOF | sudo tee /etc/sddm.conf.d/general.conf >/dev/null
[Theme]
Current=$THEME_NAME
EOF

    echo -e "\033[1;32m[ OK ]\033[0m SDDM and theme installed and configured successfully!"
  else
    echo -e "\033[1;31m[ ERROR ]\033[0m No SDDM theme folder ('config/sddm' or 'sddm') was found in the repository."
  fi

  # Clean up
  rm -rf "$TEMP_DIR"
}

# Detect distros and install dependencies
if command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --needed --noconfirm sddm sddm-astronaut-theme qt5-graphicaleffects qt5-quickcontrols2 qt5-svg
  config_sddm

  # AUR packages (using paru or yay if available)
  if command -v paru >/dev/null; then
    paru -S --noconfirm sddm sddm-astronaut-theme qt5-graphicaleffects qt5-quickcontrols2 qt5-svg
    config_sddm
  elif command -v yay >/dev/null; then
    yay -S --noconfirm sddm sddm-astronaut-theme qt5-graphicaleffects qt5-quickcontrols2 qt5-svg
    config_sddm
  else
    echo "Warning: paru or yay not found."
  fi
elif command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y sddm qml-module-qtquick-controls2 qml-module-qtgraphicaleffects qml-module-qtsvg
  config_sddm
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y sddm qt5-qtgraphicaleffects qt5-qtquickcontrols2
  config_sddm
elif command -v xbps-install >/dev/null 2>&1; then
  # Added qt5 dependencies for void linux
  sudo xbps-install -Sy sddm qt5-quickcontrols2 qt5-graphicaleffects qt5-svg
  config_sddm
fi

# Enable SDDM service to start with the system
echo "Enabling SDDM service..."
if command -v systemctl >/dev/null 2>&1; then
  # For systemd-based distros (Arch, Debian, Fedora)
  sudo systemctl enable sddm.service -f
elif command -v sv >/dev/null 2>&1 && [ -d "/etc/sv/sddm" ]; then
  # For runit-based distros (Void Linux)
  sudo ln -sf /etc/sv/sddm /var/service/
else
  echo -e "\033[1;33m[ WARNING ]\033[0m Service manager (systemd/runit) not detected or sddm service missing. Enable the service manually."
fi

echo -e "\033[1;32m[ OK ]\033[0m SDDM configuration finished!"

#!/bin/bash
echo "Installing Flatpak..."
sudo pacman -S --noconfirm flatpak || sudo dnf install -y flatpak || sudo apt install -y flatpak || sudo xbps-install -Sy flatpak
echo "Adding Flathub repository..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

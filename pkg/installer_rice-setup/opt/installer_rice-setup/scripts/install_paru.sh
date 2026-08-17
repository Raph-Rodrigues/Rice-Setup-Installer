#!/bin/bash
echo "Installing Paru (AUR Helper)..."
sudo pacman -S --needed --noconfirm base-devel git
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru && makepkg -si --noconfirm
rm -rf /tmp/paru

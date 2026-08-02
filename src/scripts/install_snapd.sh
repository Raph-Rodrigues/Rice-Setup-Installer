#!/bin/bash
echo "Installing Snapd..."

sudo pacman -S --noconfirm snapd || sudo dnf install -y snapd || sudo apt install -y snapd || sudo xbps-install -Sy snapd

sudo ln -s /var/lib/snapd/snap /snap 2>/dev/null

if command -v systemctl >/dev/null 2>&1; then
  echo "Systemd detectado. Habilitando snapd.socket..."
  sudo systemctl enable --now snapd.socket[cite: 12]
elif command -v sv >/dev/null 2>&1; then
  echo "Runit detectado. Habilitando serviço do snapd para Void Linux..."
  # Cria o symlink na pasta /var/service para o runit gerenciar
  sudo ln -s /etc/sv/snapd /var/service/
else
  echo "Sistema de init não reconhecido. Por favor, inicie o daemon do snapd manualmente."
fi

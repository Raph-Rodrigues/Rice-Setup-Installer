#!/bin/bash

echo -e "\033[1;35m[ ÍCONES ]\033[0m Instalando tema de ícones Papirus e utilitários..."

# Detectar distros e instalar dependências
if command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --needed --noconfirm papirus-icon-theme kvantum qt5ct qt6ct

  # pacotes do AUR (usando paru ou yay se disponíveis)
  if command -v paru >/dev/null; then
    paru -S --noconfirm papirus-folders nwg-look
  elif command -v yay >/dev/null; then
    yay -S --noconfirm papirus-folders nwg-look
  else
    echo "Aviso: paru ou yay não encontrados. Não foi possível instalar papirus-folders e nwg-look."
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

# Configurar Papirus como padrão no GTK (Gnome/XFCE/etc)
echo "Configurando GTK..."
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

# Aplicar cores de pastas do Papirus se o utilitário foi instalado
if command -v papirus-folders >/dev/null; then
  papirus-folders -C blue --theme Papirus-Dark
fi

echo -e "\033[1;32m[ OK ]\033[0m Configuração de ícones finalizada!"

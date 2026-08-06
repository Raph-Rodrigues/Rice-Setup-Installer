#!/bin/bash

echo -e "\033[1;35m[ TERMINAL ]\033[0m Instalando Kitty e JetBrainsMono Nerd Font..."

# 1. Instalar o Kitty pelo gerenciador de pacotes do sistema
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
  echo -e "\033[1;31m[ ERRO ]\033[0m Gerenciador de pacotes não suportado."
  exit 1
fi

# 2. Instalar a JetBrainsMono Nerd Font (Método Universal)
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
TEMP_FONT_DIR=$(mktemp -d)

echo "Baixando JetBrainsMono Nerd Font (Latest Release)..."
wget -qO "$TEMP_FONT_DIR/JetBrainsMono.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

echo "Extraindo a fonte..."
mkdir -p "$FONT_DIR/JetBrainsMono"
unzip -qo "$TEMP_FONT_DIR/JetBrainsMono.zip" -d "$FONT_DIR/JetBrainsMono"

# Atualizar o cache de fontes do sistema para reconhecer a nova fonte
echo "Atualizando cache de fontes (fc-cache)..."
fc-cache -fv "$FONT_DIR" >/dev/null

rm -rf "$TEMP_FONT_DIR"

# 3. Configurar o Kitty com o seu "Rice" (one-dev-click)
echo "Configurando o Kitty..."
TEMP_REPO=$(mktemp -d)
git clone --depth=1 https://github.com/Raph-Rodrigues/one-dev-click.git "$TEMP_REPO"

KITTY_CONFIG_DIR="$HOME/.config/kitty"

# Faz backup da configuração atual do usuário (se existir)
if [ -d "$KITTY_CONFIG_DIR" ]; then
  echo "Fazendo backup da configuração antiga do Kitty para ~/.config/kitty.bak"
  rm -rf "${KITTY_CONFIG_DIR}.bak"
  mv "$KITTY_CONFIG_DIR" "${KITTY_CONFIG_DIR}.bak"
fi

mkdir -p "$HOME/.config"

# Verifica se a pasta existe em config/kitty ou na raiz kitty
if [ -d "$TEMP_REPO/config/kitty" ]; then
  cp -r "$TEMP_REPO/config/kitty" "$KITTY_CONFIG_DIR"
  echo -e "\033[1;32m[ OK ]\033[0m Configurações do Kitty aplicadas!"
elif [ -d "$TEMP_REPO/kitty" ]; then
  cp -r "$TEMP_REPO/kitty" "$KITTY_CONFIG_DIR"
  echo -e "\033[1;32m[ OK ]\033[0m Configurações do Kitty aplicadas!"
else
  echo -e "\033[1;33m[ AVISO ]\033[0m Nenhuma configuração do Kitty ('config/kitty' ou 'kitty') encontrada no repositório. O Kitty usará o tema padrão."
fi

rm -rf "$TEMP_REPO"

echo -e "\033[1;32m[ OK ]\033[0m Instalação do Kitty e da Fonte finalizada com sucesso!"

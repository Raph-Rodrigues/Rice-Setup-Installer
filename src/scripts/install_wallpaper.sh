#!/bin/bash

echo -e "\033[1;35m[ WALLPAPER ]\033[0m Configurando Wallpapers..."

# Localiza a pasta do usuário para Imagens (independente do idioma do sistema)
PICTURES_DIR=$(xdg-user-dir PICTURES 2>/dev/null)
if [ -z "$PICTURES_DIR" ]; then
  PICTURES_DIR="$HOME/Pictures"
fi

DEST_DIR="$PICTURES_DIR/wallpaper"
mkdir -p "$DEST_DIR"

# Diretório temporário para clonagem
TEMP_DIR=$(mktemp -d)
echo "Clonando repositório..."
git clone --depth=1 https://github.com/Raph-Rodrigues/one-dev-click.git "$TEMP_DIR"

if [ -d "$TEMP_DIR/Wallpapers" ]; then
  echo "Copiando wallpapers para $DEST_DIR..."
  cp -r "$TEMP_DIR/Wallpapers/"* "$DEST_DIR/"
  echo -e "\033[1;32m[ OK ]\033[0m Wallpapers instalados com sucesso!"
else
  echo -e "\033[1;31m[ ERRO ]\033[0m Pasta 'Wallpapers' não encontrada no repositório."
fi

rm -rf "$TEMP_DIR"

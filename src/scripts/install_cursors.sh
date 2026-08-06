#!/bin/bash

echo -e "\033[1;35m[ CURSORES ]\033[0m Instalando cursor Bibata Modern Classic..."

CURSOR_DIR="$HOME/.local/share/icons"
mkdir -p "$CURSOR_DIR"
TEMP_DIR=$(mktemp -d)

echo "Baixando Bibata-Modern-Classic..."
wget -qO "$TEMP_DIR/Bibata.tar.gz" "https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Classic.tar.gz"

echo "Extraindo cursores..."
tar -xf "$TEMP_DIR/Bibata.tar.gz" -C "$CURSOR_DIR/"
rm -rf "$TEMP_DIR"

# Definir para o GTK/Gnome
echo "Aplicando ao sistema..."
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'

# Definir para QT / Plasma (Adiciona no index.theme local)
mkdir -p "$HOME/.icons/default"
cat <<EOF >"$HOME/.icons/default/index.theme"
[Icon Theme]
Inherits=Bibata-Modern-Classic
EOF

# Aplicar permissões/overrides para o Flatpak reconhecer o tema
if command -v flatpak >/dev/null 2>&1; then
  echo "Dando permissão de cursores aos Flatpaks..."
  flatpak override --user --filesystem="$HOME/.local/share/icons/:ro"
  flatpak override --user --filesystem="$HOME/.icons/:ro"
  flatpak override --user --env=XCURSOR_THEME="Bibata-Modern-Classic"
fi

echo -e "\033[1;32m[ OK ]\033[0m Tema de cursor Bibata configurado com sucesso!"

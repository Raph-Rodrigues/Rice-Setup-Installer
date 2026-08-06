#!/bin/bash

echo -e "\033[1;35m[ LOGIN ]\033[0m Instalando SDDM e configurando tema..."

config_sddm() {
  echo "Configurando SDDM..."
  # Clonar o repositório em um diretório temporário
  TEMP_DIR=$(mktemp -d)
  echo "Clonando o repositório one-dev-click..."
  git clone --depth=1 https://github.com/Raph-Rodrigues/one-dev-click.git "$TEMP_DIR"

  # Configurar o tema
  if [ -d "$TEMP_DIR/config/sddm" ]; then
    THEME_SRC="$TEMP_DIR/config/sddm"
  elif [ -d "$TEMP_DIR/sddm" ]; then
    THEME_SRC="$TEMP_DIR/sddm"
  else
    THEME_SRC=""
  fi

  if [ -n "$THEME_SRC" ]; then
    THEME_NAME="sddm-astronout-theme"

    echo "Copiando o tema para /usr/share/sddm/themes/..."
    sudo mkdir -p /usr/share/sddm/themes/
    # Remove se já existir para evitar conflitos
    sudo rm -rf "/usr/share/sddm/themes/$THEME_NAME"
    sudo cp -r "$THEME_SRC" "/usr/share/sddm/themes/$THEME_NAME"

    echo "Definindo o tema como padrão do sistema..."
    sudo mkdir -p /etc/sddm.conf.d

    # Cria/Sobrescreve o arquivo de configuração para apontar para o novo tema
    cat <<EOF | sudo tee /etc/sddm.conf.d/general.conf >/dev/null
[Theme]
Current=$THEME_NAME
EOF

    echo -e "\033[1;32m[ OK ]\033[0m SDDM e tema instalados e configurados com sucesso!"
  else
    echo -e "\033[1;31m[ ERRO ]\033[0m Nenhuma pasta de tema SDDM ('config/sddm' ou 'sddm') foi encontrada no repositório."
  fi

  # Limpar o lixo
  rm -rf "$TEMP_DIR"
}

# Detectar distros e instalar dependências
if command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --needed --noconfirm sddm sddm-astronaut-theme qt5-graphicaleffects qt5-quickcontrols2 qt5-svg
  config_sddm

  # pacotes do AUR (usando paru ou yay se disponíveis)
  if command -v paru >/dev/null; then
    paru -S --noconfirm sddm sddm-astronaut-theme qt5-graphicaleffects qt5-quickcontrols2 qt5-svg
    config_sddm
  elif command -v yay >/dev/null; then
    yay -S --noconfirm sddm sddm-astronaut-theme qt5-graphicaleffects qt5-quickcontrols2 qt5-svg
    config_sddm
  else
    echo "Aviso: paru ou yay não encontrados."
  fi
elif command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y sddm qml-module-qtquick-controls2 qml-module-qtgraphicaleffects qml-module-qtsvg
  config_sddm
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y sddm qt5-qtgraphicaleffects qt5-qtquickcontrols2
  config_sddm
elif command -v xbps-install >/dev/null 2>&1; then
  # Adicionado dependências qt5 para o void linux
  sudo xbps-install -Sy sddm qt5-quickcontrols2 qt5-graphicaleffects qt5-svg
  config_sddm
fi

# Habilitar o serviço do SDDM para iniciar com o sistema
echo "Habilitando o serviço do SDDM..."
if command -v systemctl >/dev/null 2>&1; then
  # Para distros baseadas em systemd (Arch, Debian, Fedora)
  sudo systemctl enable sddm.service -f
elif command -v sv >/dev/null 2>&1 && [ -d "/etc/sv/sddm" ]; then
  # Para distros baseadas em runit (Void Linux)
  sudo ln -sf /etc/sv/sddm /var/service/
else
  echo -e "\033[1;33m[ AVISO ]\033[0m Gerenciador de serviços (systemd/runit) não detectado ou serviço sddm ausente. Habilite o serviço manualmente."
fi

echo -e "\033[1;32m[ OK ]\033[0m Configuração de SDDM finalizada!"

#!/bin/bash

# Encerra o script se nenhum argumento foi passado
if [ "$#" -eq 0 ]; then
  echo -e "\e[1;31m[ ERROR ]\e[0m Nenhum pacote de produtividade/estudo foi selecionado."
  exit 0
fi

echo -e "\e[1;34m==>\e[0m Iniciando a instalacao de softwares de produtividade e estudos..."

# Detecta a base da distro lendo o /etc/os-release
if [ -f /etc/os-release ]; then
  source /etc/os-release
  OS_ID=$ID
  OS_LIKE=$ID_LIKE
else
  echo -e "\e[1;31m[ ERROR ]\e[0m Nao foi possivel detectar o sistema operacional."
  exit 1
fi

PKG_MNGR=""

# Define o gerenciador de pacotes baseado na distro
if [[ "$OS_ID" == "arch" || "$OS_LIKE" == *"arch"* ]]; then
  PKG_MNGR="sudo pacman -S --needed --noconfirm"
elif [[ "$OS_ID" == "fedora" || "$OS_LIKE" == *"fedora"* ]]; then
  PKG_MNGR="sudo dnf install -y"
elif [[ "$OS_ID" == "debian" || "$OS_ID" == "ubuntu" || "$OS_LIKE" == *"debian"* || "$OS_LIKE" == *"ubuntu"* ]]; then
  PKG_MNGR="sudo apt-get install -y"
elif [[ "$OS_ID" == "void" ]]; then
  PKG_MNGR="sudo xbps-install -y"
else
  echo -e "\e[1;31m[ ERROR ]\e[0m Distribuicao nao suportada nativamente por este script."
  exit 1
fi

# Itera sobre os argumentos (softwares) selecionados na interface gráfica
for pkg in "$@"; do
  echo -e "\n\e[1;36m->\e[0m Instalando pacote: \e[1m$pkg\e[0m"
  $PKG_MNGR "$pkg"
done

echo -e "\n\e[1;32m[ OK ]\e[0m Instalacao de softwares de produtividade finalizada!"

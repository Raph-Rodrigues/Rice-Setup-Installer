#!/bin/bash

# Encerra o script se nenhum argumento foi passado
if [ "$#" -eq 0 ]; then
  echo -e "\e[1;31m[ ERROR ]\e[0m Nenhum pacote de jogo foi selecionado."
  exit 0
fi

echo -e "\e[1;34m==>\e[0m Preparando instalacao de ferramentas para jogos..."

# Detecta a base da distro lendo o /etc/os-release
if [ -f /etc/os-release ]; then
  source /etc/os-release
  OS_ID=$ID
  OS_NAME=$NAME
  OS_LIKE=$ID_LIKE
else
  echo -e "\e[1;31m[ ERROR ]\e[0m Nao foi possivel detectar o sistema operacional."
  exit 1
fi

# ==========================================
# REGRA ESPECÍFICA PARA CACHYOS
# ==========================================
if [[ "${OS_ID,,}" == *"cachyos"* || "${OS_NAME,,}" == *"cachyos"* ]]; then
  echo -e "\e[1;35m[ CachyOS Detectado ]\e[0m Sistema operacional focado em performance detectado."
  echo -e "\e[1;36m->\e[0m Ignorando selecao manual e instalando meta-pacotes oficiais do CachyOS..."

  sudo pacman -S --needed --noconfirm cachyos-gaming-applications cachyos-gaming-meta

  echo -e "\n\e[1;32m[ OK ]\e[0m Processo de instalacao de jogos para CachyOS finalizado!"
  exit 0
fi

# ==========================================
# INSTALAÇÃO PADRÃO PARA DEMAIS DISTRIBUIÇÕES
# ==========================================
PKG_MNGR=""

# Define o gerenciador de pacotes e instala as dependências essenciais baseadas na distro
if [[ "$OS_ID" == "arch" || "$OS_LIKE" == *"arch"* ]]; then
  PKG_MNGR="sudo pacman -S --needed --noconfirm"

  echo -e "\e[1;36m->\e[0m Instalando dependencias essenciais de jogos (Vulkan, 32-bit libs, Wine deps) para Arch..."
  $PKG_MNGR vulkan-icd-loader lib32-vulkan-icd-loader \
    giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap \
    gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal \
    v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error \
    lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib \
    libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite \
    libxcomposite lib32-libxcomposite libxinerama lib32-libxinerama \
    ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader \
    libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 \
    gst-plugins-base-libs lib32-gst-plugins-base-libs winetricks

elif [[ "$OS_ID" == "fedora" || "$OS_LIKE" == *"fedora"* ]]; then
  PKG_MNGR="sudo dnf install -y"

  echo -e "\e[1;36m->\e[0m Instalando dependencias essenciais de jogos (Vulkan, 32-bit libs, Wine deps) para Fedora..."
  $PKG_MNGR vulkan-loader vulkan-loader.i686 mesa-vulkan-drivers mesa-vulkan-drivers.i686 \
    alsa-plugins-pulseaudio.i686 glibc-devel.i686 glibc-devel \
    libgcc.i686 libX11-devel.i686 freetype.i686 zlib.i686 \
    libxcrypt-compat.i686 winetricks

elif [[ "$OS_ID" == "debian" || "$OS_ID" == "ubuntu" || "$OS_LIKE" == *"debian"* || "$OS_LIKE" == *"ubuntu"* ]]; then
  PKG_MNGR="sudo apt-get install -y"

  echo -e "\e[1;36m->\e[0m Habilitando arquitetura 32-bit (i386) e atualizando repositorios..."
  sudo dpkg --add-architecture i386
  sudo apt-get update

  echo -e "\e[1;36m->\e[0m Instalando dependencias essenciais de jogos para Debian/Ubuntu..."
  $PKG_MNGR wine wine32 wine64 libvulkan1 libvulkan1:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386 vulkan-tools winetricks

elif [[ "$OS_ID" == "void" ]]; then
  PKG_MNGR="sudo xbps-install -y"

  echo -e "\e[1;36m->\e[0m Habilitando repositorio multilib (32-bit) e atualizando..."
  sudo xbps-install -y void-repo-multilib
  sudo xbps-install -Sy

  echo -e "\e[1;36m->\e[0m Instalando dependencias essenciais de jogos para Void Linux..."
  $PKG_MNGR vulkan-loader vulkan-loader-32bit wine wine-32bit winetricks

else
  echo -e "\e[1;31m[ ERROR ]\e[0m Distribuicao nao suportada nativamente por este script."
  exit 1
fi

# ==========================================
# INSTALAÇÃO DOS PACOTES SELECIONADOS NA UI
# ==========================================
for pkg in "$@"; do
  echo -e "\n\e[1;36m->\e[0m Instalando: \e[1m$pkg\e[0m"
  $PKG_MNGR "$pkg"
done

echo -e "\n\e[1;32m[ OK ]\e[0m Processo de instalacao de jogos finalizado!"

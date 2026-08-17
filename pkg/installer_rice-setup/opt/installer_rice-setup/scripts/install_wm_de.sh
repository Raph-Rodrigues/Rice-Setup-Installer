#!/bin/bash

# Encerra o script se nenhum argumento foi passado
if [ "$#" -eq 0 ]; then
  echo -e "\e[1;31m[ ERROR ]\e[0m Nenhum WM/DE foi selecionado para instalacao."
  exit 0
fi

echo -e "\e[1;34m==>\e[0m Iniciando a instalacao dos ambientes graficos: $@"

# Detecta a base da distro lendo o /etc/os-release
if [ -f /etc/os-release ]; then
  source /etc/os-release
  OS_ID=$ID
  OS_LIKE=$ID_LIKE
else
  echo -e "\e[1;31m[ ERROR ]\e[0m Nao foi possivel detectar o sistema operacional."
  exit 1
fi

IS_ARCH=false
IS_FEDORA=false

# Define o gerenciador de pacotes baseado na distro
if [[ "$OS_ID" == "arch" || "$OS_LIKE" == *"arch"* ]]; then
  IS_ARCH=true
  PKG_MNGR="sudo pacman -S --needed --noconfirm"
  AUR_MNGR="paru -S --needed --noconfirm" # Utiliza o paru, que é oferecido no seu Rice Installer
elif [[ "$OS_ID" == "fedora" || "$OS_LIKE" == *"fedora"* ]]; then
  IS_FEDORA=true
  PKG_MNGR="sudo dnf install -y"
  GRP_MNGR="sudo dnf groupinstall -y"
else
  echo -e "\e[1;31m[ ERROR ]\e[0m Distribuicao nao suportada nativamente por este script."
  exit 1
fi

# Itera sobre todos os argumentos passados pelo C++
for env in "$@"; do
  echo -e "\n\e[1;36m->\e[0m Preparando a instalacao: \e[1m$env\e[0m"

  case $env in
  hyprland)
    if $IS_ARCH; then
      $PKG_MNGR hyprland qt5-wayland qt6-wayland polkit-kde-agent
      # Aqui você pode adicionar o git clone para o noctalia shell
      echo "Baixando as configuracoes do Noctalia Shell..."
      # git clone https://github.com/usuario/noctalia-shell.git ~/.config/hypr
    elif $IS_FEDORA; then
      $PKG_MNGR hyprland qt5-qtwayland qt6-qtwayland polkit-kde
    fi
    ;;

  cinnamon)
    if $IS_ARCH; then
      $PKG_MNGR cinnamon
    elif $IS_FEDORA; then
      $GRP_MNGR "Cinnamon Desktop"
    fi
    ;;

  kde-plasma)
    if $IS_ARCH; then
      $PKG_MNGR plasma-meta konsole dolphin
    elif $IS_FEDORA; then
      $GRP_MNGR "KDE Plasma Workspaces"
    fi
    ;;

  gnome)
    if $IS_ARCH; then
      $PKG_MNGR gnome gnome-tweaks
    elif $IS_FEDORA; then
      $GRP_MNGR "GNOME"
    fi
    ;;

  cosmic)
    # O COSMIC (em Rust) da System76 requer repositórios específicos dependendo da distro
    if $IS_ARCH; then
      echo "Instalando COSMIC Desktop (via repositorios Arch/AUR)..."
      # Geralmente disponível no extra/Chaotic-AUR ou AUR como cosmic-session / cosmic-epoch
      $PKG_MNGR cosmic-session || $AUR_MNGR cosmic-epoch-git
    elif $IS_FEDORA; then
      echo "Habilitando COPR para o COSMIC..."
      sudo dnf copr enable -y ryanabx/cosmic-epoch
      $PKG_MNGR cosmic-desktop
    fi
    ;;

  kinetic)
    echo "Instalando pacote Kinetic..."
    if $IS_ARCH; then
      $PKG_MNGR kinetic || $AUR_MNGR kinetic
    elif $IS_FEDORA; then
      $PKG_MNGR kinetic
    fi
    ;;

  *)
    echo -e "\e[1;33m[ AVISO ]\e[0m Ambiente desconhecido ignorado: $env"
    ;;
  esac
done

echo -e "\n\e[1;32m[ OK ]\e[0m Processo de instalacao de WM/DE finalizado!"

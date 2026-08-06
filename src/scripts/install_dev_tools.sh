#!/bin/bash

echo -e "\033[1;34m[ EXEC ]\033[0m Iniciando a instalação de Ferramentas de Desenvolvimento..."

# 1. Detectar o Gerenciador de Pacotes do Sistema Base
if command -v pacman >/dev/null 2>&1; then
  PKG_MGR="sudo pacman -S --needed --noconfirm"
  DISTRO="arch"
elif command -v dnf >/dev/null 2>&1; then
  PKG_MGR="sudo dnf install -y"
  DISTRO="fedora"
elif command -v apt-get >/dev/null 2>&1; then
  PKG_MGR="sudo apt-get install -y"
  DISTRO="debian"
elif command -v xbps-install >/dev/null 2>&1; then
  PKG_MGR="sudo xbps-install -Sy"
  DISTRO="void"
else
  echo "Erro: Gerenciador de pacotes não suportado detectado."
  exit 1
fi

# Função inteligente de instalação
smart_install() {
  local tool_name=$1
  local repo_pkg=$2
  local aur_pkg=$3
  local flatpak_id=$4
  local installed=0

  # Lógica para Arch Linux
  if [ "$DISTRO" == "arch" ]; then
    if pacman -Si "$repo_pkg" &>/dev/null; then
      $PKG_MGR "$repo_pkg"
      installed=1
    else
      if command -v paru >/dev/null 2>&1; then
        echo "Instalando $aur_pkg via Paru..."
        paru -S --noconfirm "$aur_pkg"
        installed=1
      elif command -v yay >/dev/null 2>&1; then
        echo "Instalando $aur_pkg via Yay..."
        yay -S --noconfirm "$aur_pkg"
        installed=1
      else
        echo -e "\033[1;33m[ AVISO ]\033[0m Pacote '$aur_pkg' não encontrado no pacman. Instale o 'paru' ou 'yay' para instalá-lo via AUR."
      fi
    fi
  
  # Lógica para outras distribuições
  else
    local found=0
    if [ "$DISTRO" == "fedora" ] && dnf info "$repo_pkg" &>/dev/null; then found=1; fi
    if [ "$DISTRO" == "debian" ] && apt-cache show "$repo_pkg" &>/dev/null; then found=1; fi
    if [ "$DISTRO" == "void" ] && xbps-query -R "$repo_pkg" &>/dev/null; then found=1; fi

    if [ "$found" -eq 1 ]; then
      $PKG_MGR "$repo_pkg"
      installed=1
    fi
  fi

  # Fallback global para Flatpak
  if [ "$installed" -eq 0 ] && [ -n "$flatpak_id" ]; then
    if command -v flatpak >/dev/null 2>&1; then
      echo -e "\n\033[1;33m[ AVISO ]\033[0m O pacote '$tool_name' não foi encontrado no repositório oficial."
      read -p "Deseja tentar fazer a instalação de '$tool_name' via Flatpak? (s/N): " choice
      case "$choice" in
        s|S ) 
          flatpak install -y flathub "$flatpak_id" 
          ;;
        * ) 
          echo "Instalação de $tool_name via Flatpak cancelada." 
          ;;
      esac
    else
      echo -e "\033[1;31m[ ERRO ]\033[0m Não foi possível instalar '$tool_name' e o Flatpak não está disponível no sistema."
    fi
  fi
}

# 2. Processar cada pacote recebido como argumento
for tool in "$@"; do
  echo -e "\n\033[1;36m==>\033[0m Configurando: $tool"

  case $tool in

  # ==========================================
  # NEOVIM CONFIGURATION LOGIC
  # ==========================================
  neovim)
    smart_install "Neovim" "neovim" "neovim" ""
    
    echo -e "\n\033[1;35m[ NEOVIM ]\033[0m Deseja utilizar o setup personalizado do repositório one-dev-click? (s/N): "
    read -r setup_choice
    
    if [[ "$setup_choice" =~ ^[sS]$ ]]; then
      NVIM_DIR="$HOME/.config/nvim"
      
      # Verifica se já existe uma configuração
      if [ -d "$NVIM_DIR" ]; then
        echo -e "\033[1;33m[ AVISO ]\033[0m Diretório de configuração $NVIM_DIR já existe."
        read -r -p "Deseja fazer backup das configurações existentes? (S/n): " backup_choice
        
        # Se a resposta não for n/N, faz o backup (Padrão: Sim)
        if [[ ! "$backup_choice" =~ ^[nN]$ ]]; then
          echo "Criando backup em ${NVIM_DIR}.bak..."
          rm -rf "${NVIM_DIR}.bak" # Garante que o backup antigo não atrapalhe
          mv "$NVIM_DIR" "${NVIM_DIR}.bak"
        else
          echo "Removendo configurações antigas..."
          rm -rf "$NVIM_DIR"
        fi
      fi
      
      echo "Clonando o repositório..."
      # Usando diretório temporário para não sujar a home do usuário
      TEMP_DIR=$(mktemp -d)
      git clone https://github.com/Raph-Rodrigues/one-dev-click.git "$TEMP_DIR"
      
      echo "Aplicando as novas configurações..."
      mkdir -p "$HOME/.config"
      
      # Verifica e copia apenas a pasta específica config/nvim
      if [ -d "$TEMP_DIR/config/nvim" ]; then
        cp -r "$TEMP_DIR/config/nvim" "$NVIM_DIR"
        echo -e "\033[1;32m[ OK ]\033[0m Setup do Neovim concluído com sucesso!"
      else
        echo -e "\033[1;31m[ ERRO ]\033[0m A pasta 'config/nvim' não foi encontrada no repositório clonado."
      fi
      
      rm -rf "$TEMP_DIR"
    else
      echo "Mantendo a configuração padrão do Neovim."
    fi
    ;;
  
  # Ferramentas CLI
  git|gcc|make|cmake|luarocks|docker)
    smart_install "$tool" "$tool" "$tool" ""
    ;;

  # Lógica específica para Lua
  lua51|lua54|lua55|luajit)
    if [ "$DISTRO" == "fedora" ]; then
      $PKG_MGR "compat-lua"
    elif [ "$DISTRO" == "debian" ] && [ "$tool" == "lua51" ]; then
      $PKG_MGR "lua5.1"
    else
      smart_install "$tool" "$tool" "$tool" ""
    fi
    ;;

  lazygit)
    smart_install "lazygit" "lazygit" "lazygit-bin" ""
    ;;
  
  lazydocker)
    smart_install "lazydocker" "lazydocker" "lazydocker-bin" ""
    ;;

  # Dotnet SDKs
  dotnet-8|dotnet-9|dotnet-10)
    VERSION=$(echo "$tool" | cut -d'-' -f2)
    if [ "$DISTRO" == "debian" ]; then
      $PKG_MGR "dotnet-sdk-$VERSION.0"
    else
      smart_install "Dotnet $VERSION" "dotnet-sdk" "dotnet-sdk" ""
    fi
    ;;

  # ASDF Version Manager (Direto via Git pois não fica em repo oficial)
  asdf-vm)
    if [ ! -d "$HOME/.asdf" ]; then
      git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
      echo "Adicione '. \"\$HOME/.asdf/asdf.sh\"' no seu shell rc."
    else
      echo "ASDF já instalado."
    fi
    ;;

  love2d)
    smart_install "Love2D" "love" "love" "org.love2d.love"
    ;;

  lovr)
    smart_install "Lovr" "lovr" "lovr-bin" "org.lovr.LOVR"
    ;;

  # Ferramentas Gráficas complexas e IDEs
  vscode)
    smart_install "VSCode" "code" "visual-studio-code-bin" "com.visualstudio.code"
    ;;
  vscodium)
    smart_install "VSCodium" "codium" "vscodium-bin" "com.vscodium.codium"
    ;;
  zeditor)
    smart_install "Zed" "zed" "zed" "dev.zed.Zed"
    ;;
  rider)
    smart_install "Rider" "rider" "rider" "com.jetbrains.Rider"
    ;;
  intellij-community)
    smart_install "IntelliJ Community" "intellij-idea-community-edition" "intellij-idea-community-edition" "com.jetbrains.IntelliJ-IDEA-Community"
    ;;
  godot-hub)
    smart_install "Godot Hub" "godots" "godot-hub-bin" "io.github.MakovWait.Godots"
    ;;
  bottles)
    smart_install "Bottles" "bottles" "bottles" "com.usebottles.bottles"
    ;;
  unity-hub)
    smart_install "Unity Hub" "unity-hub" "unityhub" "com.unity.UnityHub"
    ;;

  # Bibliotecas Gráficas e de Jogos (C/C++)
  sdl2)
    if [ "$DISTRO" == "debian" ]; then repo="libsdl2-dev"
    elif [ "$DISTRO" == "arch" ]; then repo="sdl2"
    else repo="SDL2-devel"
    fi
    smart_install "SDL2" "$repo" "sdl2" ""
    ;;
    
  sdl3)
    if [ "$DISTRO" == "debian" ]; then repo="libsdl3-dev"
    elif [ "$DISTRO" == "arch" ]; then repo="sdl3"
    else repo="SDL3-devel"
    fi
    smart_install "SDL3" "$repo" "sdl3-git" ""
    ;;
    
  sfml2)
    if [ "$DISTRO" == "debian" ]; then repo="libsfml-dev"
    elif [ "$DISTRO" == "arch" ]; then repo="sfml"
    elif [ "$DISTRO" == "fedora" ]; then repo="SFML-devel"
    else repo="sfml-devel"
    fi
    smart_install "SFML 2" "$repo" "sfml" ""
    ;;
    
  sfml3)
    smart_install "SFML 3" "sfml3" "sfml3-git" ""
    ;;
    
  opengl)
    if [ "$DISTRO" == "debian" ]; then repo="libgl1-mesa-dev"
    elif [ "$DISTRO" == "arch" ]; then repo="mesa"
    elif [ "$DISTRO" == "fedora" ]; then repo="mesa-libGL-devel"
    else repo="mesalib-devel"
    fi
    smart_install "OpenGL" "$repo" "mesa" ""
    ;;
    
  vulkan)
    if [ "$DISTRO" == "debian" ]; then repo="libvulkan-dev"
    elif [ "$DISTRO" == "arch" ]; then repo="vulkan-devel"
    elif [ "$DISTRO" == "void" ]; then repo="vulkan-loader-devel"
    else repo="vulkan-devel"
    fi
    smart_install "Vulkan" "$repo" "vulkan-devel" ""
    ;;
    
  raylib)
    if [ "$DISTRO" == "debian" ]; then repo="libraylib-dev"
    elif [ "$DISTRO" == "arch" ]; then repo="raylib"
    else repo="raylib-devel"
    fi
    smart_install "Raylib" "$repo" "raylib-git" ""
    ;;

  *)
    echo "Aviso: Nenhuma regra de instalação definida para '$tool'."
    ;;
  esac
done

echo -e "\n\033[1;32m[ OK ]\033[0m Instalação da categoria Development finalizada."

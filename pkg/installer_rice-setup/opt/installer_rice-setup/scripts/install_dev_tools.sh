#!/bin/bash

echo -e "\033[1;34m[ EXEC ]\033[0m Starting the installation of Development Tools..."

# 1. Detect the Base System Package Manager
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
  echo "Error: Unsupported package manager detected."
  exit 1
fi

# Smart installation function
smart_install() {
  local tool_name=$1
  local repo_pkg=$2
  local aur_pkg=$3
  local flatpak_id=$4
  local installed=0

  # Logic for Arch Linux
  if [ "$DISTRO" == "arch" ]; then
    if pacman -Si "$repo_pkg" &>/dev/null; then
      $PKG_MGR "$repo_pkg"
      installed=1
    else
      if command -v paru >/dev/null 2>&1; then
        echo "Installing $aur_pkg via Paru..."
        paru -S --noconfirm "$aur_pkg"
        installed=1
      elif command -v yay >/dev/null 2>&1; then
        echo "Installing $aur_pkg via Yay..."
        yay -S --noconfirm "$aur_pkg"
        installed=1
      else
        echo -e "\033[1;33m[ WARNING ]\033[0m Package '$aur_pkg' not found in pacman. Install 'paru' or 'yay' to install it via AUR."
      fi
    fi

  # Logic for other distributions
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

  # Global fallback for Flatpak
  if [ "$installed" -eq 0 ] && [ -n "$flatpak_id" ]; then
    if command -v flatpak >/dev/null 2>&1; then
      echo -e "\n\033[1;33m[ WARNING ]\033[0m The package '$tool_name' was not found in the official repository."
      read -p "Do you want to try installing '$tool_name' via Flatpak? (y/N): " choice
      case "$choice" in
      y | Y)
        flatpak install -y flathub "$flatpak_id"
        ;;
      *)
        echo "Installation of $tool_name via Flatpak canceled."
        ;;
      esac
    else
      echo -e "\033[1;31m[ ERROR ]\033[0m Could not install '$tool_name' and Flatpak is not available on the system."
    fi
  fi
}

# 2. Process each package received as an argument
for tool in "$@"; do
  echo -e "\n\033[1;36m==>\033[0m Configuring: $tool"

  case $tool in

  # ==========================================
  # NEOVIM CONFIGURATION LOGIC
  # ==========================================
  neovim)
    smart_install "Neovim" "neovim" "neovim" ""

    echo -e "\n\033[1;35m[ NEOVIM ]\033[0m Do you want to use the custom setup from the one-dev-click repository? (y/N): "
    read -r setup_choice

    if [[ "$setup_choice" =~ ^[yY]$ ]]; then
      NVIM_DIR="$HOME/.config/nvim"

      # Check if a configuration already exists
      if [ -d "$NVIM_DIR" ]; then
        echo -e "\033[1;33m[ WARNING ]\033[0m Configuration directory $NVIM_DIR already exists."
        read -r -p "Do you want to backup existing configurations? (Y/n): " backup_choice

        # If the answer is not n/N, backup (Default: Yes)
        if [[ ! "$backup_choice" =~ ^[nN]$ ]]; then
          echo "Creating backup at ${NVIM_DIR}.bak..."
          rm -rf "${NVIM_DIR}.bak" # Ensures the old backup doesn't interfere
          mv "$NVIM_DIR" "${NVIM_DIR}.bak"
        else
          echo "Removing old configurations..."
          rm -rf "$NVIM_DIR"
        fi
      fi

      echo "Cloning the repository..."
      # Using a temporary directory to keep the user's home clean
      TEMP_DIR=$(mktemp -d)
      git clone https://github.com/Raph-Rodrigues/one-dev-click.git "$TEMP_DIR"

      echo "Applying new configurations..."
      mkdir -p "$HOME/.config"

      # Checks and copies only the specific config/nvim folder
      if [ -d "$TEMP_DIR/config/nvim" ]; then
        cp -r "$TEMP_DIR/config/nvim" "$NVIM_DIR"
        echo -e "\033[1;32m[ OK ]\033[0m Neovim setup completed successfully!"
      else
        echo -e "\033[1;31m[ ERROR ]\033[0m The 'config/nvim' folder was not found in the cloned repository."
      fi

      rm -rf "$TEMP_DIR"
    else
      echo "Keeping the default Neovim configuration."
    fi
    ;;

  # CLI Tools
  git | gcc | make | cmake | luarocks | docker)
    smart_install "$tool" "$tool" "$tool" ""
    ;;

  # Specific logic for Lua
  lua51 | lua54 | lua55 | luajit)
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
  dotnet-8 | dotnet-9 | dotnet-10)
    VERSION=$(echo "$tool" | cut -d'-' -f2)
    if [ "$DISTRO" == "debian" ]; then
      $PKG_MGR "dotnet-sdk-$VERSION.0"
    else
      smart_install "Dotnet $VERSION" "dotnet-sdk" "dotnet-sdk" ""
    fi
    ;;

  # ASDF Version Manager (Directly via Git as it's not in the official repo)
  asdf-vm)
    if [ ! -d "$HOME/.asdf" ]; then
      git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
      echo "Add '. \"\$HOME/.asdf/asdf.sh\"' to your shell rc."
    else
      echo "ASDF is already installed."
    fi
    ;;

  love2d)
    smart_install "Love2D" "love" "love" "org.love2d.love"
    ;;

  lovr)
    smart_install "Lovr" "lovr" "lovr-bin" "org.lovr.LOVR"
    ;;

  # Complex graphical tools and IDEs
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

  # Graphical and Game Libraries (C/C++)
  sdl2)
    if [ "$DISTRO" == "debian" ]; then
      repo="libsdl2-dev"
    elif [ "$DISTRO" == "arch" ]; then
      repo="sdl2"
    else
      repo="SDL2-devel"
    fi
    smart_install "SDL2" "$repo" "sdl2" ""
    ;;

  sdl3)
    if [ "$DISTRO" == "debian" ]; then
      repo="libsdl3-dev"
    elif [ "$DISTRO" == "arch" ]; then
      repo="sdl3"
    else
      repo="SDL3-devel"
    fi
    smart_install "SDL3" "$repo" "sdl3-git" ""
    ;;

  sfml2)
    if [ "$DISTRO" == "debian" ]; then
      repo="libsfml-dev"
    elif [ "$DISTRO" == "arch" ]; then
      repo="sfml"
    elif [ "$DISTRO" == "fedora" ]; then
      repo="SFML-devel"
    else
      repo="sfml-devel"
    fi
    smart_install "SFML 2" "$repo" "sfml2" ""
    ;;

  sfml3)
    smart_install "SFML 3" "sfml" "sfml-git" ""
    ;;

  opengl)
    if [ "$DISTRO" == "debian" ]; then
      repo="libgl1-mesa-dev"
    elif [ "$DISTRO" == "arch" ]; then
      repo="mesa"
    elif [ "$DISTRO" == "fedora" ]; then
      repo="mesa-libGL-devel"
    else
      repo="mesalib-devel"
    fi
    smart_install "OpenGL" "$repo" "mesa" ""
    ;;

  vulkan)
    if [ "$DISTRO" == "debian" ]; then
      repo="libvulkan-dev"
    elif [ "$DISTRO" == "arch" ]; then
      repo="vulkan-devel"
    elif [ "$DISTRO" == "void" ]; then
      repo="vulkan-loader-devel"
    else
      repo="vulkan-devel"
    fi
    smart_install "Vulkan" "$repo" "vulkan-devel" ""
    ;;

  raylib)
    if [ "$DISTRO" == "debian" ]; then
      repo="libraylib-dev"
    elif [ "$DISTRO" == "arch" ]; then
      repo="raylib"
    else
      repo="raylib-devel"
    fi
    smart_install "Raylib" "$repo" "raylib-git" ""
    ;;

  fresh-editor)
    if ["$DISTRO" == "debian"]; then
      curl -sL $(curl -s https://api.github.com/repos/sinelaw/fresh/releases/latest | grep "browser_download_url.*_$(dpkg --print-architecture)\.deb" | cut -d '"' -f 4) -o fresh-editor.deb && sudo dpkg -i fresh-editor.deb
    elif [ "$DISTRO" == "arch" ]; then
      repo="fresh-editor"
    elif [ "$DISTRO" == "fedora" ]; then
      curl -sL $(curl -s https://api.github.com/repos/sinelaw/fresh/releases/latest | grep "browser_download_url.*\.$(uname -m)\.rpm" | cut -d '"' -f 4) -o fresh-editor.rpm && sudo rpm -U fresh-editor.rpm
    elif [ "$DISTRO" == "void" ]; then
      curl https://raw.githubusercontent.com/sinelaw/fresh/refs/heads/master/scripts/install.sh | sh
    fi

  opencode)
    if ["$DISTRO" == "debian"]; then
      curl -fsSL https://opencode.ai/install | bash
    elif ["$DISTRO" == "arch"]; then
      repo="opencode"
    elif ["$DISTRO" == "fedora"];  then
      curl -fsSL https://opencode.ai/install | bash
    elif ["$DISTRO" == "void"]; then
      curl -fsSL https://opencode.ai/install | bash
    fi

  claude-code)
    if ["$DISTRO" == "debian"]; then
      sudo get-apt install -y claude-code
    elif ["$DISTRO" == "arch"]; then
      repo="claude-code"
    elif ["$DISTRO" == "fedora"]; then
      sudo dnf install claude-code
    elif ["$DISTRO" == "void"]; then
      curl -fsSL https://claude.ai/install.sh | bash
    fi

  *)
    echo "Warning: No installation rule defined for '$tool'."
    ;;
  esac
done

echo -e "\n\033[1;32m[ OK ]\033[0m Development category installation finished."

#!/bin/bash

# ==============================================================================
# Configuration Variables
# ==============================================================================
REPO_URL="https://github.com/Raph-Rodrigues/one-dev-click.git"
TEMP_DIR="/tmp/rice"
FISH_CONFIG_DIR="$HOME/.config/fish"
FASTFETCH_CONFIG_DIR="$HOME/.config/fastfetch/"
STARSHIP_CONFIG_FILE="$HOME/.config/starship.toml"

# ==============================================================================
# TUI - Colors and Message Functions
# ==============================================================================
C_RESET='\033[0m'
C_BLUE='\033[1;34m'
C_GREEN='\033[1;32m'
C_RED='\033[1;31m'
C_CYAN='\033[1;36m'
C_YELLOW='\033[1;33m'

print_header() {
  clear
  echo -e "${C_CYAN}"
  echo "==============================================================="
  echo "                 ONE DEV CLICK - RICE INSTALLER                "
  echo "==============================================================="
  echo -e "${C_RESET}"
}

print_info() { echo -e "${C_BLUE}[ INFO ]${C_RESET} $1"; }
print_step() { echo -e "\n${C_CYAN}==>${C_RESET} ${C_YELLOW}$1${C_RESET}"; }
print_success() { echo -e "${C_GREEN}[ OK ]${C_RESET} $1"; }
print_error() { echo -e "${C_RED}[ ERROR ]${C_RESET} $1"; }
print_warning() { echo -e "${C_YELLOW}[ WARN ]${C_RESET} $1"; }

# ==============================================================================
# Verification and Installation Functions
# ==============================================================================
check_dependencies() {
  print_step "Checking required packages..."
  local all_installed=true
  local pkgs=("fish" "git" "starship" "fastfetch")

  for pkg in "${pkgs[@]}"; do
    if command -v "$pkg" >/dev/null 2>&1; then
      print_success "'$pkg' is already installed."
    else
      print_warning "'$pkg' is not installed."
      all_installed=false
    fi
  done

  if $all_installed; then return 0; else return 1; fi
}

instalar_pacotes() {
  print_step "Detecting the system package manager..."

  if command -v pacman >/dev/null 2>&1; then
    print_info "Arch Linux / Derivatives (pacman) detected."
    pkexec pacman -S --noconfirm fish git starship fastfetch

  elif command -v dnf >/dev/null 2>&1; then
    print_info "Fedora detected (dnf)."
    pkexec dnf install -y fish git fastfetch starship

  elif command -v apt-get >/dev/null 2>&1; then
    print_info "Ubuntu / Debian / Derivatives (apt) detected."

    pkexec bash -c "apt-get update && \
    apt-get install -y software-properties-common curl && \
    add-apt-repository -y ppa:zhangsongcui3371/fastfetch && \
    apt-get update && \
    apt-get install -y fish git fastfetch"

    print_info "Installing Starship (via official script)..."
    curl -sS https://starship.rs/install.sh | pkexec sh -s -- -y

  elif command -v xbps-install >/dev/null 2>&1; then
    print_info "Void Linux detected (xbps)."
    pkexec xbps-install -Sy fish-shell git fastfetch starship

  else
    print_error "Distribution or package manager not supported."
    print_error "Please install 'fish', 'git', 'fastfetch' and 'starship' manually."
    exit 1
  fi
}

# ==============================================================================
# Execution Flow
# ==============================================================================
print_header

# 1. Package Installation
if check_dependencies; then
  print_info "Skipping installation phase as all packages are present."
else
  print_info "Proceeding with package installation..."
  instalar_pacotes

  print_step "Verifying installation..."
  if ! command -v fish >/dev/null 2>&1; then
    print_error "Fish shell not found after installation. Aborting."
    exit 1
  fi
  print_success "Dependencies installed successfully."
fi

# 2. Cloning Repository (With live progress)
print_step "Cloning configuration repository..."
rm -rf "$TEMP_DIR"

# Roda o git forceçando a saída de progresso e lê as porcentagens dinamicamente
git clone --progress "$REPO_URL" "$TEMP_DIR" 2>&1 | while read -r -d $'\r' line || [[ -n "$line" ]]; do
  if [[ "$line" =~ ([0-9]+)% ]]; then
    printf "\r\033[K${C_BLUE}[ INFO ]${C_RESET} Downloading... %3d%%" "${BASH_REMATCH[1]}"
  fi
done
# Garante que a linha termine em 100% e pula para a próxima
printf "\r\033[K${C_BLUE}[ INFO ]${C_RESET} Downloading... 100%%\n"
print_success "Repository cloned."

# 3. Applying Configurations (With simulated progress)
print_step "Applying configurations..."

# Configurando Fish (25%)
printf "\r\033[K${C_BLUE}[ INFO ]${C_RESET} Configuring Fish Shell... [ 25%% ]"
mkdir -p "$FISH_CONFIG_DIR"
if [ -d "$TEMP_DIR/fish" ]; then
  cp -rf "$TEMP_DIR/fish/"* "$FISH_CONFIG_DIR/"
else
  cp -rf "$TEMP_DIR/"* "$FISH_CONFIG_DIR/"
fi
sleep 0.5

# Configurando Starship (50%)
printf "\r\033[K${C_BLUE}[ INFO ]${C_RESET} Configuring Starship... [ 50%% ]"
touch "$STARSHIP_CONFIG_FILE"
if [ -f "$TEMP_DIR/starship.toml" ]; then
  cp -rf "$TEMP_DIR/starship.toml" "$STARSHIP_CONFIG_FILE"
else
  cp -rf "$TEMP_DIR/starship.toml"* "$STARSHIP_CONFIG_FILE" 2>/dev/null || true
fi
sleep 0.5

# Configurando Fastfetch (75%)
printf "\r\033[K${C_BLUE}[ INFO ]${C_RESET} Configuring Fastfetch... [ 75%% ]"
mkdir -p "$FASTFETCH_CONFIG_DIR"
if [ -d "$TEMP_DIR/fastfetch" ]; then
  cp -rf "$TEMP_DIR/fastfetch/"* "$FASTFETCH_CONFIG_DIR"
else
  cp -rf "$TEMP_DIR/"* "$FASTFETCH_CONFIG_DIR"
fi
sleep 0.5

# Limpeza (100%)
printf "\r\033[K${C_BLUE}[ INFO ]${C_RESET} Cleaning up temporary files... [ 100%% ]"
rm -rf "$TEMP_DIR"
sleep 0.5

echo -ne "\n" # Quebra a linha após concluir o carregamento
print_success "All configurations applied successfully."

# 4. Finalização
print_step "Changing default shell to Fish..."
print_info "(You may be prompted for your password again)"
pkexec chsh -s $(which fish) $USER

echo -e "\n==============================================================="
print_success "Installation and configuration successfully finished!"
echo -e "===============================================================\n"

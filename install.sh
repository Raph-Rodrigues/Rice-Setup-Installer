#!/bin/bash

echo -e "\e[1;36m==>\e[0m \e[1;33mIniciando a instalacao do Rice-Setup-Installer...\e[0m"

# 1. Detecta o Sistema Operacional
if [ -f /etc/os-release ]; then
  source /etc/os-release
  OS_ID=$ID
  OS_LIKE=$ID_LIKE
else
  echo -e "\e[1;31m[ ERROR ]\e[0m Sistema operacional nao detectado."
  exit 1
fi

echo -e "\e[1;36m->\e[0m Instalando dependencias de compilacao para $OS_ID..."

# 2. Instala dependências (git, cmake, compiladores, gtkmm4, vte4)
if [[ "$OS_ID" == "arch" || "$OS_LIKE" == *"arch"* ]]; then
  sudo pacman -S --needed --noconfirm git cmake gcc pkgconf gtkmm4 vte3
elif [[ "$OS_ID" == "debian" || "$OS_ID" == "ubuntu" || "$OS_LIKE" == *"debian"* || "$OS_LIKE" == *"ubuntu"* ]]; then
  sudo apt-get update
  sudo apt-get install -y git cmake g++ pkg-config libgtkmm-4.0-dev libvte-2.91-gtk4-dev
elif [[ "$OS_ID" == "fedora" || "$OS_LIKE" == *"fedora"* ]]; then
  sudo dnf install -y git cmake gcc-c++ pkgconf gtkmm4-devel vte291-gtk4-devel
elif [[ "$OS_ID" == "void" ]]; then
  sudo xbps-install -Sy git cmake gcc pkg-config gtkmm4-devel vte3-gtk4-devel
else
  echo -e "\e[1;31m[ ERROR ]\e[0m OS nao suportado automaticamente para dependencias."
  echo "Por favor, instale CMake, GCC, pkg-config, GTKmm4 e VTE3 manualmente."
  exit 1
fi

# 3. Baixa e compila o projeto
echo -e "\e[1;36m->\e[0m Baixando e compilando o projeto..."
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
git clone https://github.com/Raph-Rodrigues/Rice-Setup-Installer.git
cd Rice-Setup-Installer

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build

# 4. Instala no sistema (Estrutura no /opt e wrapper no /usr/local/bin)
echo -e "\e[1;36m->\e[0m Instalando no sistema..."
sudo install -dm755 /opt/installer_rice-setup
sudo install -Dm755 build/installer_rice-setup /opt/installer_rice-setup/installer_rice-setup
sudo cp -r src/scripts /opt/installer_rice-setup/
sudo chmod -R +x /opt/installer_rice-setup/scripts/

sudo install -dm755 /usr/local/bin
sudo bash -c 'cat <<EOF >/usr/local/bin/installer_rice-setup
#!/bin/bash
cd /opt/installer_rice-setup
./installer_rice-setup
EOF'
sudo chmod +x /usr/local/bin/installer_rice-setup

# 5. Limpeza
rm -rf "$TMP_DIR"

echo -e "\n\e[1;32m[ OK ]\e[0m Instalacao concluida com sucesso!"
echo -e "Para iniciar o programa, digite: \e[1minstaller_rice-setup\e[0m no terminal."

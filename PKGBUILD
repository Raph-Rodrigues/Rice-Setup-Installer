# Maintainer: Raph Rodrigues <raph.edits06@gmail.com>
pkgname=installer_rice-setup
pkgver=r12.292a89e
pkgrel=1
pkgdesc="A graphical tool written in C++ and GTKmm to automate Linux ricing and installations"
arch=('x86_64')
url="https://github.com/Raph-Rodrigues/Rice-Setup-Installer.git"
license=('GPL3')
depends=('gtkmm-4.0' 'vte3' 'glibmm')
makedepends=('git' 'cmake' 'gcc' 'pkgconf')
provides=("${pkgname%-git}")
conflicts=("${pkgname%-git}")

# Substitua pela URL do seu repositório Git
source=("git+https://github.com/Raph-Rodrigues/Rice-Setup-Installer.git")
sha256sums=('SKIP')

# Função para gerar a versão dinamicamente a partir dos commits do Git
pkgver() {
  cd "$srcdir/Rice-Setup-Installer"
  printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

build() {
  cd "$srcdir/Rice-Setup-Installer"

  # Compila o projeto utilizando o CMake
  cmake -B build -DCMAKE_BUILD_TYPE=Release
  cmake --build build
}

package() {
  cd "$srcdir/Rice-Setup-Installer"

  # 1. Cria o diretório de destino no /opt
  install -dm755 "$pkgdir/opt/installer_rice-setup"

  # 2. Copia o binário compilado (Assumindo que o CMake gera o executável chamado 'rice_installer')
  # Verifique o nome exato do executável gerado pelo seu CMakeLists.txt e ajuste abaixo se necessário
  install -Dm755 build/rice_installer "$pkgdir/opt/installer_rice-setup/rice_installer"

  # 3. Copia a pasta de scripts mantendo as permissões de execução
  cp -r scripts "$pkgdir/opt/installer_rice-setup/"
  chmod -R +x "$pkgdir/opt/installer_rice-setup/scripts/"

  # 4. Cria o wrapper em /usr/bin para que o usuário possa rodar pelo terminal de qualquer lugar
  install -dm755 "$pkgdir/usr/bin"
  cat <<'EOF' >"$pkgdir/usr/bin/installer_rice-setup"
#!/bin/bash
cd /opt/installer_rice-setup
./rice_installer
EOF

  # Dá permissão de execução ao wrapper
  chmod +x "$pkgdir/usr/bin/installer_rice-setup"
}

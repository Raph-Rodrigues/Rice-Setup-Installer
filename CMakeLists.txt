cmake_minimum_required(VERSION 3.10)
project(InstallerRice-Setup)

set(CMAKE_CXX_STANDARD 20)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Procura pelos módulos
find_package(PkgConfig REQUIRED)

# Cria os targets importados separadamente
pkg_check_modules(GTKMM REQUIRED IMPORTED_TARGET gtkmm-4.0)
pkg_check_modules(VTE REQUIRED IMPORTED_TARGET vte-2.91-gtk4)

add_executable(installer_rice-setup
  src/main.cpp
  src/InitWindow.cpp
  src/utils.cpp
  src/ConfigData.cpp
  src/ScriptManager.cpp
)

# Linka os targets (isso automaticamente resolve include_dirs e link_libraries)
target_link_libraries(installer_rice-setup PRIVATE PkgConfig::GTKMM PkgConfig::VTE)

# Copia os scripts
file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/src/scripts DESTINATION ${CMAKE_CURRENT_BINARY_DIR})

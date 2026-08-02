#include "utils.hpp"
#include <algorithm>
#include <cctype>
#include <fstream>
#include <string>

std::string get_distro() {
  std::ifstream file("/etc/os-release");
  std::string line;
  std::string name = "Linux Desconhecido";
  std::string id_like = "";

  if (file.is_open()) {
    while (std::getline(file, line)) {
      if (line.find("PRETTY_NAME=") == 0) {
        name = line.substr(12);
        if (name.front() == '"' && name.back() == '"') {
          name = name.substr(1, name.length() - 2);
        }
        return name;
      } else if (line.find("ID_LIKE=") == 0) {
        id_like = line.substr(8);
        if (id_like.front() == '"' && id_like.back() == '"') {
          id_like = id_like.substr(1, id_like.length() - 2);
        }
      }
    }
  }
  return !id_like.empty() ? "Base " + id_like : name;
}

bool is_arch_based(const std::string &distro_name) {
  std::string lower_name = distro_name;
  std::transform(lower_name.begin(), lower_name.end(), lower_name.begin(),
                 ::tolower);
  return (lower_name.find("arch") != std::string::npos ||
          lower_name.find("manjaro") != std::string::npos ||
          lower_name.find("endeavour") != std::string::npos ||
          lower_name.find("biglinux") != std::string::npos ||
          lower_name.find("steamos") != std::string::npos ||
          lower_name.find("cachyos") != std::string::npos);
}

bool is_fedora_based(const std::string &distro_name) {
  std::string lower_name = distro_name;
  std::transform(lower_name.begin(), lower_name.end(), lower_name.begin(),
                 ::tolower);

  return (lower_name.find("fedora") != std::string::npos ||
          lower_name.find("nobara") != std::string::npos ||
          lower_name.find("bazzite") != std::string::npos ||
          lower_name.find("aurora") != std::string::npos ||
          lower_name.find("bluefin") != std::string::npos);
}

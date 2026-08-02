#pragma once
#include <string>

std::string get_distro();

bool is_arch_based(const std::string &distro_name);
bool is_fedora_based(const std::string &distro_name);

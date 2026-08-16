#pragma once

#include <string>
#include <utility>
#include <vector>

namespace ConfigData {
// Declaração da lista de ferramentas e suas descrições
extern const std::vector<std::pair<std::string, std::string>> dev_tools;

extern const std::vector<std::pair<std::string, std::string>> wm_de_list;

extern const std::vector<std::pair<std::string, std::string>> game_tools;

extern const std::vector<std::pair<std::string, std::string>> prod_tools;
} // namespace ConfigData

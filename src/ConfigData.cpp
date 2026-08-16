#include "ConfigData.hpp"
#include <string>
#include <utility>
#include <vector>

namespace ConfigData {
const std::vector<std::pair<std::string, std::string>> dev_tools = {
    {"vscode", "Most popular Microsoft Code Editor"},
    {"vscodium", "Open Source version of Visual Studio Code"},
    {"neovim", "Terminal code editor, fork from Vim Terminal code editor"},
    {"zeditor", "High Performance Code Editor written in Rust"},
    {"rider", "IDE cross-platform for .Dotnet made by JetBrains"},
    {"intellij-community", "IDE opensource for Java made by JetBrains"},
    {"godot-hub", "Version manager for Godot Engine"},
    {"bottles", "Execute softwares and games from Windows easily on Linux"},
    {"unity-hub", "Project and Unity-Editor version hub manager"},
    {"asdf-vm", "Version manager for Development tools like programming "
                "languages and compilers"},
    {"lua51", "Lua brazilliam programming language version 5.1"},
    {"lua54", "Lua brazilliam programming language version 5.4"},
    {"lua55", "Lua brazilliam programming language version 5.5"},
    {"luajit", "Compiler Just-In-Time for Lua programming language"},
    {"luarocks", "Package manager for Lua modules"},
    {"git", "Version control system made by Linus Torvalds the creator of "
            "Kernel Linux"},
    {"lazygit", "TUI for git commands"},
    {"docker", "Platform for criation and execution of containers"},
    {"lazydocker", "TUI for manage docker"},
    {"gcc", "Colection of compilers GNU (C, C++, etc)"},
    {"make", "Classic tool of compilation"},
    {"cmake", "Cross-platform tool to manage builds and dependencies"},
    {"love2d", "Game Framework for 2D games with Lua"},
    {"lovr", "Game Framework for 3D games with Lua"},
    {"dotnet-10", "SDK version 10 from .NET ecossistem"},
    {"dotnet-9", "SDK version 9 from .NET ecossistem"},
    {"dotnet-8", "SDK version 8 from .NET ecossistem"},
    {"sdl2", "Low level Multimedia Library v2"},
    {"sdl3", "Low level Multimedia Library v3"},
    {"sfml2", "Simple and Fast Multimedia Library (version 2.x)"},
    {"sfml3", "Simple and Fast Multimedia Library (version 3.x)"},
    {"opengl", "API cross-platform for 2D and 3D graphics"},
    {"vulkan", "Graphical API and 3D computing of low overhead"},
    {"raylib", "Simple game library for 3D and 2D Games with C and C++"},
    {"fresh-editor", "TUI code editor simple and fast"},
    {"opencode", "Code AI agent opensource"},
    {"claude-code", "Claude Code CLI code AI agent"}};

const std::vector<std::pair<std::string, std::string>> wm_de_list = {
    {"hyprland", "Hyprland with noctalia shell"},
    {"cinnamon", "Cinnamon"},
    {"kde-plasma", "KDE Plasma"},
    {"gnome", "Gnome Desktop"},
    {"kinetic", "KDE Plasma with noctalia shell"},
    {"cosmic", "COSMIC DE"},
    {"niri", "Niri with noctalia shell"}};

const std::vector<std::pair<std::string, std::string>> game_tools = {
    {"steam", "Steam client for Linux"},
    {"lutris", "Open Source gaming platform for Linux"},
    {"heroic", "Open Source GOG and Epic Games launcher"},
    {"wine", "Run Windows applications on Linux"},
    {"mangohud", "Vulkan and OpenGL overlay for monitoring FPS"},
    {"gamemode", "Optimize Linux system performance on demand"},
    {"proton-plus", "Manage Proton versions"},
    {"bottles", "Run Windows applications on linux"},
    {"protontricks", "Run wine tricks commands for Steam Play/Proton games "
                     "among other common Wine features"}};

const std::vector<std::pair<std::string, std::string>> prod_tools = {
    // Browsers
    {"firefox", "Mozilla Firefox Web Browser"},
    {"brave-browser", "Brave Web Browser (Privacy focused)"},
    {"chromium", "Chromium Web Browser (Open source basis for Chrome)"},
    {"helium", "Lightweight browser focused on privacy based on chromium"},
    {"librewolf", "privacy focused browser based on firefox"},
    {"zen-browser", "firefox based browser"},

    // Produtividade & Office
    {"libreoffice",
     "Complete open-source office suite (Writer, Calc, Impress)"},
    {"obsidian", "Markdown-based knowledge base and note-taking app"},
    {"thunderbird", "Open-source email, news, and chat client"},
    {"xournalpp", "Handwriting note-taking software with PDF annotation"},

    // Comunicação
    {"discord", "Voice, video and text chat app"},
    {"telegram-desktop", "Fast and secure messaging app"},

    // Matemática, Ciências e Engenharia
    {"geogebra", "Dynamic mathematics software for all levels of education"},
    {"octave",
     "Scientific programming language (open-source MATLAB alternative)"},
    {"kicad", "EDA software suite for the creation of professional schematics "
              "and printed circuit boards"},
    {"freecad", "General purpose feature-based, parametric 3D modeler for CAD, "
                "MCAD, CAx, CAE and PLM"},
    {"avogadro",
     "Advanced molecular editor and visualizer (Chemistry/Biology)"},
    {"qalculate-gtk", "Multi-purpose cross-platform desktop calculator"},
    {"scidavis", "Graphical tool to plot graphics"},
    {"spyder", "Python DE for physics and engeneers"},

    // Multimídia e Design
    {"vlc", "VLC media player"},
    {"obs-studio",
     "Free and open source software for video recording and live streaming"},
    {"gimp", "GNU Image Manipulation Program"},
    {"inkscape", "Professional vector graphics editor"}};
} // namespace ConfigData

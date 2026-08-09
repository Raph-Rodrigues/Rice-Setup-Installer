#include "InitWindow.hpp"
#include "ConfigData.hpp"
#include "utils.hpp"
#include <glib.h>
#include <gtkmm/alertdialog.h>
#include <gtkmm/box.h>
#include <gtkmm/checkbutton.h>
#include <gtkmm/enums.h>
#include <gtkmm/expander.h>
#include <gtkmm/object.h>
#include <string>
#include <utility>
#include <vector>
#include <vte/vte.h>

InitWindow::InitWindow()
    : m_btn_check_distro("Verify your Distro Linux"),
      m_btn_install("Install Configurations") {
  set_title("Rice Installer");
  set_default_size(600, 700);

  m_distro_name = get_distro();

  setup_main_layout();
  build_appearance_category();
  build_system_category();
  build_repos_category();
  build_software_category();
  setup_terminal();

  set_child(m_vbox_main);
}

void InitWindow::setup_main_layout() {
  m_title.set_markup("<span size='xx-large' weight='bold'>Welcome!</span>");
  m_title.set_halign(Gtk::Align::CENTER);
  m_title.set_margin_top(20);

  m_txt_distro.set_text("Click 'Verify your Distro' to begin");
  m_txt_distro.set_halign(Gtk::Align::CENTER);
  m_txt_distro.set_margin_top(10);
  m_txt_distro.set_margin_bottom(20);

  m_vbox_main.append(m_title);
  m_vbox_main.append(m_txt_distro);

  m_scroll_options.set_child(m_vbox_options);
  m_scroll_options.set_vexpand(true);
  m_scroll_options.set_margin_start(20);
  m_scroll_options.set_margin_end(20);

  m_vbox_main.append(m_scroll_options);

  m_btn_check_distro.set_halign(Gtk::Align::CENTER);
  m_btn_check_distro.signal_clicked().connect(
      sigc::mem_fun(*this, &InitWindow::on_btn_clicked));
  m_vbox_main.append(m_btn_check_distro);

  m_btn_install.set_margin(10);
  m_btn_install.signal_clicked().connect(
      sigc::mem_fun(*this, &InitWindow::on_btn_install_clicked));
  m_vbox_main.append(m_btn_install);
}

void InitWindow::build_appearance_category() {
  auto box_appearance = add_category("Set Appearance");
  m_ck_wallpaper =
      add_install_option(box_appearance, "Wallpaper",
                         "Downloads and creates the Wallpaer folder on the "
                         "pictures folder on the user directories.",
                         "");
  m_ck_icons = add_install_option(
      box_appearance, "Ícones (Papirus)",
      "Installs the Papirus theme, nwg-look, kvantum and sets up as the main "
      "icon theme on the system",
      "• papirus-icon-theme\n• papirus-folders\n• nwg-look\n• kvantum");
  m_ck_cursors =
      add_install_option(box_appearance, "Cursors (Bibata)",
                         "Install the cursor Bibata Modern Classic theme and "
                         "sets on the GTK, QT and Flatpaks",
                         "• bibata-cursor-theme");
  m_ck_login = add_install_option(box_appearance, "Login Display (SDDM)",
                                  "Install the sddm on the system if necessary "
                                  "and then sets a theme on sddm",
                                  "sddm");
}

void InitWindow::build_system_category() {
  auto box_system = add_category("System and Interface");
  m_ck_shell =
      add_install_option(box_system, "Shell (fish)",
                         "Installs the Fish Shell and sets as main shell in "
                         "your system, clones my rice for fish",
                         "• fish\n• starship\n• fastfetch\n• eza");
  m_ck_terminal = add_install_option(
      box_system, "Terminal (Kitty)",
      "Installs the Kitty emulator terminal and sets my rice for kitty",
      "• kitty\n• jetbrains-mono-nerd\n• iosevka-nerd");
  m_ck_shader_boost =
      add_install_option(box_system, "Shader Boost",
                         "Clones the psygrep repo and runs the script for "
                         "improve the shader cache on the system",
                         "");
  m_ck_filemanager = add_install_option(
      box_system, "File Manager",
      "Installs a graphical file manager and TUI file manager",
      "• thunar\n• yazi\n");
  add_install_option(box_system, "WM/DE",
                     "Installs a Window Manager or Desktop Environment",
                     "• bspwm\n• sxhkd\n• polybar\n• rofi");
}

void InitWindow::build_repos_category() {
  auto box_repos = add_category("Repositories and Package Managers");
  m_ck_flatpak =
      add_install_option(box_repos, "Flatpak", "Universally distributed apps",
                         "flatpak and flathub repository");
  m_ck_homebrew = add_install_option(box_repos, "Homebrew",
                                     "The MacOs package manager", "homebrew");
  m_ck_snap = add_install_option(box_repos, "Snapd",
                                 "Canonical's package manager", "snapd");
  m_ck_nix = add_install_option(box_repos, "Nix Shell", "NixOS package manager",
                                "nix-shell");

  if (is_arch_based(m_distro_name)) {
    m_ck_paru = add_install_option(box_repos, "AUR (Paru)",
                                   "Install the Paru AUR Helper", "paru");
    m_ck_chaotic = add_install_option(
        box_repos, "Chaotic AUR", "Pre-compiled AUR repository", "chaotic-aur");
  } else if (is_fedora_based(m_distro_name)) {
    m_ck_rpmfusion = add_install_option(box_repos, "RPM Fusion",
                                        "Community driven RPMs", "rpm-fusion");
  }
}

void InitWindow::build_software_category() {
  auto box_software = add_category("Softwares");

  auto exp_dev = Gtk::make_managed<Gtk::Expander>("Development Tools");
  exp_dev->set_margin_start(15);
  auto vbox_dev = Gtk::make_managed<Gtk::Box>(Gtk::Orientation::VERTICAL, 2);
  vbox_dev->set_margin_start(10);
  vbox_dev->set_margin_top(5);

  for (const auto &pair : ConfigData::dev_tools) {
    auto chk = Gtk::make_managed<Gtk::CheckButton>(pair.first);
    chk->set_tooltip_text(pair.second);

    vbox_dev->append(*chk);
    m_dev_tools_checks.push_back({pair.first, chk});
  }

  exp_dev->set_child(*vbox_dev);
  box_software->append(*exp_dev);

  add_install_option(box_software, "Games",
                     "Installs lutris, steam, heroic game launcher, video "
                     "drivers, wine, proton",
                     "• lutris\n• steam\n• heroic");
  add_install_option(
      box_software, "Productivity / Study / Work",
      "Installs browser, office package, pdfs readers, obsidian, etc",
      "• firefox\n• libreoffice\n• obsidian");
}

void InitWindow::setup_terminal() {
  m_vte_term = vte_terminal_new();
  gtk_scrolled_window_set_child(m_scroll_console.gobj(), m_vte_term);
  m_scroll_console.set_size_request(-1, 200);
  m_scroll_console.set_margin(10);
  m_vbox_main.append(m_scroll_console);
}

Gtk::Box *InitWindow::add_category(const std::string &title) {
  auto expander = Gtk::make_managed<Gtk::Expander>();
  auto label = Gtk::make_managed<Gtk::Label>();

  label->set_markup("<span weight='bold' size='large'>" + title + "</span>");
  expander->set_label_widget(*label);
  expander->set_expanded(true);
  expander->set_margin_top(10);

  auto vbox = Gtk::make_managed<Gtk::Box>(Gtk::Orientation::VERTICAL, 5);
  vbox->set_margin_start(15);
  vbox->set_margin_top(5);

  expander->set_child(*vbox);
  m_vbox_options.append(*expander);

  return vbox;
}

Gtk::CheckButton *InitWindow::add_install_option(Gtk::Box *parent_box,
                                                 const std::string &label,
                                                 const std::string &tooltip,
                                                 const std::string &packages) {
  auto item_box = Gtk::make_managed<Gtk::Box>(Gtk::Orientation::VERTICAL, 2);

  auto chk = Gtk::make_managed<Gtk::CheckButton>(label);
  chk->set_tooltip_text(tooltip);
  item_box->append(*chk);

  if (!packages.empty()) {
    auto pkg_expander =
        Gtk::make_managed<Gtk::Expander>("Packages to be installed");
    pkg_expander->set_margin_start(28);

    auto pkg_label = Gtk::make_managed<Gtk::Label>(packages);
    pkg_label->set_halign(Gtk::Align::START);
    pkg_label->set_margin_start(10);
    pkg_label->set_margin_top(5);
    pkg_label->set_margin_bottom(5);

    pkg_expander->set_child(*pkg_label);
    pkg_expander->set_visible(false);

    chk->signal_toggled().connect([chk, pkg_expander]() {
      pkg_expander->set_visible(chk->get_active());
    });

    item_box->append(*pkg_expander);
  }

  parent_box->append(*item_box);
  return chk;
}

void InitWindow::on_btn_clicked() {
  m_distro_name = get_distro();
  m_txt_distro.set_text("Ricing on the " + m_distro_name);

  auto dialog = Gtk::AlertDialog::create("We have detected your distribution!");
  dialog->set_detail(": " + m_distro_name);
  dialog->show(*this);
}

void InitWindow::on_btn_install_clicked() {
  m_btn_install.set_sensitive(false);

  m_script_manager.clear();

  if (m_ck_shell->get_active())
    m_script_manager.add_script("./scripts/install_fish.sh");
  if (m_ck_terminal->get_active())
    m_script_manager.add_script("./scripts/install_terminal.sh");
  if (m_ck_filemanager->get_active())
    m_script_manager.add_script("./scripts/install_filemanager.sh");
  if (m_ck_shader_boost->get_active())
    m_script_manager.add_script("./scripts/install_shaderboost.sh");

  if (m_ck_flatpak->get_active())
    m_script_manager.add_script("./scripts/install_flatpak.sh");
  if (m_ck_homebrew->get_active())
    m_script_manager.add_script("./scripts/install_homebrew.sh");
  if (m_ck_snap->get_active())
    m_script_manager.add_script("./scripts/install_snap.sh");
  if (m_ck_nix->get_active())
    m_script_manager.add_script("./scripts/install_nix.sh");

  if (m_ck_wallpaper->get_active())
    m_script_manager.add_script("./scripts/install_wallpaper.sh");
  if (m_ck_cursors->get_active())
    m_script_manager.add_script("./scripts/install_cursors.sh");
  if (m_ck_icons->get_active())
    m_script_manager.add_script("./scripts/install_icons.sh");
  if (m_ck_login->get_active())
    m_script_manager.add_script("./scripts/install_sddm.sh");

  if (m_ck_paru && m_ck_paru->get_active())
    m_script_manager.add_script("./scripts/install_paru.sh");
  if (m_ck_chaotic && m_ck_chaotic->get_active())
    m_script_manager.add_script("./scripts/install_chaotic_aur.sh");
  if (m_ck_rpmfusion && m_ck_rpmfusion->get_active())
    m_script_manager.add_script("./scripts/install_rpmfusion.sh");

  // coleta todas as ferramentas de desenvolvimento selecionadas
  std::string dev_args = "";
  for (const auto &pair : m_dev_tools_checks) {
    if (pair.second->get_active()) {
      dev_args += pair.first + " ";
    }
  }

  // se houver ferramentas selecionadas, adiciona script com argumentos na fila
  if (!dev_args.empty()) {
    m_script_manager.add_script("./scripts/install_dev_tools.sh " + dev_args);
  }

  std::string init_msg = "\r\n\033[1;36m==>\033[0m \033[1;33mInicializing the "
                         "configuration process...\033[0m\r\n";
  vte_terminal_feed(VTE_TERMINAL(m_vte_term), init_msg.c_str(), -1);

  m_script_manager.start(VTE_TERMINAL(m_vte_term),
                         [this]() { on_process_finished(0); });
}

void InitWindow::on_process_finished(int status) {
  m_btn_install.set_sensitive(true);
  std::string end_msg =
      "\r\n\033[1;32m[ OK ]\033[0m All requested tasks were completed.\r\n";
  vte_terminal_feed(VTE_TERMINAL(m_vte_term), end_msg.c_str(), -1);

  auto dialog = Gtk::AlertDialog::create("Success Installation!");
  dialog->set_detail("All the process are done with success");
  dialog->show(*this);
}

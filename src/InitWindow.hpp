#pragma once

#include "ScritpManager.hpp"
#include <gtkmm.h>
#include <gtkmm/button.h>
#include <gtkmm/checkbutton.h>
#include <string>
#include <utility>
#include <vector>
#include <vte/vte.h>

class InitWindow : public Gtk::Window {
public:
  InitWindow();
  ~InitWindow() = default;

protected:
  // Eventos
  void on_btn_clicked();
  void on_btn_install_clicked();
  void on_process_finished(int status);

  // Utilitários de UI
  Gtk::Box *add_category(const std::string &title);
  Gtk::CheckButton *add_install_option(Gtk::Box *parent_box,
                                       const std::string &label,
                                       const std::string &tooltip,
                                       const std::string &packages);

private:
  // separação de tarefas
  void setup_main_layout();
  void build_appearance_category();
  void build_system_category();
  void build_repos_category();
  void build_software_category();
  void setup_terminal();

  ScriptManager m_script_manager;

protected:
  // Layout principal
  Gtk::Box m_vbox_main{Gtk::Orientation::VERTICAL, 10};
  Gtk::Label m_title, m_txt_distro;

  // Área de opções rolável
  Gtk::ScrolledWindow m_scroll_options;
  Gtk::Box m_vbox_options{Gtk::Orientation::VERTICAL, 5};

  // Checkboxes
  Gtk::CheckButton *m_ck_shell;
  Gtk::CheckButton *m_ck_terminal;
  Gtk::CheckButton *m_ck_shader_boost;
  Gtk::CheckButton *m_ck_filemanager;
  Gtk::CheckButton *m_ck_wallpaper;
  Gtk::CheckButton *m_ck_icons;
  Gtk::CheckButton *m_ck_cursors;
  Gtk::CheckButton *m_ck_login;
  Gtk::CheckButton *m_ck_flatpak = nullptr;
  Gtk::CheckButton *m_ck_homebrew = nullptr;
  Gtk::CheckButton *m_ck_snap = nullptr;
  Gtk::CheckButton *m_ck_nix = nullptr;
  Gtk::CheckButton *m_ck_paru = nullptr;
  Gtk::CheckButton *m_ck_chaotic = nullptr;
  Gtk::CheckButton *m_ck_rpmfusion = nullptr;

  // Console (VTE)
  Gtk::ScrolledWindow m_scroll_console;
  GtkWidget *m_vte_term;

  // Botões
  Gtk::Button m_btn_check_distro;
  Gtk::Button m_btn_install;

  // Armazena os ponteiros para os checkboxes de desenvolvimento
  std::vector<std::pair<std::string, Gtk::CheckButton *>> m_dev_tools_checks;
  // Armazena os ponteiros para os checkboxes de WM/DE
  std::vector<std::pair<std::string, Gtk::CheckButton *>> m_wm_de_checks;
  std::vector<std::pair<std::string, Gtk::CheckButton *>> m_game_checks;
  std::vector<std::pair<std::string, Gtk::CheckButton *>> m_prod_checks;

  // Variáveis de estado
  std::string m_distro_name;
};

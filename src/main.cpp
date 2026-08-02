#include <array>
#include <cstdlib>
#include <fstream>
#include <glib-object.h>
#include <glib.h>
#include <gtk/gtk.h>
#include <gtkmm.h>
#include <gtkmm/alertdialog.h>
#include <gtkmm/widget.h>
#include <iostream>
#include <memory>
#include <mutex>
#include <queue>
#include <string>
#include <thread>
#include <vte/vte.h>

// pega o nome da distro
std::string get_distro() {
  std::ifstream file("/etc/os-release");
  std::string line;
  std::string name = "Linux Desconhecido";
  std::string id_like = "";

  if (file.is_open()) {
    while (std::getline(file, line)) {
      // checa se consegue encontrar o nome da distro
      if (line.find("PRETTY_NAME=") == 0) {
        name = line.substr(12);

        // remove as aspas
        if (name.front() == '"' && name.back() == '"') {
          name = name.substr(1, name.length() - 2);
        }
        return name; // retorna o nome

        // se não consegue encontrar o nome, vai tentar encontrar qual a base da
        // distro
      } else if (line.find("ID_LIKE=") == 0) {
        id_like = line.substr(8);

        // remove as aspas
        if (id_like.front() == '"' && id_like.back() == '"') {
          id_like = id_like.substr(1, id_like.length() - 2);
        }
      }
    }
  }

  // retorna o nome da base da distro
  return !id_like.empty() ? "Base " + id_like : name;
}

// Nossa classe herda de Gtk::Window para criar a janela principal
class InitWindow : public Gtk::Window {
public:
  InitWindow();
  ~InitWindow() = default;

protected:
  // Tratador do sinal de clique
  void on_btn_clicked();
  void on_btn_install_clicked();
  void on_process_finished(int status);

  // Elementos da interface (Widgets)
  // utilitários
  Gtk::CheckButton *create_checkbox(const std::string &label,
                                    const std::string &tooltip);
  void add_category(const std::string &title);

  // layout
  Gtk::Box m_vbox_main{Gtk::Orientation::VERTICAL,
                       10}; // caixa para organizar os itens na vertical
  Gtk::Label m_title, m_txt_distro;

  // area rolavel
  Gtk::ScrolledWindow m_scroll_options;
  Gtk::Box m_vbox_options{Gtk::Orientation::VERTICAL, 5};

  // Check box
  Gtk::CheckButton *m_ck_shell;
  // TODO: add more check boxes

  // console
  Gtk::ScrolledWindow m_scroll_console;
  GtkWidget *m_vte_term;

  Gtk::Button m_btn_check_distro;
  Gtk::Button m_btn_install;

  // multithreading
  std::string m_distro_name;
  std::thread m_thread_installation;
  Glib::Dispatcher m_dispatcher; // comunica thread com UI
  std::mutex m_mutex;
  std::queue<std::string> m_msg_stack;
  bool m_finalized_process = false;
};

// Construtor da janela
InitWindow::InitWindow()
    : m_btn_check_distro("Verify your Distro Linux"),
      m_btn_install("Install Configurations") {
  set_title("Rice Installer");
  set_default_size(600, 700);

  m_distro_name = get_distro();

  m_title.set_markup("<span size='xx-large' weight='bold'>Welcome!</span>");
  m_title.set_halign(Gtk::Align::CENTER);
  m_title.set_margin_top(20);

  m_txt_distro.set_text("Click 'Verify your Distro' to begin");
  m_txt_distro.set_halign(Gtk::Align::CENTER);
  m_txt_distro.set_margin_top(10);
  m_txt_distro.set_margin_bottom(20);

  // adicionando tudo na box vertical
  m_vbox_main.append(m_title);
  m_vbox_main.append(m_txt_distro);

  // lista de categorias
  m_scroll_options.set_child(m_vbox_options);
  m_scroll_options.set_vexpand(true);
  m_scroll_options.set_margin_start(20);
  m_scroll_options.set_margin_end(20);

  add_category("Set Appearance");
  m_vbox_options.append(*create_checkbox(
      "Wallpaper", "Downloads and sets up the wallpaper from my repo."));

  add_category("System and Interface");
  m_ck_shell = create_checkbox("Shell (fish)",
                               "Installs the Fish Shell and sets as main shell "
                               "in your system, clones my rice for fish");
  m_vbox_options.append(*m_ck_shell);
  m_vbox_options.append(*create_checkbox(
      "WM/DE", "Installs a Window Manager or Desktop Environment"));

  add_category("Softwares");
  m_vbox_options.append(*create_checkbox(
      "Development", "Installs asdf, compilers, code editors and etc"));
  m_vbox_options.append(
      *create_checkbox("Games", "Installs lutris, steam, heroic game launcher, "
                                "video drivers, wine, proton"));
  m_vbox_options.append(*create_checkbox(
      "Productivity / Study / Work",
      "Installs browser, office package, pdfs readers, obsidian, etc"));

  m_vbox_main.append(m_scroll_options);

  // botão checar distro
  // Configura uma margem ao redor do botão
  m_btn_check_distro.set_halign(Gtk::Align::CENTER);
  // Conecta o evento de clique do botão à nossa função usando sigc::mem_fun
  m_btn_check_distro.signal_clicked().connect(
      sigc::mem_fun(*this, &InitWindow::on_btn_clicked));
  m_vbox_main.append(m_btn_check_distro);

  // botão instalar
  m_btn_install.set_margin(10);
  m_btn_install.signal_clicked().connect(
      sigc::mem_fun(*this, &InitWindow::on_btn_install_clicked));
  m_vbox_main.append(m_btn_install);

  // console de saída
  m_vte_term = vte_terminal_new();

  gtk_scrolled_window_set_child(m_scroll_console.gobj(), m_vte_term);

  m_scroll_console.set_size_request(-1, 200);
  m_scroll_console.set_margin(10);

  m_vbox_main.append(m_scroll_console);

  g_signal_connect(
      m_vte_term, "child-exited",
      G_CALLBACK(+[](VteTerminal *terminal, gint status, gpointer user_data) {
        auto *window = static_cast<InitWindow *>(user_data);
        window->on_process_finished(status);
      }),
      this);

  // adiciona box como filha da Janela principal
  set_child(m_vbox_main);
}

void InitWindow::add_category(const std::string &title) {
  auto label = Gtk::make_managed<Gtk::Label>();
  label->set_markup("<span weight='bold' size='large'>" + title + "</span>");
  label->set_halign(Gtk::Align::START);
  label->set_margin_top(15);
  label->set_margin_bottom(5);
  m_vbox_options.append(*label);
}

Gtk::CheckButton *InitWindow::create_checkbox(const std::string &label,
                                              const std::string &tooltip) {
  auto chk = Gtk::make_managed<Gtk::CheckButton>(label);
  chk->set_tooltip_text(tooltip);
  return chk;
}

// Ação executada ao clicar
void InitWindow::on_btn_clicked() {
  m_distro_name = get_distro();
  m_txt_distro.set_text("Ricing on the " + m_distro_name);

  // No GTK4, usamos AlertDialog para janelas de mensagem simples (pop-ups)
  auto dialog = Gtk::AlertDialog::create("We have detected your distrobution!");
  dialog->set_detail(": " + m_distro_name);

  // O AlertDialog já cria botões de "Fechar/OK" nativamente baseados no
  // sistema. O comando "show" exibe o pop-up atrelado à nossa janela atual
  // (*this)
  dialog->show(*this);
}

void InitWindow::on_btn_install_clicked() {
  m_btn_install.set_sensitive(false);

  std::string init_msg = "\r\n\003[1;36m==>\033[0m \033[1;Inicializing the "
                         "configuration process...\033[0m\r\n";
  vte_terminal_feed(VTE_TERMINAL(m_vte_term), init_msg.c_str(), -1);

  if (m_ck_shell->get_active()) {
    const char *argv[] = {"/bin/bash", "./scripts/install_fish.sh", nullptr};

    vte_terminal_spawn_async(VTE_TERMINAL(m_vte_term), VTE_PTY_DEFAULT, nullptr,
                             (char **)argv, nullptr, G_SPAWN_DEFAULT, nullptr,
                             nullptr, nullptr, -1, nullptr, nullptr, nullptr);
  } else {
    std::string skip_msg =
        "\r\n\033[1;31m[ WARN ]\033[0m Shell Configuration was skipped.\r\n";
    vte_terminal_feed(VTE_TERMINAL(m_vte_term), skip_msg.c_str(), -1);

    on_process_finished(0);
  }
}

void InitWindow::on_process_finished(int status) {
  m_btn_install.set_sensitive(true);

  std::string end_msg =
      "\r\n\033[1;32m[ OK ]\033[0m All requested tasks were completed.\r\n";
  vte_terminal_feed(VTE_TERMINAL(m_vte_term), end_msg.c_str(), -1);

  auto dialog = Gtk::AlertDialog::create("Success Instalation!");
  dialog->set_detail("All the proccesses are done with success");
  dialog->show(*this);
}

int main(int argc, char *argv[]) {
  // Cria a aplicação principal com um identificador único
  auto app = Gtk::Application::create("org.exemplo.gtkmm");

  // Instancia a janela, exibe na tela e entra no loop principal (aguardando
  // eventos)
  return app->make_window_and_run<InitWindow>(argc, argv);
}

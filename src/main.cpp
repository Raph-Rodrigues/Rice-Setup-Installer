#include <fstream>
#include <gtkmm.h>
#include <string>

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

protected:
  // Tratador do sinal de clique
  void on_btn_clicked();

  // Elementos da interface (Widgets)
  Gtk::Box m_vbox; // caixa para organizar os itens na vertical
  Gtk::Label m_title;
  Gtk::Label m_txt_distro;
  Gtk::Button m_btn;

  std::string m_distro_name;
};

// Construtor da janela
InitWindow::InitWindow()
    : m_vbox(Gtk::Orientation::VERTICAL, 10),
      m_btn("Verifique sua distro Linux") {
  set_title("Rice Installer");
  set_default_size(450, 250);

  m_distro_name = get_distro();

  m_title.set_markup("<span size='xx-large' weight='bold'>Bem-vindo!</span>");
  m_title.set_halign(Gtk::Align::CENTER);
  m_title.set_margin_top(20);

  m_txt_distro.set_text("Customização e Configurado em " + m_distro_name);
  m_txt_distro.set_halign(Gtk::Align::CENTER);
  m_txt_distro.set_margin_top(10);
  m_txt_distro.set_margin_bottom(20);

  // Configura uma margem ao redor do botão
  m_btn.set_halign(Gtk::Align::CENTER);
  // Conecta o evento de clique do botão à nossa função usando sigc::mem_fun
  m_btn.signal_clicked().connect(
      sigc::mem_fun(*this, &InitWindow::on_btn_clicked));

  // adicionando tudo na box vertical
  m_vbox.append(m_title);
  m_vbox.append(m_txt_distro);
  m_vbox.append(m_btn);

  // adiciona box como filha da Janela principal
  set_child(m_vbox);
}

// Ação executada ao clicar
void InitWindow::on_btn_clicked() {
  // No GTK4, usamos AlertDialog para janelas de mensagem simples (pop-ups)
  auto dialog = Gtk::AlertDialog::create("Detectamos sua distribuição!");
  dialog->set_detail("Você está rodando: " + m_distro_name);

  // O AlertDialog já cria botões de "Fechar/OK" nativamente baseados no
  // sistema. O comando "show" exibe o pop-up atrelado à nossa janela atual
  // (*this)
  dialog->show(*this);
}

int main(int argc, char *argv[]) {
  // Cria a aplicação principal com um identificador único
  auto app = Gtk::Application::create("org.exemplo.gtkmm");

  // Instancia a janela, exibe na tela e entra no loop principal (aguardando
  // eventos)
  return app->make_window_and_run<InitWindow>(argc, argv);
}

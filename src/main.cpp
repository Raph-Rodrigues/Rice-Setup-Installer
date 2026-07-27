#include <gtkmm.h>
#include <iostream>

// Nossa classe herda de Gtk::Window para criar a janela principal
class JanelaInicial : public Gtk::Window {
public:
  JanelaInicial();

protected:
  // Tratador do sinal de clique
  void on_botao_clicado();

  // Elementos da interface (Widgets)
  Gtk::Button m_botao;
};

// Construtor da janela
JanelaInicial::JanelaInicial() : m_botao("Clique em mim!") {
  set_title("Exemplo GTK com C++");
  set_default_size(300, 200);

  // Configura uma margem ao redor do botão
  m_botao.set_margin(40);

  // Conecta o evento de clique do botão à nossa função usando sigc::mem_fun
  m_botao.signal_clicked().connect(
      sigc::mem_fun(*this, &JanelaInicial::on_botao_clicado));

  // Adiciona o botão como o widget filho da janela (no GTK4 usamos set_child)
  set_child(m_botao);
}

// Ação executada ao clicar
void JanelaInicial::on_botao_clicado() {
  std::cout << "Olá, Mundo! O botão foi clicado." << std::endl;
}

int main(int argc, char *argv[]) {
  // Cria a aplicação principal com um identificador único
  auto app = Gtk::Application::create("org.exemplo.gtkmm");

  // Instancia a janela, exibe na tela e entra no loop principal (aguardando
  // eventos)
  return app->make_window_and_run<JanelaInicial>(argc, argv);
}

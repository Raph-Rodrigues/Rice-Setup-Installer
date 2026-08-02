#include "InitWindow.hpp"
#include <gtkmm.h>

int main(int argc, char *argv[]) {
  auto app = Gtk::Application::create("org.exemplo.gtkmm");
  return app->make_window_and_run<InitWindow>(argc, argv);
}

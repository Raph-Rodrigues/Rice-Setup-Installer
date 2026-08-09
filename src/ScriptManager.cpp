#include "ScritpManager.hpp"
#include <functional>
#include <glib-object.h>
#include <glib.h>
#include <string>
#include <vte/vte.h>

void ScriptManager::add_script(const std::string &script_cmd) {
  m_script_queue.push(script_cmd);
}

void ScriptManager::clear() {
  while (!m_script_queue.empty()) {
    m_script_queue.pop();
  }
}

void ScriptManager::start(VteTerminal *vte_terminal,
                          std::function<void()> on_finished) {
  m_vte_term = vte_terminal;
  m_on_finished_callback = on_finished;

  g_signal_connect(m_vte_term, "child-exited", G_CALLBACK(on_child_exited),
                   this);

  run_next();
}

void ScriptManager::run_next() {
  if (m_script_queue.empty()) {
    if (m_on_finished_callback) {
      m_on_finished_callback();
    }

    return;
  }

  std::string current_cmd = m_script_queue.front();
  m_script_queue.pop();

  static std::string safe_cmd;
  safe_cmd = current_cmd;
  const char *argv[] = {"/bin/bash", "-c", safe_cmd.c_str(), nullptr};

  vte_terminal_spawn_async(m_vte_term, VTE_PTY_DEFAULT, nullptr, (char **)argv,
                           nullptr, G_SPAWN_DEFAULT, nullptr, nullptr, nullptr,
                           -1, nullptr, nullptr, nullptr);
}

void ScriptManager::on_child_exited(VteTerminal *terminal, int status,
                                    gpointer user_data) {
  auto *manager = static_cast<ScriptManager *>(user_data);
  if (manager) {
    manager->run_next();
  }
}

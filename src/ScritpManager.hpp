#pragma once

#include <functional>
#include <glib.h>
#include <queue>
#include <string>
#include <vte/vte.h>

class ScriptManager {
public:
  ScriptManager() = default;
  ~ScriptManager() = default;

  void add_script(const std::string &script_cmd);

  void clear();

  void start(VteTerminal *vte_terminal, std::function<void()> on_finished);

private:
  void run_next();

  std::queue<std::string> m_script_queue;
  VteTerminal *m_vte_term = nullptr;
  std::function<void()> m_on_finished_callback;

  static void on_child_exited(VteTerminal *terminal, int status,
                              gpointer user_data);
};

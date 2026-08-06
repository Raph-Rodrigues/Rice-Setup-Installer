#!/bin/bash

echo -e "\033[1;35m[ SHADER BOOSTER ]\033[0m Instalando e aplicando Shader Booster..."

# Cria um diretório temporário para clonar o repositório
TEMP_DIR=$(mktemp -d)

echo "Clonando o repositório psygreg/shader-booster..."
git clone https://github.com/psygreg/shader-booster.git "$TEMP_DIR"

# Entra no diretório clonado para garantir que o script encontre seus arquivos relativos
cd "$TEMP_DIR" || exit 1

# Detecta o shell padrão do usuário isolando apenas o nome (ex: /usr/bin/zsh vira zsh)
USER_SHELL=$(basename "$SHELL")
echo "Shell padrão detectado: $USER_SHELL"

# Verifica o shell e executa o script correspondente
if [[ "$USER_SHELL" == "fish" ]]; then
  if [ -f "patcher.fish" ]; then
    echo "Dando permissão e executando patcher.fish..."
    chmod +x patcher.fish
    # O script fish é chamado com o próprio fish para evitar problemas de compatibilidade
    fish ./patcher.fish
  else
    echo -e "\033[1;31m[ ERRO ]\033[0m Arquivo patcher.fish não encontrado no repositório."
  fi
elif [[ "$USER_SHELL" == "bash" || "$USER_SHELL" == "zsh" ]]; then
  if [ -f "patcher.sh" ]; then
    echo "Dando permissão e executando patcher.sh..."
    chmod +x patcher.sh
    ./patcher.sh
  else
    echo -e "\033[1;31m[ ERRO ]\033[0m Arquivo patcher.sh não encontrado no repositório."
  fi
else
  # Fallback caso o usuário esteja usando um shell diferente (ex: sh, ksh, csh)
  echo -e "\033[1;33m[ AVISO ]\033[0m Shell ($USER_SHELL) não suportado nativamente pelo script. Tentando executar via bash..."
  if [ -f "patcher.sh" ]; then
    chmod +x patcher.sh
    bash ./patcher.sh
  fi
fi

# Volta para o diretório original de execução
cd - >/dev/null

# Limpa a pasta temporária após o script finalizar
rm -rf "$TEMP_DIR"

echo -e "\033[1;32m[ OK ]\033[0m Execução do Shader Booster finalizada!"

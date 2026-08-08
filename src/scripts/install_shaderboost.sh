#!/bin/bash

echo -e "\033[1;35m[ SHADER BOOSTER ]\033[0m Installing and applying Shader Booster..."

# Creates a temporary directory to clone the repository
TEMP_DIR=$(mktemp -d)

echo "Cloning the psygreg/shader-booster repository..."
git clone https://github.com/psygreg/shader-booster.git "$TEMP_DIR"

# Enters the cloned directory to ensure the script finds its relative files
cd "$TEMP_DIR" || exit 1

# Detects the user's default shell by isolating just the name (e.g., /usr/bin/zsh becomes zsh)
USER_SHELL=$(basename "$SHELL")
echo "Default shell detected: $USER_SHELL"

# Checks the shell and executes the corresponding script
if [[ "$USER_SHELL" == "fish" ]]; then
  if [ -f "patcher.fish" ]; then
    echo "Granting permission and executing patcher.fish..."
    chmod +x patcher.fish
    # The fish script is called with fish itself to avoid compatibility issues
    fish ./patcher.fish
  else
    echo -e "\033[1;31m[ ERROR ]\033[0m patcher.fish file not found in the repository."
  fi
elif [[ "$USER_SHELL" == "bash" || "$USER_SHELL" == "zsh" ]]; then
  if [ -f "patcher.sh" ]; then
    echo "Granting permission and executing patcher.sh..."
    chmod +x patcher.sh
    ./patcher.sh
  else
    echo -e "\033[1;31m[ ERROR ]\033[0m patcher.sh file not found in the repository."
  fi
else
  # Fallback in case the user is using a different shell (e.g., sh, ksh, csh)
  echo -e "\033[1;33m[ WARNING ]\033[0m Shell ($USER_SHELL) not natively supported by the script. Trying to execute via bash..."
  if [ -f "patcher.sh" ]; then
    chmod +x patcher.sh
    bash ./patcher.sh
  fi
fi

# Returns to the original execution directory
cd - >/dev/null

# Cleans up the temporary folder after the script finishes
rm -rf "$TEMP_DIR"

echo -e "\033[1;32m[ OK ]\033[0m Shader Booster execution finished!"

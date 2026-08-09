#!/bin/bash
export IDF_PATH="/usr/share/esp-idf"
export ESP_ROM_ELF_DIR="/usr/share/esp-rom-elfs"
export OPENOCD_SCRIPTS="/opt/openocd-esp32/share/openocd/scripts"
export PATH="/opt/openocd-esp32/bin:$PATH"
# Disable default tools check/venv
export IDF_PYTHON_ENV_PATH="/usr"
export IDF_TOOLS_PATH="/usr/share/esp-idf"
export IDF_VIRTUAL_ENV_DISABLED="1"
export PYTHON="/usr/bin/${EPYTHON:-python3}"
exec "${PYTHON}" "/usr/share/esp-idf/tools/idf.py" "$@"

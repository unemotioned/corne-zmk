#!/usr/bin/env bash
set -euo pipefail

# NOTE: Change the keyboard names and controller type from here.
shield_left='corne_left nice_view_adapter nice_view'
shield_right='corne_right nice_view_adapter nice_view'
board='nice_nano_v2'

venv_dir="$HOME/venv/zmk"

# absolute path to script's directory not where you ran it
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR"

# activate python venv
source "$venv_dir/bin/activate"

# source Zephyr SDK env var
source "$SCRIPT_DIR/zephyr_env.sh"

# remove Homebrew injected flags only for this script
unset CPPFLAGS
unset LDFLAGS

# make sure west to use repo dir
cd "$ROOT_DIR"

# start timer
SECONDS=0

build_target() {
  local build_dir="$1"
  local shield="$2"
  local controller="$3"

  west build \
    -d "$build_dir" \
    -p always \
    -b "$controller" \
    -s zmk/app \
    -- \
    -DSHIELD="$shield" \
    -DZMK_CONFIG="$ROOT_DIR/config" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
}

build_target build/left "$shield_left" "$board"
build_target build/right "$shield_right" "$board"
# NOTE: Uncomment the following line to build the "settings_reset.uf2" file.
# build_target build/settings_reset settings_reset "$controller"

mkdir -p output
cp build/left/zephyr/zmk.uf2 output/"${shield_left}".uf2
cp build/right/zephyr/zmk.uf2 output/"${shield_right}".uf2
[ -f build/settings_reset/zephyr/zmk.uf2 ] && cp build/settings_reset/zephyr/zmk.uf2 output/settings_reset.uf2

echo -e "\n----------------------------------------------"
echo -e "\n Build done. (took ${SECONDS}s)"
echo -e "\n uf2 files are copied to the output directory."
echo -e "\n----------------------------------------------\n"

read -rp 'Open output directory with finder? [y/N]: ' answer
if [[ "${answer,,}" == 'y' ]]; then
  open ./output
fi


#!/bin/bash

source "/root/RucoPie/scripts/commons.sh"

failed_status=1

function run_game () {
  core=""
  case $1 in
    atari2600) core="stella2014" ;;
    nes)       core="fceumm" ;;
    snes)      core="snes9x" ;;
    gb|gbc)    core="gambatte" ;;
    neogeo)    core="fbneo" ;;
    *)         color_echo "red" "Error: System $1 is not valid."
  esac

  if [ -z $core ]; then
    return $failed_status
  fi

  ## full game path:
  path="$2"
  color_echo "green" "Executing retroarch with: core = $core, rom = $path"

  /opt/retropie/emulators/retroarch/bin/retroarch -L \
  /opt/retropie/libretrocores/lr-"$core"/"$core"_libretro.so \
  --config /opt/retropie/configs/all/retroarch/cores/"$core".cfg "$path" \
  /

  return 0
}

run_game "$1" "$2"

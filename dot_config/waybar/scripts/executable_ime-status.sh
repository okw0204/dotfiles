#!/usr/bin/env bash

state="$(fcitx5-remote 2>/dev/null || true)"

case "$state" in
  2)
    printf '{"text":"あ","tooltip":"Japanese input (Mozc)","class":"active"}\n'
    ;;
  1)
    printf '{"text":"A","tooltip":"Half-width alphanumeric","class":"inactive"}\n'
    ;;
  0)
    printf '{"text":"A","tooltip":"Input method disabled","class":"inactive"}\n'
    ;;
  *)
    printf '{"text":"?","tooltip":"fcitx5 unavailable","class":"unavailable"}\n'
    ;;
esac

#!/bin/sh

enable_color() {
  ENABLECOLOR='-c '
  ANSI_RED="\033[31m"
  ANSI_GREEN="\033[32m"
  ANSI_YELLOW="\033[33m"
  ANSI_BLUE="\033[34m"
  ANSI_MAGENTA="\033[35m"
  ANSI_GRAY="\033[90m"
  ANSI_CYAN="\033[36;1m"
  ANSI_DARKCYAN="\033[36m"
  ANSI_NOCOLOR="\033[0m"
}

disable_color() { unset ENABLECOLOR ANSI_RED ANSI_GREEN ANSI_YELLOW ANSI_BLUE ANSI_MAGENTA ANSI_CYAN ANSI_DARKCYAN ANSI_NOCOLOR; }

enable_color

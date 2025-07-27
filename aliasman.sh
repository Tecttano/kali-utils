#!/bin/bash

zshrc="$HOME/.zshrc"
default_truncate=100
use_bat=0
command -v batcat &> /dev/null && use_bat=1

print_usage() {
  echo "Usage: aliasman [--full | --length <N> | --add <name> | --edit <name> | --rm <name> | --search <keyword> | --reload]"
  exit 1
}

is_command_like() {
  type "$1" &>/dev/null
}

colorize_truncated() {
  local cmd="$1"
  local limit="$2"
  local words=($cmd)
  local output=""
  for word in "${words[@]}"; do
    local color="\033[0;37m"
    if [[ "$word" == "sudo" ]]; then
      color="\033[1;32m"  # green
    elif [[ "$word" =~ ^- ]]; then
      color="\033[1;33m"  # yellow
    elif is_command_like "$word"; then
      color="\033[1;36m"  # cyan
    fi
    output+=" ${color}${word}\033[0m"
  done
  local stripped=$(echo -e "$output" | cut -c1-"$limit")
  [[ ${#output} -gt $limit ]] && stripped="$stripped\u2026"
  echo -e "$stripped"
}

print_aliases() {
  local truncate_len="$1"
  in_ctf_section=0
  printed_ctf=0
  printed_other=0

  echo -e "\n\033[1;32mAlias Overview:\033[0m"

  while IFS= read -r line; do
    lower_line="${line,,}"
    if [[ "$lower_line" =~ ^#[[:space:]]*ctf[[:space:]]aliases ]]; then
      in_ctf_section=1
      continue
    elif [[ "$line" =~ ^#[[:space:]]* ]]; then
      in_ctf_section=0
      continue
    fi

    if [[ "$line" =~ ^alias[[:space:]]+ ]]; then
      name=$(echo "$line" | cut -d= -f1 | awk '{print $2}')
      command=$(echo "$line" | cut -d= -f2- | sed "s/^'//;s/'$//")

      if [[ $in_ctf_section -eq 1 && $printed_ctf -eq 0 ]]; then
        echo -e "\n\033[1;33m# CTF Aliases\033[0m"
        printed_ctf=1
      elif [[ $in_ctf_section -eq 0 && $printed_other -eq 0 ]]; then
        echo -e "\n\033[1;33m# Other Aliases\033[0m"
        printed_other=1
      fi

      printf " \033[1;34m%-12s\033[0m → " "$name"

      if [[ $use_bat -eq 1 && $truncate_len -eq 0 ]]; then
        echo "$command" | batcat --language=bash --style=plain --color=always --paging=never
      else
        colorize_truncated "$command" "$truncate_len"
      fi
    fi
  done < "$zshrc"
}

add_alias() {
  local name="$1"
  read -rp "Enter command for alias '$name': " cmd
  echo "alias $name='$cmd'" >> "$zshrc"
  echo "Alias '$name' added."
  reload_shell
}

edit_alias() {
  local name="$1"
  grep -q "alias $name=" "$zshrc" || { echo "Alias not found."; exit 1; }
  line=$(grep -n "alias $name=" "$zshrc" | cut -d: -f1 | head -n1)
  ${EDITOR:-nano} +$line "$zshrc"
  reload_shell
}

remove_alias() {
  local name="$1"
  sed -i "/^alias $name=/d" "$zshrc"
  echo "Alias '$name' removed if it existed."
  reload_shell
}

search_aliases() {
  local keyword="$1"
  echo -e "\n\033[1;32mSearch Results for '$keyword':\033[0m"
  grep "^alias " "$zshrc" | grep "$keyword" | while IFS= read -r line; do
    name=$(echo "$line" | cut -d= -f1 | awk '{print $2}')
    command=$(echo "$line" | cut -d= -f2- | sed "s/^'//;s/'$//")
    printf " \033[1;34m%-12s\033[0m → " "$name"
    colorize_truncated "$command" "$default_truncate"
  done
}

reload_shell() {
  echo -e "\n\033[1;35mReloading .zshrc…\033[0m"
  zsh -ic "source ~/.zshrc" >/dev/null
  echo -e "\033[1;32m.zshrc reloaded.\033[0m"
}

# === ARG PARSING ===

if [[ $# -eq 0 ]]; then
  print_aliases "$default_truncate"
  exit 0
fi

case "$1" in
  --full)
    print_aliases 0
    ;;
  --length)
    [[ -z "$2" || ! "$2" =~ ^[0-9]+$ ]] && print_usage
    print_aliases "$2"
    ;;
  --add)
    [[ -z "$2" ]] && print_usage
    add_alias "$2"
    ;;
  --edit)
    [[ -z "$2" ]] && print_usage
    edit_alias "$2"
    ;;
  --rm)
    [[ -z "$2" ]] && print_usage
    remove_alias "$2"
    ;;
  --search)
    [[ -z "$2" ]] && print_usage
    search_aliases "$2"
    ;;
  --reload)
    reload_shell
    ;;
  *)
    print_usage
    ;;
esac

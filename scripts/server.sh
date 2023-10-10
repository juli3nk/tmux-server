#!/usr/bin/env bash

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
source "${PLUGIN_DIR}/helper.sh"

is_connected() {
  local stype="$1"
  local result="false"

  if [ "$(ps --tty "$(tmux display -p '#{pane_tty}')" -o command | grep "^${stype} " | grep -Evc "git-receive-pack")" -gt 0 ]; then
    result="true"
  fi

  echo "$result"
}

show_ssh_infos() {
  local result
  local cmd="$(ps --tty "$(tmux display -p '#{pane_tty}')" -o command | grep "^[s]sh ")"

  if [ "$(echo "$cmd" | grep -c "@")" -gt 0 ]; then
    result="$(echo "$cmd" | sed 's/ssh //')"
  else
    ssh_host="$(echo "$cmd" | awk '{ print $2 }')"
    ssh_user="$(grep -A 5 "$ssh_host" ~/.ssh/config | grep -i "User" | awk '{ print $2 }')"

    result="${ssh_user}@${ssh_host}"
  fi

  echo "$result"
}

show_docker_infos() {
  echo "container"
}

show_k8s_context() {
  local context="$(kubectl config get-contexts | grep '^*')"
  local ctx_name="$(echo "$context" | awk '{ print $2 }')"
  local ctx_namespace="$(echo "$context" | awk '{ print $5 }')"

  local ctx_display="$ctx_name"
  if [ -n "$ctx_namespace" ]; then
    ctx_display="${ctx_display}/${ctx_namespace}"
  fi

  echo "$ctx_display"
}

main() {
  local display_label display_text

  if [ "$(is_connected "ssh")" == "true" ]; then
    display_label="ssh"
    display_text="$(show_ssh_infos)"
  elif [ "$(is_connected "docker")" == "true" ]; then
    display_label="[c]"

    display_text="$(show_docker_infos)"
    if [ "$(ps --tty "$(tmux display -p '#{pane_tty}')" -o command | grep "^docker " | grep -c "\.kube")" -gt 0 ]; then
      display_text="$(show_k8s_context)"
    fi
  else
    display_label="󱃾"
    display_text="$(show_k8s_context)"
  fi

  local label="#[fg=$thm_black,bg=$thm_orange]${display_label} #[default]"
  local text="#[fg=$thm_white,bg=$thm_gray] ${display_text} #[default]"

  local opt_sep_left=$(get_tmux_option "@server_left_separator" "")
  local opt_sep_right=$(get_tmux_option "@server_right_separator" "")

  if [ -n "$opt_sep_left" ]; then
    sep_left="#[fg=$thm_orange,bg=$thm_black]${opt_sep_left}█#[default]"
    sep_right="#[fg=$thm_gray,bg=$thm_black]${opt_sep_right}#[default]"

    echo "${sep_left}${label}${text}${sep_right}"
  else
    echo "${label}${text}"
  fi
}


main

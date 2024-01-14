#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

script="#(${CURRENT_DIR}/scripts/server.sh)"
pattern="\#{server-info}"

source "${CURRENT_DIR}/helper.sh"

tmux bind-key K run-shell -b "${CURRENT_DIR}/scripts/bindkey-k8s.sh"

update_tmux_option "status-right"

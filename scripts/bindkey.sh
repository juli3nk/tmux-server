#!/usr/bin/env bash

PATH="${PATH}:${HOME}/.local/bin:${HOME}/.fzf/bin"

context_name=$(kubectl config get-contexts -o name | sort | fzf-tmux -d 50% -r 20%)

if [ -z "$context_name" ]; then exit 0 ; fi

kubectl config use-context "$context_name"

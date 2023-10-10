
do_interpolation() {
  local string="$1"
  local interpolated="${string/$pattern/$script}"

  echo "$interpolated"
}

get_tmux_option() {
  local option value default

  option="$1"
  default="$2"
  value=$(tmux show-option -gqv "$option")

  if [ -n "$value" ]; then
    if [ "$value" == "null" ]; then
      echo ""
    else
      echo "$value"
    fi
  else
    echo "$default"
  fi
}

update_tmux_option() {
  local option="$1"
  local option_value="$(tmux show-option -gqv "$option")"
  local new_option_value="$(do_interpolation "$option_value")"

  tmux set-option -gq "$option" "$new_option_value"
}

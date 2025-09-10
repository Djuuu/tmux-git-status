#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/scripts/tmux-helpers.sh"


tmux source "$CURRENT_DIR/git-status.tmux.conf"

git_status_interpolation=(
    "\#{git_status}"
    "\#{@catppuccin_status_git}"
)

git_status_commands=(
    "#(${CURRENT_DIR}/git-status.sh)"
    "#(${CURRENT_DIR}/git-status.sh catppuccin)"
)

do_interpolation() {
    local all_interpolated="$1"
    local i
    for ((i=0; i<${#git_status_commands[@]}; i++)); do
        all_interpolated=${all_interpolated//${git_status_interpolation[$i]}/${git_status_commands[$i]}}
    done
    echo "$all_interpolated"
}

main() {
    update_tmux_option "status-right"
    update_tmux_option "status-left"
}
main

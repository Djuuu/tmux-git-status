#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/scripts/tmux-helpers.sh"
source "$CURRENT_DIR/scripts/options-helpers.sh"
source "$CURRENT_DIR/scripts/git-helpers.sh"

git() {
    command git -C "${pane_path:-"./"}" "$@"
}

git_status_init() {
    local gitDir=${1:-}

    if [[ -z $gitDir ]]; then
        local pane_path; pane_path=$(tmux display-message -p "#{pane_current_path}")

        local gitDir; gitDir="$(git rev-parse --git-dir 2>/dev/null)" ||
            return # Not a git repository

        gitDir="${pane_path}/${gitDir}"
    fi

    init_options

    _branchLine=

    git_untracked=0
    git_changed=0
    git_deleted=0
    git_staged=0
    git_conflicts=0
    git_stashed=0

    __git_extract_statuses

    local stashLine
    if [[ -f "${gitDir}/logs/refs/stash" ]]; then
        while IFS='' read -r stashLine || [[ -n "$stashLine" ]]; do
            ((git_stashed++))
        done < "${gitDir}/logs/refs/stash"
    fi

    git_branch=""
    git_branch_display=""
    git_remote=""
    git_remote_branch=""
    git_remote_branch_display=""
    git_branch_icon="${git_status_branch_icon}"
    git_ahead=0
    git_behind=0
    git_detached=0

    __git_extract_status_info "$_branchLine"

    git_divergence=
    git_divergence_icon=

    __git_set_divergence $git_ahead $git_behind $git_detached

    git_action_name=""
    git_action=""

    __git_set_action

    git_state=""

    __git_set_state
}

git_status_print() {
    git_branch_display="${git_branch}"
    if [[ $git_status_branch_max_length -gt 0 ]] &&
        [[ ${#git_branch_display} -gt $git_status_branch_max_length ]]; then
        git_branch_display="${git_branch_display:0:(git_status_branch_max_length - 1)}…"
    fi

    if [[ $git_action_name != "rebase" ]]; then

        [[ -n $git_branch_icon ]] &&
            echo -n "${git_status_icon_style}${git_branch_icon} "
        echo -n "${git_status_branch_style}${git_branch_display}"

        if [[ -n $git_remote_branch ]]; then

            git_remote_branch_display="${git_remote_branch}"
            if [[ $git_status_remote_max_length -gt 0 ]] &&
                [[ ${#git_remote_branch_display} -gt $git_status_remote_max_length ]]; then
                git_remote_branch_display="${git_remote_branch_display:0:(git_status_remote_max_length - 1)}…"
                if [[ ${#git_remote_branch_display} -lt $((${#git_remote} + 2)) ]]; then
                    git_remote_branch_display="${git_remote}/…"
                fi
            fi

            echo -n "${git_status_remote_prefix}${git_status_remote_style}"
            echo -n "${git_remote_branch_display}"

            #echo -n "${git_divergence_icon}"
            echo -n "${git_divergence}"
        fi

        [[ -n ${git_action} ]] && echo -n " "
    fi

    echo -n "${git_action}"

    echo -n "${git_state}"
}

git_status() {
    git_status_init
    git_status_print
}

catppuccin_status_git() {
    local pane_path; pane_path=$(tmux display-message -p "#{pane_current_path}")
    local gitDir; gitDir="$(git rev-parse --git-dir 2>/dev/null)" || {
        # Not a git repository
        if [[ $(get_tmux_option "@git_status_hide_outside_repository") -eq 1 ]]; then
            return # Hide module altogether
        fi

        # Show empty module shell (default Catppuccin behavior)
        local output
        output="$(tmux display -p '#{E:@catppuccin_status_git}')"
        output="${output//#\{git_status_icon\}/"$(get_tmux_option "@catppuccin_git_default_icon")"}"
        echo "${output}"
        return
    }

    git_status_init "${pane_path}/${gitDir}"

    local git_status_icon
    if [[ $git_status_replace_catppuccin_module_icon -eq 1 ]]; then
        # Replace catppuccin icon with branch icon
        git_status_icon="$git_branch_icon"
        git_branch_icon=
    else
        # Use default catppuccin module icon
        git_status_icon="$(get_tmux_option "@catppuccin_git_default_icon")"
    fi

    local output
    output="$(tmux display -p '#{E:@catppuccin_status_git}')"
    output="${output//#\{git_status\}/$(git_status_print)}"
    output="${output//#\{git_status_icon\}/${git_status_icon}}"

    echo "${output}"
}


if [ "$1" = "catppuccin" ]; then
    catppuccin_status_git
    exit $?
fi

if [ "$1" = "options" ]; then
    debug_options
    exit $?
fi

git_status

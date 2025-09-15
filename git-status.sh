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
        [[ $gitDir != /* ]] && gitDir="${pane_path}/${gitDir}"
    fi

    init_options

    _status_branch_line=

    git_untracked=0
    git_changed=0
    git_deleted=0
    git_staged=0
    git_conflicts=0
    git_stashes=0

    __git_extract_statuses

    git_branch=
    git_branch_display=
    git_remote=
    git_upstream_branch=
    git_upstream_display=
    git_branch_icon="${git_status_branch_icon}"
    git_ahead=0
    git_behind=0
    git_detached=0

    __git_extract_status_info "$_status_branch_line"

    git_divergence=

    __git_set_divergence $git_ahead $git_behind $git_detached

    git_action_name=
    git_action=

    __git_set_action

    git_state=

    __git_set_state
}

git_status_print() {
    local git_branch_icon_output=
    local git_branch_output=
    local git_remote_output=

    if [[ $git_action_name != "rebase" ]] || [[ $git_status_rebase_hide_branch_info != true ]]; then

        if [[ -n $git_branch_icon ]]; then
            git_branch_icon_output=" ${git_status_icon_style}${git_branch_icon}"
        fi

        git_branch_display="${git_branch}"
        if [[ $git_status_branch_max_length -gt 0 ]] &&
            [[ ${#git_branch_display} -gt $git_status_branch_max_length ]]; then
            git_branch_display="${git_branch_display:0:(git_status_branch_max_length - 1)}…"
        fi
        git_branch_output=" ${git_status_branch_style}${git_branch_display}"

        if [[ -n $git_upstream_branch ]]; then
            git_upstream_display="${git_upstream_branch}"
            if [[ $git_status_upstream_max_length -gt 0 ]] &&
                [[ ${#git_upstream_display} -gt $git_status_upstream_max_length ]]; then
                git_upstream_display="${git_upstream_display:0:(git_status_upstream_max_length - 1)}…"
                if [[ ${#git_upstream_display} -lt $((${#git_remote} + 2)) ]]; then
                    git_upstream_display="${git_remote}/…"
                fi
            fi

            git_remote_output="${git_status_upstream_prefix}${git_status_upstream_style}${git_upstream_display}"
        fi
    fi

    # Assemble output from template
    local output="${git_status_format}"
    output="${output/"{branch_icon}"/"${git_branch_icon_output}"}"
    output="${output/"{branch}"/"${git_branch_output}"}"
    output="${output/"{upstream}"/"${git_remote_output}"}"
    output="${output/"{divergence}"/"${git_divergence}"}"
    output="${output/"{action}"/"${git_action}"}"
    output="${output/"{state}"/"${git_state}"}"

    output=${output# } # trim leading space

    echo -n "${output}"
}

git_status() {
    git_status_init
    git_status_print
}

catppuccin_status_git() {
    local pane_path; pane_path=$(tmux display-message -p "#{pane_current_path}")
    local gitDir; gitDir="$(git rev-parse --git-dir 2>/dev/null)" || {
        # Not a git repository
        if [[ $(get_tmux_option "@git_status_catppuccin_hide_outside_repository") == true ]]; then
            return # Hide module altogether
        fi

        # Show empty module shell (default Catppuccin behavior)
        local output
        output="$(tmux display -p '#{E:@catppuccin_status_git}')"
        output="${output//#\{git_status_icon\}/"$(get_tmux_option "@catppuccin_git_default_icon")"}"
        echo "${output}"
        return
    }
    [[ $gitDir != /* ]] && gitDir="${pane_path}/${gitDir}"

    git_status_init "${gitDir}"

    local git_status_icon
    if [[ $git_status_catppuccin_replace_module_icon == true ]]; then
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


if [[ $1 == "catppuccin" ]]; then
    catppuccin_status_git
    exit $?
fi

if [[ $1 == "options" ]]; then
    debug_options
    exit $?
fi

git_status

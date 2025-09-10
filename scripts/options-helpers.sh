#!/usr/bin/env bash

declare_options() {
    git_status_show_remote_counters=
    git_status_show_state_counters=
    git_status_state_mode=

    git_status_hide_outside_repository=
    git_status_replace_catppuccin_module_icon=

    git_status_default_style=

    git_status_icon_style=
    git_status_branch_style=
    git_status_remote_prefix=
    git_status_remote_style=

    git_status_branch_max_length=
    git_status_remote_max_length=

    git_status_branch_icon=
    git_status_detached_icon=
    git_status_github_icon=
    git_status_gitlab_icon=
    git_status_bitbucket_icon=
    git_status_forgejo_icon=

    git_status_ahead_icon=
    git_status_behind_icon=
    git_status_ahead_behind_separator=

    git_status_divergence_ahead_icon=
    git_status_divergence_behind_icon=
    git_status_divergence_diverged_icon=

    git_status_action_rebase_icon=
    git_status_action_merge_icon=
    git_status_action_cherry_icon=
    git_status_action_revert_icon=
    git_status_action_bisect_icon=

    git_status_rebase_icon_style=
    git_status_rebase_progress_style=
    git_status_rebase_head_style=
    git_status_rebase_target_style=
    git_status_conflict_style=

    git_status_action_prefix=
    git_status_action_suffix=

    git_status_state_prefix=
    git_status_state_show_stashed=

    git_status_state_clean_icon=
    git_status_state_changed_icon=
    git_status_state_deleted_icon=
    git_status_state_untracked_icon=
    git_status_state_staged_icon=
    git_status_state_conflict_icon=
    git_status_state_stashed_icon=
}

print_options() {
    echo "git_status_show_remote_counters:           |$git_status_show_remote_counters|"
    echo "git_status_show_state_counters:            |$git_status_show_state_counters|"
    echo "git_status_state_mode:                     |$git_status_state_mode|"
    echo
    echo "git_status_hide_outside_repository:        |$git_status_hide_outside_repository|"
    echo "git_status_replace_catppuccin_module_icon: |$git_status_replace_catppuccin_module_icon|"
    echo
    echo "git_status_default_style:                  |$git_status_default_style|"
    echo
    echo "git_status_icon_style:                     |$git_status_icon_style|"
    echo "git_status_branch_style:                   |$git_status_branch_style|"
    echo "git_status_remote_prefix:                  |$git_status_remote_prefix|"
    echo "git_status_remote_style:                   |$git_status_remote_style|"
    echo
    echo "git_status_branch_max_length:              |$git_status_branch_max_length|"
    echo "git_status_remote_max_length:              |$git_status_remote_max_length|"
    echo
    echo "git_status_branch_icon:                    |$git_status_branch_icon|"
    echo "git_status_detached_icon:                  |$git_status_detached_icon|"
    echo "git_status_github_icon:                    |$git_status_github_icon|"
    echo "git_status_gitlab_icon:                    |$git_status_gitlab_icon|"
    echo "git_status_bitbucket_icon:                 |$git_status_bitbucket_icon|"
    echo "git_status_forgejo_icon:                   |$git_status_forgejo_icon|"
    echo
    echo "git_status_ahead_icon:                     |$git_status_ahead_icon|"
    echo "git_status_behind_icon:                    |$git_status_behind_icon|"
    echo "git_status_ahead_behind_separator:         |$git_status_ahead_behind_separator|"
    echo
    echo "git_status_divergence_ahead_icon:          |$git_status_divergence_ahead_icon|"
    echo "git_status_divergence_behind_icon:         |$git_status_divergence_behind_icon|"
    echo "git_status_divergence_diverged_icon:       |$git_status_divergence_diverged_icon|"
    echo
    echo "git_status_action_rebase_icon:             |$git_status_action_rebase_icon|"
    echo "git_status_action_merge_icon:              |$git_status_action_merge_icon|"
    echo "git_status_action_cherry_icon:             |$git_status_action_cherry_icon|"
    echo "git_status_action_revert_icon:             |$git_status_action_revert_icon|"
    echo "git_status_action_bisect_icon:             |$git_status_action_bisect_icon|"
    echo
    echo "git_status_rebase_icon_style:              |$git_status_rebase_icon_style|"
    echo "git_status_rebase_progress_style:          |$git_status_rebase_progress_style|"
    echo "git_status_rebase_head_style:              |$git_status_rebase_head_style|"
    echo "git_status_rebase_target_style:            |$git_status_rebase_target_style|"
    echo "git_status_conflict_style:                 |$git_status_conflict_style|"
    echo
    echo "git_status_action_prefix:                  |$git_status_action_prefix|"
    echo "git_status_action_suffix:                  |$git_status_action_suffix|"
    echo
    echo "git_status_state_prefix:                   |$git_status_state_prefix|"
    echo "git_status_state_show_stashed:             |$git_status_state_show_stashed|"
    echo
    echo "git_status_state_clean_icon:               |$git_status_state_clean_icon|"
    echo "git_status_state_changed_icon:             |$git_status_state_changed_icon|"
    echo "git_status_state_deleted_icon:             |$git_status_state_deleted_icon|"
    echo "git_status_state_untracked_icon:           |$git_status_state_untracked_icon|"
    echo "git_status_state_staged_icon:              |$git_status_state_staged_icon|"
    echo "git_status_state_conflict_icon:            |$git_status_state_conflict_icon|"
    echo "git_status_state_stashed_icon:             |$git_status_state_stashed_icon|"
}

init_options() {
    declare_options

    # Read and parse options once, instead of calling get_tmux_option for each variable (~60ms vs. <10ms)
    local line name value options
    while IFS='' read -r line; do
        name="${line%% *}"
        name="${name:1}"
        value="${line#* }"
        options="${options}${name}=${value}"$'\n'
    done <<< "$(tmux show -g | grep "@git_status")"

    eval "$options"
}

debug_options() {
    init_options
    print_options
}

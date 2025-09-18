#!/usr/bin/env bash

declare_options() {
    git_status_default_style=
    git_status_format=

    git_status_icon_style=
    git_status_branch_style=

    git_status_branch_max_length=

    git_status_branch_icon=
    git_status_detached_icon=
    git_status_github_icon=
    git_status_gitlab_icon=
    git_status_bitbucket_icon=
    git_status_forgejo_icon=
    git_status_default_remote_icon=

    git_status_custom_remote_1_pattern=
    git_status_custom_remote_1_icon=
    git_status_custom_remote_2_pattern=
    git_status_custom_remote_2_icon=
    git_status_custom_remote_3_pattern=
    git_status_custom_remote_3_icon=

    git_status_upstream_prefix=
    git_status_upstream_style=

    git_status_upstream_max_length=

    git_status_divergence_mode=
    git_status_ahead_icon=
    git_status_behind_icon=
    git_status_divergence_separator=
    git_status_divergence_swap=
    git_status_divergence_single_ahead_icon=
    git_status_divergence_single_behind_icon=
    git_status_divergence_single_diverged_icon=

    git_status_action_prefix=
    git_status_action_suffix=
    git_status_action_rebase_icon=
    git_status_action_merge_icon=
    git_status_action_cherry_icon=
    git_status_action_revert_icon=
    git_status_action_bisect_icon=
    git_status_rebase_head_style=
    git_status_rebase_target_style=
    git_status_rebase_head_target_separator=
    git_status_rebase_interactive_edit_icon=
    git_status_rebase_progress_style=
    git_status_rebase_conflict_style=
    git_status_rebase_hide_branch_info=

    git_status_state_mode=
    git_status_ignore_submodules=
    git_status_show_state_counters=
    git_status_state_prefix=
    git_status_state_clean_icon=
    git_status_state_deleted_icon=
    git_status_state_changed_icon=
    git_status_state_untracked_icon=
    git_status_state_staged_icon=
    git_status_state_conflict_icon=
    git_status_state_show_stash=
    git_status_state_stashes_icon=

    git_status_catppuccin_hide_outside_repository=
    git_status_catppuccin_replace_module_icon=
}

print_options() {
    echo "git_status_default_style:      |$git_status_default_style|"
    echo "git_status_format:             |$git_status_format|"
    echo
    echo "git_status_icon_style:         |$git_status_icon_style|"
    echo "git_status_branch_style:       |$git_status_branch_style|"
    echo
    echo "git_status_branch_max_length:  |$git_status_branch_max_length|"
    echo
    echo "git_status_branch_icon:         |$git_status_branch_icon|"
    echo "git_status_detached_icon:       |$git_status_detached_icon|"
    echo "git_status_github_icon:         |$git_status_github_icon|"
    echo "git_status_gitlab_icon:         |$git_status_gitlab_icon|"
    echo "git_status_bitbucket_icon:      |$git_status_bitbucket_icon|"
    echo "git_status_forgejo_icon:        |$git_status_forgejo_icon|"
    echo "git_status_default_remote_icon: |$git_status_default_remote_icon|"
    echo
    echo "git_status_custom_remote_1_pattern: |$git_status_custom_remote_1_pattern|"
    echo "git_status_custom_remote_1_icon:    |$git_status_custom_remote_1_icon|"
    echo "git_status_custom_remote_2_pattern: |$git_status_custom_remote_2_pattern|"
    echo "git_status_custom_remote_2_icon:    |$git_status_custom_remote_2_icon|"
    echo "git_status_custom_remote_3_pattern: |$git_status_custom_remote_3_pattern|"
    echo "git_status_custom_remote_3_icon:    |$git_status_custom_remote_3_icon|"
    echo
    echo "git_status_upstream_prefix:     |$git_status_upstream_prefix|"
    echo "git_status_upstream_style:      |$git_status_upstream_style|"
    echo
    echo "git_status_upstream_max_length: |$git_status_upstream_max_length|"
    echo
    echo "git_status_divergence_mode:                 |$git_status_divergence_mode|"
    echo "git_status_ahead_icon:                      |$git_status_ahead_icon|"
    echo "git_status_behind_icon:                     |$git_status_behind_icon|"
    echo "git_status_divergence_separator:            |$git_status_divergence_separator|"
    echo "git_status_divergence_swap:                 |$git_status_divergence_swap|"
    echo "git_status_divergence_single_ahead_icon:    |$git_status_divergence_single_ahead_icon|"
    echo "git_status_divergence_single_behind_icon:   |$git_status_divergence_single_behind_icon|"
    echo "git_status_divergence_single_diverged_icon: |$git_status_divergence_single_diverged_icon|"
    echo
    echo "git_status_action_prefix:                |$git_status_action_prefix|"
    echo "git_status_action_suffix:                |$git_status_action_suffix|"
    echo "git_status_action_rebase_icon:           |$git_status_action_rebase_icon|"
    echo "git_status_action_merge_icon:            |$git_status_action_merge_icon|"
    echo "git_status_action_cherry_icon:           |$git_status_action_cherry_icon|"
    echo "git_status_action_revert_icon:           |$git_status_action_revert_icon|"
    echo "git_status_action_bisect_icon:           |$git_status_action_bisect_icon|"
    echo "git_status_rebase_head_style:            |$git_status_rebase_head_style|"
    echo "git_status_rebase_target_style:          |$git_status_rebase_target_style|"
    echo "git_status_rebase_head_target_separator: |$git_status_rebase_head_target_separator|"
    echo "git_status_rebase_interactive_edit_icon: |$git_status_rebase_interactive_edit_icon|"
    echo "git_status_rebase_progress_style:        |$git_status_rebase_progress_style|"
    echo "git_status_rebase_conflict_style:        |$git_status_rebase_conflict_style|"
    echo "git_status_rebase_hide_branch_info:      |$git_status_rebase_hide_branch_info|"
    echo
    echo "git_status_state_mode:           |$git_status_state_mode|"
    echo "git_status_ignore_submodules:    |$git_status_ignore_submodules|"
    echo "git_status_show_state_counters:  |$git_status_show_state_counters|"
    echo "git_status_state_prefix:         |$git_status_state_prefix|"
    echo "git_status_state_clean_icon:     |$git_status_state_clean_icon|"
    echo "git_status_state_deleted_icon:   |$git_status_state_deleted_icon|"
    echo "git_status_state_changed_icon:   |$git_status_state_changed_icon|"
    echo "git_status_state_untracked_icon: |$git_status_state_untracked_icon|"
    echo "git_status_state_staged_icon:    |$git_status_state_staged_icon|"
    echo "git_status_state_conflict_icon:  |$git_status_state_conflict_icon|"
    echo "git_status_state_show_stash:     |$git_status_state_show_stash|"
    echo "git_status_state_stashes_icon:   |$git_status_state_stashes_icon|"
    echo
    echo "git_status_catppuccin_hide_outside_repository: |$git_status_catppuccin_hide_outside_repository|"
    echo "git_status_catppuccin_replace_module_icon:     |$git_status_catppuccin_replace_module_icon|"
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

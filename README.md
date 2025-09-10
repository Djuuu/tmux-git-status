# Tmux-Git-status

Shows git status in your [tmux](https://github.com/tmux/tmux/wiki) status bar.

## Prerequisites

- [Bash](https://www.gnu.org/software/bash/)
- [Git](https://git-scm.com/)
- [tmux](https://github.com/tmux/tmux/wiki)
- [Nerd Font](https://www.nerdfonts.com/) (to display icons correctly)

## Installation

### Using Tmux Plugin Manager (recommended)

1. Install [TPM](https://github.com/tmux-plugins/tpm)
1. Add the plugin in your `~/.tmux.conf` / `~/.config/tmux/tmux.conf`:
   ```
   set -g @plugin 'Djuuu/tmux-git-status'
   ```
1. Add the module to your status bar:
   ```
   set -ag status-left "#{git_status}"
   ```

### Additional Catppuccin configuration

A custom [Catppuccin](https://github.com/catppuccin/tmux) status line module configuration is provided:

1. Source the configuration file, after `catppuccin.tmux`
   ```
   # Load catppuccin
   run "/path/to/catppuccin.tmux/catppuccin.tmux"
   
   # ...

   # Configure git status catppuccin module
   source -q "/path/to/tmux-git-status/git_status.catppuccin.conf"   
   ```
1. Add the module to your status bar:
   ```
   set -ag status-left "#{@catppuccin_status_git}"
   ```
   
## Usage

## Configuration

Available options (see [git-status.tmux.conf](git-status.tmux.conf)):

```
set -gq @git_status_show_remote_counters 1
set -gq @git_status_show_state_counters  1
set -gq @git_status_state_mode           "detail" # "detail" | "summary"

set -gq @git_status_hide_outside_repository  1
set -gq @git_status_replace_catppuccin_module_icon  1

set -gq @git_status_default_style "#[fg=white,nobold]"

set -gq @git_status_icon_style     "#[fg=white,bold]"
set -gq @git_status_branch_style   "#[fg=white,bold]"
set -gq @git_status_remote_prefix  "#[fg=white,nobold] → "
set -gq @git_status_remote_style   "#[fg=cyan,bold]"

set -gq @git_status_branch_max_length  40
set -gq @git_status_remote_max_length  15

set -gq @git_status_branch_icon    "" # nf-fa-code_branch
set -gq @git_status_detached_icon  " " # nf-fa-code_commit
set -gq @git_status_github_icon    "󰊤" # nf-md-github
set -gq @git_status_gitlab_icon    "" # nf-seti-gitlab
set -gq @git_status_bitbucket_icon "" # nf-dev-bitbucket
set -gq @git_status_forgejo_icon   "" # nf-linux-forgejo

set -gq @git_status_ahead_icon             "#[fg=green,bold]↑"
set -gq @git_status_behind_icon            "#[fg=red,bold]↓"
set -gq @git_status_ahead_behind_separator "#[fg=#666666]·"

set -gq @git_status_divergence_ahead_icon    "#[fg=green,bold] " # nf-fa-arrow_up
set -gq @git_status_divergence_behind_icon   "#[fg=red,bold] "   # nf-fa-arrow_down
set -gq @git_status_divergence_diverged_icon "#[fg=yellow,bold] " # nf-fa-arrows_up_down

set -gq @git_status_action_rebase_icon  "☈ "  # nf-oct-git_merge
set -gq @git_status_action_merge_icon   ""   # nf-oct-git_merge
set -gq @git_status_action_cherry_icon  " " # nf-fae-cherry
set -gq @git_status_action_revert_icon  " "  # nf-fa-rotate_left
set -gq @git_status_action_bisect_icon  "?"  # nf-fa-arrows_up_down

set -gq @git_status_rebase_icon_style      "#[fg=yellow,bold]"
set -gq @git_status_rebase_progress_style  "#[fg=yellow,bold]"
set -gq @git_status_rebase_head_style      "#[fg=yellow,bold]"
set -gq @git_status_rebase_target_style    "#[fg=cyan,bold]"
set -gq @git_status_conflict_style         "#[fg=red,bold]"

set -gq @git_status_action_prefix  " #[fg=yellow,bold]"
set -gq @git_status_action_suffix  "#[fg=yellow,bold]"

set -gq @git_status_state_prefix         " "
set -gq @git_status_state_show_stashed   0

set -gq @git_status_state_clean_icon     "#[fg=green,bold] "  # nf-cod-sparkle
set -gq @git_status_state_changed_icon   "#[fg=yellow,bold] " # nf-cod-request_changes
set -gq @git_status_state_deleted_icon   "#[fg=red,bold]󰍴"     # nf-md-minus
set -gq @git_status_state_untracked_icon "#[fg=green,bold]"   # nf-oct-plus
set -gq @git_status_state_staged_icon    "#[fg=green,bold] "  # nf-cod-request_changes
set -gq @git_status_state_conflict_icon  "#[fg=red,bold] "    # nf-fa-arrows_left_right
set -gq @git_status_state_stashed_icon   "#[fg=cyan,nobold]⚐ "
```

## Alternatives

- https://github.com/arl/gitmux
- https://github.com/arl/tmux-gitbar
- https://github.com/romkatv/gitstatus

#!/usr/bin/env bash

##
## Git prompt var helpers
##

# Store statuses in the following variables:
#  - $_status_branch_line (first line of `git status -sb`)
#  - $git_untracked
#  - $git_changed
#  - $git_deleted
#  - $git_staged
#  - $git_conflicts
__git_extract_statuses() {
    # External affected vars
    _status_branch_line=
    git_untracked=
    git_changed=
    git_deleted=
    git_staged=
    git_conflicts=

    local statusLine status

    local statusCommand=(
        "git"
        "--no-optional-locks"
        "status"
        "--porcelain"
        "--branch"
    )
    if [[ $git_status_ignore_submodules == true ]]; then
        statusCommand+=('--ignore-submodules')
    fi

    while IFS='' read -r statusLine || [[ -n "${statusLine}" ]]; do
        status="${statusLine:0:2}"
        while [[ -n ${status} ]]; do
            case "${status}" in
                \#\#) _status_branch_line="${statusLine/\.\.\./^}"; break ;;

                \?\?) ((git_untracked++)); break ;;
                U?)   ((git_conflicts++)); break ;;
                ?U)   ((git_conflicts++)); break ;;
                DD)   ((git_conflicts++)); break ;;
                AA)   ((git_conflicts++)); break ;;

                ?M) ((git_changed++)) ;;
                ?D) ((git_deleted++)) ;;
                ?\ ) ;;

                U) ((git_conflicts++)) ;;
                \ ) ;;

                *) ((git_staged++)) ;;
            esac
            status="${status:0:(${#status}-1)}"
        done
    done <<< "$(LANG=C "${statusCommand[@]}" 2>/dev/null)"

    if [[ $git_status_state_show_stash == true ]]; then
        local stashLine
        if [[ -f "${gitDir}/logs/refs/stash" ]]; then
            while IFS='' read -r stashLine || [[ -n "$stashLine" ]]; do
                ((git_stashes++))
            done < "${gitDir}/logs/refs/stash"
        fi
    fi
}

# Store current branch & upstream info in variables:
#  - $git_branch
#  - $git_upstream_branch
#  - $git_remote
#  - $git_branch_icon
#  - $git_ahead
#  - $git_behind
#  - $git_detached
__git_extract_status_info() {
    local branchLine=$1

    local branchFields fields

    IFS="^" read -ra branchFields <<< "${branchLine/\#\# }"
    git_branch="${branchFields[0]}"

    git_ahead=0
    git_behind=0
    git_detached=0

    if [[ "${git_branch}" == *"Initial commit on"* ]]; then
        IFS=" " read -ra fields <<< "${git_branch}"
        git_branch="${fields[3]}"
    elif [[ "${git_branch}" == *"No commits yet on"* ]]; then
        IFS=" " read -ra fields <<< "${git_branch}"
        git_branch="${fields[4]}"
    elif [[ "${git_branch}" == *"no branch"* ]]; then
        git_branch="$(git rev-parse --short HEAD)"
        git_detached=1
    else
        if [[ "${#branchFields[@]}" -ne 1 ]]; then
            IFS="[,]" read -ra fields <<< "${branchFields[1]}"

            local upstream
            upstream="${fields[0]}"
            upstream="${upstream% }"

            local upstream_field
            for upstream_field in "${fields[@]}"; do
                if [[ "${upstream_field}" == "ahead "* ]]; then
                    git_ahead="${upstream_field:6}"
                fi
                if [[ "${upstream_field}" == "behind "* ]] || [[ "${upstream_field}" == " behind "* ]]; then
                    git_behind="${upstream_field:7}"
                    git_behind="${git_behind# }"
                fi
            done
        fi
    fi

    if [[ $git_detached -eq 1 ]]; then
        git_branch_icon="${git_status_detached_icon}"
    else
        git_upstream_branch=$(git rev-parse --abbrev-ref --symbolic-full-name "${git_branch}@{u}" 2>/dev/null)

        [[ -n $git_upstream_branch ]] &&
            git_remote="${git_upstream_branch:0:-(${#git_branch}+1)}" ||
            git_remote=

        local remoteUrl remoteIcon=""
        if [[ -n $git_remote ]]; then
            remoteUrl=$(git remote get-url "$git_remote")
            if   [[ $remoteUrl == *"github.com"*    ]]; then remoteIcon="${git_status_github_icon}"
            elif [[ $remoteUrl == *"gitlab.com"*    ]]; then remoteIcon="${git_status_gitlab_icon}"
            elif [[ $remoteUrl == *"bitbucket.org"* ]]; then remoteIcon="${git_status_bitbucket_icon}"
            elif [[ $remoteUrl == *"codeberg.org"*  ]]; then remoteIcon="${git_status_forgejo_icon}"
            else
                remoteIcon="${git_status_default_remote_icon}"
            fi
            git_branch_icon=${remoteIcon}
        fi
    fi
}

# Set the following variable:
#  - $git_divergence
__git_set_divergence() {
    local ahead=${1:-0}
    local behind=${2:-0}
    local detached=${3:-0}

    # External affected vars
    git_divergence=

    if [[ $detached -eq 1 ]]; then
        return
    fi

    local icon

    if [[ ${git_status_divergence_mode} == "single" ]]; then
        if [[ $ahead -gt 0 && $behind -eq 0 ]]; then
            icon=" $git_status_divergence_single_ahead_icon"
        elif [[ $ahead -eq 0 && $behind -gt 0 ]]; then
            icon=" $git_status_divergence_single_behind_icon"
        elif [[ $ahead -gt 0 && $behind -gt 0 ]]; then
            icon=" $git_status_divergence_single_diverged_icon"
        fi
        git_divergence="${icon}"
        return
    fi

    local divergence a b
    if [[ $git_status_divergence_mode == "detailed" ]]; then
        a=${ahead}
        b=${behind}
    fi

    if [[ $ahead -gt 0 && $behind -eq 0 ]]; then
        divergence=" ${git_status_ahead_icon}${a}"
    elif [[ $ahead -eq 0 && $behind -gt 0 ]]; then
        divergence=" ${git_status_behind_icon}${b}"
    elif [[ $ahead -gt 0 && $behind -gt 0 ]]; then
        divergence=" "
        if [[ $git_status_divergence_swap == true ]]; then
            divergence="${divergence}${git_status_behind_icon}${b}"
            divergence="${divergence}${git_status_divergence_separator}"
            divergence="${divergence}${git_status_ahead_icon}${a}"
        else
            divergence="${divergence}${git_status_ahead_icon}${a}"
            divergence="${divergence}${git_status_divergence_separator}"
            divergence="${divergence}${git_status_behind_icon}${b}"
        fi
    fi

    git_divergence="${divergence}"
}

# Set the following variables:
#  - $git_action_name
#  - $git_action
__git_set_action() {
    # External affected vars
    git_action_name=
    git_action=

    local rebaseStep="" rebaseTotal="" rebaseHeadName="" rebaseOnto="" rebaseOntoBranch=""

    __git_extract_action_info

    case "${git_action_name}" in
        rebase)
            local rebaseTarget rebaseProgress doneColor

            [[ $git_conflicts -gt 0 ]] &&
                doneColor=${git_status_rebase_conflict_style} ||
                doneColor=${git_status_rebase_progress_style}

            local rebaseHeadNameDisplay="${rebaseHeadName}"
            local rebaseOntoBranchDisplay="${rebaseOntoBranch}"
            if [[ $git_status_branch_max_length -gt 0 ]]; then
                [[ ${#rebaseHeadNameDisplay} -gt $git_status_branch_max_length ]] &&
                    rebaseHeadNameDisplay="${rebaseHeadNameDisplay:0:(git_status_branch_max_length - 1)}…"
                [[ ${#rebaseOntoBranchDisplay} -gt $git_status_branch_max_length ]] &&
                    rebaseOntoBranchDisplay="${rebaseOntoBranchDisplay:0:(git_status_branch_max_length - 1)}…"
            fi

            rebaseTarget=
            rebaseTarget="${rebaseTarget}${git_status_rebase_head_style}${rebaseHeadNameDisplay}${git_status_default_style}"
            rebaseTarget="${rebaseTarget}${git_status_rebase_head_target_separator}"
            rebaseTarget="${rebaseTarget}${git_status_rebase_target_style}${rebaseOntoBranchDisplay}${git_status_default_style}"

            [[ -n $rebaseStep && -n $rebaseTotal ]] &&
                rebaseProgress="${doneColor}${rebaseStep}${git_status_default_style}/${rebaseTotal} " ||
                rebaseProgress="${git_status_rebase_interactive_edit_icon}"

            git_action="${git_status_action_rebase_icon}"
            git_action="${git_action}${rebaseTarget}${git_status_default_style} ${rebaseProgress}"
            ;;
        merge)       git_action="${git_status_action_merge_icon}"  ;;
        cherry-pick) git_action="${git_status_action_cherry_icon}" ;;
        revert)      git_action="${git_status_action_revert_icon}"  ;;
        bisect)      git_action="${git_status_action_bisect_icon}"  ;;
        *)           git_action=""    ;;
    esac

    if [[ -n $git_action ]]; then
        git_action="${git_status_action_prefix}${git_action}${git_status_action_suffix}"
    fi
}

# Extract the following variables:
#  - $git_action_name
#  - $rebaseStep
#  - $rebaseTotal
#  - $rebaseHeadName
#  - $rebaseOnto
#  - $rebaseOntoBranch
__git_extract_action_info() {
    # External affected vars

    git_action_name=
    rebaseStep=; rebaseTotal=; rebaseHeadName=; rebaseOnto=; rebaseOntoBranch=;

    if [[ -d "${gitDir}/rebase-merge" ]]; then
        git_action_name="rebase"

        __git_readval "${gitDir}/rebase-merge/msgnum"    rebaseStep
        __git_readval "${gitDir}/rebase-merge/end"       rebaseTotal
        __git_readval "${gitDir}/rebase-merge/head-name" rebaseHeadName
        __git_readval "${gitDir}/rebase-merge/onto"      rebaseOnto

        rebaseHeadName=${rebaseHeadName#refs/heads/}
        rebaseOntoBranch=$(__git_get_commit_branch "${rebaseOnto}")
        [[ -z $rebaseOntoBranch ]] && rebaseOntoBranch=$(git rev-parse --short "${rebaseOnto}")
        return
    fi

    if [[ -d "${gitDir}/rebase-apply" ]]; then
        __git_readval "${gitDir}/rebase-apply/next" rebaseStep
        __git_readval "${gitDir}/rebase-apply/last" rebaseTotal

        if [[ -f "${gitDir}/rebase-apply/rebasing" ]]; then
            git_action_name="rebase"
            __git_readval "${gitDir}/rebase-apply/head-name" rebaseHeadName
            __git_readval "${gitDir}/rebase-apply/onto"      rebaseOnto # TODO: check

            rebaseHeadName=${rebaseHeadName#refs/heads/}
            rebaseOntoBranch=$(__git_get_commit_branch "${rebaseOnto}")
            [[ -z $rebaseOntoBranch ]] && rebaseOntoBranch=$(git rev-parse --short "${rebaseOnto}")
        fi
        # TODO: am

        return
    fi

    if   [[ -f "${gitDir}/MERGE_HEAD"       ]]; then git_action_name="merge"
    elif [[ -f "${gitDir}/CHERRY_PICK_HEAD" ]]; then git_action_name="cherry-pick"
    elif [[ -f "${gitDir}/REVERT_HEAD"      ]]; then git_action_name="revert"
    elif [[ -f "${gitDir}/BISECT_LOG"       ]]; then git_action_name="bisect"
    fi
}

# Set the $git_state variable
__git_set_state() {
    # External affected vars
    git_state=

    local git_stateA=()

    local ss ch dl ut md sg cf
    if [[ $git_status_show_state_counters == true ]]; then
        ss="${git_stashes}"
        ch="${git_changed}"
        dl="${git_deleted}"
        ut="${git_untracked}"
        md="$(( git_changed + git_deleted + git_untracked ))"
        sg="${git_staged}"
        cf="${git_conflicts}"
    fi

    if [[ $git_status_state_show_stash == true ]] && [[ $git_stashes -gt 0 ]]; then
        git_stateA+=("${git_status_state_stashes_icon}${ss}")
    fi

    if [[ $git_untracked -eq 0 && $git_changed -eq 0 && $git_deleted -eq 0 && $git_staged -eq 0 && $git_conflicts -eq 0 ]]; then
        if [[ -n $git_status_state_clean_icon ]]; then
            git_stateA+=("${git_status_state_clean_icon}")
        fi
    fi

    case "${git_status_state_mode}" in
        detail*)
            [[ $git_deleted   -gt 0 ]] && git_stateA+=("${git_status_state_deleted_icon}${dl}")
            [[ $git_changed   -gt 0 ]] && git_stateA+=("${git_status_state_changed_icon}${ch}")
            [[ $git_untracked -gt 0 ]] && git_stateA+=("${git_status_state_untracked_icon}${ut}")
            [[ $git_staged    -gt 0 ]] && git_stateA+=("${git_status_state_staged_icon}${sg}")
            [[ $git_conflicts -gt 0 ]] && git_stateA+=("${git_status_state_conflict_icon}${cf}")
            ;;
        summary)
            if [[ $git_changed -gt 0 || $git_deleted -gt 0 ]]; then # Misc. changes
                git_stateA+=("${git_status_state_changed_icon}${md}")
            elif [[ $git_untracked -gt 0 ]] && [[ $git_changed -eq 0 || $git_deleted -eq 0 ]]; then # Only untracked
                [[ -z $ut ]] && ut=" "
                git_stateA+=("${git_status_state_untracked_icon}${ut}")
            fi
            [[ $git_staged    -gt 0 ]] && git_stateA+=("${git_status_state_staged_icon}${sg}")
            [[ $git_conflicts -gt 0 ]] && git_stateA+=("${git_status_state_conflict_icon}${cf}")
            ;;
    esac

    if [[ $git_status_show_state_counters == true ]]; then
        git_state=${git_stateA[*]} # Join with spaces
    else
        git_state=$(IFS=; echo "${git_stateA[*]}") # Join without spaces
    fi

    if [[ -n $git_state ]]; then
        git_state="${git_status_state_prefix}${git_state}"
    fi
}

##
## Git prompt general helpers
##

# Get branch name attached to given commit
__git_get_commit_branch() {
    local commit=$1

    git log \
        --oneline \
        --no-abbrev-commit \
        --decorate \
        --simplify-by-decoration \
        --decorate-refs='refs/heads/*' \
        --decorate-refs='refs/remotes/*' "$commit" | # select only commits with a branch
        head -n1 | grep "$commit"                  | # keep only current commit, if it actually has a branch
        sed 's/[a-f0-9]\+ (\([^)]*\)) .*/\1/'      | # filter out everything but decorations
        sed -e 's/, /\n/g'                         | # splits decorations
        tail -n1                                     # keep only last decoration
}

# Read first line of file into variable
__git_readval() {
    local file=$1
    local varName=$2

    [[ -r "$file" ]] && IFS=$'\r\n' read -r "${varName?}" <"$file"
}

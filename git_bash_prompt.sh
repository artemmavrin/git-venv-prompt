# Simple colored prompt with git branch and status indicators
git_bash_prompt() {
    # Define the colors that will be used
    local blue=$(tput setaf 33)
    local orange=$(tput setaf 166)
    local green=$(tput setaf 64)
    local yellow=$(tput setaf 136)
    local red=$(tput setaf 124)
    local cyan=$(tput setaf 37)
    local reset=$(tput sgr0)

    local status=""

    # \W is the current directory
    PS1="\[$blue\]\W\[$reset\] "

    # Check that we're in a directory managed by git
    if $(git rev-parse &> /dev/null); then
        # Check for any changes
        git update-index --really-refresh -q &> /dev/null

        # Save current directory and move to the top directory of the git repo
        pushd . &> /dev/null
        cd $(git rev-parse --show-toplevel)

        PS1+="(\[$cyan\]"

        # Try to get the current branch name
        PS1+=$(git symbolic-ref --quiet --short HEAD 2> /dev/null) \
            || PS1+=$(git rev-parse --short HEAD 2> /dev/null) \
            || PS1+="unknown branch"

        # Check that we're not in a subdirectory of .git
        if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == "false" ]
        then
            # Check for uncomitted changes
            if ! $(git diff --staged --quiet); then
                status+="\[$green\]+"
                status+=$(git diff --staged --numstat | wc -l | sed 's/ //g')
            fi

            # Check for unstaged changes
            if ! $(git diff-files --quiet); then
                status+="\[$yellow\]!"
                status+=$(git diff-files | wc -l | sed 's/ //g')
            fi

            # Check for untracked files
            if [ -n "$(git ls-files --others --exclude-standard)" ]; then
                status+="\[$red\]?"
                status+=$(git ls-files --others --exclude-standard \
                    | wc -l | sed 's/ //g')
            fi

            if [ -n "$status" ]; then
                status=" $status"
            fi
        fi
        PS1+="$status\[$reset\]) "

        # Return to the current directory
        popd &> /dev/null
    fi

    # \$ is the bash prompt
    PS1+="\[$orange\]\$\[$reset\] "
}

# Run the git_bash_prompt function at every prompt
PROMPT_COMMAND='git_bash_prompt'

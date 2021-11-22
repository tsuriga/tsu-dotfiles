# Common settings

HISTFILE=/Users/tsurikamppuri/.zsh_history
HISTSIZE=512
HISTFILESIZE=512
SAVEHIST=512

setopt HIST_IGNORE_DUPS
setopt INC_APPEND_HISTORY

export EDITOR=nano

# Common aliases

alias ..="cd .."
alias l="ls -ahlG"
alias howbig="du -sh"

# OS X aliases

# For easy unmounting on OS X El Capitano
alias ejectdmg="diskutil eject /dev/disk2"

# Git aliases

alias glog=showGitLog
alias pushbranch=pushActiveBranch
alias branch=createGitBranch
alias resetbranch=hardResetGitBranch
alias git-add-symlink=gitAddSymlink
alias deletebranch=gitDeleteBranch

# how-to reminders
alias howto-rename-recursive="echo \"find . -iname FILENAME -exec rename -v 's/SUBJECT/REPLACEMENT/;' '{}' \;\""
alias howto-replace-recursive="echo \"find . -type f -print0 | xargs -0 sed -i '' 's/SUBJECT/REPLACEMENT/g'\""
alias howto-find-app-using-a-port='echo lsof -n -i:PORT'
alias howto-fix-sudoed-git-repo='echo sudo chown -R \`whoami\` ".git/**/*"'

# my ip
function getMyIp() {
    dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}'
}
alias myip=getMyIp

# Git functions

function gitDeleteBranch() {
  branchName=$1
  git push origin -d $branchName && git branch -D $branchName
}

function hardResetGitBranch() {
    git reset --hard && git clean -fd `git rev-parse --show-toplevel`
}

# USAGE: glog [parent|limit|full messages?] [limit|full messages?] [full messages?]
# REQUIREMENTS:
# - getMasterBranch function
# - no branches with only numbers in the name
function showGitLog() {
    logLimit=''
    logFormat='--oneline'
    parentFormat=''

    activeBranch=`git rev-parse --abbrev-ref HEAD`

    repository=`basename \`git rev-parse --show-toplevel\``
    masterBranch=`getMasterBranch`

    if [ "$#" -eq "1" ]; then
        if [[ "$1" = "-h" ]]; then
            echo "USAGE: glog [parent|limit|full messages?] [limit|full messages?] [full messages?]"

            return
        fi

        re='^[0-9]+$'

        if [[ $1 =~ $re ]]; then
            logLimit="-n $1"
        else
            if [ "$activeBranch" = "$masterBranch" ]; then
                logFormat=''
            else
                masterBranch="$1"
            fi
        fi
    elif [ "$#" -eq "2" ]; then
        re='^[0-9]+$'

        if [[ $1 =~ $re ]]; then
            logLimit="-n $1"
            logFormat=''
        elif [[ $2 =~ $re ]]; then
            if [ "$activeBranch" = "$masterBranch" ]; then
                logFormat=''
            else
                masterBranch="$1"
            fi

            logLimit="-n $2"
        else
            masterBranch="$1"
            logFormat=''
        fi
    elif [ "$#" -eq "3" ]; then
        masterBranch="$1"
        logLimit="-n $2"
        logFormat=''
    fi

    if [ "$activeBranch" != "$masterBranch" ]; then
        parentFormat="origin/$masterBranch.."
    fi

    git log $logLimit $logFormat $parentFormat
}

function getMasterBranch() {
    repository=`basename \`git rev-parse --show-toplevel\``
    masterBranch="master"

    echo "$masterBranch"
}

function createGitBranch() {
    if [ "$#" -eq "0" ]; then
        echo "ERROR: Branch name required"
        return
    fi

    git branch "$1" 2>/dev/null
    git checkout "$1"
}

function pushActiveBranch() {
    activeBranch=`git rev-parse --abbrev-ref HEAD`
    git push --set-upstream origin $activeBranch
}

# Super neat PS1 that updates with time and branch status every second

function we_are_in_git_work_tree() {
    git rev-parse --is-inside-work-tree &> /dev/null
}

function parse_git_branch() {
    if we_are_in_git_work_tree; then
        BR=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD 2> /dev/null)

        if [ "$BR" = "HEAD" ]; then
            NM=$(git name-rev --name-only HEAD 2> /dev/null)

            if [ "$NM" != undefined ]; then
                echo -n "@$NM"
            else
                git rev-parse --short HEAD 2> /dev/null
            fi

        else
            echo -n $BR
        fi
    else
        echo ''
    fi
}

function parse_git_status {
    if we_are_in_git_work_tree; then
        ST=$(git status --short 2> /dev/null)

        if [ -n "$ST" ]; then
            echo -n "%F{1} ! "
        else
            echo -n "%F{2} ✓ "
        fi
    else
        echo ''
    fi
}

function gitAddSymlink {
    src=$1
    target=$2

    if [ "$#" -lt "2" ]; then
        echo "Usage: git-add-symlink <source> <target>"
        echo "<source> and <target> are relative to pwd"
        return 0
    fi

    prefix=`git rev-parse --show-prefix`
    hash=`echo -n "$src" | git hash-object -w --stdin`

    git update-index --add --cacheinfo 120000 $hash "$prefix$target"
    git checkout -- "$target"
}

setopt PROMPT_SUBST
PROMPT='%B%F{0}[%F{5}%D{%H}%F{0}:%F{5}%D{%M}%F{0}:%F{5}%D{%S}%F{0}] %F{4}${${(%):-%~}}$(parse_git_status)%F{5}$(parse_git_branch)%f %b$ '
TMOUT=1

TRAPALRM() {
    zle reset-prompt
}

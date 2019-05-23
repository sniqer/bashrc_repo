git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
NIRA_ROOT='/c/nira_tools'

LS_COLORS='rs=0:di=1;31:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:';
export LS_COLORS

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ff="grep -ril . | grep -i"
alias reload="source ~/.bashrc"
alias nirabuild="nirabuild.bat"
alias nb="nirabuild scons -j8"
alias s="/c/'Program Files'/'Sublime Text 3'/sublime_text.exe"
alias bashrc="s ~/.bashrc &"
alias e="explorer ."
alias ga="git add"
alias gb="git branch"
alias gc="git checkout"
alias gcm="git commit -m"
alias gd="git diff"
alias gdt="git difftool -d"
alias gf="git fetch"
alias gp="git push"
alias gs="git status"
alias findbranch="gb -r | grep -i"
alias b="popd > /dev/null && ll"
alias niracloneall="niraclone ND4 && cd ND4 && git fetch --all"
alias python="winpty python.exe"
alias chrome="\"/c/Program Files (x86)/Google/Chrome/Application/chrome.exe\""
alias niramatlab="nirabuild matlab"


function fixcolors {
    git config color.status.changed yellow
    git config color.status.untracked magenta
}

fixcolors

function cdgitroot {
    cd `git rev-parse --show-toplevel` > /dev/null || echo "error: cd into a ND4 repository"
}

function cd {
    pushd . > /dev/null && command cd ${1} && ll
}

function clean {
    git clean -fdx
}

function nbt {
    cdgitroot
    cd Deliverable > /dev/null
    nb TAG=$1 ${@:2}
    cdgitroot
}

function newbranch {
    if [ $# -eq 1 ]; then
        FOLDER_NAME=branch_$1
    elif [ $# -eq 2 ]; then
        FOLDER_NAME=$2
    else
        echo "arguments 'branch name'"
        echo "or ..."
        echo "arguments 'branch name' 'folder name'"
        return 1
    fi
    mkdir -p $NIRA_ROOT/$FOLDER_NAME
    cd $NIRA_ROOT/ND4 > /dev/null
    git worktree prune
    git fetch --all
    git worktree add $NIRA_ROOT/$FOLDER_NAME $1
    cd $NIRA_ROOT/$FOLDER_NAME
}

function buildmextester {
    if [ $# -gt 0 ]; then
        cdgitroot
        cd Matlab > /dev/null
        nb TAG=$1 WIN32=True OPTIMIZE=debug
        cdgitroot
    else
        echo "arguments: 'project tag'"
    fi
}

function rununittest {
    if [ $# -gt 0 ]; then
        cdgitroot
        cd UnitTest > /dev/null
        nb TAG=$1 WIN32=true UNITTEST
        nb TAG=$1 WIN32=true UNITTEST_REPORTS
        nb TAG=$1 WIN32=true UNITTEST INTEGRATIONLAYER=True
        nb TAG=$1 WIN32=true UNITTEST_REPORTS INTEGRATIONLAYER=True
        cd Build/$1/etc > /dev/null
        chrome *.pdf
        cdgitroot
    else
        echo "arguments: 'project tag'"
    fi
}

function runfunctest {
    if [ $# -gt 0 ]; then
        cdgitroot
        cd FunctionalTest > /dev/null
        nb TAG=$1 RUNTESTS CODING=RELEASE ${@:2} || return
        cd Build/$1/testResult > /dev/null
        chrome *.pdf
        cdgitroot
    else
        echo "arguments: 'project tag'"
    fi
}

function createreleasetag {
    if [ $# -eq 2 ]; then
        cdgitroot
        cd Devtools > /dev/null
        nirabuild CreateReleaseTag.py --directorypath ../ --tag $1 --branch $2
        cdgitroot
    else
        echo "arguments: 'tag name' 'branch name'"
    fi
}

function createtrackingsheet {
    if [ $# -eq 4 ]; then
        cdgitroot
        cd Devtools > /dev/null
        nirabuild MakeTrackingSheet.py --directorypath ../ --release $1 --changes_since $2 --branch $3 --notes $4
    else
        echo "arguments: 'tag name' 'previous tag name' 'branch name' 'notes number'"
    fi


}

function setupTPITest14xx {
    if [ $# -eq 1 ]; then
        cdgitroot
        nirabuild.bat checkout_module ND4TPITest
        cd ND4TPITest
        nirabuild.bat BuildTPITestMappings.bat $1
        cdgitroot
    else
        echo "arguments: 'Autosar generation' (e.g. TPIAutosar2G or TPIAutosar or ... "
    fi
}

function reviewpush {
    if [ $# -gt 0 ]; then
        git push gerrit HEAD:refs/for/$1
    else
        echo "arguments: 'branch to push to'"
    fi
}

function cds {
    if [ $# -gt 0 ]; then
        if [ $1 == "-h" ]; then
            echo "cds [args]"
            echo "cds 'name':    cd into bookmark 'name'"
            echo "cds -l:        list all stored bookmarks"
            echo "cds -a 'name': add bookmark 'name' to your current directory"
            echo "cds -r 'name': remove bookmark 'name'"
        elif [ $1 == "-l" ]; then
            cat ~/.cds_list
        elif [ $1 == "-a" ]; then
            if [ $# -eq 2 ]; then
                if grep "$2:" ~/.cds_list > /dev/null; then
                    cds -r $2
                fi
                echo "$2: $PWD" >> ~/.cds_list
            else
                echo "cds -a name_of_bookmark"
            fi
        elif [ $1 == "-r" ]; then
            if [ $# -eq 2 ]; then
                sed -i "/$2:/d" ~/.cds_list
            else
                echo "cds -r name_of_bookmark_to_be_removed"
            fi
        else
            CD_VAR=`cat ~/.cds_list | grep -i "$1: "| cut -f2 -d":"`
            echo $CD_VAR
            if ! [ -z $CD_VAR ]; then
                cd $CD_VAR
            else
                echo "bookmark not found in list..."
                cds -l
            fi
        fi
    else
        cds -h
    fi
}

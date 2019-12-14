# hadm-profile alias common-profile
# vim:ts=3:sw=3

# echo common-profile.sh

# Copyright © 2018 by Christian ENGEL (mailto:engel-ch@outlook.com)
# License: BSD
# All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#    This product includes software developed by the <organization>.
# 4. Neither the name of the <organization> nor the
#    names of its contributors may be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ''AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# DESCRIPTION:
#  - common-profile can be used on its own as a default profile for bash and zsh.
#
# RELEASES:
# 1.5.1
# - TeX-specific (OSX) path creation
# 1.4.12
# - PS1 as 2 line prompt
# 1.4.11
# - HISTFILE checks now also for existence.
# 1.4.10
# - user-detection not working if not in group wheel. fix.
# 1.4.9
# - HISTFILE changed to default naming with underscore
# - HISTSIZE enhanced to 8000
# 1.4.8
# - paths for WSL integrated
# 1.4.7
# 1.4.6
# - issue warning if .bash.history is not writable
# 1.4.5
# - Simplification Profile.d/...
# 1.4.4
# - gitInit added
# 1.4.3
# - determine user by ssh login journalctl only if SSH_CLIENT is set
# 1.4.2
# - add .zshrc in installCommonrc
# 1.4.1
# - new function installCommonrc
# 1.4.0
# - add gitPrompt support using gitContents
# - color prompts
# 1.3.1
# - add path to COMMONRC_FILE
# 1.3.0
# - rl fixed w/ COMMONRC_FILE
# 1.2.0
# - k8 aliased improved
# - alias gibr added
# 1.1.0
# - k8 aliases introduced
# 1.0.0
# - cleanup

export COMMONRC_VERSION="1.5.1"
export COMMONRC_FILE=${COMMONRC_FILE:-/etc/common-profile.sh}

export HISTSIZE=8000
export HISTFILE="$HOME/.bash_history"

export REAL_USER=$(who am i | awk '{print $1}')
if [ -e "$HISTFILE" -a ! -w "$HISTFILE" ] ; then
   printf "\033[0;31m$HISTFILE not writable\033[0m\n\t" > /dev/stderr
   sudo chown $REAL_USER $HISTFILE; res=$?
   if [ "$res" -ne 0 ] ; then
      echo Could NOT fix it. Please intervene... > /dev/stderr
   else
      echo fixed. > /dev/stderr
   fi
fi

export SAVEHIST=$HISTSIZE
export RSYNC_FLAGS="-rltDvu --modfiy-window=1"
export RSYNC_SLINK_FLAGS="$RSYNCFLAGS --copy-links"
export RSYNC_LINK='--copy-links'
export VISUAL=vim
export BLOCKSIZE=1K

COLOUR_RED="\033[0;31m"
COLOUR_YELLOW="\033[0;33m"
COLOUR_GREEN="\033[0;32m"
COLOUR_BLUE="\033[0;34m"
COLOUR_WHITE="\033[0;37m"
COLOUR_RESET="\033[0m"

# git bash prompt like, but much shorter and also working for darwin.
gitContents()
{
    cmd='git status -s --show-stash -b'
    if [[ $(git rev-parse --is-inside-work-tree 2>&1 | grep fatal | wc -l) -eq 0  ]] ; then
            branch=$($cmd | head -1 | sed 's/^##.//')
            status=$($cmd | tail -n +2 | sed 's/^\(..\).*/\1/' | sort | uniq | tr "\n" " " | sed -e 's/ //g' -e 's/??/?/' -e 's/^[ ]*//')
            echo ':'$status $branch
    fi
}

PATH=/snap/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:$HOME/bin     # define a std PATH 4 starters

case $- in
  *i*) #  "This shell is interactive"
	;;
  *)   #echo "This is a script";;
	return
   ;;
esac
[[ -o login ]] && set -o ignoreeof  # prevent ^d logout for login shell. This is not inherited to sub-shells.
set -o noclobber                    # overwrite protection
setopt SH_WORD_SPLIT 2&>/dev/null
unsetopt nomatch 2&>/dev/null

for POTENTIAL_DIR in \
   /usr/local/opt/openssl\@1.1/bin \
   /usr/local/opt/gnu-getopt/bin \
   /opt/Arch/*/bin \
   /Library/Java/JavaVirtualMachines/current/bin \
   /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin \
   $HOME/Library/Android/sdk/platform-tools \
   /usr/local/share/dotnet /usr/local/go/bin \
   /Applications/Visual\ Studio\ Code.app//Contents/Resources/app/bin/ \
   /Applications/Sublime\ Tex*.app/Contents/MacOS/ \
   $HOME/.dotnet/tools $HOME/.rvm/bin \
   /mnt/c/Windows/System32 \
   /mnt/c/Windows \
   /mnt/c/Windows/System32/wbem \
   /mnt/c/Windows/System32/WindowsPowerShell/v1.0 \
   /mnt/c/Users/engelch/AppData/Local/Microsoft/WindowsApps
do
    test -d "$POTENTIAL_DIR/." &&  PATH="$POTENTIAL_DIR":$PATH
done

# executing the finds takes time. So, let's cache the result.
TEXBASEDIR=${TEXBASEDIR:-/usr/local/texlive}
TEXPATHFILE="$HOME/.bash.tex.path"
if [ -d "$TEXBASEDIR" -a ! -f "$TEXPATHFILE" ] ; then
   echo creating TEXPATHFILE $TEXPATHFILE...
   find "$TEXBASEDIR" -type d -name '*bin' | egrep '.*/bin$' > $TEXPATHFILE
   find "$TEXBASEDIR" -type d -name '*linux' | egrep '.*linux$' >> $TEXPATHFILE
   find "$TEXBASEDIR" -type d -name '*darwin' | egrep '.*darwin$' >> $TEXPATHFILE
fi
if [ -f "$TEXPATHFILE" ] ; then
   for line in $(egrep -v '^[[:space:]]*$' $TEXPATHFILE) ; do
      PATH=$PATH:"$line"
   done
fi
unset line

# not so easy as expected to determine the actual shell type
CALC_SHELL=$(ps | grep $$ | grep -v grep | sed 's/-l$//' | awk '{ print $NF }' | sed 's/^-//')
alias root='sudo $CALC_SHELL -l'

### debug helpers
function debugSet() {
   export DEBUG_FLAG_BASH=TRUE
}

function debugUnset() {
   export DEBUG_FLAG_BASH=FALSE
}

# debug outputs to stderr with newline
function debug() {
   [ "$DEBUG_FLAG_BASH" = TRUE ] && echo '[DEBUG]' $* 1>&2
   unset xxx # always return 0 exit code
}

debug debug is on.

### sourcing further files. This is only done for non-root shells.
# sourceHomeProfiles pre zshrc
function sourceHomeProfiles() {
   debug sourceHomeProfiles $*
   [[ $# -ne 2 ]] && echo wrong number of arguments to sourceHomeProfiles. > /dev/stderr && return
    for FILE in $HOME/.$2.$1.sh $HOME/$2.$1.sh; do
      [ -e $FILE ] && debug sourcing $FILE && source $FILE
    done
    unset FILE
}

function sourceProfileDir() {
   debug sourceProfileDir
   for _dir in ~/Profile.d/./ /opt/Profile.d/./ /opt/Arch/Profile.d/./ ; do
      if [[ -d $_dir ]] ; then
            cd $_dir
            for _file in *.sh ; do
               debug sourcing $_file
               source $_file
            done
         break
      fi
   done
   unset _dir _file
}

function setupShell() {
   debug setupShell
   CDPATH=~:/usr/local

   # OS-specific setup
   if [ $(uname) = Linux ] ; then
      LS_COLOUR='--color=auto'
      alias proc='ps -ef | grep -i '
      alias o=xdg-open
      alias open=o
      alias xlock='xlock -remote -mode blank -allowroot'
      alias xl=xlock

      function restat()	{
         systemctl restart $* ; systemctl status $*
      }

   elif [ $(uname) = Darwin ] ; then
      LS_COLOUR='-G'
      alias proc='ps -ef | grep -i '
      alias o=open
   fi

   # OS independent setup
   alias ls="/bin/ls    -CF      $LS_COLOUR"
   alias ll="/bin/ls    -lF      $LS_COLOUR"
   alias la="/bin/ls    -aCF     $LS_COLOUR"
   alias lla="/bin/ls   -alF     $LS_COLOUR"

   alias ..='cd ..'
   alias ...='cd ../..'
   alias .2='cd ../..'
   alias .3='cd ../../..'
   alias .4='cd ../../../..'
   alias .5='cd ../../../../..'
   alias .6='cd ../../../../../..'
   alias a=alias
   alias brmd='cd .. ; rmdir $OLDPWD'
   alias cm=cmake
   alias cp='cp -i'
   alias e=egrep
   alias enf='env | egrep -i '
   alias fin='find . -name'

	alias gidi='git diff'               # show delta working-tree vs index
   alias gidic='git diff --cached'     # show delta index vs last commit
	alias avv='git branch -avv'
   alias gibr=avv
	alias gilo='git log --branches --remotes --tags --graph --oneline --decorate'
	alias gist='git status'
	alias gipl='git pull --all; git fetch --tags'
   alias gipu='git push --all; git push --tags'

   alias h=history
   alias hf='history | egrep -i '
   alias j=jobs

   alias k=kubectl
   alias k8=kubectl
   alias k8gn='kubectl get nodes'
   alias k8cg='kubectl config get-contexts'
   alias k8cs='kubectl config set-context'
   alias k8c='kubectl config '

   alias k8cg='kubectl config get-contexts'
   alias k8cu='kubectl config use-context'
   alias k8cv='kubectl config view'
   alias k8gn='kubectl get nodes -o wide'
   alias k8gs='kubectl get services -o wide'
   alias k8ns='kubectl get ns'
   alias k8ga='kubectl get all -A -o wide'

   alias l=less
   export LESS='-iR'
   export PAGER=less
   alias ln-s='ln -s'
   alias m=make
   alias mv='mv -i'
   alias po=popd
   alias pu='pushd .'
   alias rm='rm -i'                    # life assurance
   alias rl="source $COMMONRC_FILE"
   alias tm='tmux new -s '
   alias tw='tmux new-window -n'
   alias tn=tw
   alias tj='tmux join-pane -s'
   alias wh=which
}

gicm()
{
    if [ $# -ne 0 ] ; then
        git commit -m "$*"
    else
        git commit
    fi
}

function installCommonrc()
{
   [ "$1" != '-f' ] && cd
   [ ! -L .bashrc ] && mv -f .bashrc .bashrc.orig
   [ ! -L .bash_profile ] && mv -f .bash_profile .bash_profile.orig
   [ ! -L .zshrc ] && mv -f .zshrc .zshrc.orig
   ln -sf /etc/common-profile.sh .bashrc
   ln -sf /etc/common-profile.sh .bash_profile
   ln -sf /etc/common-profile.sh .zshrc
   [ "$1" != '-f' ] && cd -
}

function gitInit()
{
   _fullName=$(git config --global user.name)
   if [ "$_fullName" = "" ] ; then
      _userName=$(id -un)     # get current potential user-name
      _fullName=$(getent passwd | egrep ^$_userName | awk -F: '{print $5}')
   fi
   read -e -p 'Username for commits:' -i "$_fullName" _gitUsername
   git config --global user.name "$_gitUsername"

   _gitMailAddr=$(git config --global user.email)
   read -e -p 'Email address for commits:' -i "$_gitMailAddr" _gitMailAddr
   git config --global user.email "$_gitMailAddr"

   for _editor in vi vim emacs uemacs nano ; do
      command -v $_editor >/dev/null 2>&1 && git config --global core.editor $_editor && \
         echo editor set to $_editor && break
   done
}

### ssh helpers
function ssf() {
   grep -iA 5 "$*" ~/.ssh/config
}

function sshagent_findsockets {
   find /tmp -uid $(id -u) -type s -name agent.\* 2>/dev/null
}

function sshagent_testsocket {
    [ ! -x "$(which ssh-add)" ] && echo "ssh-add is not available; agent testing aborted" && return 1

    [ X"$1" != X ] && export SSH_AUTH_SOCK=$1

    [ X"$SSH_AUTH_SOCK" = X ] && return 2

    if [ -S $SSH_AUTH_SOCK ] ; then
        ssh-add -l > /dev/null
        if [ $? = 2 ] ; then
            debug  "socket $SSH_AUTH_SOCK is dead! Deleting!"; rm -f $SSH_AUTH_SOCK; return 4
        elif [ $? = 1 -a $(ssh-add -l | wc -l) -eq 0 ] ; then
            ssh-add
        else
            debug "ssh-agent found: $SSH_AUTH_SOCK"; return 0
        fi
    else
        debug "$SSH_AUTH_SOCK is not a socket!"; return 3
    fi
}

function sshagent_init {
    # ssh agent sockets can be attached to a ssh daemon process or an ssh-agent process.
    AGENTFOUND=0

    # Attempt to find and use the ssh-agent in the current environment
    if sshagent_testsocket ; then AGENTFOUND=1 ; fi

    # If there is no agent in the environment, search /tmp for possible agents to reuse before starting a fresh ssh-agent process.
    if [ $AGENTFOUND = 0 ] ; then
         for agentsocket in $(sshagent_findsockets) ; do
            if [ $AGENTFOUND != 0 ] ; then break ; fi
            if sshagent_testsocket $agentsocket ; then AGENTFOUND=1 ; fi
         done
         eval `ssh-agent`
    fi

    unset AGENTFOUND    # Clean up
    unset agentsocket

    [[ $(ssh-add -l | grep  'no identities' | wc -l) -eq 1 ]] && ssh-add # load keys if none loaded so far
}

alias sagent="sshagent_init"

### zsh vs bash specific parts


if [[  "$CALC_SHELL" =~ .*bash ]] ; then
	#echo matching bash
	if [ $(id -u) -eq 0 ] ; then
      debug bash ROOT shell
		PS1='\033[0;31m\u@\h \033[0;34m\! \033[0;32m$(pwd)\033[0;31m#\033[0m\n'
      setupShell
	else
      debug bash shell
		PS1='\033[0m\u@\h|\033[0;34m\!\033[0m|\033[0;33m$(gitContents)\033[0m|\033[0;32m\w\e[0m\n'
      sourceHomeProfiles pre bashrc
      sourceProfileDir
      setupShell
      sourceHomeProfiles post bashrc
	fi
elif [[ "$CALC_SHELL" =~ .*zsh ]] ; then
	setopt hist_ignore_all_dups
	setopt hist_ignore_space
	setopt autocd
	setopt extendedglob
	autoload -U compinit
	compinit
	setopt correctall    	# Correction
	if [ $(id -u) -eq 0 ] ; then
	   debug zsh ROOT shell
		PS1="%(?..%B{%v}%b)%Broot%b%(2v.%B@%b.@)%m:%h:%B%d%b#"
      		setupShell
	else
	   debug zsh shell
		PS1="%(?..%B{%v}%b)%n%(2v.%B@%b.@)%m:%h:%B%~%b%(!.#.$)"
      sourceHomeProfiles pre zshrc
      sourceProfileDir
      setupShell
      sourceHomeProfiles post zshrc
	fi
else
	echo no definition found
fi

sagent   #echo start ssh

unset POTENTIAL_DIR FILE _file

if [[ $(uname) = Linux && ! $(uname -r) =~ Microsoft && $(id -Gn) =~ wheel ]] ; then
   export HADM_LAST_LOGIN_FINGERPRINT=${HADM_LAST_LOGIN_FINGERPRINT:-$(sudo journalctl -u ssh | grep 'Accepted publickey for' | tail -n 1 | awk '{ print $NF }')}

   if [ "$SSH_CLIENT" != "" ] ; then
      for file in ~/.ssh/*.pub
      do
         if [ $(ssh-keygen -lf $file | grep $HADM_LAST_LOGIN_FINGERPRINT | wc -l) -eq 1 ] ; then
            export HADM_LAST_LOGIN_USER=$(basename $file .pub)
            echo You are $HADM_LAST_LOGIN_USER. Welcome.
            break
         fi
      done
   fi
fi

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
[[ -s "$HOME/.rvm/environments/default" ]] && source "$HOME/.rvm/environments/default" && \
  export PATH="$PATH:$HOME/.rvm/bin"

[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

# EOF

#!/bin/sh

################################################################################
# Java Jenv Init                                                               #
################################################################################

eval "$(jenv init -)"

################################################################################
# Core ENV VARS                                                                #
################################################################################

export DOTFILES_HOME=$HOME/.dotfiles
export PERSONAL_DOTFILES_HOME=$DOTFILES_HOME/personal
export WORK=/opt/spectrum_health
export JAVA_HOME=$(jenv javahome)
export M2_HOME=$HOME/.m2
export HOME_BIN=$WORK/bin
export TNS_ADMIN=$WORK/oracleTns/network/admin
export MAVEN_OPTS="-Xmx512m -Djava.awt.headless=true"

################################################################################
# MODULE ENV VARS - Status Variables                                           #
################################################################################

export JAVA_8_LOADED=0
export GIT_PROFILE_LOADED=0
export BASH_RC_LOADED=0
export BASH_PROFILE_LOADED=0
export HOMEBREW_LOADED=0
export BREWFILE_LOADED=0
export GIT_CONFIG_LOADED=0

################################################################################
# Core ALIASES                                                                 #
################################################################################

# Workspace
alias wg="cd $WORK" # wg -> workspace git
alias dot="cd $DOTFILES_HOME"
alias tns="cd $WORK/oracletns/network/admin"
alias bin="cd $HOME_BIN"

# Misc
alias brew="all_proxy=http://$USER:@proxy.spectrum-health.org:9090 brew"

# Examples
alias ll="ls -l"
alias l="ls -al"

################################################################################
# Base PATH                                                                    #
################################################################################

export PATH=~/Downloads:$JAVA_HOME/bin:$HOME/.jenv/bin:$HOME_BIN:$DOTFILES_HOME/bin:$DOTFILES_HOME/bin/cbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

################################################################################
# Any extensions, put into newly created .bashrc                               #
################################################################################

if [ -r $PERSONAL_DOTFILES_HOME/.bashrc ]; then
   . $PERSONAL_DOTFILES_HOME/.bashrc
   export BASH_RC_LOADED=1
fi
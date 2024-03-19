# ~/.bashrc

# Write git branch in terminal output
parse_git_branch() {
 git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(parse_git_branch)\$ '
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(parse_git_branch)\$ '
fi
unset color_prompt force_color_prompt


# Aliases
alias gs='git status'
alias gp='git pull'
alias gd='git diff'
alias kge='kubectl get events'
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgn='kubectl get nodes'
alias ls='ls -l'
alias gs='git status'
alias gd='git diff'
alias ra='ranger'

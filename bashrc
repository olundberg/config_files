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
#alias gt='git log --graph --pretty=oneline --abbrev-commit'
alias gt='log --graph --abbrev-commit --decorate=no --date=format:'%Y-%m-%d %H:%I:%S' --format=format:'%C(03)%>|(26)%h%C(reset)  %C(04)%ad%C(reset)  %C(green)%<(16,trunc)%an%C(reset)  %C(bold 1)%d%C(reset) %C(bold 0)%|(1)%s%C(reset)' --all'
alias gl='git log'
alias gs='git status'
alias gd='git diff'
alias gp='git pull'
alias gpd='ls | xargs -I{} git -C {} pull'
alias k='kubectl'
alias kge='kubectl get events'
alias kgp='kubectl get pods'
alias kgn='kubectl get nodes'
alias ls='ls -l'
alias ra='. ranger'  # Exit in current cwd
alias sb='source ~/.bashrc'

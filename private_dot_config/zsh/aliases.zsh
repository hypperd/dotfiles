alias ls="eza --icons --color=auto --group-directories-first --no-quotes"
alias ip="ip --color=auto"
alias cat="bat"
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias df='df -h'
alias du='du -h'
alias checkupdates="updates"
alias bash="bash --rcfile <(echo 'HISTFILE="$XDG_STATE_HOME"/bash/history')"
alias speedtest-cli="speedtest-cli --secure"
alias vim="nvim"
alias vi="nvim"
alias neofetch="clear && fastfetch"
alias rm="rm -i"
alias less="less -r"
alias duf="duf --hide special"
alias spicetify="spicetify --no-restart"

# fix ssh for kitty
[[ $TERM == "xterm-kitty" ]] && alias ssh="kitty +kitten ssh"

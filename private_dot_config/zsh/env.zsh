# Less pager colors
export LESS_TERMCAP_mb=$'\E[01;31m'      # Begins blinking.
export LESS_TERMCAP_md=$'\E[01;31m'      # Begins bold.
export LESS_TERMCAP_me=$'\E[0m'          # Ends mode.
export LESS_TERMCAP_se=$'\E[0m'          # Ends standout-mode.
export LESS_TERMCAP_so=$'\E[00;47;30m'   # Begins standout-mode.
export LESS_TERMCAP_ue=$'\E[0m'          # Ends underline.
export LESS_TERMCAP_us=$'\E[01;32m'      # Begins underline.

# Preferred editor
export EDITOR='nvim'

# FZF theme
export FZF_DEFAULT_OPTS="
  --color fg:#eceff4
  --color fg+:#2e3440
  --color bg:#2e3440
  --color bg+:#5e81ac
  --color hl:#a3be8c
  --color hl+:#a3be8c
  --color prompt:#81a1c1
  --color spinner:#8fbcbb
  --color pointer:#a3be8c
  --color marker:#bf616a
  --color border:#4c566a
  --color gutter:#3b4252
  --color info:#b48ead
  --color header:#81a1c1
  --border rounded
  --pointer ' >'
  --prompt '>> '
  --exact"
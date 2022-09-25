# terminfo db
zmodload zsh/terminfo

# Functions
## Make sure that the terminal is in application mode when zle is active
function zle-line-init() {
    (( ${+terminfo[smkx]} )) && echoti smkx
}

function zle-line-finish() {
    (( ${+terminfo[rmkx]} )) && echoti rmkx
}

zle -N zle-line-init
zle -N zle-line-finish

# Expands .... to ../..
function expand-dot-to-parent-directory-path {
	if [[ $LBUFFER = *.. ]]; then
		LBUFFER+='/..'
	else
		LBUFFER+='.'
	fi
}

zle -N expand-dot-to-parent-directory-path

# Displays an indicator when completing.
function expand-or-complete-with-indicator {
    printf '\e[?7l%s\e[?7h' "..."
    zle expand-or-complete
    zle redisplay
}

zle -N expand-or-complete-with-indicator

# Do nothing
function _do_nothing() {;}
zle -N _do_nothing

##-- Variables
typeset -gA key_info
key_info=(
	'Control'         '\C-'
	'ControlLeft'     '\e[1;5D \e[5D \e\e[D \eOd'
	'ControlRight'    '\e[1;5C \e[5C \e\e[C \eOc'
	'ControlPageUp'   '\e[5;5~'
	'ControlPageDown' '\e[6;5~'
	'Escape'          '\e'
	'Meta'            '\M-'
	'Backspace'       "^?"
	'Delete'          "^[[3~"
	'F1'              "$terminfo[kf1]"
	'F2'              "$terminfo[kf2]"
	'F3'              "$terminfo[kf3]"
	'F4'              "$terminfo[kf4]"
	'F5'              "$terminfo[kf5]"
	'F6'              "$terminfo[kf6]"
	'F7'              "$terminfo[kf7]"
	'F8'              "$terminfo[kf8]"
	'F9'              "$terminfo[kf9]"
	'F10'             "$terminfo[kf10]"
	'F11'             "$terminfo[kf11]"
	'F12'             "$terminfo[kf12]"
	'Insert'          "$terminfo[kich1]"
	'Home'            "$terminfo[khome]"
	'PageUp'          "$terminfo[kpp]"
	'End'             "$terminfo[kend]"
	'PageDown'        "$terminfo[knp]"
	'Up'              "$terminfo[kcuu1]"
	'Left'            "$terminfo[kcub1]"
	'Down'            "$terminfo[kcud1]"
	'Right'           "$terminfo[kcuf1]"
	'BackTab'         "$terminfo[kcbt]"
)

# Unbound keys in vicmd and viins mode will cause really odd things to happen!
local -a unbound_keys
unbound_keys=(
  "${key_info[F1]}"
  "${key_info[F2]}"
  "${key_info[F3]}"
  "${key_info[F4]}"
  "${key_info[F5]}"
  "${key_info[F6]}"
  "${key_info[F7]}"
  "${key_info[F8]}"
  "${key_info[F9]}"
  "${key_info[F10]}"
  "${key_info[F11]}"
  "${key_info[F12]}"
#  "${key_info[PageUp]}"
#  "${key_info[PageDown]}"
  "${key_info[ControlPageUp]}"
  "${key_info[ControlPageDown]}"
)

##-- Layout
KEYTIMEOUT=1 # faster vim mode switching
bindkey -v  # use vim layout 

# Keybindings for all keymaps
for keymap in 'viins' 'vicmd'; do
    bindkey -M "$keymap" "$key_info[Home]" beginning-of-line
    bindkey -M "$keymap" "$key_info[End]" end-of-line
	bindkey -M "$keymap" "$key_info[PageUp]" up-line-or-history
	bindkey -M "$keymap" "$key_info[PageDown]" down-line-or-history
done

for unbound_key in $unbound_keys; do
  bindkey -M viins "${unbound_key}" _do_nothing
  bindkey -M vicmd "${unbound_key}" _do_nothing
done

# fuzzy find history
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Keybindings vim insert mode
bindkey -M viins "$key_info[Insert]" overwrite-mode
bindkey -M viins "$key_info[Delete]" delete-char
bindkey -M viins "$key_info[Backspace]" backward-delete-char

bindkey -M viins "$key_info[Left]" backward-char
bindkey -M viins "$key_info[Right]" forward-char
bindkey -M viins "$key_info[Control]L" clear-screen

# Expand .... to ../..
bindkey -M viins "." expand-dot-to-parent-directory-path

# Typing - fuzzy find history
bindkey -M viins "$key_info[Up]" up-line-or-beginning-search
bindkey -M viins "$key_info[Down]" down-line-or-beginning-search

# Bind Shift + Tab to go to the previous menu item.
bindkey -M viins "$key_info[BackTab]" reverse-menu-complete

# Display an indicator when completing.
bindkey -M viins "$key_info[Control]I" expand-or-complete-with-indicator

bindkey ' ' magic-space


##-- Keybindings vi normal mode (vi cmd in zsh)
bindkey -M vicmd "$key_info[Delete]" delete-char
bindkey -M vicmd "u" undo
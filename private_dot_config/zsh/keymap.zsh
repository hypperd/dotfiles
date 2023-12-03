# Load terminfo db
zmodload zsh/terminfo

## Functions

# Set Application mode
function zle-line-init() {
    (( ${+terminfo[smkx]} )) && echoti smkx
}

function zle-line-finish() {
    (( ${+terminfo[rmkx]} )) && echoti rmkx
}

zle -N zle-line-init
zle -N zle-line-finish

# fix vim mode yank
function vi-yank-wl() {
    zle vi-yank
    kitty +kitten clipboard <<< "$CUTBUFFER"
}

zle -N vi-yank-wl
bindkey -M vicmd 'y' vi-yank-wl

function vi-put-wl-after() {
    CUTBUFFER=$(wl-paste)
    zle vi-put-after
}

function vi-put-wl-before() {
    CUTBUFFER=$(wl-paste)
    zle vi-put-before
}

zle -N vi-put-wl-after

bindkey -M vicmd 'p' vi-put-wl-after

# Do nothing
function _do_nothing() {;}

zle -N _do_nothing

## Variables
typeset -gA keys; keys=(
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
	'Shift-Tab'       "$terminfo[kcbt]"
)

# Keys to remove wrong behavior
local -a unbound_keys; unbound_keys=(
	"${keys[F1]}" "${keys[F2]}" "${keys[F3]}" "${keys[F4]}" 
	"${keys[F5]}" "${keys[F6]}" "${keys[F7]}" "${keys[F8]}"
	"${keys[F9]}" "${keys[F10]}" "${keys[F11]}" "${keys[F12]}"
	"${keys[ControlPageUp]}" "${keys[ControlPageDown]}"
)

# Keybindings for viins and vicmd
for keymap in 'viins' 'vicmd'; do
  bindkey -M "$keymap" "$keys[Home]" beginning-of-line
  bindkey -M "$keymap" "$keys[End]" end-of-line
	bindkey -M "$keymap" "$keys[PageUp]" up-line-or-history
	bindkey -M "$keymap" "$keys[PageDown]" down-line-or-history

	for key in "${(s: :)keys[ControlLeft]}"
    	bindkey -M "$keymap" "$key" vi-backward-word

  	for key in "${(s: :)keys[ControlRight]}"
    	bindkey -M "$keymap" "$key" vi-forward-word
		
done

# Remove wrong behavior
for unbound_key in $unbound_keys; do
	bindkey -M viins "${unbound_key}" _do_nothing
	bindkey -M vicmd "${unbound_key}" _do_nothing
done

## Keybindings vim insert mode

# fuzzy find history
autoload -U up-line-or-beginning-search down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# General
bindkey -M viins "$keys[Insert]" overwrite-mode
bindkey -M viins "$keys[Delete]" delete-char
bindkey -M viins "$keys[Backspace]" backward-delete-char
bindkey -M viins "$keys[Left]" backward-char
bindkey -M viins "$keys[Right]" forward-char
bindkey -M viins "$keys[Control]L" clear-screen
bindkey -M viins "$keys[Shift-Tab]" reverse-menu-complete

# Typing - fuzzy find history
bindkey -M viins "$keys[Up]" up-line-or-beginning-search
bindkey -M viins "$keys[Down]" down-line-or-beginning-search

bindkey -M emacs "$keys[Up]" up-line-or-beginning-search
bindkey -M emacs "$keys[Down]" down-line-or-beginning-search

# Type '!! ' - get previous command
bindkey ' ' magic-space

## Keybindings vim normal mode

# Edit command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line

# General
bindkey -M vicmd "$keys[Delete]" delete-char
bindkey -M vicmd "$keys[Control]E" edit-command-line
bindkey -M vicmd "$keys[Control]R" redo

# Toggle comment at the start of the line.
bindkey -M vicmd "\e/" vi-pound-insert



bindkey -M vicmd "?" history-incremental-pattern-search-backward
bindkey -M vicmd "/" history-incremental-pattern-search-forward

# Set Layout
KEYTIMEOUT=1 	# Faster vim mode switching
if [[ -z $VIMRUNTIME ]]; then
    bindkey -v  	# Use vim layout 
else
    bindkey -e
fi

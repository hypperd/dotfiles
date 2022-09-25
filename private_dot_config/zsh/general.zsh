# General Options
setopt COMBINING_CHARS      # Combine zero-length punctuation characters (accents) with the base character.
setopt INTERACTIVE_COMMENTS # Enable comments in interactive shell.
setopt RC_QUOTES            # Allow 'Henry''s Garage' instead of 'Henry'\''s Garage'.
unsetopt MAIL_WARNING       # Don't print a warning message if a mail file has been accessed.

# Jobs Options
setopt LONG_LIST_JOBS     # List jobs in the long format by default.
setopt AUTO_RESUME        # Attempt to resume existing job before creating a new process.
setopt NOTIFY             # Report status of background jobs immediately.

# Magic functions
autoload -Uz bracketed-paste-magic bracketed-paste-url-magic

zle -N bracketed-paste bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-magic

# History Options
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing non-existent history.

# The file to save the history in.
HISTFILE="$HOME/.zsh_history"

#The maximum number of events stored
HISTSIZE=50000 # -> in memory
SAVEHIST=50000 # -> in filesystem

# Default ls color theme.
(( $+commands[dircolors] )) && eval "$(dircolors -b)"

# set terminal title
if [[ "$TERM" != (dumb|linux|*bsd*|eterm*) ]]; then
    # Based in kitty shell integration
    functions[_ksi_precmd]+="builtin print -rnu $_ksi_fd \$'\\e]2;'\"\${(%):-%n@%m:%(3~|…/%2~|%~)}\"\$'\\a'"
    functions[_ksi_preexec]+="builtin print -rnu $_ksi_fd \$'\\e]2;'\"\${(V)1}\"\$'\\a'"
fi
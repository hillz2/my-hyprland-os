# Plugins (Installed in Home for Silverblue compatibility)
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- History Configuration ---
# it makes zsh-autosuggestions remember a lot more commands
HISTFILE="$HOME/.zsh_history"    # Where to save the history
HISTSIZE=100000                  # Max commands to keep in memory
SAVEHIST=100000                  # Max commands to save to the file

# Options for better history management
setopt EXTENDED_HISTORY          # Save timestamp and duration
setopt INC_APPEND_HISTORY        # Write to file immediately (don't wait for shell exit)
setopt HIST_IGNORE_DUPS          # Don't record a command if it repeats the previous one
setopt HIST_IGNORE_SPACE         # Ignore commands starting with a space
setopt HIST_EXPIRE_DUPS_FIRST    # Delete duplicates first when cache is full
setopt SHARE_HISTORY             # Share history across terminals (optional)

# Alias
alias op='ssh root@192.168.1.1 -v'
alias work='ssh root@100.116.0.112 -v'

# Enable colors
autoload -U colors && colors

# Format: [Green User]@[Blue Host] [Yellow Dir] [Red Arrow]
PROMPT="%B%{$fg[green]%}%n%{$reset_color%}@%{$fg[blue]%}%m %{$fg_bold[yellow]%}%~ %{$fg_bold[red]%}➜ %{$reset_color%}"

# Detect Distrobox/Toolbox and modify prompt
if [ -n "$CONTAINER_ID" ]; then
  # Defines the container name in Yellow (Change color if you want)
  BOX_NAME="%F{yellow}[$CONTAINER_ID]%f"

  # Prepend it to your existing prompt
  PROMPT="$BOX_NAME $PROMPT"
fi

# Define path
export PATH="$HOME/.local/bin:$PATH"

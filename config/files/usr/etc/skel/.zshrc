# Plugins (Installed in Home for Silverblue compatibility)
source ~/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

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

# aliasman

**aliasman** is a terminal alias manager built for Kali CTF setups. It organizes your `.zshrc` aliases into clean sections, displays them with smart syntax highlighting, supports truncation, and allows adding, editing, removing, and searching aliases directly from the CLI. It is generally specific to my Kali setup.

## Features
- Categorizes aliases based on ```# CTF Aliases''' header and an '''Other Aliases'''
- Truncated or full command preview
- Syntax-highlighted output using `batcat` (if installed)
- Add, edit, remove, or search aliases from terminal
- Reload `.zshrc` instantly

## Installation
```sudo apt install bat``` <- Optional

```curl -L https://raw.githubusercontent.com/Tecttano/kali-utils/main/aliasman/aliasman -o aliasman```

```chmod +x aliasman```

```echo "alias aliasman='$PWD/aliasman'" >> ~/.zshrc``` <- Optional if you want to alias to your zsh

```source ~/.zshrc```

## Usage 
```aliasman           # Default view (truncated)```

```aliasman --full    # Show full commands, uses batcat if available```

```aliasman --length 50     # Truncate to 50 characters```

```aliasman --add name      # Add a new alias```

```aliasman --edit name     # Edit an existing alias```

```aliasman --rm name       # Remove an alias```

```aliasman --search word   # Search aliases```

```aliasman --reload        # Reloads your .zshrc```

## Example Output
```
Alias Overview:

# CTF Aliases
scripts      → cd ~/CTF/scripts
update       → sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y

# Other Aliases
 ll           → ls -l
 
 l            → ls -CF```
```
## Notes
- Aliases under # CTF Aliases in .zshrc are grouped separately.

- Requires ZSH and a .zshrc with # CTF Aliases comment line.

- Best experienced with batcat installed for proper syntax highlighting.

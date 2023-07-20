# dotfiles

My dotfiles. WIP

## Installation

- Close the repository.

```bash
git clone https://github.com/ntrupin/dotfiles.git
```

- Configure cross-platform utilities:

<details><summary>List of cross-platform utilities</summary>

- Git
    Speaks for itself.
- Nano
    The perfect minimal text editor. Now with syntax highlighting!
- Neofetch
    Pretty-printed system information.
- Vim
    *The* text editor.

</details>

```bash
./dotfiles/dots-util.sh general
```

- Configure Alpine APK:

```bash
./dotfiles/dots-util.sh alpine
```

- Configure macOS-specific utilities:

<details><summary>List of macOS-specific utilities</summary>

- Homebrew
    Installs formulae from [./homebrew/Brewfile](https://github.com/ntrupin/dotfiles/blob/main/homebrew/Brewfile)

</details>

```bash
./dotfiles/dots-util.sh macos
```
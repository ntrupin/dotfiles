# Removes all installed Homebrew packages.

brew remove --force $(brew list --formula)
brew remove --cask --force $(brew list)

brew cleanup
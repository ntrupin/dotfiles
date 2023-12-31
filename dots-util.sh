#!/bin/bash

# thanks https://dotfiles.github.io/

DOTS=(git nano neofetch neovim vim)
DOTS_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
DOTS_BAK_DIR=~/dotfiles.bak

######## COLORS ########

GREEN="\x1b[1;32m"
YELLOW="\x1b[1;33m"
RED='\x1b[1;31m'
NOCOL="\x1b[0m"

######## ECHO HELPERS ########

# $1 = color, $2 = message
echo_color() {
    echo -e "${1}${2}${NOCOL}"
}

# regular messages 
echo_message() {
    echo_color $GREEN "[Message] $1"
}

# warning
echo_warning() {
    echo_color $YELLOW "[Warning] $1"
}

# error
echo_error() {
    echo_color $RED "[Error] $1"
}

######## UTILITY FUNCTIONS ########

# $1 = message
prompt() {
    echo_warning "Do you wish to proceed with configuring ${1}?"
    read -p "[y/N] " -n1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then 
        true
    else
        echo_message "Skipping ${1}..."
        false
    fi
}

######## INSTALL FUNCTIONS ########

backup_link() {
    # check if file exists
    if [[ -f $2 ]]; then
        # backup
        echo_message "Moving existing $2 to ${DOTS_BAK_DIR}..."
        mkdir -p ${DOTS_BAK_DIR}
        mv $2 ${DOTS_BAK_DIR}/
    fi

    # link
    echo_message "Symlinking $1 at $2..."
    ln -s $1 $2
}

install-git() {
    if prompt "Git"; then
        for file in ${DOTS_DIR}/git/*; do
            backup_link $file ~/.$(basename $file)
        done
    fi
}

install-nano() {
    if prompt "Nano"; then
        backup_link ${DOTS_DIR}/nano/nanorc ~/.nanorc

        # syntax highlighters
        echo_message "Installing Nano syntax highlighters..."
        wget https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh -O- | sh
    fi
}

install-neofetch() {
    if prompt "Neofetch"; then
        mkdir -p ~/.config/neofetch/
        backup_link ${DOTS_DIR}/neofetch/config.conf ~/.config/neofetch/config.conf
    fi
}

install-vim() {
    if prompt "Vim"; then
        backup_link ${DOTS_DIR}/vim/vimrc ~/.vimrc
    fi
}

install-neovim() {
    if prompt "Neovim"; then

        # backup
        echo_message "Moving existing ~/.config/nvim to ${DOTS_BAK_DIR}..."
        mkdir -p ${DOTS_BAK_DIR}
        mv ~/.config/nvim ${DOTS_BAK_DIR}/.config/

        mkdir -p ~/.config/nvim
        cd ~/.config/nvim

        echo_message "Cloning ntrupin/noahvim..."
        git clone --depth 1 https://github.com/ntrupin/noahvim.git .

        cd - > /dev/null 2>&1
    fi
}

install() {
    echo_message "Starting cross-platform configuration..."

    for item in "${DOTS[@]}"; do
        $"install-$item"
    done

    echo_message "Successfully configured cross-platform utilities."
}

install-only() {
    # make sure we received an argument
    if [[ ! $1 ]]; then
        echo_error "No argument provided."
        exit 1
    fi

    # make sure dotfile exits
    if [[ ! " ${DOTS[@]} " =~ " $1 " ]]; then
        echo_error "Dotfile '$1' does not exist."
        exit 1
    fi

    $"install-$1"

    echo_message "Successfully ran install-$1."
}

config-alpine() {
    echo_message "Starting Alpine configuration..."

    # alpine doesn't support OSTYPE
    # validate operating system
    if [[ $(uname) != "Linux" ]]; then
        echo_error "Expected uname == 'Linux', got '$(uname)' instead"
        exit 1
    fi

    # install base repos
    echo_warning "APK Repositories: 
    Base alpine packages will be installed and existing packages will be updated."
    if prompt "APK base packages"; then
        echo_message "Updating packages..."
        apk update
        echo_message "Installing alpine-base..."
        apk add alpine-base
        echo_message "Installing alpine-sdk..."
        apk add alpine-sdk
        echo_message "Upgrading all packages..."
        apk upgrade
    fi

    echo_message "Successfully configured Alpine."
}

config-macos() {
    echo_message "Starting macOS configuration..."

    # validate operating system
    if [[ "${OSTYPE}" != "darwin"* ]]; then
        echo_error "Expected OSTYPE == 'darwin', got '${OSTYPE}' instead"
        exit 1
    fi

    # Homebrew and packages
    echo_warning "Homebrew:
    Homebrew will be installed from 'https://brew.sh'."
    if prompt "Homebrew"; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        echo_warning "Homebrew:
    Formulae will be installed from homebrew/Brewfile. Existing formulae will be uninstalled."
        if prompt "Homebrew packages"; then
            ${DOTS_DIR}/macos/utils/brewrma.sh
            brew bundle --file ${DOTS_DIR}/homebrew/Brewfile
        fi

    fi

    echo_message "Successfully configured macOS."
}

# thanks https://github.com/theopn/dotfiles
install-font() {
    # make sure we received an argument
    if [[ ! $1 ]]; then
        echo_error "No font provided."
        exit 1
    fi

    # validate from nerd fonts
    if [[ "${1}" != "https://github.com/ryanoasis/nerd-fonts/"* ]]; then
        echo_warning "Your provided font doesn't appear to be from Nerd Fonts and may not work with this install script."
        if !proceed "Non-Nerd Font installation"; then
            echo_message "Skipping font installation..."
            exit 1
        fi 
    fi

    echo_message "Insalling font from $1..."
    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts
    wget -O tmp.zip $1
    unzip tmp.zip
    rm tmp.zip

    echo_message "Adding font to cache..."
    fc-cache -fv

    cd - > /dev/null 2>&1

    echo_message "Successfully installed font from $1."
}

######## MAIN, LIST, AND HELP ########

list() {
    echo "
                   Noah's Dotfiles
=====================================================

All Dotfiles : ./dots-util.sh install
One Dotfile  : ./dots-util.sh install-only <name>
-----------------------------------------------------

available dotfiles:"
    for item in "${DOTS[@]}"; do
        echo "    ${item}"
    done
}

help() {
    echo -e "
                   Noah's Dotfiles
=====================================================

Manage dotfiles, install software, and fetch useful 
scripts.

Shameless plug - https://ntrupin.com

Usage: ./dots-util.sh <arg>
-----------------------------------------------------

available arguments:
    install            : Install cross-platform dots.
    install-only <arg> : Install <arg>'s dotfiles.
    list               : List available dotfiles.
    macos              : Configure macOS.
    alpine             : Configure Alpine.
    install-font <url> : Install font from <url>.
                         Designed for use with Nerd
                         Fonts.
    " 
}

main() {
    case $1 in
        "install") install ;;
        "install-only") install-only $2 ;;
        "list") list ;;
        "macos") config-macos ;;
        "alpine") config-alpine ;;
        "install-font") install-font $2 ;;
        "help") help ;;
        *) 
            echo_warning "Invalid option" 
            help ;;
    esac

    exit 0
}

main $@

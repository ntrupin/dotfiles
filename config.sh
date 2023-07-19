#!/bin/bash

# Inspired by https://github.com/holman/dotfiles, https://github.com/theopn/dotfiles, 
# and advice from https://dotfiles.github.io/

DOTS_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
DOTS_BAK_DIR=~/dotfiles.bak

######## COLORS ########

GREEN="\x1b[1;32m"
YELLOW="\x1b[1;33m"
RED='\x1b[1;31m'
NOCOL="\x1b[0m"

######## ECHO HELPERS ########

# $1 = color, $2 = message
function echo_color() {
    echo -e "${1}${2}${NOCOL}"
}

# regular messages 
function echo_message() {
    echo_color $GREEN "[Message] $1"
}

# warning
function echo_warning() {
    echo_color $YELLOW "[Warning] $1"
}

# error
function echo_error() {
    echo_color $RED "[Error] $1"
}

######## UTILITY FUNCTIONS ########

# $1 = message
function prompt() {
    echo_warning "Do you wish to proceed with configuring ${1}?"
    read -p "[y/N] " -n1 -r 
    if [[ $REPLY =~ ^[Yy]$ ]]; then 
        true
    else
        echo_message "Skipping ${1}..."
        false
    fi
}

######## INSTALL FUNCTIONS ########

function backup_link() {
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

function general() {
    echo_message "Starting cross-platform configuration..."

    if prompt "Git"; then
        for file in ${DOTS_DIR}/git/*; do
            backup_link $file ~/.$(basename $file)
        done
    fi

    if prompt "Neofetch"; then
        mkdir -p ~/.config/neofetch/
        backup_link ${DOTS_DIR}/neofetch/config.conf ~/.config/neofetch/config.conf
    fi

    if prompt "Vim"; then
        mkdir -p ~/.config/neofetch/
        backup_link ${DOTS_DIR}/vim/vimrc ~/.vimrc
    fi

    echo_message "Successfully configured cross-platform utilities."
}

function alpine() {
    echo_message "Launching alpine install script..."
    $(DOTS_DIR)/deprecated/alpine/config.sh
}

function macos() {
    echo_message "Starting macOS configuration..."

    # validate operating system
    if [[ "${OSTYPE}" != "darwin"* ]]; then
        echo_error "Expected OSTYPE == 'darwin', got '${OSTYPE}' instead"
        exit 1
    fi

    # Homebrew and packages
    echo_warning "Homebrew:
    Homebrew will be installed from 'https://brew.sh'
    Proceed?"
    if prompt "Homebrew"; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        echo_warning "Homebrew:
    Packages will be installed from homebrew/Brewfile
    Existing packages will be uninstalled"
        if prompt "Homebrew packages"; then
            ${DOTS_DIR}/macos/utils/brewrma.sh
            brew bundle --file ${DOTS_DIR}/homebrew/Brewfile
        fi

    fi

    echo_message "Successfully configured macOS."
}

######## MAIN AND HELP ########

function help() {
    echo -e "
                    Noah's Dotfiles
    ===============================================

    Manage dotfiles, install software, and fetch 
    useful scripts.

    Usage: ./config.sh <arg>
    -----------------------------------------------

    available arguments:
        general     : Setup cross-platform dots
        macos       : Setup macOS
        alpine      : Setup Alpine (deprecated)
    " 
}

function main() {
    case $1 in
        "general") general ;;
        "macos") macos ;;
        "alpine") alpine ;;
        "help") help ;;
        *) 
            echo_warning "Invalid option" 
            help ;;
    esac

    exit 0
}

main $@
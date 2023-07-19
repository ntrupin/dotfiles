#!/bin/ash

base() {
    wget -qO- http://dl-cdn.alpinelinux.org/alpine/v3.12/main/x86/apk-tools-static-2.10.5-r1.apk | tar -xz sbin/apk.static && ./sbin/apk.static add apk-tools && rm sbin/apk.static && rmdir sbin 2> /dev/null
}

shell() {
    rfile="/etc/apk/repositories"
    echo "overwriting '$rfile' with edge repos..."
    IFS='' read -r -d '' repos << EOF
http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/testing
EOF
    echo "$repos" > $rfile

    echo "installing alpine-sdk..."
    apk add alpine-sdk
    
}

editor() {
    IFS='' read -r -d '' desc << EOF

    Select a text editor to install:
        1) nano
        2) neovim
        3) none
EOF
    echo "$desc"
    echo -n "editor (default 1): "
    read choice
    if [ -z "$choice" ]
    then
        choice=1
    fi
    exp=$(expr "$choice" : "[1-3]")
    if [[ "$exp" -ne "1" ]]
    then
        echo "error: invalid input"
        editor
        return 0
    fi
    case $choice in
        1)
            echo "installing nano..."
            apk add nano

            echo "installing syntax highlighting..."
            curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh

            nfile="$HOME/.nanorc"
            echo "setting nano preferences..."
            IFS='' read -r -d '' prefs << EOF

set constantshow
set tabsize 4
set tabstospaces
EOF
            echo "$prefs" >> $nfile
            ;;
        2)
            echo "installing neovim..."
            apk add neovim
            ;;
        *) break ;;
    esac
}

base
shell
editor

echo "all done! restart your shell to see changes"

exit 0
#!/usr/bin/env bash
set -euofab pipefail

unset PATH
export PATH=/bin:/usr/bin:/usr/local/bin:/opt/homebrew/bin:/sbin:/usr/sbin:/usr/local/sbin

CWD=$(dirname $(realpath $0))

if [[ ! -d $HOME/.oh-my-zsh ]]; then
    echo "sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
    echo "Run this command to install Oh My Zsh !!"
    exit 0
fi

if [[ $(python3 -c "import distro;print(str(distro.name()).lower())") == "darwin" ]]; then
    for FILE in $(ls Preferences/); do
        if [[ -f ~/Library/Preferences/$FILE ]]; then
            echo "Deleting ~/Library/Preferences/$FILE ..."
            rm -rf ~/Library/Preferences/$FILE
        fi
        cp -p Preferences/$FILE ~/Library/Preferences/$FILE
    done
fi

binaryFiles=(.func_profile .gitconfig .gitignore_global .vimrc .zshrc)
for s in "${binaryFiles[@]}"; do
    # delete existing
    if [[ -f "$HOME/$s" || -L "$HOME/$s" || -e "$HOME/$s" ]]; then
        rm -rf "$HOME/$s"
    fi

    # simulink
    if [[ ! -f "$CWD/$s" ]]; then
        echo "File $CWD/$s not found, skipped simulink ..."
        continue
    fi
    ln -fs "$CWD/$s" "$HOME/$s"
done

binaryDirs=(.fzf .hammerspoon .krew)
for s in "${binaryDirs[@]}"; do
    # delete existing
    if [[ -d "$HOME/$s" || -L "$HOME/$s" || -e "$HOME/$s" ]]; then
        rm -rf $HOME/$s
    fi

    # simulink
    if [[ ! -d "$CWD/$s" ]]; then
        echo "Directory $CWD/$s not found, skipped simulink ..."
        continue
    fi
    # echo "ln -fs $CWD/$s $HOME/"
    cp -pr $CWD/$s $HOME/
done

plugins=(
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-syntax-highlighting
    zsh-users/zsh-completions
    zsh-users/zsh-history-substring-search
    bobthecow/git-flow-completion
)
for s in "${plugins[@]}"; do
    name=$(echo $s | cut -d "/" -f2)
    if [[ -d ~/.oh-my-zsh/custom/plugins/$name ]]; then
        rm -rf ~/.oh-my-zsh/custom/plugins/$name
    fi
    git clone --quiet https://github.com/$s ~/.oh-my-zsh/custom/plugins/$name
done

# install distro
installDistro=true
for pack in $(python3 -m pip freeze); do
    pack=$(echo $pack | cut -d "=" -f1)
    if [[ $pack == 'distro' ]]; then
        installDistro=false
        break
    fi
done
if [[ $installDistro == true ]]; then
    python3 -m pip install distro
fi

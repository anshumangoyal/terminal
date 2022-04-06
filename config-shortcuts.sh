#!/usr/bin/env bash
set -euofab pipefail

unset PATH
export PATH=/bin:/usr/bin:/usr/local/bin:/opt/homebrew/bin:/sbin:/usr/sbin:/usr/local/sbin

CWD=$(dirname $(realpath $0))

if [[ ! -d $HOME/.oh-my-zsh ]]; then
    echo "sh -c \$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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
    ln -fs $CWD/$s $HOME/
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

# kubectx & kubens
version=$(curl -s https://api.github.com/repos/ahmetb/kubectx/releases/latest | jq --raw-output .tag_name)
if [[ -f ~/.krew/bin/kubectl-ns && "v$(kubectl ns --version)" == "$version" ]]; then
    echo "kubectl-ns is on latest version :)"
else
    curl -fSsL "https://github.com/ahmetb/kubectx/releases/download/$version/kubens_${version}_$(uname -s)_$(uname -m).tar.gz" | tar -C ~/.krew/bin/ -xz;
    mv ~/.krew/bin/kubens ~/.krew/bin/kubectl-ns
fi

if [[ -f ~/.krew/bin/kubectx && "v$(kubectx --version)" == "$version" ]]; then
    echo "kubectx is on latest version :)"
else
    curl -fSsL "https://github.com/ahmetb/kubectx/releases/download/$version/kubectx_${version}_$(uname -s)_$(uname -m).tar.gz" | tar -C ~/.krew/bin/ -xz;
fi

# kubectl-images
if [[ $(uname -s) == 'Linux' ]]; then
    platform=$(uname -r | grep -o '[^-]*$')
elif [[ $(uname -s) == 'Darwin' ]]; then
    platform=$(uname -a | grep -o '[^ ]*$')
fi
version=$(curl -s https://api.github.com/repos/chenjiandongx/kubectl-images/releases/latest | jq --raw-output .tag_name)
curl -fSsL "https://github.com/chenjiandongx/kubectl-images/releases/download/$version/kubectl-images_$(uname -s)_$platform.tar.gz" | tar -C ~/.krew/bin/ -xz;
chmod +x ~/.krew/bin/kubectl-images
kubectl-images --version

# kubectl-tail
if [[ $(uname -s) == 'Linux' ]]; then
    curl -fSsL "https://github.com/boz/kail/releases/download/v0.15.0/kail_0.15.0_linux_amd64.tar.gz" | tar -C ~/.krew/bin/ -xz;
elif [[ $(uname -s) == 'Darwin' ]]; then
    curl -fSsL "https://github.com/boz/kail/releases/download/v0.15.0/kail_0.15.0_darwin_amd64.tar.gz" | tar -C ~/.krew/bin/ -xz;
fi
mv ~/.krew/bin/kail ~/.krew/bin/kubectl-tail
chmod +x ~/.krew/bin/kubectl-tail
rm -rf ~/.krew/bin/*.txt ~/.krew/bin/*.md


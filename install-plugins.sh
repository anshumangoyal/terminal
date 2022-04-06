#!/usr/bin/env bash
set -euofab pipefail

# ******** kubectx & kubens ********
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

# ******** kubectl-images ********
version=$(curl -s https://api.github.com/repos/chenjiandongx/kubectl-images/releases/latest | jq --raw-output .tag_name)
if [[ -f ~/.krew/bin/kubectl-images && "v$(kubectl-images --version | rev | cut -d " " -f1 | rev)" == $version ]]; then
    echo "kubectl-images is on latest version :)"
else
    if [[ $(uname -s) == 'Linux' ]]; then
        platform=$(uname -r | grep -o '[^-]*$')
    elif [[ $(uname -s) == 'Darwin' ]]; then
        platform=$(uname -a | grep -o '[^ ]*$')
    fi
    curl -fSsL "https://github.com/chenjiandongx/kubectl-images/releases/download/$version/kubectl-images_$(uname -s)_$platform.tar.gz" | tar -C ~/.krew/bin/ -xz;
    chmod +x ~/.krew/bin/kubectl-images
    kubectl-images --version
fi

# ******** kubectl-tail ********
if [[ $(uname -s) == 'Linux' ]]; then
    curl -fSsL "https://github.com/boz/kail/releases/download/v0.15.0/kail_0.15.0_linux_amd64.tar.gz" | tar -C ~/.krew/bin/ -xz;
elif [[ $(uname -s) == 'Darwin' ]]; then
    curl -fSsL "https://github.com/boz/kail/releases/download/v0.15.0/kail_0.15.0_darwin_amd64.tar.gz" | tar -C ~/.krew/bin/ -xz;
fi
mv ~/.krew/bin/kail ~/.krew/bin/kubectl-tail
chmod +x ~/.krew/bin/kubectl-tail
rm -rf ~/.krew/bin/*.txt ~/.krew/bin/*.md

# ******* fzf *******
version=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | jq --raw-output .tag_name)
if [[ -f ~/.fzf/fzf && $(fzf --version | cut -d " " -f1) == $version ]]; then
    echo "fzf is on latest version :)"
else
    if [[ $(uname -s) == 'Linux' ]]; then
        platform=$(uname -r | grep -o '[^-]*$')
        curl -fSsL "https://github.com/junegunn/fzf/releases/download/${version}/fzf-${version}-$(uname -s)_$platform.tar.gz" | tar -C ~/.fzf/ -xz;
    elif [[ $(uname -s) == 'Darwin' ]]; then
        curl -fSsL "https://github.com/junegunn/fzf/releases/download/${version}/fzf-${version}-$(uname -s)_$(uname -m).zip" -o /tmp/fzf.zip
        unzip -o /tmp/fzf.zip -d ~/.fzf/
    fi
fi

rm -rf ~/.krew/bin/LICENSE* ~/.krew/bin/README*
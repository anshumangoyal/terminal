#!/usr/bin/env bash
set -euofab pipefail

# ******** kubectx & kubens ********
echo "installing kubectx & kubens ..."
version=$(curl -s https://api.github.com/repos/ahmetb/kubectx/releases/latest | jq --raw-output .tag_name)
curl -fSsL "https://github.com/ahmetb/kubectx/releases/download/$version/kubens_${version}_$(uname -s)_$(uname -m).tar.gz" | tar -C ~/.krew/bin/ -xz;
mv ~/.krew/bin/kubens ~/.krew/bin/kubectl-ns
curl -fSsL "https://github.com/ahmetb/kubectx/releases/download/$version/kubectx_${version}_$(uname -s)_$(uname -m).tar.gz" | tar -C ~/.krew/bin/ -xz;

# ******** kubectl-images ********
echo "installing kubectl-images ..."
version=$(curl -s https://api.github.com/repos/chenjiandongx/kubectl-images/releases/latest | jq --raw-output .tag_name)
if [[ $(uname -s) == 'Linux' ]]; then
    curl -fSsL "https://github.com/chenjiandongx/kubectl-images/releases/download/$version/kubectl-images_linux_amd64.tar.gz" | tar -C ~/.krew/bin/ -xz;
elif [[ $(uname -s) == 'Darwin' ]]; then
    platform=$(uname -a | grep -o '[^ ]*$')
    curl -fSsL "https://github.com/chenjiandongx/kubectl-images/releases/download/$version/kubectl-images_$(uname -s)_$platform.tar.gz" | tar -C ~/.krew/bin/ -xz;
fi
chmod +x ~/.krew/bin/kubectl-images
kubectl-images --version

# ******** kubectl-tail ********
echo "installing kubectl-tail ..."
if [[ $(uname -s) == 'Linux' ]]; then
    curl -fSsL "https://github.com/boz/kail/releases/download/v0.15.0/kail_0.15.0_linux_amd64.tar.gz" | tar -C ~/.krew/bin/ -xz;
elif [[ $(uname -s) == 'Darwin' ]]; then
    curl -fSsL "https://github.com/boz/kail/releases/download/v0.15.0/kail_0.15.0_darwin_amd64.tar.gz" | tar -C ~/.krew/bin/ -xz;
fi
mv ~/.krew/bin/kail ~/.krew/bin/kubectl-tail
chmod +x ~/.krew/bin/kubectl-tail
rm -rf ~/.krew/bin/*.txt ~/.krew/bin/*.md

# ******* fzf *******
echo "installing fzf ..."
version=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | jq --raw-output .tag_name)
if [[ $(uname -s) == 'Linux' ]]; then
    curl -fSsL "https://github.com/junegunn/fzf/releases/download/${version}/fzf-${version}-linux_amd64.tar.gz" | tar -C ~/.fzf/ -xz;
elif [[ $(uname -s) == 'Darwin' ]]; then
    curl -fSsL "https://github.com/junegunn/fzf/releases/download/${version}/fzf-${version}-$(uname -s)_$(uname -m).zip" -o /tmp/fzf.zip
    unzip -o /tmp/fzf.zip -d ~/.fzf/
fi

# ***** kubectl ****
echo "installing kubectl ..."
version=$(curl -fSsL https://dl.k8s.io/release/stable.txt)
curl -fSsL "https://dl.k8s.io/release/$version/bin/linux/amd64/kubectl" -o /usr/bin/kubectl
chmod +x /usr/bin/kubectl

# ***** Deleting Temp Files *****
rm -rf ~/.krew/bin/LICENSE* ~/.krew/bin/README*

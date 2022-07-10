#!/bin/bash
set -eo pipefail
IFS=$'\n\t'

if [[ $# -ne 1 ]] && [[ ! -f $1 ]]; then
    echo "requirements.txt file is missing !!"
    exit 0
fi

# ask for sudo password in beginning, so that it is not asked in between.
sudo -v

# Check if brew is installed and installing it
if ! (command -v brew >/dev/null 2>&1); then
    echo "→ Brew is not installed, installing it now ..."
    yes '' | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Tapping Brew Repos
tapsToInstall=(
    buo/cask-upgrade
    homebrew/cask-versions
    homebrew/core
    homebrew/cask
    microsoft/mssql-release
)
for t in "${tapsToInstall[@]}"; do
    toTap=true
    for tap in $(brew tap); do
        if [[ $tap = $t ]]; then
            toTap=false
        fi
    done
    if [[ $toTap = true ]]; then
        echo -n "→ Tapping $t ..."
        if [[ $t == 'microsoft/mssql-release' ]]; then
            if (brew tap --quiet $t https://github.com/Microsoft/homebrew-mssql-release >/tmp/tap.log 2>&1); then
                echo " done"
            else
                echo " failed !! $(cat /tmp/tap.log)"
            fi
        else
            if (brew tap --quiet $t >/tmp/tap.log 2>&1); then
                echo " done"
            else
                echo " failed !! $(cat /tmp/tap.log)"
            fi
        fi
    else
        echo "→ Tap $t already tapped."
    fi
done
unset toTap
unset t

# Install Brew Formulas
function brew-formula() {(
    set -eo pipefail
    local package=$1
    local toInstall=true
    for installed in $(brew list --formula -1); do
        if [[ $installed = $package ]]; then
            echo "→ Formula $package is already installed."
            toInstall=false
        fi
    done
    if [[ $toInstall == true ]]; then
        echo -n "→ Installing Formula $package ..."
        if (HOMEBREW_NO_ENV_FILTERING=1 ACCEPT_EULA=Y brew install $package >/tmp/$package.log 2>&1); then
            echo " done"
        else
            echo " failed $(cat /tmp/$package.log)"
        fi
    fi
)}
formulaToInstall=(
    adns allure autoconf automake awk bash bash-completion bc bdw-gc berkeley-db bfg brew-cask-completion brotli
    c-ares carthage coreutils curl dive docker-completion dos2unix fabric-completion fzf gcc gdbm
    gettext git gmp gnu-sed gnupg gnutls go grep groovy guile helm icu4c isl jansson jemalloc jpeg jq kompose krb5
    krew kubectx kubernetes-cli ldns libassuan libcbor libev libevent libffi libfido2 libgcrypt libgpg-error
    libidn2 libksba libmetalink libmpc libssh2 libtasn1 libtool libunistring libusb libuv libyaml lua lz4 lzo m4
    mpdecimal mpfr ncurses nettle nghttp2 nmap node npth oniguruma openjdk openldap openssh openssl@3 openvpn
    p11-kit pcre pcre2 perl pinentry pip-completion pkcs11-helper pkg-config postgresql python@3.8 python@3.10
    readline rename rtmpdump ruby shyaml speedtest-cli sqlite tcl-tk telnet tree unbound vim watch wget xz yarn
    yarn-completion yq zlib zsh-completions zstd colima zsh-syntax-highlighting zplug
)
for p in "${formulaToInstall[@]}"; do
    brew-formula $p
done
unset p

brew cu --all --cleanup --yes
brew update
brew upgrade --display-times
brew cleanup --prune=0

# Check for Python3.8 Path
if [[ ! -d "$(brew --prefix)/python@3.8/bin" ]]; then
    echo "ERROR → python3.8 path $(brew --prefix)/python@3.8/bin not found, stopping"
    exit 0
fi

# Local Variables
OPEN_SSL=$(find -L $(brew --prefix)/opt -name openssl*.* -type d -print -quit)
WORKSPACE=$(pwd -P)

# setup Paths
addPaths=(
    $(brew --prefix)/opt/gnu-sed/libexec/gnubin  # gnu sed
    $(brew --prefix)/opt/grep/libexec/gnubin  # gnu grep
    $(brew --prefix)/opt/awk/bin  # gnu awk
    $(brew --prefix)/opt/curl/bin
    /bin /usr/bin /usr/local/bin
    /sbin /usr/sbin /usr/local/sbin
    $(brew --prefix)/opt/python@3.8/bin
    $(brew --prefix)/opt/sqlite/bin
    $OPEN_SSL
)
for s in "${addPaths[@]}"; do
    if [[ -d $s ]]; then
        if [[ -z ${PATH-} ]]; then
            export PATH="$s"
        else
            export PATH="$PATH:$s"
        fi
    else
        echo "WARNING: $s is not a directory, skipped from \$PATH !!"
    fi
done
export PATH=$(echo $PATH | tr ':' '\n' | uniq | tr '\n' ':')

# Setting up .zshrc
if [[ ! -f $HOME/.zshrc ]]; then
    touch $HOME/.zshrc
    if ! (ls -l >/dev/null 2>&1); then
        sed --in-place='' --follow-symlinks "/^export PATH*/d" $HOME/.zshrc
    fi
fi
echo "export PATH=$PATH" >>$HOME/.zshrc

export PYCURL_SSL_LIBRARY=openssl
if (deactivate >/dev/null 2>&1); then
    echo "Deactivated virtual environment"
fi

echo "→ Updating Base Packages with python3.8"
python3.8 -m pip install --quiet --upgrade pip
python3.8 -m pip install --quiet --upgrade setuptools virtualenv wheel twine

echo "→ Making Virtual Environment: $(pwd -P)/venv"
if [[ -d venv ]]; then
    rm -rf venv
fi
python3.8 -m venv venv
source venv/bin/activate
python3.8 -m pip install --quiet --upgrade pip
python3.8 -m pip install --quiet --upgrade setuptools virtualenv wheel twine

echo "→ Installing Pip Packages"
python3.8 -m pip install --requirement $1

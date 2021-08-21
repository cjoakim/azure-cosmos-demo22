#!/usr/bin/env bash

# Installs the requirements for pyenv.  Run as root, as follows:
# $ sudo ./pyenv_install_part1.sh
#
# see https://www.liquidweb.com/kb/how-to-install-pyenv-on-ubuntu-18-04/
# Chris Joakim, Microsoft, July 2021

apt update -y

apt install -y make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
    libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl

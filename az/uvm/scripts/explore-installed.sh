#!/bin/bash

# Bash script to explore the installed software and its versions.
# Chris Joakim, Microsoft, July 2021

echo '=== git:'
which git
git --version

echo '=== python and pip:'
which python
python --version

which pip
pip --version

echo '=== python3 and pip3:'
which python3
python3 --version

which pip3
pip3 --version

echo '=== dotnet:'
which dotnet
dotnet --version

echo '=== nodejs:'
which nodejs
which npm
nodejs --version
npm --version

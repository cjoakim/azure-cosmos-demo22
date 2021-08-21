#!/bin/bash

# Bash script to install the software necessary for the migration process.
# Chris Joakim, Microsoft, July 2021

echo '=== install the az cli'
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

echo '=== apt install python3-pip'
sudo apt update
sudo apt install python3-pip --assume-yes
pip3 --version
pip3 --help

echo '=== apt install python3-venv'
sudo apt update
sudo apt-get install python3-dev python3-venv --assume-yes
sudo apt-get install libpq-dev 
sudo apt-get install unixodbc-dev --assume-yes

echo '=== apt install jq'
sudo apt update
sudo apt install jq --assume-yes
jq --version

# https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
# https://www.liquidweb.com/kb/how-to-install-mongodb-on-ubuntu-18-04/

echo '=== install mongodb community edition'
wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
sudo apt-get install gnupg
wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
cat /etc/apt/sources.list.d/mongodb-org-5.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
which mongo
mongo --version
which mongoimport
mongoimport --version

echo '=== install dotnet 5'
sudo snap remove dotnet-sdk
sudo snap install dotnet-sdk --classic --channel=5.0
sudo dotnet --info
sudo ln -s /snap/dotnet-sdk/current/dotnet /usr/local/bin/dotnet
which dotnet  #  -> /usr/local/bin/dotnet
#export DOTNET_ROOT=/snap/dotnet-sdk/current

# dotnet-sdk (5.0/stable) 5.0.400 from Microsoft .NET Core (dotnetcore✓) installed
# See https://docs.microsoft.com/en-us/dotnet/core/install/linux-snap
# See https://ubuntuforums.org/showthread.php?t=2465790&amp%3Bgoto=newpost

echo '=== install docker'
sudo apt install docker.io
docker version

echo '=== install docker-compose'
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

echo '=== listing the installed apt packages'
sudo apt list --installed

echo ''
echo 'todo - run sudo ./pyenv_install_part1.sh'
echo 'todo - run ./pyenv_install_part2.sh'
echo 'todo - restart shell and run: pyenv install 3.8.6'
echo 'done'

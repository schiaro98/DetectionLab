# This script is used for install and configure Guacamole and Ansible
#! usr/bin/bash

# Clone the Guacamole-docker-compose project
git clone "https://github.com/boschkundendienst/guacamole-docker-compose"

# Install docker and docker compose
sudo apt install docker docker-compose

# Change docker permissions
sudo chmod 666 /var/run/docker.sock

# Clone the repo with the Ansible material
git clone "https://github.com/schiaro98/DetectionLab"

# Before install Ansible, make sure we have pip installed
python3 -m pip -V

# Download pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py

# Install pip
python3 get-pip.py --user

# Install ansible
python3 -m pip install --user ansible

# Verify installation
ansible --version

# Other requirements
pip install pywinrm

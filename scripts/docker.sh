#!/bin/bash

# Add the Docker repository to your apt sources list.
sudo sh -c "wget -qO- https://get.docker.io/gpg | apt-key add -"
sudo sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"

# Update your sources
sudo apt-get update

# Install, you will see another warning that the package cannot be authenticated. Confirm install.
sudo apt-get install -y --force-yes lxc-docker

# Listen on TCP as well as local socket.
cd /etc/init/; sudo rm docker.conf; sudo wget https://raw.github.com/octohost/octohost/master/config/docker.conf

sudo service docker restart
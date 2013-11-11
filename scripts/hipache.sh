#!/bin/bash
sudo add-apt-repository -y ppa:chris-lea/node.js
sudo apt-get update
sudo apt-get -y install nodejs redis-server
sudo npm install https://github.com/darron/hipache/archive/0.2.4.tar.gz -g
sudo mkdir /etc/hipache
cd /etc/hipache; sudo wget https://raw.github.com/darron/packer-ubuntu-12.04-docker-serf-hipache/master/config/hipache.json
cd /etc/init/; sudo wget https://raw.github.com/darron/packer-ubuntu-12.04-docker-serf-hipache/master/config/hipache.conf
cd /etc/logrotate.d/; sudo wget https://raw.github.com/darron/packer-ubuntu-12.04-docker-serf-hipache/master/config/hipache.logrotate; sudo mv hipache.logrotate hipache
cd /etc/init.d; sudo ln -s /lib/init/upstart-job hipache
sudo start hipache
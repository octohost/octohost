#!/bin/bash
sudo apt-get -y install unzip
cd /tmp
wget https://dl.bintray.com/mitchellh/serf/0.1.1_linux_amd64.zip
unzip 0.1*
sudo mv serf /usr/local/bin
sudo mkdir /etc/serf/
wget https://raw.github.com/darron/packer-ubuntu-12.04-docker-serf-hipache/master/config/serf.conf
sudo mv serf.conf /etc/init/
wget https://raw.github.com/darron/packer-ubuntu-12.04-docker-serf-hipache/master/config/serf.default
sudo mv serf.default /etc/default/serf
cd /etc/init.d; sudo ln -s /lib/init/upstart-job serf
cd /etc/logrotate.d/; sudo wget https://raw.github.com/darron/packer-ubuntu-12.04-docker-serf-hipache/master/config/serf.logrotate; sudo mv serf.logrotate serf
sudo service serf start
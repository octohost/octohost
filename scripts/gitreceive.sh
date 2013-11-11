#!/bin/bash
# Setup Source Code Repo
sudo apt-get install -y git-core
cd /usr/bin/
sudo wget https://raw.github.com/progrium/gitreceive/master/gitreceive
sudo chmod +x gitreceive 
sudo gitreceive init
sudo sh -c "echo 'git ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/80-git"
sudo chmod 440 /etc/sudoers.d/80-git
cd /home/git/
sudo mv receiver receiver-dist
sudo wget -O receiver https://raw.github.com/darron/packer-ubuntu-12.04-docker-serf-hipache/master/receiver.sh
sudo chmod 755 receiver

echo "Do this now: "
echo 'cat ~/.ssh/id_dsa.pub | ssh ubuntu@server.goes.here -i key.pem "sudo gitreceive upload-key ubuntu"'

# On the machine that will push git repos over:
#
# cat ~/.ssh/id_dsa.pub | ssh ubuntu@server.goes.here -i key.pem "sudo gitreceive upload-key ubuntu"
# git init testing
# cd testing
# git remote add source git@server.goes.here:testing.git
# touch file
# git add file
# git commit -a
# git push build master
Octohost
===========================

A [Packer](http://www.packer.io/) template to build:

  1. An AMI using Ubuntu 12.04 in AWS USW-2 (Oregon) region. It's built using [another AMI](https://github.com/octohost/ubuntu-12.0.4-3.8).
  2. A Virtualbox Vagrant box.

Includes:

  1. [Docker](http://www.docker.io/)
  2. [Serf](http://www.serfdom.io/) - Currently unused - we have some [plans](https://github.com/darron/serf-docker-events).
  3. [Hipache](https://github.com/dotcloud/hipache) - to route traffic to the proper docker container.
  4. [Gitreceive](https://github.com/progrium/gitreceive) - to receive pushes and do the magic.
  5. [Redis](http://redis.io/) - the storage backend for Hipache.
  6. [Shipyard](https://github.com/shipyard/shipyard) - available on port 8000 to help manage containers.

Purpose
--------

To host any web code possible:

1. Ruby - [1.8.7](https://github.com/octohost/ruby-1.8.7p352), [1.9.3](https://github.com/octohost/ruby-1.9.3p194), [2.0.0](https://github.com/octohost/ruby-2.0.0p247), [Sinatra](https://github.com/octohost/sinatra), [Middleman](https://github.com/octohost/middleman), Rails 2, Rails 3, Rails 4
2. PHP - [5.4.x w/nginx](https://github.com/octohost/php5-nginx), WordPress
3. Node - [0.10.x](https://github.com/octohost/nodejs), [Harp](https://github.com/octohost/harp), Ghost
4. Python - [3.3](https://github.com/octohost/python-3.3), Django
5. Go - [1.2rc3](https://github.com/octohost/go-1.2rc3), [Web.go](https://github.com/octohost/web.go), [Revel](https://github.com/octohost/revel)
6. Openresty - [1.4.2.8](https://github.com/octohost/openresty)
7. Java - [OpenJDK7](https://github.com/octohost/openjdk7)

The goal is to host anything - more are being worked on.

Start Using Octohost
---------

1\. Build your AMI - clone this repo and build using [Packer](http://www.packer.io/):

`packer build template.json`

2\. Create an AWS security group with port 80 open to the world, port 22 open to you and all ports open to other members of that group.

```
ec2-create-group -K your-key octohost -d "Octohost Group" --region us-west-2
ec2-authorize octohost -P tcp -p 80 -s 0.0.0.0/0 --region us-west-2
ec2-authorize octohost -P tcp -p 22 -s 0.0.0.0/0 --region us-west-2
ec2-authorize octohost -P tcp -p 0-65535 -o sg-groupid --region us-west-2
ec2-authorize octohost -P udp -p 0-65535 -o sg-groupid --region us-west-2
```

In the end - your group should look like this:

```
ec2-describe-group octohost --region us-west-2
GROUP	sg-groupid	0000000000	octohost	Octohost Group	
PERMISSION	457992882886	octohost	ALLOWS	tcp	0	65535	FROM	USER	0000000000	NAME octohost	ID sg-groupid	ingress
PERMISSION	457992882886	octohost	ALLOWS	udp	0	65535	FROM	USER	0000000000	NAME octohost	ID sg-groupid	ingress
PERMISSION	457992882886	octohost	ALLOWS	tcp	22	22	FROM	CIDR	0.0.0.0/0	ingress
PERMISSION	457992882886	octohost	ALLOWS	tcp	80	80	FROM	CIDR	0.0.0.0/0	ingress
```

3\. Create a running instance using your AMI and security group:

`ec2-run-instances --key your-key -g sg-groupid ami-yourAMI --region us-west-2`

4\. Once it's launched - visit that ip address with your web browser - it should say:

"No Application Configured - This domain is not associated with an application."

5\. Add your private key to gitreceive:

`cat ~/.ssh/id_dsa.pub | ssh -i ~/your-key.pem ubuntu@ip.address.here "sudo gitreceive upload-key ubuntu"`

6\. Now you can push one of our example repos:

```
git clone git@github.com:octohost/harp.git
cd harp
git remote add octohost git@ip.address.here:harp.git
git push octohost master
```

It will pull the base Docker container, build your repo and launch your site. The last "remote:" line should look like this:

`Your site is available at: http://harp.ip.address.here.xip.io`

7\. Visit that site:

http://harp.ip.address.here.xip.io

8\. Take a look around at all of the frameworks and languages available at [https://github.com/octohost](https://github.com/octohost).

Send us a pull request - we'll look at adding whatever is needed.


To Build the VM's
--------

`vagrant up`

`packer build template.json`

To Install on Rackspace using Ansible:
---------

Create the instance. Add your public key to the root user - use [ssh-copy-id](https://github.com/beautifulcode/ssh-copy-id-for-OSX):

`ssh-copy-id -i ~/.ssh/id_dsa.pub root@ip.address.here`

Upgrade the kernel and reboot:

`ssh root@ip.address.here "apt-get update && apt-get -y upgrade && apt-get -y install linux-image-generic-lts-raring linux-headers-generic-lts-raring && reboot"`

Update your Ansible Inventory file - add a "rackspace" group - then:

`ansible-playbook site.yml`

Follow step 4 - 8 as above.
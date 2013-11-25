Octohost
===========================

A [Packer](http://www.packer.io/) template to build:

  1. An AMI using Ubuntu 12.04 in AWS USW-2 (Oregon) region. It's built using [another AMI](https://github.com/octohost/ubuntu-12.0.4-3.8).
  2. A Virtualbox Vagrant box.

There's also an Ansible playbook to build on Rackspace and other systems that support it.

Includes:

  1. [Docker 0.6.7](http://www.docker.io/)
  2. [Serf](http://www.serfdom.io/) - Currently unused - we have some [plans](https://github.com/darron/serf-docker-events).
  3. [Hipache](https://github.com/dotcloud/hipache) - to route traffic to the proper docker container.
  4. [Gitreceive](https://github.com/progrium/gitreceive) - to receive pushes and do the magic.
  5. [Redis](http://redis.io/) - the storage backend for Hipache.
  6. [Shipyard](https://github.com/shipyard/shipyard) - available on port 8000 to help manage containers.

Purpose
--------

To host any web code possible:

1. Ruby - [1.8.7](https://github.com/octohost/ruby-1.8.7p352), [1.9.3](https://github.com/octohost/ruby-1.9.3p484), [2.0.0](https://github.com/octohost/ruby-2.0.0p353), [Sinatra](https://github.com/octohost/sinatra), [Middleman](https://github.com/octohost/middleman), [Octopress](https://github.com/octohost/octopress), Rails 2, Rails 3, Rails 4
2. PHP - [5.4.x w/nginx](https://github.com/octohost/php5-nginx), WordPress
3. Node - [0.10.x](https://github.com/octohost/nodejs), [Harp](https://github.com/octohost/harp), Ghost
4. Python - [3.3](https://github.com/octohost/python-3.3), Django
5. Go - [1.2rc5](https://github.com/octohost/go-1.2rc5), [Web.go](https://github.com/octohost/web.go), [Revel](https://github.com/octohost/revel), [martini](https://github.com/octohost/martini)
6. Openresty - [1.4.2.8](https://github.com/octohost/openresty)
7. Java - [OpenJDK7](https://github.com/octohost/openjdk7)

The goal is to host anything - more are being worked on.

PLEASE NOTE: There may be security holes, there are rough edges, it is not complete and may eat your data - but *it works for us* at the moment. We are experiencing some container crashing - but it's alpha software so that's to be expected. YMMV.

Advanced Quickstart
---------

These are the minimum amount of commands needed to get started:

```
ec2-run-instances --key your-key -g group-with-22-and-80-open ami-da910bea --region us-west-2
cat ~/.ssh/id_dsa.pub | ssh -i ~/.ssh/your-key.pem ubuntu@ip.address.here "sudo gitreceive upload-key ubuntu"
git clone git@github.com:octohost/harp.git
cd harp && git remote add octohost git@ip.address.here:harp.git
git push octohost master
```

If this doesn't make sense or doesn't work - keep reading.

To Start Using Octohost
---------

1\. Build your AMI - clone this repo and build using [Packer](http://www.packer.io/):

`packer build template.json`

NOTE: The AMI in [template.json](https://github.com/octohost/octohost/blob/master/template.json) has all of the proper required kernel extensions for Docker as well as [Chef](http://www.opscode.com/chef/) \(currently unused\) and [Ansible](https://github.com/ansible/ansible) provisioners. If you supply your own AMI, make sure it's got those items. You can rebuild build your own from [this repo](https://github.com/octohost/ubuntu-12.0.4-3.8).

2\. Create an AWS security group with port 80 open to the world, port 22 open to you and all ports open to other members of that group.

```
ec2-create-group -K your-key octohost -d "Octohost Group" --region us-west-2
ec2-authorize octohost -P tcp -p 80 -s 0.0.0.0/0 --region us-west-2
ec2-authorize octohost -P tcp -p 22 -s 0.0.0.0/0 --region us-west-2
# Not totally required - but helpful with Serf and Shipyard.
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

3\. Create a running instance using your AMI (or use ami-da910bea) and security group:

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

NOTE: Whatever you name your git repo is what the website URL is - for example:

`git remote add octohost git@ip.address.here:octohost-test.git`

would be located at:

http://octohost-test.ip.address.here.xip.io

8\. Take a look around at all of the frameworks and languages available at [https://github.com/octohost](https://github.com/octohost).

There's lots to do, this is nowhere near done - but it's working as the backend for a service of ours.

Got a change? Send us a pull request - we'll look at adding whatever is needed.

The 'octo' cli
--------

In v0.4 we added a small cli to check status of all hosted sites and reload if needed:

`sudo /usr/bin/octo status`

Will show the status of all installed sites - example output:

```
harp: OK
martini: OK
middleman: OK
octopress: OK
php5-nginx: OK
revel: OK
sinatra: DOWN
web.go: OK
www: OK
```

Restarting a site that is "DOWN" is as easy as:

`sudo /usr/bin/octo restart sinatra`

Pretty nice way to quickly see problems and deal with them.

A few notes
--------

1. The key to octohost is the Dockerfile in the root of any repo. That's what determines how the site is built and runs.
2. Currently there is only a single exposed port working per container.
3. Only websites can be pushed via git - any additional services - Redis, MySQL, Postgresql, etc. will need to be built and installed on the server. We're using external managed MySQL and Memcache at the moment.
4. If you want to use your own domain name, just point a wildcard record to the server and edit DOMAIN_SUFFIX in the [/home/git/receiver](https://github.com/octohost/octohost/blob/master/receiver.sh) and [/usr/bin/octo](https://github.com/octohost/octohost/blob/master/bin/octo) files.
5. If you want to add an additional domain name record for your website - add a CNAME text file to the root directory. Here's an [example file](https://gist.github.com/darron/7571573). If it's not a wildcard - make sure to point the DNS there - it won't work otherwise.
6. Port 8000 is blocked off on AWS (depending on your security group), but will be wide open on Rackspace and other providers - login and change the password from the [default](https://github.com/shipyard/shipyard).

To Build the VM's
--------

`vagrant up`

`packer build template.json`

To Install on Rackspace using Ansible:
---------

You'll need to install Ansible on your local computer - on OS X:

`brew install ansible`

Create the instance. Add your public key to the root user - use [ssh-copy-id](https://github.com/beautifulcode/ssh-copy-id-for-OSX):

`ssh-copy-id -i ~/.ssh/id_dsa.pub root@ip.address.here`

Upgrade the kernel and reboot:

`ssh root@ip.address.here "apt-get update && apt-get -y upgrade && apt-get -y install linux-image-generic-lts-raring linux-headers-generic-lts-raring && reboot"`

Update your Ansible Inventory file - add a "rackspace" group - then:

`ansible-playbook ansible.yml`

Follow step 4 - 8 as above. PLEASE READ NOTE \#6.

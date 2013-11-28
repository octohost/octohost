octo cli
---------

Added in v0.4 - the octo cli can help with:

1. Showing status of containers you've pushed.
2. Restarting a DOWN container.
3. Cleaning up exited containers.

For example:

1\. /usr/bin/octo status:

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

2\. /usr/bin/octo restart sinatra

```
Restarting sinatra.
Put repo in src format somewhere.
Building Docker image.
Base: sinatra
Uploading context 30720 bytes
Step 1 : FROM octohost/ruby-1.9.3p484
 ---> 922290f7c4f1
Step 2 : ADD . /srv/www
 ---> 8eb3a32cb9c6
Step 3 : RUN cd /srv/www; bundle install
 ---> Running in 09098d33afbe
Fetching gem metadata from https://rubygems.org/..........
Fetching gem metadata from https://rubygems.org/..
Using dotenv (0.9.0) 
Using thor (0.18.1) 
Using foreman (0.63.0) 
Installing rack (1.5.2) 
Installing rack-protection (1.5.1) 
Installing tilt (1.4.1) 
Installing sinatra (1.4.4) 
Using bundler (1.3.5) 
Your bundle is complete!
Use `bundle show [gemname]` to see where a bundled gem is installed.
 ---> 4286bd625ca8
Step 4 : EXPOSE 5000
 ---> Running in 18825e485607
 ---> 92673c2fb9e7
Step 5 : CMD ["/usr/local/bin/foreman","start","-d","/srv/www"]
 ---> Running in d69c7a35ff0e
 ---> 90db4ea68d6a
Successfully built 90db4ea68d6a
OK
1
2
Killing b373bee10efe
b373bee10efe
Your site is available at: http://sinatra.at-a-server.io
```

3\. /usr/bin/octo clean

```
Cleaning old exited containers.
d69c7a35ff0e
18825e485607
09098d33afbe
e865dd7d7dca
b373bee10efe
Showining all remaining containers.
CONTAINER ID        IMAGE                        COMMAND                CREATED              STATUS              PORTS                                               NAMES
dc5e1d961230        octohost/sinatra:latest      /usr/local/bin/forem   About a minute ago   Up About a minute   0.0.0.0:49167->5000/tcp                             purple_shark        
6e8d65bef177        octohost/revel:latest        /bin/sh -c revel run   18 hours ago         Up 18 hours         0.0.0.0:49165->9000/tcp                             purple_dog          
cc5f8debd9ca        octohost/martini:latest      /bin/sh -c cd /srv/w   18 hours ago         Up 18 hours         0.0.0.0:49164->3000/tcp                             white_koala         
fd1b2884ccc7        octohost/web.go:latest       /bin/sh -c cd /srv/w   18 hours ago         Up 18 hours         0.0.0.0:49163->9999/tcp                             orange_horse        
86a3d795426d        octohost/harp:latest         /bin/sh -c cd /srv/w   18 hours ago         Up 18 hours         0.0.0.0:49162->5000/tcp                             brown_octopus9      
c221106f78c7        octohost/middleman:latest    /bin/sh -c cd /srv/w   18 hours ago         Up 18 hours         0.0.0.0:49160->4567/tcp                             red_duck            
27cce081bee0        octohost/php5-nginx:latest   /bin/sh -c service p   18 hours ago         Up 18 hours         0.0.0.0:49159->80/tcp                               fuchsia_horse       
8cc0a2ea686f        octohost/octopress:latest    /bin/sh -c cd /srv/w   18 hours ago         Up 18 hours         0.0.0.0:49158->4000/tcp                             olive_lemur         
bdffdd3fbce1        octohost/www:latest          /bin/sh -c cd /srv/w   18 hours ago         Up 18 hours         0.0.0.0:49156->5000/tcp                             lime_spider         
b3fc849ec1f8        shipyard/shipyard:latest     /opt/apps/shipyard/.   19 hours ago         Up 19 hours         0.0.0.0:8000->8000/tcp, 443/tcp, 6379/tcp, 80/tcp   red_spider          
```
4\. /usr/bin/octo remove sinatra

```
root@octohost:~# /usr/bin/octo remove sinatra
Removed the source for sinatra.
d2dcefd53f64
Removed running conainter.
```

5\. /usr/bin/octo move sites ip.address.here

As long as you have ssh access to the other server, you can pull all the git repos over and relaunch all of the active sites.

v0.5 supports SSH Agent Forwarding - to forward your agent - in your ~/.ssh/config file:

```
Host octohost
  ForwardAgent yes
  Hostname ip.address.here
  Port 22
  User ubuntu
  LocalForward 8000 127.0.0.1:8000
```

Launch your new AMI, then login and: `sudo /usr/bin/octo move sites old.ip.address.here`

It will take a while, but seems to work pretty well.

BASH Functions
---------

Here's some bash functions to help dealing with a remote octohost a little nicer.

Add your octohost server IP addresses into a file located at ~/.octohost - one per line.

```
# Pass it the address of the server.
octok() {
  cat ~/.ssh/id_dsa.pub | ssh ubuntu@$1 "sudo gitreceive upload-key $your-name"
}

# Pass it the address of the server and the name of the repo.
octoa() {
  git remote add octo git@$1:$2.git
}

# Show status of all apps on all servers.
octos() {
  OCTOHOSTS="/Users/$your-name/.octohost"
  cat $OCTOHOSTS | while read server
  do
    echo "===== $server ====="
    ssh -n ubuntu@$server "sudo /usr/bin/octo status"
  done
}

# Pass the name of the server and the site to restart.
octor() {
  ssh ubuntu@$1 "sudo /usr/bin/octo restart $2"
}

# Show all running containers.
octol() {
  OCTOHOSTS="/Users/$your-name/.octohost"
  cat $OCTOHOSTS | while read server
  do
    echo "===== $server ====="
    ssh -n ubuntu@$server "sudo docker ps"
  done
}

# Clean up all exited containers.
octoc() {
  OCTOHOSTS="/Users/$your-name/.octohost"
  cat $OCTOHOSTS | while read server
  do
    echo "===== $server ====="
    ssh -n ubuntu@$server "sudo /usr/bin/octo clean"
  done
}

# Show all available images.
octoi() {
  OCTOHOSTS="/Users/$your-name/.octohost"
  cat $OCTOHOSTS | while read server
  do
    echo "===== $server ====="
    ssh -n ubuntu@$server "sudo docker images"
  done
}
```
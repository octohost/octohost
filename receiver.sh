#!/bin/bash
if [ -d /home/git/src/$1 ]; then rm -rf /home/git/src/$1; fi
echo "Put repo in src format somewhere."
mkdir -p /home/git/src/$1 && cat | tar -x -C /home/git/src/$1
echo "Building Docker image."
BASE=`basename $1 .git`
echo "Base: $BASE"

# Get Public IP address.
PUBLIC_IP=$(curl -s http://ipv4.icanhazip.com)
XIP_IO="$PUBLIC_IP.xip.io"

# Set the domain name here if desired.
DOMAIN_SUFFIX="$PUBLIC_IP.xip.io"

# Find out the old container ID.
OLD_ID=$(sudo docker ps | grep "$BASE:latest" | cut -d ' ' -f 1)

if [ -n "$OLD_ID" ]
then
  OLD_PORT=$(sudo docker inspect $OLD_ID | grep "HostPort" | cut -d ':' -f 2 | cut -d '"' -f 2)
else
  echo "Nothing running - no need to look for a port."
fi

if [ -e "/home/git/src/$1/Dockerfile" ]
then
  # Look for the exposed port.
  INTERNAL_PORT=$(grep "EXPOSE" /home/git/src/$1/Dockerfile | cut -d ' ' -f 2)
  # Build and get the ID.
  sudo docker build -t octohost/$BASE /home/git/src/$1

  ID=$(sudo docker run -P -d octohost/$BASE)
  # Get the $PORT from the container.
  PORT=$(sudo docker port $ID $INTERNAL_PORT | sed 's/0.0.0.0://')
else
  echo "There is no Dockerfile present."
  exit
fi

if [ -n "$XIP_IO"]
then
  # Zero out any existing items.
  /usr/bin/redis-cli ltrim frontend:$BASE.$XIP_IO 200 200
  # Connect $BASE.$PUBLIC_IP.xip.io to the $PORT
  /usr/bin/redis-cli rpush frontend:$BASE.$XIP_IO $BASE
  /usr/bin/redis-cli rpush frontend:$BASE.$XIP_IO http://127.0.0.1:$PORT
fi

if [ -n "$DOMAIN_SUFFIX"]
then
  # Zero out any existing items.
  /usr/bin/redis-cli ltrim frontend:$BASE.$DOMAIN_SUFFIX 200 200
  # Connect $BASE.$PUBLIC_IP.xip.io to the $PORT
  /usr/bin/redis-cli rpush frontend:$BASE.$DOMAIN_SUFFIX $BASE
  /usr/bin/redis-cli rpush frontend:$BASE.$DOMAIN_SUFFIX http://127.0.0.1:$PORT
fi

# Support a CNAME file in repo src
CNAME=/home/git/src/$1/CNAME
if [ -f $CNAME ]
then
  # Add a new line at end if it does not exist to ensure the loop gets last line
  sed -i -e '$a\' $CNAME
  while read DOMAIN
  do
    /usr/bin/redis-cli ltrim frontend:$DOMAIN 200 200
    /usr/bin/redis-cli rpush frontend:$DOMAIN $DOMAIN
    /usr/bin/redis-cli rpush frontend:$DOMAIN http://127.0.0.1:$PORT
  done < $CNAME
fi

# Kill the old container by ID.
if [ -n "$OLD_ID" ]
then
  echo "Killing $OLD_ID"
  sudo docker kill $OLD_ID
else
  echo "Not killing anything."
fi

echo "Your site is available at: http://$BASE.$DOMAIN_SUFFIX"
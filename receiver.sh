#!/bin/bash
echo "Put repo in src format somewhere."
mkdir -p /home/git/src/$1 && cat | tar -x -C /home/git/src/$1
echo "Building Docker image."
BASE=`basename $1 .git`
echo "Base: $BASE"

# Find out the old container ID.
OLD_ID=$(sudo docker ps | grep "$BASE:latest" | cut -d ' ' -f 1)
OLD_PORT=$(sudo docker inspect $OLD_ID | grep "HostPort" | cut -d ':' -f 2 | cut -d '"' -f 2)

# Look for the exposed port.
INTERNAL_PORT=$(grep "EXPOSE" /home/git/src/$1/Dockerfile | cut -d ' ' -f 2)

# Build and get the ID.
sudo docker build -t nonfiction/$BASE /home/git/src/$1
ID=$(sudo docker run -P -d nonfiction/$BASE)
# Get the $PORT from the container.
PORT=$(sudo docker port $ID $INTERNAL_PORT | sed 's/0.0.0.0://')

# Zero out any existing items.
/usr/bin/redis-cli ltrim frontend:$BASE.handbill.io 200 200
# Connect $BASE.handbill.io to the $PORT
/usr/bin/redis-cli rpush frontend:$BASE.handbill.io $BASE
/usr/bin/redis-cli rpush frontend:$BASE.handbill.io http://127.0.0.1:$PORT

# Kill the old container by ID.
if [ -n "$OLD_ID" ]
then
  echo "Killing $OLD_ID"
  sudo docker kill $OLD_ID
else
  echo "Not killing anything."
fi
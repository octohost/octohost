#!/bin/bash
REPOSITORY="$1"
BRANCH="$5"

if [ "$REPOSITORY" == "" ] ; then
  echo "Something is wrong. Your Repository name is blank!"
  exit 1
fi

if [ -f /etc/default/octohost ]; then
  . /etc/default/octohost
fi

if [ -d "$REPO_PATH" ]; then rm -rf "$REPO_PATH"; fi
echo "Put repo in src format somewhere."
mkdir -p "$REPO_PATH" && cat | tar -x -C "$REPO_PATH"
echo "Building Docker image."
BASE=`basename $REPOSITORY .git`

if [ "$BRANCH" != "master" ]
then
  BASE="$BASE-$BRANCH"
fi
echo "Base: $BASE"

# Find out the old container ID.
OLD_ID=$(sudo docker ps | grep "$BASE:latest" | cut -d ' ' -f 1)

IMAGE_ID=$(sudo docker images | grep $BASE | awk '{ print $3 }')

if [ -e "$DOCKERFILE" ]
then
  # Look for the exposed port.
  INTERNAL_PORT=$(grep -i "^EXPOSE" $DOCKERFILE | cut -d ' ' -f 2)
  # Build and get the ID.
  sudo docker build -t $BUILD_ORG_NAME/$BASE $REPO_PATH

  if [ $? -ne 0 ]
  then
    echo "Failed build - exiting."
    exit
  fi

  RUN_OPTIONS=$(/usr/bin/octo config:options $BASE $DOCKERFILE)

  ID=$(echo "$RUN_OPTIONS $BUILD_ORG_NAME/$BASE" | xargs sudo docker run)

  # Get the $PORT from the container.
  if [ -n "$INTERNAL_PORT" ]
  then
    PORT=$(sudo docker port $ID $INTERNAL_PORT | sed 's/0.0.0.0://')
  fi

  NO_HTTP_PROXY=$(grep -i "^# NO_HTTP_PROXY" $DOCKERFILE)
  if [ -n "$NO_HTTP_PROXY" ]
  then
    if [ -n "$PORT" ]
    then
      echo "Port: $PORT"
    fi
    # Kill the old container by ID.
    if [ -n "$OLD_ID" ]
    then
      echo "Killing $OLD_ID container."
      sudo docker kill $OLD_ID > /dev/null
    else
      echo "Not killing any containers."
    fi
    exit
  fi

else
  echo "There is no Dockerfile present."
  exit
fi

echo "Registering a new Consul service."
TAGS=$(/usr/bin/octo service:tags $ID)
/usr/bin/octo service:set $BASE $PORT $TAGS


if [ -n "$XIP_IO" ]
then
  echo "Adding $LINK_PREFIX://$BASE.$XIP_IO"
  DOMAINS="$BASE.$XIP_IO"
fi

if [ -n "$DOMAIN_SUFFIX" ]
then
  echo "Adding $LINK_PREFIX://$BASE.$DOMAIN_SUFFIX"
  if [ -n "$XIP_IO" ]
  then
    DOMAINS="$DOMAINS,$BASE.$DOMAIN_SUFFIX"
  else
    DOMAINS="$BASE.$DOMAIN_SUFFIX"
  fi
fi

# Support a CNAME file in repo src
CNAME=/home/git/src/$REPOSITORY/CNAME
if [ -f $CNAME ]
then
  # Add a new line at end if it does not exist to ensure the loop gets last line
  sed -i -e '$a\' $CNAME
  while read DOMAIN
  do
    echo "Adding $LINK_PREFIX://$DOMAIN"
    DOMAINS="$DOMAINS,$DOMAIN"
  done < $CNAME
fi

/usr/bin/octo domains:set $BASE $DOMAINS

NUM_CONTAINERS=$(/usr/bin/octo config:get $BASE/CONTAINERS)
NUM_CONTAINERS=${NUM_CONTAINERS:-1}

# Launch more containers based on the KV set.
if [ "$NUM_CONTAINERS" -gt "1" ]
then
  let NUM_CONTAINERS-=1
  /usr/bin/octo start $BASE $NUM_CONTAINERS
fi

# Kill the old container by ID.
if [ -n "$OLD_ID" ]
then
  /usr/bin/octo stop $BASE $IMAGE_ID
else
  echo "Not killing any containers."
fi

/usr/bin/octo config:consul_template $BASE

if [ -n "$XIP_IO" ]; then echo "Your site is available at: $LINK_PREFIX://$BASE.$XIP_IO";fi
if [ -n "$DOMAIN_SUFFIX" ]; then echo "Your site is available at: $LINK_PREFIX://$BASE.$DOMAIN_SUFFIX";fi

if [ -n "$PRIVATE_REGISTRY" ]; then
  echo "Pushing $BASE to a private registry."
  /usr/bin/octo push $BASE > /dev/null
fi

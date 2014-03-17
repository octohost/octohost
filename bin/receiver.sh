#!/bin/bash
REPOSITORY="$1"
BRANCH="$5"
REPO_PATH="/home/git/src/$REPOSITORY"
DOCKERFILE="$REPO_PATH/Dockerfile"
BUILD_ORG_NAME="octoprod"

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

# Get Public IP address.
PUBLIC_IP=$(curl -s http://ipv4.icanhazip.com)
XIP_IO="$PUBLIC_IP.xip.io"

# Set the domain name here if desired. Comment out if not used.
DOMAIN_SUFFIX="$PUBLIC_IP.xip.io"

# Find out the old container ID.
OLD_ID=$(sudo docker ps | grep "$BASE:latest" | cut -d ' ' -f 1)

if [ -n "$OLD_ID" ]
then
  OLD_PORT=$(sudo docker inspect $OLD_ID | grep "HostPort" | cut -d ':' -f 2 | cut -d '"' -f 2)
else
  echo "Nothing running - no need to look for a port."
fi

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

  RUN_OPTIONS="-P -d"

  ADD_NAME=$(grep -i "^# ADD_NAME" $DOCKERFILE)
  if [ -n "$ADD_NAME" ]
  then
    RUN_OPTIONS="$RUN_OPTIONS -name $BASE"
  fi

  VOLUMES_FROM=$(grep -i "^# VOLUMES_FROM" $DOCKERFILE)
  if [ -n "$VOLUMES_FROM" ]
  then
    VOLUME_NAME="${BASE}_data"
    RUN_OPTIONS="$RUN_OPTIONS -volumes-from $VOLUME_NAME"
  fi

  LINK_SERVICE=$(grep -i "^# LINK_SERVICE" $DOCKERFILE)
  if [ -n "$LINK_SERVICE" ]
  then
    SOURCE=$(grep -i "^# LINK_SERVICE" $DOCKERFILE | awk '{ print $3 }')
    LINK_NAME=$(grep -i "^# LINK_SERVICE" $DOCKERFILE | awk '{ print $4 }')
    if [ -n "$LINK_NAME" ]
    then
      LINK_NAME="$LINK_NAME:$SOURCE"
      echo "Linking to: $LINK_NAME"
    else
      LINK_NAME="${BASE}_${SOURCE}:${SOURCE}"
      echo "Linking to: $LINK_NAME"
    fi

    RUN_OPTIONS="$RUN_OPTIONS -link $LINK_NAME"
  fi

  ENV_VARS=$(sudo /usr/bin/octo config $BASE | grep -v "Error: 100: Key not found")
  if [ -n "$ENV_VARS" ]
  then
    ENV=""
    for conf in `sudo /usr/bin/octo config $BASE`;
    do
      KEY=$(echo $conf | cut -d '/' -f 3 | cut -d ':' -f 1)
      VAR=$(echo $conf | cut -d ':' -f 2-10)
      ENV="$ENV -e $KEY=$VAR"
    done
    RUN_OPTIONS="$ENV $RUN_OPTIONS"
  fi

  ID=$(sudo docker run $RUN_OPTIONS $BUILD_ORG_NAME/$BASE)

  # Get the $PORT from the container.
  if [ -n "$INTERNAL_PORT" ]
  then
    PORT=$(sudo docker port $ID $INTERNAL_PORT | sed 's/0.0.0.0://')
  fi
else
  echo "There is no Dockerfile present."
  exit
fi

NO_HTTP_PROXY=$(grep -i "^# NO_HTTP_PROXY" $DOCKERFILE)
if [ -n "$NO_HTTP_PROXY" ]
then
  if [ -n "$PORT" ]
  then
    echo "Port: $PORT"
  fi
  exit
fi

if [ -n "$XIP_IO" ]
then
  echo "Adding http://$BASE.$XIP_IO"
  # Zero out any existing items.
  /usr/bin/redis-cli ltrim frontend:$BASE.$XIP_IO 200 200 > /dev/null
  # Connect $BASE.$PUBLIC_IP.xip.io to the $PORT
  /usr/bin/redis-cli rpush frontend:$BASE.$XIP_IO $BASE > /dev/null
  /usr/bin/redis-cli rpush frontend:$BASE.$XIP_IO http://127.0.0.1:$PORT > /dev/null
fi

if [ -n "$DOMAIN_SUFFIX" ]
then
  echo "Adding http://$BASE.$DOMAIN_SUFFIX"
  # Zero out any existing items.
  /usr/bin/redis-cli ltrim frontend:$BASE.$DOMAIN_SUFFIX 200 200 > /dev/null
  # Connect $BASE.$PUBLIC_IP.xip.io to the $PORT
  /usr/bin/redis-cli rpush frontend:$BASE.$DOMAIN_SUFFIX $BASE > /dev/null
  /usr/bin/redis-cli rpush frontend:$BASE.$DOMAIN_SUFFIX http://127.0.0.1:$PORT > /dev/null
fi

# Support a CNAME file in repo src
CNAME=/home/git/src/$REPOSITORY/CNAME
if [ -f $CNAME ]
then
  # Add a new line at end if it does not exist to ensure the loop gets last line
  sed -i -e '$a\' $CNAME
  while read DOMAIN
  do
    echo "Adding http://$DOMAIN"
    /usr/bin/redis-cli ltrim frontend:$DOMAIN 200 200 > /dev/null
    /usr/bin/redis-cli rpush frontend:$DOMAIN $DOMAIN > /dev/null
    /usr/bin/redis-cli rpush frontend:$DOMAIN http://127.0.0.1:$PORT > /dev/null
  done < $CNAME
fi

# Kill the old container by ID.
if [ -n "$OLD_ID" ]
then
  echo "Killing $OLD_ID container."
  sudo docker kill $OLD_ID > /dev/null
else
  echo "Not killing any containers."
fi

if [ -n "$XIP_IO" ]; then echo "Your site is available at: http://$BASE.$XIP_IO";fi
if [ -n "$DOMAIN_SUFFIX" ]; then echo "Your site is available at: http://$BASE.$DOMAIN_SUFFIX";fi

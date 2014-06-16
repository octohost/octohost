#!/bin/bash
REPOSITORY="$1"
BRANCH="$5"
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

  RUN_OPTIONS=$(/usr/bin/octo config:options $BASE $DOCKERFILE)

  ID=$(sudo docker run $RUN_OPTIONS $BUILD_ORG_NAME/$BASE)

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
    Kill the old container by ID.
    if [ -n "$OLD_ID" ]
    then
      echo "Killing $OLD_ID container."
      sudo docker kill $OLD_ID > /dev/null
    else
      echo "Not killing any containers."
    fi
    exit
  fi

  if [ -z "$PORT" ]
  then
    echo "#################################################"
    echo "Something went wrong, trying again."
    echo "Killing the container we just launched."
    sudo docker kill $ID > /dev/null
    echo "Launching a new one"
    ID=$(sudo docker run $RUN_OPTIONS $BUILD_ORG_NAME/$BASE)
    PORT=$(sudo docker port $ID $INTERNAL_PORT | sed 's/0.0.0.0://')
    if [ -z "$PORT" ]
    then
      echo "docker run $RUN_OPTIONS $BUILD_ORG_NAME/$BASE" | mail -s "$BASE failed to launch on $PUBLIC_IP" $EMAIL_NOTIFICATION
    else
      echo "docker run $RUN_OPTIONS $BUILD_ORG_NAME/$BASE" | mail -s "$BASE launched on the second try on $PUBLIC_IP" $EMAIL_NOTIFICATION
    fi
    echo "#################################################"
  else
    echo "Everything looks good."
  fi

else
  echo "There is no Dockerfile present."
  exit
fi

if [ -n "$XIP_IO" ]
then
  echo "Adding http://$BASE.$XIP_IO"
  `/usr/bin/octo proxy:set $BASE.$XIP_IO $PORT`
fi

if [ -n "$DOMAIN_SUFFIX" ]
then
  echo "Adding http://$BASE.$DOMAIN_SUFFIX"
  `/usr/bin/octo proxy:set $BASE.$DOMAIN_SUFFIX $PORT`
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
    `/usr/bin/octo proxy:set $DOMAIN $PORT`
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

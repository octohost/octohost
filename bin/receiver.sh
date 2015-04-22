#!/bin/bash
REPOSITORY="$1"
BRANCH="$5"
BASE=`basename $REPOSITORY .git`

log () {
  local message="$1"
  logger -p local4.info -t octohost "$message"
}

if [ "$BRANCH" != "master" ]
then
  BASE="$BASE-$BRANCH"
  REPOSITORY="$BASE.git"
fi
echo "Base: $BASE"

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

if [ -n "$PRIVATE_REGISTRY" ]; then
  IMAGE_NAME="$PRIVATE_REGISTRY\/$BASE"
else
  IMAGE_NAME="$BUILD_ORG_NAME\/$BASE"
fi

# Find out the old container ID.
OLD_ID=$(sudo docker -H $DOCKER_HOST ps | grep "$IMAGE_NAME" | cut -d ' ' -f 1)
log "Old ID: '$OLD_ID'"

IMAGE_ID=$(sudo docker -H $DOCKER_HOST images | grep "$IMAGE_NAME " | awk '{ print $3 }' | sort | uniq)
log "IMAGE ID: '$IMAGE_ID'"

if [ -e "$DOCKERFILE" ]
then
  sudo docker build -t $BUILD_ORG_NAME/$BASE $REPO_PATH
  log "Build 'docker build -t $BUILD_ORG_NAME/$BASE $REPO_PATH'"

  if [ $? -ne 0 ]
  then
    echo "Failed build - exiting."
    exit
  fi

else
  echo "There is no Dockerfile present."
  exit
fi

NO_HTTP_PROXY=$(/usr/bin/octo config:check "$BASE" "NO_HTTP_PROXY")
if [ -z "$NO_HTTP_PROXY" ]; then

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

  /usr/bin/octo domains:set "$BASE" "$DOMAINS"

fi

NUM_CONTAINERS=$(/usr/bin/octo config:get $BASE/CONTAINERS)
NUM_CONTAINERS=${NUM_CONTAINERS:-1}

if [ -n "$PRIVATE_REGISTRY" ]; then
  echo "Pushing $BASE to a private registry."
  /usr/bin/octo push $BASE > /dev/null
  docker -H $DOCKER_HOST pull $PRIVATE_REGISTRY/$BASE
fi

/usr/bin/octo start "$BASE" "$NUM_CONTAINERS"

# Kill the old container by ID.
if [ -n "$OLD_ID" ]
then
  /usr/bin/octo stop "$BASE" "$IMAGE_ID"
else
  echo "Not killing any containers."
fi

/usr/bin/octo config:consul_template "$BASE"

NO_HTTP_PROXY=$(/usr/bin/octo config:check "$BASE" "NO_HTTP_PROXY")
if [ -z "$NO_HTTP_PROXY" ]; then

  if [ -n "$XIP_IO" ]; then echo "Your site is available at: $LINK_PREFIX://$BASE.$XIP_IO";fi
  if [ -n "$DOMAIN_SUFFIX" ]; then echo "Your site is available at: $LINK_PREFIX://$BASE.$DOMAIN_SUFFIX";fi

else
  echo "Your container isn't available from the web because you set NO_HTTP_PROXY."
fi

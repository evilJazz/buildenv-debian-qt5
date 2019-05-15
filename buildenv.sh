#!/bin/bash -x
SCRIPT_FILENAME="`cd \`dirname \"$0\"\`; pwd`/`basename \"$0\"`"
SCRIPT_ROOT=$(dirname "$SCRIPT_FILENAME")

IMAGE_NAME="buildenv-ubuntu-stretch-qt5"

if [ $(uname -m | grep arm | wc -l) -gt 0 ]; then
        BASE_IMAGE_NAME=resin/raspberry-pi-debian:stretch
else
        BASE_IMAGE_NAME=debian:stretch
fi

[[ -z "$1" || -z "$2" ]] && echo "$0 [workdir] [command] ..." && exit 1

# Map current user and group to user/group buildenv in container
CONTAINER_USERNAME="buildenv"
CONTAINER_GROUPNAME="buildenv"
HOMEDIR="/home/${CONTAINER_USERNAME}"
GROUP_ID=$(id -g)
USER_ID=$(id -u)

function create_user_cmd()
{
  echo \
    groupadd -f -g $GROUP_ID $CONTAINER_GROUPNAME '&&' \
    useradd -u $USER_ID -g $CONTAINER_GROUPNAME $CONTAINER_USERNAME '&&' \
    mkdir --parent $HOMEDIR '&&' \
    chown -R $CONTAINER_USERNAME:$CONTAINER_GROUPNAME $HOMEDIR
}

function execute_as_cmd()
{
  echo sudo -u $CONTAINER_USERNAME HOME=$HOMEDIR
}

function full_container_cmd()
{
  echo "'$(create_user_cmd) && $(execute_as_cmd) $(printf "%q " "$@")'"
}

WORK_DIR=$(realpath "$1")
shift 1

cd "$SCRIPT_ROOT"

set -e

docker build -t "$IMAGE_NAME" docker --build-arg BASE_IMAGE_NAME=$BASE_IMAGE_NAME

DOCKER_ADDITIONAL_PARAMS=""
[ -t 1 ] && DOCKER_ADDITIONAL_PARAMS="-i"

eval docker run --rm $DOCKER_ADDITIONAL_PARAMS -t \
  --cap-add SYS_PTRACE \
  --volume "${IMAGE_NAME}-home:${HOMEDIR}" \
  --volume "$WORK_DIR:/workdir" \
  "$IMAGE_NAME" \
  /bin/bash -ci $(full_container_cmd "$@")

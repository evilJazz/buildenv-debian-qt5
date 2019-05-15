#!/bin/bash -x
SCRIPT_FILENAME="`cd \`dirname \"$0\"\`; pwd`/`basename \"$0\"`"
SCRIPT_ROOT=$(dirname "$SCRIPT_FILENAME")

[ -z "$1" ] && IMAGE_NAME="buildenv-debian-stretch-qt5" || IMAGE_NAME="$1"
[ -z "$2" ] && DEBIAN_VERSION="stretch" || DEBIAN_VERSION="$2"

if [ $(uname -m | grep arm | wc -l) -gt 0 ]; then
	# Use armv6l version of Debian, since the armhf version will not work on RaspPi 1/2/Zero
        BASE_IMAGE_NAME=resin/raspberry-pi-debian:${DEBIAN_VERSION}
else
        BASE_IMAGE_NAME=debian:${DEBIAN_VERSION}
fi

docker build -t "$IMAGE_NAME" docker-${DEBIAN_VERSION} --build-arg BASE_IMAGE_NAME=$BASE_IMAGE_NAME

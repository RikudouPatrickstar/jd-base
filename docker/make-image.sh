#!/bin/sh
#
# Copyright (C) 2021 Patrick⭐
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#
DOCKER_IMAGE="patrick/jdbase:v3"
JD_PATH="$(pwd)/patrick-jd"
SCRIPT_NAME=$0

if [ ! -z "$(docker images -q $DOCKER_IMAGE 2> /dev/null)" ]; then
    docker image rm -f $DOCKER_IMAGE
fi

mkdir $JD_PATH
wget -q https://github.com/RikudouPatrickstar/jd-base/raw/v3/docker/Dockerfile -O $JD_PATH/Dockerfile
wget -q https://github.com/RikudouPatrickstar/jd-base/raw/v3/docker/docker-entrypoint.sh -O $JD_PATH/docker-entrypoint.sh
docker build -t $DOCKER_IMAGE $JD_PATH

rm -fr $JD_PATH

exit 0
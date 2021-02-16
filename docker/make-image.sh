#!/bin/sh
#
# Copyright (C) 2021 Patrick⭐
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#
DockerImage="patrick/jd-base:v3"
JdDir="$(pwd)/patrick-jd"
ShellName=$0

if [ ! -z "$(docker images -q $DockerImage 2> /dev/null)" ]; then
    docker image rm -f $DockerImage
fi

mkdir $JdDir
wget -q https://github.com/RikudouPatrickstar/jd-base/raw/v3/docker/Dockerfile -O $JdDir/Dockerfile
docker build -t $DockerImage $JdDir

rm -fr $JdDir

exit 0

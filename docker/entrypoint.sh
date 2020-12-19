#!/bin/bash
set -e

[ ! -d ${JD_DIR}/log ] && mkdir -p ${JD_DIR}/log
crond

if [ -f ${JD_DIR}/crontab.list ]
then
  crontab ${JD_DIR}/crontab.list
else
  cp -f ${JD_DIR}/sample/docker.list.sample ${JD_DIR}/crontab.list
  crontab ${JD_DIR}/crontab.list
fi

if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- node "$@"
fi

exec "$@"

#!/bin/bash
set -e

[ ! -d ${JD_DIR}/log ] && mkdir -p ${JD_DIR}/log
crond

if [ -d ${JD_DIR}/config ]
then
  if [ -s ${JD_DIR}/config/crontab.list ]
  then
    echo -e "检测到config配置目录下存在crontab.list，自动导入定时任务...\n"
    crontab ${JD_DIR}/config/crontab.list
    echo -e "导入自定义定时任务成功，当前的定时任务如下：\n"
    crontab -l
    echo -e "\n容器启动成功...\n"
  else
    echo -e "检测到config配置目录下不存在crontab.list或存在但文件为空，自动从示例文件复制一份作为初始任务...\n"
    cp -fv ${JD_DIR}/sample/docker.list.sample ${JD_DIR}/config/crontab.list
    crontab ${JD_DIR}/config/crontab.list
    echo -e "\n导入默认定时任务成功，当前的定时任务如下：\n"
    crontab -l
    echo -e "\n容器启动成功...\n"
  fi
else
  echo -e "没有映射config配置目录给本容器，请先按教程映射config配置目录...\n"
  exit 1
fi

if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- node "$@"
fi

exec "$@"

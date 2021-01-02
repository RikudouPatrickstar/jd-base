#!/bin/bash
set -e

function Start_Container {
  crontab ${JD_DIR}/config/crontab.list
  echo -e "导入定时任务成功...\n"
  echo -e "--------------------4. 容器启动成功--------------------\n"
}

echo -e "\n--------------------1. 更新源代码--------------------\n"

echo -e "更新EvineDeng/jd-base...\n"
cd ${JD_DIR}
git pull
echo -e "\n更新EvineDeng/jd-base完成...\n"

echo -e "更新lxk0301/jd_scripts...\n"
cd ${JD_DIR}/scripts
git pull
echo -e "\n更新lxk0301/jd_scripts完成...\n"

echo -e "--------------------2. 启动crond程序--------------------\n"
[ ! -d ${JD_DIR}/log ] && mkdir -p ${JD_DIR}/log
crond

echo -e "--------------------3. 导入定时任务--------------------\n"
if [ -d ${JD_DIR}/config ]
then
  if [ -s ${JD_DIR}/config/crontab.list ]
  then
    echo -e "检测到config配置目录下存在crontab.list，自动导入定时任务...\n"
    Start_Container
  else
    echo -e "检测到config配置目录下不存在crontab.list或存在但文件为空，自动从示例文件复制一份作为初始任务...\n"
    cp -fv ${JD_DIR}/sample/docker.list.sample ${JD_DIR}/config/crontab.list
    echo
    Start_Container
  fi
else
  echo -e "没有映射config配置目录给本容器，请先按教程映射config配置目录...\n"
  exit 1
fi

if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- node "$@"
fi

exec "$@"

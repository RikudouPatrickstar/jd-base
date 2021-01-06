#!/bin/bash
set -e

echo -e "\n========================1. 更新源代码========================\n"
bash git_pull
[ ! -d ${JD_DIR}/log ] && mkdir -p ${JD_DIR}/log
crond

echo -e "========================2. 检测配置文件========================\n"
if [ -d ${JD_DIR}/config ]
then

  if [ -s ${JD_DIR}/config/crontab.list ]
  then
    echo -e "检测到config配置目录下存在crontab.list，自动导入定时任务...\n"
    crontab ${JD_DIR}/config/crontab.list
    echo -e "成功添加定时任务...\n"
  else
    echo -e "检测到config配置目录下不存在crontab.list或存在但文件为空，从示例文件复制一份用于始化...\n"
    cp -fv ${JD_DIR}/sample/docker.list.sample ${JD_DIR}/config/crontab.list
    echo
    crontab ${JD_DIR}/config/crontab.list
    echo -e "成功添加定时任务...\n"
  fi

  if [ ! -s ${JD_DIR}/config/config.sh ]; then
    echo -e "检测到config配置目录下不存在config.sh，从示例文件复制一份用于始化...\n"
    cp -fv ${JD_DIR}/sample/config.sh.sample ${JD_DIR}/config/config.sh
    echo
  fi

  if [ ! -s ${JD_DIR}/config/auth.json ]; then
    echo -e "检测到config配置目录下不存在auth.json，从示例文件复制一份用于始化...\n"
    cp -fv ${JD_DIR}/sample/auth.json ${JD_DIR}/config/auth.json
  fi

else
  echo -e "没有映射config配置目录给本容器，请先按教程映射config配置目录...\n"
  exit 1
fi

echo -e "========================3. 启动挂机程序========================\n"
bash jd hangup >/dev/null 2>&1
echo -e "挂机程序启动成功...\n"

echo -e "========================4. 启动控制面板========================\n"
pm2 start ${JD_DIR}/panel/server.js
echo -e "控制面板启动成功..."
echo -e "如未修改用户名密码，则初始用户名为：admin，初始密码为：adminadmin\n"
echo -e "请访问 http://<ip>:5678 登陆并修改配置...\n"

if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- node "$@"
fi

exec "$@"

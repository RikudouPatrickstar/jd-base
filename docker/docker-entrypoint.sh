#!/bin/bash
set -e

echo -e "\n========================1. 更新源代码========================\n"

WhichDep=$(grep "/jd-base" "${JD_DIR}/.git/config")

if [[ ${WhichDep} == *github* ]]; then
  ScriptsURL=https://github.com/LXK9301/jd_scripts
  ShellURL=https://github.com/EvineDeng/jd-base
else
  ScriptsURL=https://gitee.com/lxk0301/jd_scripts
  ShellURL=https://gitee.com/evine/jd-base
fi

echo -e "更新shell脚本，原地址：${ShellURL}\n"
cd ${JD_DIR}
git fetch --all
git reset --hard origin/v3
echo

if [ -d ${JD_DIR}/scripts/.git ]; then
  echo -e "更新JS脚本，原地址：${ScriptsURL}\n"
  cd ${JD_DIR}/scripts
  git fetch --all
  git reset --hard origin/master
else
  echo -e "克隆JS脚本，原地址：${ScriptsURL}\n"
  git clone -b master ${ScriptsURL} ${JD_DIR}/scripts
fi
echo
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
    echo -e "检测到config配置目录下不存在crontab.list或存在但文件为空，从示例文件复制一份用于初始化...\n"
    cp -fv ${JD_DIR}/sample/docker.list.sample ${JD_DIR}/config/crontab.list
    echo
    crontab ${JD_DIR}/config/crontab.list
    echo -e "成功添加定时任务...\n"
  fi

  if [ ! -s ${JD_DIR}/config/config.sh ]; then
    echo -e "检测到config配置目录下不存在config.sh，从示例文件复制一份用于初始化...\n"
    cp -fv ${JD_DIR}/sample/config.sh.sample ${JD_DIR}/config/config.sh
    echo
  fi

  if [ ! -s ${JD_DIR}/config/auth.json ]; then
    echo -e "检测到config配置目录下不存在auth.json，从示例文件复制一份用于初始化...\n"
    cp -fv ${JD_DIR}/sample/auth.json ${JD_DIR}/config/auth.json
    echo
  fi

else
  echo -e "没有映射config配置目录给本容器，请先按教程映射config配置目录...\n"
  exit 1
fi

echo -e "========================3. 启动挂机程序========================\n"
if [[ ${ENABLE_HANGUP} == true ]]; then
  . ${JD_DIR}/config/config.sh
  if [ -n "${Cookie1}" ]; then
    bash jd hangup >/dev/null 2>&1
    echo -e "挂机程序启动成功...\n"
  else
    echo -e "config.sh中还未填入有效的Cookie，可能是首次部署容器，因此不启动挂机程序...\n"
  fi
elif [[ ${ENABLE_HANGUP} == false ]]; then
  echo -e "已设置为不自动启动挂机程序，跳过...\n"
fi

echo -e "========================4. 启动控制面板========================\n"
if [[ ${ENABLE_WEB_PANEL} == true ]]; then
  pm2 start ${JD_DIR}/panel/server.js
  echo -e "控制面板启动成功...\n"
  echo -e "如未修改用户名密码，则初始用户名为：admin，初始密码为：adminadmin\n"
  echo -e "请访问 http://<ip>:5678 登陆并修改配置...\n"
elif [[ ${ENABLE_WEB_PANEL} == false ]]; then
  echo -e "已设置为不自动启动控制面板，跳过...\n"
fi
echo -e "容器启动成功...\n"

if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- node "$@"
fi

exec "$@"

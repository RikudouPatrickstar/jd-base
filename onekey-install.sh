#!/bin/sh
#
# Copyright (C) 2021 Patrick⭐
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#
clear

echo "
   _____ _____      ______            _    _______ 
  (_____|____ \    (____  \   /\     | |  (_______)
     _   _   \ \    ____)  ) /  \     \ \  _____   
    | | | |   | |  |  __  ( / /\ \     \ \|  ___)  
 ___| | | |__/ /   | |__)  ) |__| |_____) ) |_____ 
(____/  |_____/    |______/|______(______/|_______)
                                                                     
            ==== Create by Patrick⭐ ====
"
SHELL_DIR=$(cd "$(dirname "$0")";pwd)
JD_DIR=${SHELL_DIR}/jd

echo -e "\e[31\n警告：运行本脚本前必须手动安装好如下依赖：git wget curl perl moreutils node.js npm\n按任意键继续脚本安装，否则按 Ctrl + C 退出！\e[0m"
read

echo -e "\n\e[32m1. 获取源码\e[0m"
[ ! -d ${JD_DIR} ] && mv ${JD_DIR} ${SHELL_DIR}/jd.bak && echo "检测到当前目录下有jd目录，已备份为jd.bak"
git clone -b v3 https://github.com/RikudouPatrickstar/jd-base ${JD_DIR}

echo -e "\n\e[32m2. 检查配置文件\e[0m"
[ ! -d ${JD_DIR}/config ] && mkdir -p ${JD_DIR}/config
[ ! -d ${JD_DIR}/log ] && mkdir -p ${JD_DIR}/log

if [ ! -s ${JD_DIR}/config/crontab.list ]
then
  cp -fv ${JD_DIR}/sample/computer.list.sample ${JD_DIR}/config/crontab.list
  sed -i "s,MY_PATH,${JD_DIR},g" ${JD_DIR}/config/crontab.list
  sed -i "s,ENV_PATH=,PATH=$PATH,g" ${JD_DIR}/config/crontab.list
  echo
fi
crontab -l > ${JD_DIR}/old_crontab
crontab ${JD_DIR}/config/crontab.list

if [ ! -s ${JD_DIR}/config/config.sh ]; then
  cp -fv ${JD_DIR}/sample/config.sh.sample ${JD_DIR}/config/config.sh
  echo
fi

if [ ! -s ${JD_DIR}/config/auth.json ]; then
  cp -fv ${JD_DIR}/sample/auth.json ${JD_DIR}/config/auth.json
  echo
fi

echo -e "\n\e[32m3. 执行 git_pull\e[0m"
bash ${JD_DIR}/git_pull.sh

echo -e "\n\e[32m4. 启动控制面板\e[0m"
pushd ${JD_DIR}/panel >> /dev/null
npm install
pm2 start server.js || npm install -g pm2 && pm2 start server.js
echo -e "请访问 http://<ip>:5678 进行配置"
echo -e "$(cat ${JD_DIR}/config/auth.json)"

echo -e "\e[33m原有定时任务已备份在 ${JD_DIR}/old_crontab \e[0m"
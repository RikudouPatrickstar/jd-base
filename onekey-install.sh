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
ShellDir=$(cd "$(dirname "$0")";pwd)
ShellName=$0
JdDir=${ShellDir}/jd

echo -e "\e[33m注意：运行本脚本前必须手动安装好如下依赖：\ngit wget curl perl moreutils node.js npm\n\n按任意键继续，否则按 Ctrl + C 退出！\e[0m"
read

if [ ! -x "$(command -v node)" ] || [ ! -x "$(command -v npm)" ] || [ ! -x "$(command -v git)" ] || [ ! -x "$(command -v curl)" ] || [ ! -x "$(command -v wget)" ] || [ ! -x "$(command -v perl)" ]; then
  echo -e "\e[31m依赖未安装完整！\e[0m"
  exit 1
fi

echo -e "\n\e[32m1. 获取源码\e[0m"
[ -d ${JdDir} ] && mv ${JdDir} ${ShellDir}/jd.bak && echo "检测到当前目录下有jd目录，已备份为jd.bak"
git clone -b v3 https://github.com/RikudouPatrickstar/jd-base ${JdDir}

echo -e "\n\e[32m2. 检查配置文件\e[0m"
[ ! -d ${JdDir}/config ] && mkdir -p ${JdDir}/config

if [ ! -s ${JdDir}/config/crontab.list ]
then
  cp -fv ${JdDir}/sample/crontab.list.sample ${JdDir}/config/crontab.list
  sed -i "s,MY_PATH,${JdDir},g" ${JdDir}/config/crontab.list
  sed -i "s,ENV_PATH=,PATH=$PATH,g" ${JdDir}/config/crontab.list
fi
crontab -l > ${JdDir}/old_crontab
crontab ${JdDir}/config/crontab.list

if [ ! -s ${JdDir}/config/config.sh ]; then
  cp -fv ${JdDir}/sample/config.sh.sample ${JdDir}/config/config.sh
fi

if [ ! -s ${JdDir}/config/auth.json ]; then
  cp -fv ${JdDir}/sample/auth.json ${JdDir}/config/auth.json
fi

echo -e "\n\e[32m3. 执行 git_pull\e[0m"
bash ${JdDir}/git_pull.sh

echo -e "\n\e[32m4. 启动控制面板\e[0m"
cd ${JdDir}/panel >> /dev/null
npm install
node server.js &
cd ${ShellDir}
echo -e "\e[32m请访问 http://<ip>:5678 进行配置\e[0m"
echo -e "\e[32m初始用户名：admin，初始密码：password\e[0m"

echo -e "\n更多关于控制面板的信息请访问 https://github.com/RikudouPatrickstar/jd-base#%E5%9B%9Bweb-%E9%9D%A2%E6%9D%BF%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E\n"

echo -e "\e[33m注意：原有定时任务已备份在 ${JdDir}/old_crontab \e[0m"
rm -f ${ShellDir}/${ShellName}

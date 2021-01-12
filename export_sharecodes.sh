#!/usr/bin/env bash

## Author: Evine Deng
## Source: https://github.com/EvineDeng/jd-base
## Modified： 2021-01-11
## Version： v3.3.0

## 文件路径、脚本网址、文件版本以及各种环境的判断
if [ -f /proc/1/cgroup ]
then
  isDocker=$(cat /proc/1/cgroup | grep docker)
else
  isDocker=""
fi

if [ -z "${isDocker}" ]
then
  ShellDir=$(cd $(dirname $0); pwd)
else
  ShellDir=${JD_DIR}
fi

LogDir=${ShellDir}/log
ScriptsDir=${ShellDir}/scripts
FileConf=${ShellDir}/config/config.sh
DateToday=$(date "+%Y-%m-%d")
isTermux=${ANDROID_RUNTIME_ROOT}${ANDROID_ROOT}
if [[ ${isTermux} ]]
then
  Opt="P"
else
  Opt="E"
fi

## 导出互助码子程序
function Cat_Scodes {
  cd ${LogDir}/jd_$1
  for log in $(ls -r)
  do
    codes=$(grep -${Opt} $2 ${log} | perl -pe "s| ||")
    [ -n "${codes}" ] && break
  done
  echo ${codes}
}

## 导出口袋书店互助码
function Cat_ScodesBookShop {
  cd ${LogDir}/jd_bookshop
  for log in $(ls -r)
  do
    codes=$(perl -pe "s|信息获取成功\n||g" ${log} | grep -${Opt} "您的好友助力码为" | perl -pe "{s|您的好友助力码为||g; s|用户||g}")
    [ -n "${codes}" ] && break
  done
  echo ${codes}
}

## 导出签到领现金互助码
function Cat_ScodesCash {
  cd ${LogDir}/jd_cash
  for log in $(ls -r)
  do
    codes=$(perl -0777 -pe "s|\*+\n+||g" ${log} | grep -${Opt} "您的助力码为" | perl -pe "{s|\*+开始||g; s|您的助力码为|：|g}")
    [ -n "${codes}" ] && break
  done
  echo ${codes}
}

## 汇总
function Cat_All {
  echo -e "本脚本从最后一个正常的日志中寻找互助码，某些账号缺失则代表在最后一个正常的日志中没有找到。"
  echo -e "\n东东农场："
  Cat_Scodes fruit "的东东农场好友互助码" | perl -pe "s|的东东农场好友互助码||g"
  echo -e "\n东东萌宠："
  Cat_Scodes pet "的东东萌宠好友互助码" | perl -pe "s|的东东萌宠好友互助码||g"
  echo -e "\n种豆得豆："
  Cat_Scodes plantBean "的京东种豆得豆好友互助码" | perl -pe "s|的京东种豆得豆好友互助码||g"
  echo -e "\n京喜工厂："
  Cat_Scodes dreamFactory "的京喜工厂好友互助码" | perl -pe "s|的京喜工厂好友互助码||g"
  echo -e "\n东东工厂："
  Cat_Scodes jdfactory "的东东工厂好友互助码" | perl -pe "s|的东东工厂好友互助码||g"
  echo -e "\n疯狂的JOY："
  Cat_Scodes crazy_joy "的crazyJoy任务好友互助码" | perl -pe "s|的crazyJoy任务好友互助码||g"
  echo -e "\n京东赚赚："
  Cat_Scodes jdzz "的京东赚赚好友互助码" | perl -pe "s|的京东赚赚好友互助码||g"
  echo -e "\n京喜农场："
  Cat_Scodes jxnc "的京喜农场好友互助码" | perl -pe "s|的京喜农场好友互助码||g"
  echo -e "\n口袋书店："
  Cat_ScodesBookShop
  echo -e "\n签到领现金："
  Cat_ScodesCash
}

## 执行并写入日志
LogTime=$(date "+%Y-%m-%d-%H-%M-%S")
LogFile="${LogDir}/export_sharecodes/${LogTime}.log"
[ ! -d "${LogDir}/export_sharecodes" ] && mkdir -p ${LogDir}/export_sharecodes
touch ${LogFile}
Cat_All | perl -pe "s| |\n|g" | tee ${LogFile}
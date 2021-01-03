#!/usr/bin/env bash

## Author: Evine Deng
## Source: https://github.com/EvineDeng/jd-base
## Modified： 2021-01-03
## Version： v3.1.0

## 判断环境
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

## 导入配置文件
. ${ShellDir}/config/config.sh

## 删除运行js脚本的旧日志
function Rm_JsLog {
  LogFileList=$(ls -l ${LogDir}/*/*.log | awk '{print $9}')
  for log in ${LogFileList}
  do
    LogDate=$(echo ${log} | awk -F "/" '{print $NF}' | cut -c1-10)   #文件名比文件属性获得的日期要可靠
    if [[ $(uname -s) == Darwin ]]
    then
      DiffTime=$(($(date +%s) - $(date -j -f "%Y-%m-%d" "${LogDate}" +%s)))
    else
      DiffTime=$(($(date +%s) - $(date +%s -d "${LogDate}")))
    fi
    [ ${DiffTime} -gt $((${RmLogDaysAgo} * 86400)) ] && rm -vf ${log}
  done
}

# 删除git_pull.sh的运行日志
function Rm_GitPullLog {
  if [[ $(uname -s) == Darwin ]]
  then
    DateDelLog=$(date -v-${RmLogDaysAgo}d "+%Y-%m-%d")
  else
    DateDelLog=$(date "+%Y-%m-%d" -d "${RmLogDaysAgo} days ago")
  fi
  LineEndGitPull=$[$(cat ${LogDir}/git_pull.log | grep -n "系统时间：${DateDelLog}" | head -1 | awk -F ":" '{print $1}') - 3]
  [ ${LineEndGitPull} -gt 0 ] && perl -i -ne "{print unless 1 .. ${LineEndGitPull} }" ${LogDir}/git_pull.log
}

## 运行
if [ -n "${RmLogDaysAgo}" ]; then
  Rm_JsLog
  Rm_GitPullLog
fi
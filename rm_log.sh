#!/usr/bin/env bash

## Author: Evine Deng
## Source: https://github.com/EvineDeng/jd-base
## Modified： 2020-12-19
## Version： v3.0.2

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

LogDir=${ShellDirDir}/log

## 导入配置文件
. ${ShellDir}/config/config.sh

## 删除日志
if [ -n "${RmLogDaysAgo}" ]; then

  ## 删除运行js脚本的旧日志
  LogFileList=$(ls -l ${LogDir}/j*_*/*.log | awk '{print $9}')
  for log in ${LogFileList}
  do
    LogDate=$(echo ${log} | awk -F "/" '{print $NF}' | cut -c1-10)   #文件名比文件属性获得的日期要可靠
    if [[ $(uname -s) == Darwin ]]
    then
      DiffTime=$(($(date +%s) - $(date -j -f "%Y-%m-%d" "${LogDate}" +%s)))
    else
      DiffTime=$(($(date +%s) - $(date +%s -d "${LogDate}")))
    fi
    [ ${DiffTime} -gt $((${RmLogDaysAgo} * 86400)) ] && rm -f ${log}
  done

  # 删除git_pull.sh的运行日志
  DateDelLog=$(date "+%Y-%m-%d" -d "${RmLogDaysAgo} days ago")
  LineEndGitPull=$[$(cat ${LogDir}/git_pull.log | grep -n "系统时间：${DateDelLog}" | head -1 | awk -F ":" '{print $1}') - 3]
  perl -i -ne "{print unless 1 .. ${LineEndGitPull} }" ${LogDir}/git_pull.log

fi
#!/usr/bin/env bash

## Author: Evine Deng
## Source: https://github.com/EvineDeng/jd-base
## Modified： 2021-01-22
## Version： v3.5.0

## 文件路径、脚本网址、文件版本以及各种环境的判断
ShellDir=${JD_DIR:-$(cd $(dirname $0); pwd)}
LogDir=${ShellDir}/log
ScriptsDir=${ShellDir}/scripts
FileConf=${ShellDir}/config/config.sh
DateToday=$(date "+%Y-%m-%d")
[[ ${ANDROID_RUNTIME_ROOT}${ANDROID_ROOT} ]] && Opt="P" || Opt="E"

## 导出互助码的通用程序
function Cat_Scodes {
  if [ -d ${LogDir}/jd_$1 ] && [[ $(ls ${LogDir}/jd_$1) != "" ]]; then
    cd ${LogDir}/jd_$1
    for log in $(ls -r); do
      case $1 in
        bookshop)
          codes=$(perl -pe "s|信息获取成功\n||g" ${log} | grep -${Opt} "您的好友助力码为" | perl -pe "{s|您的好友助力码为||g; s|用户||g}")
          ;;
        cash)
          codes=$(perl -0777 -pe "s|\*+\n+||g" ${log} | grep -${Opt} "您的助力码为" | perl -pe "{s|\*+开始||g; s|您的助力码为|：|g}")
          ;;
        *)
          codes=$(grep -${Opt} $2 ${log} | perl -pe "s| ||")
          ;;
      esac
      [[ ${codes} ]] && break
    done
    [[ ${codes} ]] && echo ${codes} || echo "从日志中未找到任何互助码..."
  else
    echo "还没有产生日志..."
  fi
}

## 汇总
function Cat_All {
  echo -e "本脚本从最后一个正常的日志中寻找互助码，某些账号缺失则代表在最后一个正常的日志中没有找到。\n\n本脚本只搜索长期活动的互助码，短期活动的互助码请直接在原日志中查看。"
  for ((i=1; i<${#Name1[*]}; i++)); do
    echo -e "\n${Name2[i]}："
    Cat_Scodes "${Name1[i]}" "的${Name2[i]}好友互助码" | perl -pe "s|的${Name2[i]}好友互助码||g"
  done
}

## 执行并写入日志
LogTime=$(date "+%Y-%m-%d-%H-%M-%S")
LogFile="${LogDir}/export_sharecodes/${LogTime}.log"
Name1=(fruit pet plantBean dreamFactory jdfactory crazy_joy jdzz jxnc bookshop cash)
Name2=(东东农场 东东萌宠 京东种豆得豆 京喜工厂 东东工厂 crazyJoy任务 京东赚赚 京喜农场 口袋书店 签到领现金)
[ ! -d "${LogDir}/export_sharecodes" ] && mkdir -p ${LogDir}/export_sharecodes
Cat_All | perl -pe "{s|京东种豆|种豆|; s|crazyJoy任务|疯狂的JOY|; s| |\n|g}" | tee ${LogFile}
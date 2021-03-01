#!/usr/bin/env bash

## 路径、环境判断
ShellDir=$(cd "$(dirname "$0")";pwd)
LogDir=${ShellDir}/log
Tips="从日志中未找到任何互助码"

## 所有有互助码的活动，只需要把脚本名称去掉前缀 jd_ 后列在 Name1 中，将其中文名称列在 Name2 中即可。Name1 和 Name2 中两个名称必须一一对应。
Name1=(fruit pet plantBean dreamFactory jdfactory crazy_joy jdzz jxnc bookshop cash sgmh cfd)
Name2=(东东农场 东东萌宠 京东种豆得豆 京喜工厂 东东工厂 crazyJoy任务 京东赚赚 京喜农场 口袋书店 签到领现金 闪购盲盒 京喜财富岛)

## 导出互助码的通用程序
function Cat_Scodes {
  if [ -d ${LogDir}/jd_$1 ] && [[ $(ls ${LogDir}/jd_$1) != "" ]]; then
    cd ${LogDir}/jd_$1
    for log in $(ls -r); do
      case $# in
        1)
          [ $1 != "cfd" ] && codes=$(cat ${log} | grep -E "开始【京东账号|您的(好友)?助力码为" | uniq | perl -0777 -pe "{s|\*||g; s|开始||g; s|\n您的(好友)?助力码为(：)?:?|：|g; s|，.+||g}" | perl -ne '{print if /：/}')
          [ $1 == "cfd" ] && codes=$(cat ${log} | grep -E "开始【京东账号|【🏖岛主】你的互助码" | uniq | perl -0777 -pe "{s|\*||g; s|开始||g; s|\n【🏖岛主】你的互助码(：)?:?|：|g; s|，.+||g}" | perl -ne '{print if /：/}')
          ;;
        2)
          codes=$(grep -E $2 ${log} | perl -pe "{s| ||g; s|$2||g}")
          ;;
      esac
      [[ ${codes} ]] && break
    done
    [[ ${codes} ]] && echo "${codes}" | sed s/[[:space:]]//g || echo ${Tips}
  else
    echo "未运行过 jd_$1 脚本，未产生日志"
  fi
}

## 汇总
function Cat_All {
  echo -e "\n本脚本从最后一个正常的日志中寻找互助码，某些账号缺失则代表在最后一个正常的日志中未找到。"
  for ((i=0; i<${#Name1[*]}; i++)); do
    echo -e "\n${Name2[i]}："
    [[ $(Cat_Scodes "${Name1[i]}" "的${Name2[i]}好友互助码") == ${Tips} ]] && Cat_Scodes "${Name1[i]}" || Cat_Scodes "${Name1[i]}" "的${Name2[i]}好友互助码"
  done
}

## 执行并写入日志
LogTime=$(date "+%Y-%m-%d-%H-%M-%S")
LogFile="${LogDir}/export_sharecodes/${LogTime}.log"
[ ! -d "${LogDir}/export_sharecodes" ] && mkdir -p ${LogDir}/export_sharecodes
Cat_All | perl -pe "{s|京东种豆|种豆|; s|crazyJoy任务|疯狂的JOY|}" | tee ${LogFile}

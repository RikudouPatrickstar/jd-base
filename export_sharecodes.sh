#!/usr/bin/env bash

## 路径、环境判断
ShellDir=$(cd "$(dirname "$0")";pwd)
LogDir=${ShellDir}/log
Tips="从日志中未找到任何互助码"

## 所有有互助码的活动，只需要把脚本名称去掉前缀 jd_ 后列在 Name1 中，将其中文名称列在 Name2 中，对应config.sh 中互助码后缀列在 Name3 中即可。
## Name1、 Name2 和 Name3 中的三个名称必须一一对应。
Name1=(fruit pet plantBean dreamFactory jdfactory crazy_joy jdzz jxnc bookshop cash sgmh cfd)
Name2=(东东农场 东东萌宠 京东种豆得豆 京喜工厂 东东工厂 crazyJoy任务 京东赚赚 京喜农场 口袋书店 签到领现金 闪购盲盒 京喜财富岛)
Name3=(Fruit Pet Bean DreamFactory JdFactory Joy Jdzz Jxnc BookShop Cash Sgmh Cfd)

## 获取Cookie个数
CookieNum=$(grep -E "Cookie[0-9]{1,}=" ${ShellDir}/config/config.sh | wc -l)

## 导出互助码的通用程序
function Cat_Scodes {
  if [ -d ${LogDir}/jd_$2 ] && [[ $(ls ${LogDir}/jd_$2) != "" ]]; then
    cd ${LogDir}/jd_$2
    ## 导出Cookie列表助力码变量
    for log in $(ls -r); do
      case $# in
        3)
          [ $2 != "cfd" ] && codes=$(cat ${log} | grep -E "开始【京东账号|您的(好友)?助力码为" | uniq | perl -0777 -pe "{s|\*||g; s|开始||g; s|\n您的(好友)?助力码为(：)?:?|：|g; s|，.+||g}" | sed -r "s/【京东账号/My$3/;s/】.*?：/=\"/;s/】.*?/=\"/;s/$/\"/")
          [ $2 == "cfd" ] && codes=$(cat ${log} | grep -E "开始【京东账号|【🏖岛主】你的互助码" | uniq | perl -0777 -pe "{s|\*||g; s|开始||g; s|\n【🏖岛主】你的互助码(：)?:?|：|g; s|，.+||g}" | sed -r "s/【京东账号/My$3/;s/】.*?：/=\"/;s/】.*?/=\"/;s/$/\"/;s/\(每次运行都变化,不影响\)//")
          ;;
        4)
          [ $2 != "jxnc" ] && codes=$(grep -E $4 ${log} | sed -r "s/【京东账号/My$3/;s/（.*?】/=\"/;s/$/\"/")
          [ $2 == "jxnc" ] && codes=$(grep -E $4 ${log} | sed -r "s/【京东账号/My$3/;s/（.*?smp\":/=/;s/,.*?//")
          ;;
      esac
      [[ ${codes} ]] && break
    done
    ## 导出为他人助力变量
    HelpCodes=""
    for ((num=1;num<=$1;num++));do
        HelpCodes=${HelpCodes}"\${My"$3${num}"}@"
    done
    HelpCodes=$(echo ${HelpCodes} | sed -r "s/@$//")
    ForOtherCodes=""
    for ((num=1;num<=$1;num++));do
        ForOtherCodes=${ForOtherCodes}"ForOther"$3${num}"=\""${HelpCodes}"\"\n"
    done
    [[ ${codes} ]] && echo -e "${codes}\n\n${ForOtherCodes}" | sed s/[[:space:]]//g || echo ${Tips}
  else
    echo "未运行过 jd_$2 脚本，未产生日志"
  fi
}

## 汇总
function Cat_All {
  echo -e "\n从最后一个正常的日志中寻找互助码，仅供参考。"
  for ((i=0; i<${#Name1[*]}; i++)); do
    echo -e "\n${Name2[i]}："
    [[ $(Cat_Scodes "${CookieNum}" "${Name1[i]}" "${Name3[i]}" "的${Name2[i]}好友互助码") == ${Tips} ]] && Cat_Scodes "${CookieNum}" "${Name1[i]}" "${Name3[i]}" || Cat_Scodes "${CookieNum}" "${Name1[i]}" "${Name3[i]}" "的${Name2[i]}好友互助码"
  done
}

## 执行并写入日志
LogTime=$(date "+%Y-%m-%d-%H-%M-%S")
LogFile="${LogDir}/export_sharecodes/${LogTime}.log"
[ ! -d "${LogDir}/export_sharecodes" ] && mkdir -p ${LogDir}/export_sharecodes
Cat_All | perl -pe "{s|京东种豆|种豆|; s|crazyJoy任务|疯狂的JOY|}" | tee ${LogFile}

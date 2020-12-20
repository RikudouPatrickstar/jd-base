#!/usr/bin/env bash

## Author: Evine Deng
## Source: https://github.com/EvineDeng/jd-base
## Modified： 2020-12-18
## Version： v3.0.3

## 路径
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

ScriptsDir=${ShellDir}/scripts
FileConf=${ShellDir}/config/config.sh
FileConfSample=${ShellDir}/sample/config.sh.sample
LogDir=${ShellDir}/log
ListScripts=$(ls ${ScriptsDir} | grep -E "j[dr]_\w+\.js" | perl -pe "s|\.js||")
ListCron=${ShellDir}/config/crontab.list
CurrentCron=$(crontab -l)

## 导入config.sh
function Import_Conf {
  if [ -f ${FileConf} ]
  then
    . ${FileConf}
  else
    echo "配置文件 ${FileConf} 不存在，请先按教程配置好该文件..."
    exit 1
  fi
}

## 更新crontab
function Detect_Cron {
  if [[ $(cat ${ListCron}) != ${CurrentCron} ]]; then
    crontab ${ListCron}
  fi
}

## 用户数量UserSum
function Count_UserSum {
  i=1
  while [ ${i} -le 1000 ]
  do
    TmpCK=Cookie${i}
    eval CookieTmp=$(echo \$${TmpCK})
    if [ -n "${CookieTmp}" ]
    then
      UserSum=${i}
    else
      break
    fi
    let i++
  done
}

## 组合JD_COOKIE
function Combin_JD_COOKIE {
  CookieALL=""
  i=1
  while [ ${i} -le ${UserSum} ]
  do
    TmpCK=Cookie${i}
    eval CookieTemp=$(echo \$${TmpCK})
    CookieALL="${CookieALL}&${CookieTemp}"
    let i++
  done
  export JD_COOKIE=$(echo ${CookieALL} | perl -pe "s|^&+||")
}

## 组合FRUITSHARECODES
function Combin_FRUITSHARECODES {
  ForOtherFruitALL=""
  i=1
  while [ ${i} -le ${UserSum} ]
  do
    TmpFR=ForOtherFruit${i}
    eval ForOtherFruitTemp=$(echo \$${TmpFR})
    ForOtherFruitALL="${ForOtherFruitALL}&${ForOtherFruitTemp}@e6e04602d5e343258873af1651b603ec@52801b06ce2a462f95e1d59d7e856ef4@e2fd1311229146cc9507528d0b054da8@6dc9461f662d490991a31b798f624128"
    let i++
  done
  export FRUITSHARECODES=$(echo ${ForOtherFruitALL} | perl -pe "{s|^&+||; s|^@+||; s|&@|&|g}")
}

## 组合PETSHARECODES
function Combin_PETSHARECODES {
  ForOtherPetALL=""
  i=1
  while [ ${i} -le ${UserSum} ]
  do
    TmpPT=ForOtherPet${i}
    eval ForOtherPetTemp=$(echo \$${TmpPT})
    ForOtherPetALL="${ForOtherPetALL}&${ForOtherPetTemp}"
    let i++
  done
  export PETSHARECODES=$(echo ${ForOtherPetALL} | perl -pe "{s|^&+||; s|^@+||; s|&@|&|g}")
}

## 组合PLANT_BEAN_SHARECODES
function Combin_PLANT_BEAN_SHARECODES {
  ForOtherBeanALL=""
  i=1
  while [ ${i} -le ${UserSum} ]
  do
    TmpPB=ForOtherBean${i}
    eval ForOtherBeanTemp=$(echo \$${TmpPB})
    ForOtherBeanALL="${ForOtherBeanALL}&${ForOtherBeanTemp}@mze7pstbax4l7u5ggn5y2olhfy@3nwlq2wyvmz7sn4d5akh4rnrczsih2dehcx7as4ym6fgb3q7y5tq@olmijoxgmjutybihibx67mwivxbag4rjviz3cji@rsuben7ys7sfbu5eub7knbibke"
    let i++
  done
  export PLANT_BEAN_SHARECODES=$(echo ${ForOtherBeanALL} | perl -pe "{s|^&+||; s|^@+||; s|&@|&|g}")
}

## 组合DREAM_FACTORY_SHARE_CODES
function Combin_DREAM_FACTORY_SHARE_CODES {
  ForOtherDreamFactoryALL=""
  i=1
  while [ ${i} -le ${UserSum} ]
  do
    TmpDF=ForOtherDreamFactory${i}
    eval ForOtherDreamFactoryTemp=$(echo \$${TmpDF})
    ForOtherDreamFactoryALL="${ForOtherDreamFactoryALL}&${ForOtherDreamFactoryTemp}"
    let i++
  done
  export DREAM_FACTORY_SHARE_CODES=$(echo ${ForOtherDreamFactoryALL} | perl -pe "{s|^&+||; s|^@+||; s|&@|&|g}")
}

## 组合DDFACTORY_SHARECODES
function Combin_DDFACTORY_SHARECODES {
  ForOtherJdFactoryALL=""
  i=1
  while [ ${i} -le ${UserSum} ]
  do
    TmpJF=ForOtherJdFactory${i}
    eval ForOtherJdFactoryTemp=$(echo \$${TmpJF})
    ForOtherJdFactoryALL="${ForOtherJdFactoryALL}&${ForOtherJdFactoryTemp}"
    let i++
  done
  export DDFACTORY_SHARECODES=$(echo ${ForOtherJdFactoryALL} | perl -pe "{s|^&+||; s|^@+||; s|&@|&|g}")
}

## 设置JD_BEAN_SIGN_STOP_NOTIFY或JD_BEAN_SIGN_NOTIFY_SIMPLE
function Combin_JD_BEAN_SIGN_NOTIFY {
  case ${NotifyBeanSign} in
    0)
      export JD_BEAN_SIGN_STOP_NOTIFY="true"
      export JD_BEAN_SIGN_NOTIFY_SIMPLE=""
      ;;
    1)
      export JD_BEAN_SIGN_STOP_NOTIFY=""
      export JD_BEAN_SIGN_NOTIFY_SIMPLE="true"
      ;;
    *)
      export JD_BEAN_SIGN_STOP_NOTIFY=""
      export JD_BEAN_SIGN_NOTIFY_SIMPLE=""
      ;;
  esac
}

## 组合UN_SUBSCRIBES
function Combin_UN_SUBSCRIBES {
  export UN_SUBSCRIBES="${goodPageSize}\n${shopPageSize}\n${jdUnsubscribeStopGoods}\n${jdUnsubscribeStopShop}"
}

## 组合函数汇总
function Set_Env {
  Count_UserSum
  Combin_JD_COOKIE
  Combin_FRUITSHARECODES
  Combin_PETSHARECODES
  Combin_PLANT_BEAN_SHARECODES
  Combin_DREAM_FACTORY_SHARE_CODES
  Combin_DDFACTORY_SHARECODES
  Combin_JD_BEAN_SIGN_NOTIFY
  Combin_UN_SUBSCRIBES
}

## 随机延迟判断
function Random_Delay {
  if [ -n "${RandomDelay}" ] && [ ${RandomDelay} -gt 0 ]; then
    CurMin=$(date "+%M")
    if [ ${CurMin} -gt 2 ] && [ ${CurMin} -lt 30 ]; then
      sleep $((${RANDOM} % ${RandomDelay}))
    elif [ ${CurMin} -gt 31 ] && [ ${CurMin} -lt 59 ]; then
      sleep $((${RANDOM} % ${RandomDelay}))
    fi
  fi
}

## 使用说明
function Help {
  echo -e "本脚本的用法为：\n"
  if [ -n "${isDocker}" ]
  then
    echo -e "1. bash jd xxx      # 如果设置了随机延迟并且当时时间不在0-2、30-31、59分内，将随机延迟一定秒数\n"
    echo -e "2. bash jd xxx now  # 无论是否设置了随机延迟，均立即运行\n"
  else
    echo -e "1. bash jd.sh xxx      # 如果设置了随机延迟并且当时时间不在0-2、30-31、59分内，将随机延迟一定秒数\n"
    echo -e "2. bash jd.sh xxx now  # 无论是否设置了随机延迟，均立即运行\n"
  fi
  echo -e "无需输入后缀\".js\"，另外，如果前缀是\"jd_\"的话前缀也可以省略，当前有以下脚本可以运行（包括尚未被lxk0301大佬放进docker下crontab的脚本）：\n"
  echo -e "${ListScripts}\n"
}

## 运行京东脚本
function Run_Js {
  Import_Conf && Detect_Cron && Set_Env

  if [[ $1 == jr_* ]]; then
    FileName=$(echo $1 | perl -pe "s|\.js||")
  else
    FileName=$(echo $1 | perl -pe "{s|jd_||; s|\.js||; s|^|jd_|}")
  fi

  if [ -f ${ScriptsDir}/${FileName}.js ]; then
    [ $# -eq 1 ] && Random_Delay
    LogTime=$(date "+%Y-%m-%d-%H-%M-%S")
    LogFile="${LogDir}/${FileName}/${LogTime}.log"
	  [ ! -d ${LogDir}/${FileName} ] && mkdir -p ${LogDir}/${FileName}
    cd ${ScriptsDir}
    node ${FileName}.js | tee ${LogFile}
  else
    echo -e "$1 脚本未找到，请检查是否输入准确...\n"
    Help
  fi
}

## 命令检测
case $# in
  0)
    Help
    ;;
  1)
    Run_Js $1
    ;;
  2)
    if [[ $2 == now ]]; then
      Run_Js $1 $2
    else
      echo -e "命令输入错误...\n"
      Help
    fi
    ;;
  *)
    echo -e "命令过多...\n"
    Help
    ;;
esac
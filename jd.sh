#!/usr/bin/env bash

## Author: Evine Deng
## Source: https://github.com/EvineDeng/jd-base
## Modified： 2020-12-30
## Version： v3.6.0

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
ConfigDir=${ShellDir}/config
FileConf=${ConfigDir}/config.sh
FileConfSample=${ShellDir}/sample/config.sh.sample
LogDir=${ShellDir}/log
ListScripts=$(ls ${ScriptsDir} | grep -E "j[dr]_\w+\.js" | perl -pe "s|\.js||")
ListCron=${ConfigDir}/crontab.list

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
  if [[ $(cat ${ListCron}) != $(crontab -l) ]]; then
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

## 组合Cookie和互助码子程序
function Combin_Sub {
  CombinAll=""
  i=1
  while [ $i -le ${UserSum} ]
  do
    Tmp1=$1$i
    eval Tmp2=$(echo \$${Tmp1})
    if [ $# -eq 2 ]
    then
      CombinAll="${CombinAll}&${Tmp2}@$2"
    else
      CombinAll="${CombinAll}&${Tmp2}"
    fi
    let i++
  done
  echo ${CombinAll} | perl -pe "{s|^&||; s|^@+||; s|&@|&|g; s|@+|@|g}"
}

## 组合Cookie与互助码
function Combin_All {
  export JD_COOKIE=$(Combin_Sub Cookie)
  export FRUITSHARECODES=$(Combin_Sub ForOtherFruit "e6e04602d5e343258873af1651b603ec@52801b06ce2a462f95e1d59d7e856ef4@e2fd1311229146cc9507528d0b054da8@6dc9461f662d490991a31b798f624128@5efc7fdbb8e0436f8694c4c393359576")
  export PETSHARECODES=$(Combin_Sub ForOtherPet)
  export PLANT_BEAN_SHARECODES=$(Combin_Sub ForOtherBean "mze7pstbax4l7u5ggn5y2olhfy@3nwlq2wyvmz7sn4d5akh4rnrczsih2dehcx7as4ym6fgb3q7y5tq@olmijoxgmjutybihibx67mwivxbag4rjviz3cji@rsuben7ys7sfbu5eub7knbibke@mze7pstbax4l7dmo4vq6wz7vgu@4npkonnsy7xi3mi4ngwtraxgzwabeyj7oky5rly")
  export DREAM_FACTORY_SHARE_CODES=$(Combin_Sub ForOtherDreamFactory "xYd7cjQ3c1LyUse79rEFnw==@6E5_eFU3YHRLTljqYh_B1fg9iKwFvbWQsugw1xHcY3Q=@5AnP-NWntIbO2rEf58NCnA==@CNt5BX1eD8Tw-Wq045YSWg==@phEELHGm3o7VKPIyiBO3Vw==")
  export DDFACTORY_SHARECODES=$(Combin_Sub ForOtherJdFactory)
  export JDZZ_SHARECODES=$(Combin_Sub ForOtherJdzz)
  export JDJOY_SHARECODES=$(Combin_Sub ForOtherJoy)
}

## 转换JD_BEAN_SIGN_STOP_NOTIFY或JD_BEAN_SIGN_NOTIFY_SIMPLE
function Trans_JD_BEAN_SIGN_NOTIFY {
  case ${NotifyBeanSign} in
    0)
      export JD_BEAN_SIGN_STOP_NOTIFY="true"
      ;;
    1)
      export JD_BEAN_SIGN_NOTIFY_SIMPLE="true"
      ;;
  esac
}

## 转换UN_SUBSCRIBES
function Trans_UN_SUBSCRIBES {
  export UN_SUBSCRIBES="${goodPageSize}\n${shopPageSize}\n${jdUnsubscribeStopGoods}\n${jdUnsubscribeStopShop}"
}

## 申明全部变量
function Set_Env {
  Count_UserSum
  Combin_All
  Trans_JD_BEAN_SIGN_NOTIFY
  Trans_UN_SUBSCRIBES
}

## 随机延迟子程序
function Random_DelaySub {
  CurDelay=$((${RANDOM} % ${RandomDelay} + 1))
  echo -e "\n命令未添加 \"now\"，随机延迟 ${CurDelay} 秒后再执行任务，如需立即终止，请按 CTRL+C...\n"
  sleep ${CurDelay}
}

## 随机延迟判断
function Random_Delay {
  if [ -n "${RandomDelay}" ] && [ ${RandomDelay} -gt 0 ]; then
    CurMin=$(date "+%M")
    if [ ${CurMin} -gt 2 ] && [ ${CurMin} -lt 30 ]; then
      Random_DelaySub
    elif [ ${CurMin} -gt 31 ] && [ ${CurMin} -lt 59 ]; then
      Random_DelaySub
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
    echo -e "3. bash jd hangup   # 重启挂机程序\n"
  else
    echo -e "1. bash jd.sh xxx      # 如果设置了随机延迟并且当时时间不在0-2、30-31、59分内，将随机延迟一定秒数\n"
    echo -e "2. bash jd.sh xxx now  # 无论是否设置了随机延迟，均立即运行\n"
    echo -e "3. bash jd.sh hangup   # 重启挂机程序\n"
  fi
  echo -e "针对用法1、用法2中的\"xxx\"，无需输入后缀\".js\"，另外，如果前缀是\"jd_\"的话前缀也可以省略...\n"
  echo -e "当前有以下脚本可以运行（包括尚未被lxk0301大佬放进docker下crontab的脚本，但不含自定义脚本）：\n"
  echo -e "${ListScripts}\n"
}

## 运行挂机脚本
function Run_HangUp {
  Import_Conf && Detect_Cron && Set_Env

  HangUpJs="jd_crazy_joy_coin"

  
  for js in ${HangUpJs}
  do
    if [[ $(ps -ef | grep "${js}" | grep -v "grep") != "" ]]; then
      if [ -n "${isDocker}" ]
      then
        ps -ef | grep "${js}" | grep -v "grep" | awk '{print $1}' | xargs kill -9
      else
        ps -ef | grep "${js}" | grep -v "grep" | awk '{print $2}' | xargs kill -9
      fi
    fi
  done

  for js in ${HangUpJs}
  do
    cd ${ScriptsDir}
    LogTime=$(date "+%Y-%m-%d-%H-%M-%S")
    LogFile="${LogDir}/${js}/${LogTime}.log"
    touch ${LogFile}
    nohup node ${js}.js > ${LogFile} &
  done
}

## 运行京东脚本
function Run_Normal {
  Import_Conf && Detect_Cron && Set_Env
  
  FileNameTmp1=$(echo $1 | perl -pe "s|\.js||")
  FileNameTmp2=$(echo $1 | perl -pe "{s|jd_||; s|\.js||; s|^|jd_|}")
  SeekDir="${ScriptsDir} ${ScriptsDir}/backUp ${ConfigDir}"
  FileName=""
  WhichDir=""

  for dir in ${SeekDir}
  do
    if [ -f ${dir}/${FileNameTmp1}.js ]; then
      FileName=${FileNameTmp1}
      WhichDir=${dir}
      break
    elif [ -f ${dir}/${FileNameTmp2}.js ]; then
      FileName=${FileNameTmp2}
      WhichDir=${dir}
      break
    fi
  done
  
  if [ -n "${FileName}" ] && [ -n "${WhichDir}" ]
  then
    [ $# -eq 1 ] && Random_Delay
    LogTime=$(date "+%Y-%m-%d-%H-%M-%S")
    LogFile="${LogDir}/${FileName}/${LogTime}.log"
    [ ! -d ${LogDir}/${FileName} ] && mkdir -p ${LogDir}/${FileName}
    cd ${WhichDir}
    node ${FileName}.js | tee ${LogFile}
  else
    echo -e "\n在${ScriptsDir}、${ScriptsDir}/backUp、${ConfigDir}三个目录下均未检测到 $1 脚本的存在，请确认...\n"
    Help
  fi
}

## 命令检测
case $# in
  0)
    echo
    Help
    ;;
  1)
    if [[ $1 == hangup ]]; then
      Run_HangUp
    else
      Run_Normal $1
    fi
    ;;
  2)
    if [[ $2 == now ]]; then
      Run_Normal $1 $2
    else
      echo -e "\n命令输入错误...\n"
      Help
    fi
    ;;
  *)
    echo -e "\n命令过多...\n"
    Help
    ;;
esac
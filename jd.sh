#!/usr/bin/env bash

## 路径
ShellDir=$(cd "$(dirname "$0")";pwd)
ConfigDir=${ShellDir}/config
FileConf=${ConfigDir}/config.sh
ScriptsDir=${ShellDir}/scripts
LogDir=${ShellDir}/log
ListScripts=($(cd ${ScriptsDir}; ls *.js | grep -E "j[drx]_"))
ListCron=${ConfigDir}/crontab.list


## 导入 config.sh
function Import_Conf {
  if [ -f ${FileConf} ]
  then
    . ${FileConf}
    if [ -z "${Cookie1}" ]; then
      echo -e "请先在 config.sh 中配置好 Cookie\n"
      exit 1
    fi
  else
    echo -e "配置文件 ${FileConf} 不存在，请先按教程配置好该文件\n"
    exit 1
  fi
}


## 更新 Crontab
function Detect_Cron {
  if [[ $(cat ${ListCron}) != $(crontab -l) ]]; then
    crontab ${ListCron}
  fi
}


## 用户数量 UserSum
function Count_UserSum {
  for ((i=1; i<=35; i++)); do
    Tmp=Cookie$i
    CookieTmp=${!Tmp}
    [[ ${CookieTmp} ]] && UserSum=$i || break
  done
}


## 组合 Cookie 和互助码子程序
function Combin_Sub {
  CombinAll=""
  for ((i=1; i<=${UserSum}; i++)); do
    for num in ${TempBlockCookie}; do
      if [[ $i -eq $num ]]; then
        continue 2
      fi
    done
    Tmp1=$1$i
    Tmp2=${!Tmp1}
    CombinAll="${CombinAll}&${Tmp2}"
  done
  echo ${CombinAll} | perl -pe "{s|^&||; s|^@+||; s|&@|&|g; s|@+&|&|g; s|@+|@|g; s|@+$||}"
}


## 组合 Cookie、Token 与互助码
function Combin_All {
  export JD_COOKIE=$(Combin_Sub Cookie)
  export FRUITSHARECODES=$(Combin_Sub ForOtherFruit)
  export PETSHARECODES=$(Combin_Sub ForOtherPet)
  export PLANT_BEAN_SHARECODES=$(Combin_Sub ForOtherBean)
  export DREAM_FACTORY_SHARE_CODES=$(Combin_Sub ForOtherDreamFactory)
  export DDFACTORY_SHARECODES=$(Combin_Sub ForOtherJdFactory)
  export JDZZ_SHARECODES=$(Combin_Sub ForOtherJdzz)
  export JDJOY_SHARECODES=$(Combin_Sub ForOtherJoy)
  export JXNC_SHARECODES=$(Combin_Sub ForOtherJxnc)
  export BOOKSHOP_SHARECODES=$(Combin_Sub ForOtherBookShop)
  export JD_CASH_SHARECODES=$(Combin_Sub ForOtherCash)
  export JDSGMH_SHARECODES=$(Combin_Sub ForOtherSgmh)
  export JDCFD_SHARECODES=$(Combin_Sub ForOtherCfd)
  export JDGLOBAL_SHARECODES=$(Combin_Sub ForOtherGlobal)
}


## 转换 JD_BEAN_SIGN_STOP_NOTIFY 或 JD_BEAN_SIGN_NOTIFY_SIMPLE
function Trans_JD_BEAN_SIGN_NOTIFY {
  case ${NotifyBeanSign} in
    0)
      export JD_BEAN_SIGN_STOP_NOTIFY="true"
      ;;
    2)
      export JD_BEAN_SIGN_STOP_NOTIFY="false"
      export JD_BEAN_SIGN_NOTIFY_SIMPLE="false"
      ;;
    *)
      export JD_BEAN_SIGN_STOP_NOTIFY="false"
      export JD_BEAN_SIGN_NOTIFY_SIMPLE="true"
      ;;
  esac
}


## 转换 UN_SUBSCRIBES
function Trans_UN_SUBSCRIBES {
  export UN_SUBSCRIBES="${goodPageSize}\n${shopPageSize}\n${jdUnsubscribeStopGoods}\n${jdUnsubscribeStopShop}"
}


## 设置获取共享池助力码个数
function Get_HelpPoolNum {
  HelpPoolNum=$( printf "%d" "$HelpPoolNum" 2> /dev/null )
  if [ $HelpPoolNum -lt 0 ] || [ $HelpPoolNum -gt 25 ]; then
      HelpPoolNum=0
  fi
  HelpPoolNum16=0x$( printf %x $HelpPoolNum )
}


## 申明全部变量
function Set_Env {
  Count_UserSum
  Combin_All
  Trans_JD_BEAN_SIGN_NOTIFY
  Trans_UN_SUBSCRIBES
  Get_HelpPoolNum
}


## 随机延迟
function Random_Delay {
  if [[ -n ${RandomDelay} ]] && [[ ${RandomDelay} -gt 0 ]]; then
    CurMin=$(date "+%-M")
    if [[ ${CurMin} -gt 2 && ${CurMin} -lt 30 ]] || [[ ${CurMin} -gt 31 && ${CurMin} -lt 59 ]]; then
      CurDelay=$((${RANDOM} % ${RandomDelay} + 1))
      echo -e "\n命令未添加 \"now\"，随机延迟 ${CurDelay} 秒后再执行任务，如需立即终止，请按 CTRL+C\n"
      sleep ${CurDelay}
    fi
  fi
}


## 使用说明
function Help {
  echo -e "本脚本的用法为："
  echo -e "1. bash jd.sh xxx      # 如果设置了随机延迟并且当时时间不在 0-2、30-31、59 分内，将随机延迟一定秒数"
  echo -e "2. bash jd.sh xxx now  # 无论是否设置了随机延迟，均立即运行"
  echo -e "3. bash jd.sh hangup   # 重启挂机程序"
  echo -e "4. bash jd.sh resetpwd # 重置控制面板用户名和密码"
  echo -e "\n针对用法1、用法2中的 \"xxx\"，无需输入后缀 \".js\"，另外，如果前缀是 \"jd_\" 的话前缀也可以省略。"
  echo -e "当前有以下脚本可以运行（仅列出 jd_scripts 中以 jd_、jr_、jx_ 开头的脚本）："
  cd ${ScriptsDir}
  for ((i=0; i<${#ListScripts[*]}; i++)); do
    Name=$(grep "new Env" ${ListScripts[i]} | awk -F "'|\"" '{print $2}')
    echo -e "$(($i + 1)).${Name}：${ListScripts[i]}"
  done
}


## 查找脚本路径与准确的文件名
function Find_FileDir {
  FileNameTmp1=$(echo $1 | perl -pe "s|\.js||")
  FileNameTmp2=$(echo $1 | perl -pe "{s|jd_||; s|\.js||; s|^|jd_|}")
  SeekDir="${ScriptsDir} ${ScriptsDir}/backUp ${DiyDir}"
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
}


## nohup
function Run_Nohup {
  nohup node $1.js 2>&1 > ${LogFile} &
}


## 运行挂机脚本
function Run_HangUp {
  HangUpJs="jd_crazy_joy_coin"
  cd ${ScriptsDir}
  for js in ${HangUpJs}; do
    Import_Conf ${js}
    Count_UserSum
    Set_Env
    if type pm2 >/dev/null 2>&1; then
      pm2 stop ${js}.js 2>/dev/null
      pm2 flush
      pm2 start -a ${js}.js --watch "${ScriptsDir}/${js}.js" --name="${js}"
    else
      if [ $(. /etc/os-release && echo "$ID") == "openwrt" ]; then
        if [[ $(ps | grep "${js}" | grep -v "grep") != "" ]]; then
          ps | grep "${js}" | grep -v "grep" | awk '{print $1}' | xargs kill -9
        fi
      else
        if [[ $(ps -ef | grep "${js}" | grep -v "grep") != "" ]]; then
          ps -ef | grep "${js}" | grep -v "grep" | awk '{print $2}' | xargs kill -9
        fi
      fi
      [ ! -d ${LogDir}/${js} ] && mkdir -p ${LogDir}/${js}
      LogTime=$(date "+%Y-%m-%d-%H-%M-%S")
      LogFile="${LogDir}/${js}/${LogTime}.log"
      Run_Nohup ${js} >/dev/null 2>&1
    fi
  done
}


## 重置密码
function Reset_Pwd {
  cp -f ${ShellDir}/sample/auth.json ${ConfigDir}/auth.json
  echo -e "控制面板重置成功，用户名：admin，密码：password\n"
}


## 运行京东脚本
function Run_Normal {
  Import_Conf $1
  Detect_Cron
  Count_UserSum
  Find_FileDir $1
  Set_Env

  if [[ ${FileName} ]] && [[ ${WhichDir} ]]
  then
    [ $# -eq 1 ] && Random_Delay
    LogTime=$(date "+%Y-%m-%d-%H-%M-%S")
    LogFile="${LogDir}/${FileName}/${LogTime}.log"
    [ ! -d ${LogDir}/${FileName} ] && mkdir -p ${LogDir}/${FileName}
    cd ${WhichDir}
    sed -i "s/randomCount = .* [0-9]* : [0-9]*;/randomCount = $HelpPoolNum;/g" ${FileName}.js
    sed -i "s/randomCount=.*?0x[0-9a-f]*:0x[0-9a-f]*;/randomCount=$HelpPoolNum16;/g" ${FileName}.js
    node ${FileName}.js 2>&1 | tee ${LogFile}
  else
    echo -e "\n在有关目录下均未检测到 $1 脚本的存在\n"
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
    case $1 in
      hangup)
        Run_HangUp
        ;;
      resetpwd)
        Reset_Pwd
        ;;
      *)
        Run_Normal $1
        ;;
    esac
    ;;
  2)
    case $2 in
      now)
        Run_Normal $1 $2
        ;;
      *)
        echo -e "\n命令输入错误\n"
        Help
        ;;
    esac
    ;;
  *)
    echo -e "\n命令输入错误\n"
    Help
    ;;
esac
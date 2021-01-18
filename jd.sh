#!/usr/bin/env bash

## Author: Evine Deng
## Source: https://github.com/EvineDeng/jd-base
## Modified： 2021-01-18
## Version： v3.6.13

## 路径
if [ -z "${JD_DIR}" ]
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
ListScripts=$(ls ${ScriptsDir} | grep -E "j[drx]_\w+\.js" | perl -pe "s|\.js||")
ListCron=${ConfigDir}/crontab.list

## 导入config.sh
function Import_Conf {
  if [ -f ${FileConf} ]
  then
    . ${FileConf}
    if [ -z "${Cookie1}" ]; then
      echo -e "请先在config.sh中配置好Cookie...\n"
      exit 1
    fi
  else
    echo -e "配置文件 ${FileConf} 不存在，请先按教程配置好该文件...\n"
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
    case $# in
      1)
        CombinAll="${CombinAll}&${Tmp2}"
        ;;
      2)
        CombinAll="${CombinAll}&${Tmp2}@$2"
        ;;
      3)
        if [ $(($i % 2)) -eq 1 ]; then
          CombinAll="${CombinAll}&${Tmp2}@$2"
        else
          CombinAll="${CombinAll}&${Tmp2}@$3"
        fi
        ;;
      4)
        case $(($i % 3)) in
          1)
            CombinAll="${CombinAll}&${Tmp2}@$2"
            ;;
          2)
            CombinAll="${CombinAll}&${Tmp2}@$3"
            ;;
          0)
            CombinAll="${CombinAll}&${Tmp2}@$4"
            ;;
        esac
        ;;
    esac
    let i++
  done
  echo ${CombinAll} | perl -pe "{s|^&||; s|^@+||; s|&@|&|g; s|@+|@|g}"
}

## 组合Cookie、Token与互助码，用户自己的放在前面，我的放在后面
function Combin_All {
  export JD_COOKIE=$(Combin_Sub Cookie)
  export FRUITSHARECODES=$(Combin_Sub ForOtherFruit "e6e04602d5e343258873af1651b603ec@52801b06ce2a462f95e1d59d7e856ef4@5bc73a365ff74a559bdee785ea97fcc5" "6d402dcfae1043fba7b519e0d6579a6f@5efc7fdbb8e0436f8694c4c393359576@6dc9461f662d490991a31b798f624128" "e2fd1311229146cc9507528d0b054da8@30f29addd75d44e88fb452bbfe9f2110@1d02fc9e0e574b4fa928e84cb1c5e70b")
  export PETSHARECODES=$(Combin_Sub ForOtherPet)
  export PLANT_BEAN_SHARECODES=$(Combin_Sub ForOtherBean "mze7pstbax4l7u5ggn5y2olhfy@3nwlq2wyvmz7sn4d5akh4rnrczsih2dehcx7as4ym6fgb3q7y5tq@kjno6k3dvsn4jrzs4yspokax3ud5cqqedkdv6bi@olmijoxgmjutzoaamsfbxewhiix3znzagvxr6ia" "mze7pstbax4l7dmo4vq6wz7vgu@rsuben7ys7sfbu5eub7knbibke@olmijoxgmjutzexyge246xwmaxy43t3jsqc74zy" "olmijoxgmjutybihibx67mwivxbag4rjviz3cji@m6mhupvfogvf5kuwe3c5h5fptd2syad6cznse4i@4npkonnsy7xi3mi4ngwtraxgzwabeyj7oky5rly")
  export DREAM_FACTORY_SHARE_CODES=$(Combin_Sub ForOtherDreamFactory "xYd7cjQ3c1LyUse79rEFnw==@6E5_eFU3YHRLTljqYh_B1fg9iKwFvbWQsugw1xHcY3Q=@540bj4eZfgx_G4gtfA4_9A==@5AnP-NWntIbO2rEf58NCnA==" "CNt5BX1eD8Tw-Wq045YSWg==@phEELHGm3o7VKPIyiBO3Vw==@z-tDlNURI5HvM4MtehtjDA==@dzM8y-1G-D1pt6If32xQ0A==" "XCO7kpq00mMmYwOag2O_CQ==@48wAKDXkEE-RNwNs7W48MlW77AibIyB8QyD22ydJ4NI=@fzeFwj_aACkm-VgdmLqOhw==")
  export DDFACTORY_SHARECODES=$(Combin_Sub ForOtherJdFactory)
  export JDZZ_SHARECODES=$(Combin_Sub ForOtherJdzz)
  export JDJOY_SHARECODES=$(Combin_Sub ForOtherJoy)
  export JXNC_SHARECODES=$(Combin_Sub ForOtherJxnc "e8dd4ed6a87055a2b37982066d8910da@7d645f46ad80cddf7d6d91b4fc39f572")
  export JXNCTOKENS=$(Combin_Sub TokenJxnc)
  export BOOKSHOP_SHARECODES=$(Combin_Sub ForOtherBookShop "aea9a9e0bc9e4f49b0515020e7bbaa90@4e012467d3da47268df4ef821a9f0662@8c3cefd0dcbb4b83a32f4dffde72fa26")
  export JD_CASH_SHARECODES=$(Combin_Sub ForOtherCash "Vl1uMrk@9qqduGQCv26BJ-NiHfexAcc_08V6HjOh@eU9Yauq2M6918jzSw3oX0w@IRwwaei6bvkgnjM" "Vl1uMrmyZvs@eU9YarrjM_53p27dyXQa3g@9Jq0uXglsVCqKd5kEv-D@9YmhuUccv2W6J9VsHue5AQqJ" "eU9YarjhYqonpDrTzXcR1Q@eU9Ya77gZK5z-TqHn3UWhQ@eU9Yaui2ZP4gpG-Gz3EThA@eU9YaeizbvQnpG_SznIS0w")
  export JDNIAN_SHARECODES=$(Combin_Sub ForOtherNian "cgxZWifbeu-Wpm2AD0bol5Cu@cgxZ-tAo8DJqM5xu3ogeOY7OXkOQ2Lw_ympGPITqNcceAad8Y1ph2UOXS-LOq3PUCqmgYjpt-td3CYw18qw@cgxZdTXtIrzev12aC1eu5yr9cCz6N7HkgPrFkYPPzBDaaWjtjA3fokuFPMA@cgxZLWaFIb7S4gvPZ1jlo3Ru3_zhiy3nnTsS4mQaaZc" "cgxZWifbeu_a6gmFRGbg6Lh1SmQdF0DUmQ@cgxZdTXtIu6J7ljIXVGv6VoOs61gdyYXgT0ctAtCCykLsWw5accav11_0dI@cgxZ-fMU8RF0M5dV3r4QOsLKNQRnjyuoh9haQkLPPMH6fJjgVIkoZy5ww_K-I2JJ@cgxZ-OAB8S5NPaJF0LUYNl1oYE9tdRYPs2e2kWz3RrqEMgqutLWhZlw" "cgxZdTXtIuyLvwyYXgWh7YMhXtAVbaE0Ozjf2OUdEJZsvB1JgZ-5v5F_bDc@cgxZdTXtI-iI6FycAFH7u-1dMgurAZjyJ58rjmucS1-MNDQLuuFxg0MP4nk@cgxZdTXtIr7e6AzPXQT666v1QrNvBgZa6pzohEggDpwCCoJqAmI3w2yaU_s@cgxZdTXtIb7b4gbIXQSu6lqwwvtQXfo34CxB9K3ndzOzMDWK93LMQ85BnsQ")
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
  if [ -n "${JD_DIR}" ]
  then
    echo -e "1. bash jd xxx      # 如果设置了随机延迟并且当时时间不在0-2、30-31、59分内，将随机延迟一定秒数\n"
    echo -e "2. bash jd xxx now  # 无论是否设置了随机延迟，均立即运行\n"
    echo -e "3. bash jd hangup   # 重启挂机程序\n"
    echo -e "4. bash jd resetpwd # 重置控制面板用户名和密码\n"
  else
    echo -e "1. bash jd.sh xxx      # 如果设置了随机延迟并且当时时间不在0-2、30-31、59分内，将随机延迟一定秒数\n"
    echo -e "2. bash jd.sh xxx now  # 无论是否设置了随机延迟，均立即运行\n"
    echo -e "3. bash jd.sh hangup   # 重启挂机程序\n"
    echo -e "4. bash jd.sh resetpwd # 重置控制面板用户名和密码\n"
  fi
  echo -e "针对用法1、用法2中的\"xxx\"，无需输入后缀\".js\"，另外，如果前缀是\"jd_\"的话前缀也可以省略...\n"
  echo -e "当前有以下脚本可以运行（包括尚未被lxk0301大佬放进docker下crontab的脚本，但不含自定义脚本）：\n"
  echo -e "${ListScripts}\n"
}

## nohup sub
function Run_NohupSub {
  nohup node ${js}.js > ${LogFile} &
}

## nohup
function Run_Nohup {
  for js in ${HangUpJs}
  do
    if [[ $(ps -ef | grep "${js}" | grep -v "grep") != "" ]]; then
      if [ -n "${JD_DIR}" ]
      then
        ps -ef | grep "${js}" | grep -v "grep" | awk '{print $1}' | xargs kill -9
      else
        ps -ef | grep "${js}" | grep -v "grep" | awk '{print $2}' | xargs kill -9
      fi
    fi
  done

  for js in ${HangUpJs}
  do
    [ ! -d ${LogDir}/${js} ] && mkdir -p ${LogDir}/${js}
    LogTime=$(date "+%Y-%m-%d-%H-%M-%S")
    LogFile="${LogDir}/${js}/${LogTime}.log"
    Run_NohupSub >/dev/null 2>&1
  done
}

## pm2
function Run_Pm2 {
  for js in ${HangUpJs}
  do
    pm2 restart ${js}.js || pm2 start ${js}.js
  done
}

## 运行挂机脚本
function Run_HangUp {
  Import_Conf && Detect_Cron && Set_Env
  HangUpJs="jd_crazy_joy_coin"
  cd ${ScriptsDir}
  if type pm2 >/dev/null 2>&1; then
    Run_Pm2 2>/dev/null
  else
    Run_Nohup
  fi
}

## 重置密码
function Reset_Pwd {
  cp -f ${ShellDir}/sample/auth.json ${ConfigDir}/auth.json
  echo -e "控制面板重置成功，用户名：admin，密码：adminadmin\n"
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
    elif [[ $1 == resetpwd ]]; then
      Reset_Pwd
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

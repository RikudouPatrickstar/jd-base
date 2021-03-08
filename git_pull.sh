#!/usr/bin/env bash

## 文件路径、脚本网址、文件版本以及各种环境的判断
ShellDir=$(cd "$(dirname "$0")";pwd)
ShellJd=${ShellDir}/jd.sh
LogDir=${ShellDir}/log
[ ! -d ${LogDir} ] && mkdir -p ${LogDir}
ScriptsDir=${ShellDir}/scripts
ConfigDir=${ShellDir}/config
FileConf=${ConfigDir}/config.sh
FileConfSample=${ShellDir}/sample/config.sh.sample
ListCron=${ConfigDir}/crontab.list
ListCronLxk=${ScriptsDir}/docker/crontab_list.sh
ListTask=${LogDir}/task.list
ListJs=${LogDir}/js.list
ListJsAdd=${LogDir}/js-add.list
ListJsDrop=${LogDir}/js-drop.list
ContentVersion=${ShellDir}/version
ContentNewTask=${ShellDir}/new_task
ContentDropTask=${ShellDir}/drop_task
SendCount=${ShellDir}/send_count
ScriptsURL=https://github.com.cnpmjs.org/RikudouPatrickstar/jd_scripts
ShellURL=https://github.com.cnpmjs.org/RikudouPatrickstar/jd-base

## 更新 jd-base
function Git_PullShell {
  echo -e "更新 jd-base 脚本\n"
  cd ${ShellDir}
  git fetch --all
  ExitStatusShell=$?
  git reset --hard origin/v3
}

## 每次执行 git_pull 随机生成，每天次数随机，更新时间随机，更新秒数随机，至少 6 次，至多 12 次，大部分为 8-10 次，符合正态分布。
function Update_Cron {
  if [ -f ${ListCron} ]; then
    RanMin=$((${RANDOM} % 60))
    RanSleep=$((${RANDOM} % 56))
    RanHourArray[0]=$((${RANDOM} % 3))
    for ((i=1; i<14; i++)); do
      j=$(($i - 1))
      tmp=$((${RANDOM} % 3 + ${RanHourArray[j]} + 2))
      [[ ${tmp} -lt 24 ]] && RanHourArray[i]=${tmp} || break
    done
    RanHour=${RanHourArray[0]}
    for ((i=1; i<${#RanHourArray[*]}; i++)); do
      RanHour="${RanHour},${RanHourArray[i]}"
    done
    perl -i -pe "s|.+(bash git_pull.+)|${RanMin} ${RanHour} \* \* \* sleep ${RanSleep} && \1|" ${ListCron}
    crontab ${ListCron}
  fi
}

## 克隆 jd_scripts
function Git_CloneScripts {
  echo -e "克隆 jd_scripts 脚本\n"
  git clone -b master ${ScriptsURL} ${ScriptsDir}
  ExitStatusScripts=$?
  echo
}

## 更新 jd_scripts
function Git_PullScripts {
  echo -e "更新 jd_scripts 脚本\n"
  cd ${ScriptsDir}
  git fetch --all
  ExitStatusScripts=$?
  git reset --hard origin/master
  echo
}

## 获取用户数量 UserSum
function Count_UserSum {
  i=1
  while [ $i -le 1000 ]; do
    Tmp=Cookie$i
    CookieTmp=${!Tmp}
    [[ ${CookieTmp} ]] && UserSum=$i || break
    let i++
  done
}

## 修改 jd_scripts 的函数汇总
function Change_ALL {
  if [ -f ${FileConf} ]; then
    . ${FileConf}
    if [ -n "${Cookie1}" ]; then
      Count_UserSum
    fi
  fi
}

## 检测 jd_scripts 远程仓库中的 docker/crontab_list.sh
## 检测定时任务是否有变化，此函数会在 log 文件夹下生成四个文件，分别为：
## task.list    crontab.list 中的所有任务清单，仅保留脚本名
## js.list      上述检测文件中用来运行 jd_scripts 的清单（去掉后缀 .js，非运行脚本的不会包括在内）
## js-add.list  如果上述检测文件增加了定时任务，这个文件内容将不为空
## js-drop.list 如果上述检测文件删除了定时任务，这个文件内容将不为空
function Diff_Cron {
  if [ -f ${ListCron} ]; then
    grep "${ShellDir}/" ${ListCron} | grep -E " j[drx]_\w+" | perl -pe "s|.+ (j[drx]_\w+).*|\1|" | sort -u > ${ListTask}
    cat ${ListCronLxk} | grep -E "j[drx]_\w+\.js" | perl -pe "s|.+(j[drx]_\w+)\.js.+|\1|" | sort -u > ${ListJs}
    grep -vwf ${ListTask} ${ListJs} > ${ListJsAdd}
    grep -vwf ${ListJs} ${ListTask} > ${ListJsDrop}
  else
    echo -e "${ListCron} 文件不存在，请先定义你自己的 crontab.list\n"
  fi
}

## 发送删除失效定时任务的消息
function Notify_DropTask {
  cd ${ShellDir}
  node update.js
  [ -f ${ContentDropTask} ] && rm -f ${ContentDropTask}
}

## 发送新的定时任务消息
function Notify_NewTask {
  cd ${ShellDir}
  node update.js
  [ -f ${ContentNewTask} ] && rm -f ${ContentNewTask}
}

## 检测配置文件版本
function Notify_Version {
  [ -f "${SendCount}" ] && [[ $(cat ${SendCount}) != ${VerConfSample} ]] && rm -f ${SendCount}
  UpdateDate=$(grep " Date: " ${FileConfSample} | awk -F ": " '{print $2}')
  UpdateContent=$(grep " Update Content: " ${FileConfSample} | awk -F ": " '{print $2}')
  if [ -f ${FileConf} ] && [[ "${VerConf}" != "${VerConfSample}" ]] && [[ ${UpdateDate} == $(date "+%Y-%m-%d") ]]
  then
    if [ ! -f ${SendCount} ]; then
      echo -e "检测到配置文件 config.sh.samlpe 有更新\n\n日期: ${UpdateDate}\n版本: ${VerConf} -> ${VerConfSample}\n内容: ${UpdateContent}\n\n" | tee ${ContentVersion}
      echo -e "如需更新请手动操作\n本消息只在配置文件更新当天发送一次!" >> ${ContentVersion}
      cd ${ShellDir}
      node update.js
      if [ $? -eq 0 ]; then
        echo "${VerConfSample}" > ${SendCount}
        [ -f ${ContentVersion} ] && rm -f ${ContentVersion}
      fi
    fi
  else
    [ -f ${ContentVersion} ] && rm -f ${ContentVersion}
    [ -f ${SendCount} ] && rm -f ${SendCount}
  fi
}

## npm install 子程序，判断是否安装有 yarn
function Npm_InstallSub {
  if ! type yarn >/dev/null 2>&1
  then
    npm install || npm install --registry=https://registry.npm.taobao.org
  else
    echo -e "检测到本机安装了 yarn，使用 yarn 替代 npm\n"
    yarn install || yarn install --registry=https://registry.npm.taobao.org
  fi
}

## npm install
function Npm_Install {
  cd ${ScriptsDir}
  if [[ "${PackageListOld}" != "$(cat package.json)" ]]; then
    echo -e "检测到 package.json 有变化，运行 npm install\n"
    Npm_InstallSub
    if [ $? -ne 0 ]; then
      echo -e "\nnpm install 运行不成功，自动删除 ${ScriptsDir}/node_modules 后再次尝试一遍"
      rm -rf ${ScriptsDir}/node_modules
    fi
    echo
  fi

  if [ ! -d ${ScriptsDir}/node_modules ]; then
    echo -e "运行 npm install\n"
    Npm_InstallSub
    if [ $? -ne 0 ]; then
      echo -e "\nnpm install 运行不成功，自动删除 ${ScriptsDir}/node_modules\n"
      echo -e "请进入 ${ScriptsDir} 目录后手动运行 npm install\n"
      echo -e "当 npm install 失败时，如果检测到有新任务或失效任务，只会输出日志，不会自动增加或删除定时任务\n"
      echo -e "3\n"
      sleep 1
      echo -e "2\n"
      sleep 1
      echo -e "1\n"
      sleep 1
      rm -rf ${ScriptsDir}/node_modules
    fi
  fi
}

## 输出是否有新的定时任务
function Output_ListJsAdd {
  if [ -s ${ListJsAdd} ]; then
    echo -e "检测到有新的定时任务：\n"
    cat ${ListJsAdd}
    echo
  fi
}

## 输出是否有失效的定时任务
function Output_ListJsDrop {
  if [ ${ExitStatusScripts} -eq 0 ] && [ -s ${ListJsDrop} ]; then
    echo -e "检测到有失效的定时任务：\n"
    cat ${ListJsDrop}
    echo
  fi
}

## 自动删除失效的脚本与定时任务，需要5个条件：
##   1.AutoDelCron 设置为 true
##   2.正常更新jd_scripts ，没有报错
##   3.js-drop.list不为空
##   4.crontab.list存在并且不为空
##   5.已经正常运行过npm install
## 检测 jd_scripts 仓库中的 docker/crontab_list.sh
## 如果检测到某个定时任务在上述检测文件中已删除，那么在本地也删除对应定时任务
function Del_Cron {
  if [ "${AutoDelCron}" = "true" ] && [ -s ${ListJsDrop} ] && [ -s ${ListCron} ] && [ -d ${ScriptsDir}/node_modules ]; then
    echo -e "开始尝试自动删除定时任务：\n"
    cat ${ListJsDrop}
    echo
    JsDrop=$(cat ${ListJsDrop})
    for Cron in ${JsDrop}
    do
      perl -i -ne "{print unless / ${Cron}( |$)/}" ${ListCron}
    done
    crontab ${ListCron}
    echo -e "成功删除失效的脚本与定时任务，当前的定时任务清单：\n\n--------------------------------------------------------------\n"
    crontab -l
    echo -e "\n--------------------------------------------------------------\n"
    if [ -d ${ScriptsDir}/node_modules ]; then
      echo -e "成功删除失效的定时任务：\n\n${JsDrop}\n" > ${ContentDropTask}
      Notify_DropTask
    fi
  fi
}

## 自动增加新的定时任务，需要5个条件：
##   1.AutoAddCron 设置为 true
##   2.正常更新jd_scripts ，没有报错
##   3.js-add.list不为空
##   4.crontab.list存在并且不为空
##   5.已经正常运行过npm install
## 检测 jd_scripts 仓库中的 docker/crontab_list.sh
## 如果检测到检测文件中增加新的定时任务，那么在本地也增加
## 本功能生效时，会自动从检测文件新增加的任务中读取时间，该时间为北京时间
function Add_Cron {
  if [ "${AutoAddCron}" = "true" ] && [ -s ${ListJsAdd} ] && [ -s ${ListCron} ] && [ -d ${ScriptsDir}/node_modules ]; then
    echo -e "开始尝试自动添加定时任务：\n"
    cat ${ListJsAdd}
    echo
    JsAdd=$(cat ${ListJsAdd})

    for Cron in ${JsAdd}
    do
      if [[ ${Cron} == jd_bean_sign ]]
      then
        echo "4 0,9 * * * bash ${ShellJd} ${Cron}" >> ${ListCron}
      else
        cat ${ListCronLxk} | grep -E "\/${Cron}\." | perl -pe "s|(^.+)node */scripts/(j[drx]_\w+)\.js.+|\1bash ${ShellJd} \2|" >> ${ListCron}
      fi
    done

    if [ $? -eq 0 ]
    then
      crontab ${ListCron}
      echo -e "成功添加新的定时任务，当前的定时任务清单：\n\n--------------------------------------------------------------\n"
      crontab -l
      echo -e "\n--------------------------------------------------------------\n"
      if [ -d ${ScriptsDir}/node_modules ]; then
        echo -e "成功添加新的定时任务：\n\n${JsAdd}" > ${ContentNewTask}
        Notify_NewTask
      fi
    else
      echo -e "添加新的定时任务出错，请手动添加\n"
      if [ -d ${ScriptsDir}/node_modules ]; then
        echo -e "尝试自动添加以下新的定时任务出错，请手动添加：\n\n${JsAdd}" > ${ContentNewTask}
        Notify_NewTask
      fi
    fi
  fi
}

## 在日志中记录时间与路径
echo -e "\n--------------------------------------------------------------\n"
echo -n "系统时间："
echo $(date "+%Y-%m-%d %H:%M:%S")
if [ "${TZ}" = "UTC" ]; then
  echo
  echo -n "北京时间："
  echo $(date -d "8 hour" "+%Y-%m-%d %H:%M:%S")
fi
echo -e "--------------------------------------------------------------\n"

## 更新 jd-base、检测配置文件版本
Git_PullShell
[[ $(date "+%-H") -le 2 ]] && Update_Cron
VerConfSample=$(grep " Version: " ${FileConfSample} | perl -pe "s|.+v((\d+\.?){3})|\1|")
[ -f ${FileConf} ] && VerConf=$(grep " Version: " ${FileConf} | perl -pe "s|.+v((\d+\.?){3})|\1|")
if [ ${ExitStatusShell} -eq 0 ]
then
  echo -e "\njd-base 更新完成\n"
else
  echo -e "\njd-base 更新失败，请检查原因后再次运行 git_pull.sh，或等待定时任务自动再次运行 git_pull.sh\n"
fi

## 克隆或更新 jd_scripts 
if [ ${ExitStatusShell} -eq 0 ]; then
  echo -e "--------------------------------------------------------------\n"
  [ -f ${ScriptsDir}/package.json ] && PackageListOld=$(cat ${ScriptsDir}/package.json)
  [ -d ${ScriptsDir}/.git ] && Git_PullScripts || Git_CloneScripts
fi

## 移除通知的部分内容
sed -i '/本脚本开源免费使用 By/d' ${ScriptsDir}/sendNotify.js

## 授予可执行权限
chmod +x ${ShellDir}/*sh

## 执行各函数
if [[ ${ExitStatusScripts} -eq 0 ]]
then
  echo -e "jd_scripts 更新完成\n"
  Change_ALL
  [ -d ${ScriptsDir}/node_modules ] && Notify_Version
  Diff_Cron
  Npm_Install
  Output_ListJsAdd
  Output_ListJsDrop
  Del_Cron
  Add_Cron
else
  echo -e "jd_scripts 更新失败，请检查原因或再次运行 git_pull.sh\n"
  Change_ALL
fi

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


## 导入配置文件
function Import_Conf {
  if [ -f ${FileConf} ]; then
    . ${FileConf}
  fi
}


## 重置远程仓库地址
function Reset_RepoUrl {
  if [[ ${JD_DIR} ]] && [[ ${ENABLE_RESET_REPO_URL} == true ]]; then
    if [ -d ${ShellDir}/.git ]; then
      cd ${ShellDir}
      git remote set-url origin ${ShellURL}
      git reset --hard
    fi
    if [ -d ${ScriptsDir}/.git ]; then
      cd ${ScriptsDir}
      git remote set-url origin ${ScriptsURL}
      git reset --hard
    fi
  fi
}


## 更新 jd-base 脚本
function Git_PullShell {
  echo -e "更新 jd-base 脚本\n"
  cd ${ShellDir}
  git fetch --all
  ExitStatusShell=$?
  git reset --hard origin/v3
  echo
}


## 更新 jd-base 脚本成功后的操作
function Git_PullShellNext {
  if [[ ${ExitStatusShell} -eq 0 ]]; then
    echo -e "更新 jd-base 脚本成功\n"
    [[ "${PanelDependOld}" != "${PanelDependNew}" ]] && cd ${ShellDir}/panel && Npm_Install panel
    Notify_Version
  else
    echo -e "更新 jd-base 脚本失败，请检查原因\n"
  fi
}


## 克隆 jd_scripts 脚本
function Git_CloneScripts {
  echo -e "克隆 jd_scripts 脚本\n"
  git clone -b master ${ScriptsURL} ${ScriptsDir}
  ExitStatusScripts=$?
  echo
}


## 更新 jd_scripts 脚本
function Git_PullScripts {
  echo -e "更新 jd_scripts 脚本\n"
  cd ${ScriptsDir}
  git fetch --all
  ExitStatusScripts=$?
  git reset --hard origin/master
  echo
}


## 给所有 shell 脚本赋予 755 权限
function Chmod_ShellScripts {
  shfiles=$(find ${ShellDir} 2> /dev/null)
  for shf in ${shfiles}; do
    if [ ${shf##*.} == 'sh' ]; then
      chmod 755 ${shf}
    fi
   done
}


## 获取用户数量 UserSum
function Count_UserSum {
  for ((i=1; i<=35; i++)); do
    Tmp=Cookie$i
    CookieTmp=${!Tmp}
    [[ ${CookieTmp} ]] && UserSum=$i || break
  done
}


## 检测文件：远程仓库 jd_scripts 中的 docker/crontab_list.sh
## 检测定时任务是否有变化，此函数会在 log 文件夹下生成四个文件，分别为：
## task.list    crontab.list 中的所有任务清单，仅保留脚本名
## js.list      上述检测文件中用来运行 jd_scripts 脚本的清单（去掉后缀.js，非运行脚本的不会包括在内）
## js-add.list  如果上述检测文件增加了定时任务，这个文件内容将不为空
## js-drop.list 如果上述检测文件删除了定时任务，这个文件内容将不为空
function Diff_Cron {
  if [ -f ${ListCron} ]; then
    if [ -n "${JD_DIR}" ]
    then
      grep -E " j[drx]_\w+" ${ListCron} | perl -pe "s|.+ (j[drx]_\w+).*|\1|" | sort -u > ${ListTask}
    else
      grep "${ShellDir}/" ${ListCron} | grep -E " j[drx]_\w+" | perl -pe "s|.+ (j[drx]_\w+).*|\1|" | sort -u > ${ListTask}
    fi
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
  ## 识别出两个文件的版本号
  VerConfSample=$(grep " Version: " ${FileConfSample} | perl -pe "s|.+v((\d+\.?){3})|\1|")
  [ -f ${FileConf} ] && VerConf=$(grep " Version: " ${FileConf} | perl -pe "s|.+v((\d+\.?){3})|\1|")
  
  ## 删除旧的发送记录文件
  [ -f "${SendCount}" ] && [[ $(cat ${SendCount}) != ${VerConfSample} ]] && rm -f ${SendCount}

  ## 识别出更新日期和更新内容
  UpdateDate=$(grep " Date: " ${FileConfSample} | awk -F ": " '{print $2}')
  UpdateContent=$(grep " Update Content: " ${FileConfSample} | awk -F ": " '{print $2}')

  ## 如果是今天，并且版本号不一致，则发送通知
  if [ -f ${FileConf} ] && [[ "${VerConf}" != "${VerConfSample}" ]] && [[ ${UpdateDate} == $(date "+%Y-%m-%d") ]]
  then
    if [ ! -f ${SendCount} ]; then
      echo -e "日期: ${UpdateDate}\n版本: ${VerConf} -> ${VerConfSample}\n内容: ${UpdateContent}\n\n" | tee ${ContentVersion}
      echo -e "如需更新请手动操作，仅更新当天通知一次!" >> ${ContentVersion}
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
    npm install --registry=https://mirrors.huaweicloud.com/repository/npm/ || npm install
  else
    echo -e "检测到本机安装了 yarn，使用 yarn 替代 npm\n"
    yarn install --registry=https://mirrors.huaweicloud.com/repository/npm/ || yarn install
  fi
}


## npm install
function Npm_Install {
  echo -e "检测到 $1 的依赖包有变化，运行 npm install\n"
  Npm_InstallSub
  if [ $? -ne 0 ]; then
    echo -e "\nnpm install 运行不成功，自动删除 $1/node_modules 后再次尝试一遍"
    rm -rf node_modules
  fi
  echo

  if [ ! -d node_modules ]; then
    echo -e "运行 npm install\n"
    Npm_InstallSub
    if [ $? -ne 0 ]; then
      echo -e "\nnpm install 运行不成功，自动删除 $1/node_modules\n"
      echo -e "请进入 $1 目录后手动运行 npm install\n"
      echo -e "3s\n"
      sleep 1
      echo -e "2s\n"
      sleep 1
      echo -e "1s\n"
      sleep 1
      rm -rf node_modules
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


## 自动删除失效的定时任务，需要5个条件：
##   1. AutoAddCron 设置为 true
##   2. 正常更新 jd_scripts 脚本，没有报错
##   3. js-drop.list 不为空
##   4. crontab.list 存在并且不为空
##   5. 已经正常运行过 npm install
## 检测文件：远程仓库 jd_scripts 中的 docker/crontab_list.sh
## 如果检测到某个定时任务在上述检测文件中已删除，那么在本地也删除对应定时任务
function Del_Cron {
  if [ "${AutoDelCron}" = "true" ] && [ -s ${ListJsDrop} ] && [ -s ${ListCron} ] && [ -d ${ScriptsDir}/node_modules ]; then
    echo -e "开始尝试自动删除定时任务如下：\n"
    cat ${ListJsDrop}
    echo
    JsDrop=$(cat ${ListJsDrop})
    for Cron in ${JsDrop}
    do
      perl -i -ne "{print unless / ${Cron}( |$)/}" ${ListCron}
    done
    crontab ${ListCron}
    echo -e "成功删除失效的脚本与定时任务\n\n"
    if [ -d ${ScriptsDir}/node_modules ]; then
      echo -e "删除失效的定时任务：\n\n${JsDrop}" > ${ContentDropTask}
      Notify_DropTask
    fi
  fi
}


## 自动增加新的定时任务，需要5个条件：
##   1. AutoAddCron 设置为 true
##   2. 正常更新 jd_scripts 脚本，没有报错
##   3. js-add.list 不为空
##   4. crontab.list 存在并且不为空
##   5. 已经正常运行过 npm install
## 检测文件：远程仓库 jd_scripts 中的 docker/crontab_list.sh
## 如果检测到检测文件中增加新的定时任务，那么在本地也增加
## 本功能生效时，会自动从检测文件新增加的任务中读取时间，该时间为北京时间
function Add_Cron {
  if [ "${AutoAddCron}" = "true" ] && [ -s ${ListJsAdd} ] && [ -s ${ListCron} ] && [ -d ${ScriptsDir}/node_modules ]; then
    echo -e "开始尝试自动添加定时任务如下：\n"
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
      echo -e "成功添加新的定时任务\n\n"
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

## 为额外的 js 脚本存放目录配置 lxk0301/jd_scripts 环境
function Set_DiyEnv {
  EnvFiles=(
    Env.min.js
    JS_USER_AGENTS.js
    USER_AGENTS.js
    index.js
    jdCookie.js
    sendNotify.js
  )
  for diy_dir in ${DiyDirs[*]}; do
    for env_file in ${EnvFiles[*]}; do
      cp -f ${ScriptsDir}/${env_file} ${ShellDir}/${diy_dir}/
    done
    [ -f ${ShellDir}/${diy_dir}/package.json ] && DiyDependOld=$(cat ${ShellDir}/${diy_dir}/package.json)
    if [ ${DiyPackgeJson} == "false" ]; then
      cp -f ${ScriptsDir}/package.json ${ShellDir}/${diy_dir}/
    fi
    [ -f ${ShellDir}/${diy_dir}/package.json ] && DiyDependNew=$(cat ${ShellDir}/${diy_dir}/package.json)
    if [ "${DiyDependOld}" != "${DiyDependNew}" ] || [ ! -d ${ShellDir}/${diy_dir}/node_modules ];then
      cd ${ShellDir}/${diy_dir} && Npm_Install ${diy_dir}
    fi
  done
}


## 在日志中记录时间与路径
echo -e "\n--------------------------------------------------------------\n"
echo -n "系统时间："
echo -e "$(date "+%Y-%m-%d %H:%M:%S")\n"
if [ "${TZ}" = "UTC" ]; then
  echo -n "北京时间："
  echo -e "$(date -d "8 hour" "+%Y-%m-%d %H:%M:%S")\n"
fi

## 导入配置，设置远程仓库地址，更新 jd-base 脚本，发送新配置通知
Import_Conf "git_pull"
Reset_RepoUrl
[ -f ${ShellDir}/panel/package.json ] && PanelDependOld=$(cat ${ShellDir}/panel/package.json)
Git_PullShell
[ -f ${ShellDir}/panel/package.json ] && PanelDependNew=$(cat ${ShellDir}/panel/package.json)
Git_PullShellNext

## 克隆或更新 jd_scripts 脚本
[ -f ${ScriptsDir}/package.json ] && ScriptsDependOld=$(cat ${ScriptsDir}/package.json)
[ -d ${ScriptsDir}/.git ] && Git_PullScripts || Git_CloneScripts
[ -f ${ScriptsDir}/package.json ] && ScriptsDependNew=$(cat ${ScriptsDir}/package.json)

## 执行各函数
if [[ ${ExitStatusScripts} -eq 0 ]]
then
  echo -e "更新 jd_scripts 脚本成功\n"
  sed -i '/本脚本开源免费使用 By/d' ${ScriptsDir}/sendNotify.js
  Diff_Cron
  [[ "${ScriptsDependOld}" != "${ScriptsDependNew}" ]] && cd ${ScriptsDir} && Npm_Install scripts
  Output_ListJsAdd
  Output_ListJsDrop
  Del_Cron
  Add_Cron
  Set_DiyEnv
else
  echo -e "更新 jd_scripts 脚本失败，请检查原因\n"
fi

## 给所有 shell 脚本赋予 755 权限
Chmod_ShellScripts

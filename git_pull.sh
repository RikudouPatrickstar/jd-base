#!/usr/bin/env bash

## Author: Evine Deng
## Source: https://github.com/EvineDeng/jd-base
## Modified： 2020-12-18
## Version： v3.0.0

## 文件路径、脚本网址、文件版本
[ -z "${isDocker}" ] && ShellDir=$(cd $(dirname $0); pwd)
[ -n "${isDocker}" ] && ShellDir=${JD_DIR}
LogDir=${ShellDir}/log
[ ! -d ${LogDir} ] && mkdir -p ${LogDir}
ScriptsDir=${ShellDir}/scripts
FileConf=${ShellDir}/config.sh
FileConfSample=${ShellDir}/sample/config.sh.sample
[ -f ${FileConf} ] && VerConf=$(grep -i "Version" ${FileConf} | perl -pe "s|.+v((\d+\.?){3})|\1|")
VerConfSample=$(grep -i "Version" ${FileConfSample} | perl -pe "s|.+v((\d+\.?){3})|\1|")
ListCron=${ShellDir}/crontab.list
ListTask=${LogDir}/task.list
ListJs=${LogDir}/js.list
ListJsAdd=${LogDir}/js-add.list
ListJsDrop=${LogDir}/js-drop.list
isGithub=$(grep "github" "${ShellDir}/.git/config")
isGitee=$(grep "gitee" "${ShellDir}/.git/config")
if [ -n "${isGithub}" ]; then
  ScriptsURL=https://github.com/lxk0301/jd_scripts
  ShellURL=https://github.com/EvineDeng/jd-base
elif [ -n "${isGitee}" ]; then
  ScriptsURL=https://gitee.com/lxk0301/jd_scripts
  ShellURL=https://gitee.com/evine/jd-base
fi

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

## 克隆js脚本
function Git_CloneScripts {
  echo -e "克隆JS脚本，原地址：${ScriptsURL}\n"
  git clone -b master ${ScriptsURL} ${ScriptsDir}
  echo
}

## 更新js脚本
function Git_PullScripts {
  echo -e "更新JS脚本，原地址：${ScriptsURL}\n"
  git -C ${ScriptsDir} fetch --all
  git -C ${ScriptsDir} reset --hard origin/master
  echo
}

## 更新shell脚本
function Git_PullShell {
  echo -e "更新shell脚本，原地址：${ShellURL}\n"
  git fetch --all
  git reset --hard origin/v3
  ExitStatusShell=$?
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

## 把config.sh中提供的所有账户的PIN附加在jd_joy_run.js中，让各账户相互进行宠汪汪赛跑助力
## 你的账号将按Cookie顺序被优先助力，助力完成再助力我的账号和lxk0301大佬的账号
function Change_JoyRunPins {
  Count_UserSum
  j=${UserSum}
  PinALL=""
  while [ ${j} -ge 1 ]
  do
    TmpCK=Cookie${j}
    eval CookieTemp=$(echo \$${TmpCK})
    PinTemp=$(echo ${CookieTemp} | perl -pe "{s|.*pt_pin=(.+);|\1|; s|%|\\\x|g}")
    PinTempFormat=$(printf ${PinTemp})
    PinALL="${PinTempFormat},${PinALL}"
    let j--
  done
  PinEvine="Evine,做一颗潇洒的蛋蛋,jd_7bb2be8dbd65c,jd_664ecc3b78945,277548856_m,米大眼老鼠,jd_6dc4f1ed66423,梦回马拉多纳,"
  FriendsArrEvine='"Evine", "做一颗潇洒的蛋蛋", "jd_7bb2be8dbd65c", "jd_664ecc3b78945", "277548856_m", "米大眼老鼠", "jd_6dc4f1ed66423", "梦回马拉多纳", '
  PinALL="${PinALL}${PinEvine}"
  perl -i -pe "{s|(let invite_pins = \[\")(.+\"\];?)|\1${PinALL}\2|; s|(let run_pins = \[\")(.+\"\];?)|\1${PinALL}\2|; s|(const friendsArr = \[)|\1${FriendsArrEvine}|}" ${ScriptsDir}/jd_joy_run.js
}

## 将我的invitecode加到脚本中
function Change_InviteCode {
  CodeHealth="'P04z54XCjVUnoaW5kBOUT6t\@P04z54XCjVUnoaW5uC5orRwbaXYMmbp8xnMhfqynp9iHqsxyg', 'P04z54XCjVUnoaW5m9cZ2b-2SkZxn-5OEbVdwM\@P04z54XCjVUnoaW5jcPD2X81XRPkzNn', 'P04z54XCjVUnoaW5m9cZ2asjngclP6bwGQx-n4\@P04z54XCjVUnoaW5uOanrVTc6XTCbVCmoLyWhx9og'"
  CodeZz="  'AfnMPwfg\@A3oT8SyUgFKev3u1PC_joQpaQqr6bl8E8\@AUWE5mauUmGZbCzL_1XVOkA\@ACTJRmqmYxTAOZz0\@AUWE5mfnDyWMJXTT-23hIlg\@A3afASgY-FKyU3ttBCOjgQkn4\@A3LTVSjkHGpmE0NBJBPDa',"
  perl -i -pe "s|(const inviteCodes = \[).*(\];?)|\1${CodeHealth}\2|" ${ScriptsDir}/jd_health.js
  perl -0777 -i -pe "s|(const inviteCodes = \[\n)(.+\n.+\n\])|\1${CodeZz}\n\2|" ${ScriptsDir}/jd_jdzz.js
}

## 修改lxk0301大佬js文件的函数汇总
function Change_ALL {
    Change_JoyRunPins
    Change_InviteCode
}

## 检测定时任务是否有变化，此函数会在Log文件夹下生成四个文件，分别为：
## task.list    crontab.list中的所有任务清单，仅保留脚本名
## js.list      scripts/docker/crontab_list.sh文件中用来运行js脚本的清单（去掉后缀.js，非运行脚本的不会包括在内）
## js-add.list  如果 scripts/docker/crontab_list.sh 增加了定时任务，这个文件内容将不为空
## js-drop.list 如果 scripts/docker/crontab_list.sh 删除了定时任务，这个文件内容将不为空
function Diff_Cron {
  if [ -f ${ListCron} ]; then
    grep -E " j[dr]_\w+" ${ListCron} | perl -pe "s|.+ (j[dr]_\w+).*|\1|" > ${ListTask}
    grep -E "j[dr]_\w+\.js" ${ScriptsDir}/docker/crontab_list.sh | perl -pe "s|.+(j[dr]_\w+)\.js.+|\1|" | sort > ${ListJs}
    grep -vwf ${ListTask} ${ListJs} > ${ListJsAdd}
    grep -vwf ${ListJs} ${ListTask} > ${ListJsDrop}
  else
    echo -e "${ListCron} 文件不存在，请先定义你自己的crontab.list...\n"
  fi
}

## 发送新的定时任务消息
function Notify_NewTask {
  node ${ShellDir}/update.js
  [ -f {LogDir}/new_task ] && rm -f {LogDir}/new_task
}

## 检测配置文件版本
function Notify_Version {
  if [ "${VerConf}" != "${VerConfSample}" ]
  then
    UpdateDate=$(grep -i "Date" ${FileConfSample} | awk -F ": " '{print $2}')
    echo -e "检测到配置文件config.sh.sample有更新\n\n更新日期: ${UpdateDate}\n新的版本: ${VerConfSample}\n当前版本: ${VerConf}\n"
    echo -e "检测到配置文件config.sh.sample有更新\n\n更新日期: ${UpdateDate}\n新的版本: ${VerConfSample}\n当前版本: ${VerConf}\n\n本消息只在配置文件更新当天发送一次。" > ${LogDir}/version
    if [[ ${UpdateDate} == $(date "+%Y-%m-%d") ]]
    then
      if [ $(date "+%H") -ge 9 ] && [ ! -f ${LogDir}/send_count ]; then
        node ${ShellDir}/update.js
        echo "1" > ${LogDir}/send_count
      fi
    else
      [ -f ${LogDir}/send_count ] && rm -f ${LogDir}/send_count
    fi
  else
    [ -f ${LogDir}/version ] && rm -f ${LogDir}/version
  fi
}

## npm install 子程序，判断是否为安卓
function NpmInstallSub {
  if [ -n "${isTermux}" ]
  then
    npm install --no-bin-links || npm install --no-bin-links --registry=https://registry.npm.taobao.org
  else
    npm install || npm install --registry=https://registry.npm.taobao.org
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
echo -e "\nSHELL脚本目录：${ShellDir}\n"
echo -e "JS脚本目录：${ScriptsDir}\n"
echo -e "--------------------------------------------------------------\n"

## 克隆或更新js脚本
cd ${ShellDir}
Import_Conf
if [ $? -eq 0 ]; then
  if [ -d ${ScriptsDir} ]; then
    Git_PullScripts
    ExitStatusScripts=$?
  else
    Git_CloneScripts
    ExitStatusScripts=$?
  fi
  [ -f ${ScriptsDir}/package.json ] && PackageListOld=$(cat ${ScriptsDir}/package.json)
fi

## 替换信息并检测定时任务变化情况
if [ ${ExitStatusScripts} -eq 0 ]
then
  echo -e "js脚本更新完成...\n"
  Change_ALL
  Diff_Cron
else
  echo -e "js脚本更新失败，请检查原因或再次运行git_pull.sh...\n"
  Change_ALL
fi

## 输出是否有新的定时任务
if [ ${ExitStatusScripts} -eq 0 ] && [ -s ${ListJsAdd} ]; then
  echo -e "检测到有新的定时任务：\n"
  cat ${ListJsAdd}
  echo
fi

## 输出是否有失效的定时任务
if [ ${ExitStatusScripts} -eq 0 ] && [ -s ${ListJsDrop} ]; then
  echo -e "检测到有失效的定时任务：\n"
  cat ${ListJsDrop}
  echo
fi

## 自动删除失效的脚本与定时任务，需要5个条件：1.AutoDelCron 设置为 true；2.正常更新js脚本，没有报错；3.js-drop.list不为空；4.crontab.list存在并且不为空；5.已经正常运行过npm install
## 如果检测到某个定时任务在 scripts/docker/crontab_list.sh 中已删除，那么在本地也删除对应定时任务
if [ ${ExitStatusScripts} -eq 0 ] && [ "${AutoDelCron}" = "true" ] && [ -s ${ListJsDrop} ] && [ -s ${ListCron} ] && [ -d ${ScriptsDir}/node_modules ]; then
  echo -e "开始尝试自动删除定时任务如下：\n"
  cat ${ListJsDrop}
  echo
  for Cron in $(cat ${ListJsDrop})
  do
    perl -i -ne "{print unless /\/${Cron}\./}" ${ListCron}
    rm -f "${ShellDir}/${Cron}.sh"
  done
  crontab ${ListCron}
  echo -e "成功删除失效的脚本与定时任务，当前的定时任务清单如下：\n\n--------------------------------------------------------------\n"
  crontab -l
  echo -e "\n--------------------------------------------------------------\n"
fi

## 自动增加新的定时任务，需要5个条件：1.AutoAddCron 设置为 true；2.正常更新js脚本，没有报错；3.js-add.list不为空；4.crontab.list存在并且不为空；5.已经正常运行过npm install
## 如果检测到 scripts/docker/crontab_list.sh 中增加新的定时任务，那么在本地也增加
## 本功能生效时，会自动从 scripts/docker/crontab_list.sh 文件新增加的任务中读取时间，该时间为北京时间
if [ ${ExitStatusScripts} -eq 0 ] && [ "${AutoAddCron}" = "true" ] && [ -s ${ListJsAdd} ] && [ -s ${ListCron} ] && [ -d ${ScriptsDir}/node_modules ]; then
  echo -e "开始尝试自动添加定时任务如下：\n"
  cat ${ListJsAdd}
  echo
  JsAdd=$(cat ${ListJsAdd})
  for Cron in ${JsAdd}
  do
    grep -E "\/${Cron}\." "${ScriptsDir}/docker/crontab_list.sh" | perl -pe "s|(^.+)node */scripts/(j[dr]_\w+)\.js.+|\1bash ${ShellDir}/jd.sh \2|"  >> ${ListCron}
  done
  if [ $? -eq 0 ]
  then
    crontab ${ListCron}
    echo -e "成功添加新的定时任务，当前的定时任务清单如下：\n\n--------------------------------------------------------------\n"
    crontab -l
    # echo -e "jd-base脚本成功添加新的定时任务：\n\n${JsAdd}" > {LogDir}/new_task
    # Notify_NewTask
    echo -e "\n--------------------------------------------------------------\n"
  else
    echo -e "添加新的定时任务出错，请手动添加...\n" 
    # echo -e "jd-base脚本尝试自动添加以下新的定时任务出错，请手动添加：\n\n${JsAdd}" > {LogDir}/new_task
    # Notify_NewTask
  fi
fi

## npm install
if [ ${ExitStatusScripts} -eq 0 ]; then
  cd ${ScriptsDir}
  isTermux=$(echo ${ANDROID_RUNTIME_ROOT})
  if [[ "${PackageListOld}" != "$(cat package.json)" ]]; then
    echo -e "检测到 ${ScriptsDir}/package.json 内容有变化，再次运行 npm install...\n"
    NpmInstallSub
    if [ $? -ne 0 ]; then
      echo -e "\nnpm install 运行不成功，自动删除 ${ScriptsDir}/node_modules 后再次尝试一遍..."
      rm -rf ${ScriptsDir}/node_modules
    fi
    echo
  fi
  if [ ! -d ${ScriptsDir}/node_modules ]; then
    echo -e "运行npm install...\n"
    NpmInstallSub
    if [ $? -ne 0 ]; then
      echo -e "\nnpm install 运行不成功，自动删除 ${ScriptsDir}/node_modules...\n\n请进入 ${ScriptsDir} 目录后手动运行 npm install...\n"
      rm -rf ${ScriptsDir}/node_modules
      exit 1
    fi
  fi
fi

## 更新shell脚本并检测配置文件版本
if [ $? -eq 0 ]; then
  cd ${ShellDir}
  echo -e "--------------------------------------------------------------\n"
  Git_PullShell
  if [ ${ExitStatusShell} -eq 0 ]
  then
    echo -e "\nshell脚本更新完成...\n"
    # Notify_Version
  else
    echo -e "\nshell脚本更新失败，请检查原因后再次运行git_pull.sh，或等待定时任务自动再次运行git_pull.sh...\n"
  fi
fi

#!/usr/bin/env bash

## Author: Evine Deng
## Source: https://github.com/EvineDeng/jd-base
## Modified： 2020-12-20
## Version： v3.3.2

## 文件路径、脚本网址、文件版本以及各种环境的判断
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

LogDir=${ShellDir}/log
[ ! -d ${LogDir} ] && mkdir -p ${LogDir}

ScriptsDir=${ShellDir}/scripts
FileConf=${ShellDir}/config/config.sh
FileDiy=${ShellDir}/config/diy.sh
FileConfSample=${ShellDir}/sample/config.sh.sample
[ -f ${FileConf} ] && VerConf=$(grep " Version: " ${FileConf} | perl -pe "s|.+v((\d+\.?){3})|\1|")
VerConfSample=$(grep " Version: " ${FileConfSample} | perl -pe "s|.+v((\d+\.?){3})|\1|")

ListCron=${ShellDir}/config/crontab.list
ListTask=${LogDir}/task.list
ListJs=${LogDir}/js.list
ListJsAdd=${LogDir}/js-add.list
ListJsDrop=${LogDir}/js-drop.list
ContentVersion=${ShellDir}/version
ContentNewTask=${ShellDir}/new_task
ContentDropTask=${ShellDir}/drop_task
SendCount=${ShellDir}/send_count

isGithub=$(grep "github" "${ShellDir}/.git/config")
isGitee=$(grep "gitee" "${ShellDir}/.git/config")
isTermux=$(echo ${ANDROID_RUNTIME_ROOT})

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
  ExitStatusScripts=$?
  echo
}

## 更新js脚本
function Git_PullScripts {
  echo -e "更新JS脚本，原地址：${ScriptsURL}\n"
  cd ${ScriptsDir}
  git fetch --all
  ExitStatusScripts=$?
  git reset --hard origin/master
  echo
}

## 更新shell脚本
function Git_PullShell {
  echo -e "更新shell脚本，原地址：${ShellURL}\n"
  cd ${ShellDir}
  git fetch --all
  ExitStatusShell=$?
  git reset --hard origin/v3
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
    grep -E " j[dr]_\w+" ${ListCron} | perl -pe "s|.+ (j[dr]_\w+).*|\1|" | uniq > ${ListTask}
    grep -E "j[dr]_\w+\.js" ${ScriptsDir}/docker/crontab_list.sh | perl -pe "s|.+(j[dr]_\w+)\.js.+|\1|" | sort > ${ListJs}
    grep -vwf ${ListTask} ${ListJs} > ${ListJsAdd}
    grep -vwf ${ListJs} ${ListTask} > ${ListJsDrop}
  else
    echo -e "${ListCron} 文件不存在，请先定义你自己的crontab.list...\n"
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
  UpdateDate=$(grep " Date: " ${FileConfSample} | awk -F ": " '{print $2}')
  if [[ "${VerConf}" != "${VerConfSample}" ]] && [[ ${UpdateDate} == $(date "+%Y-%m-%d") ]]
  then
    if [ ! -f ${SendCount} ]; then
      echo -e "检测到配置文件config.sh.sample有更新\n\n更新日期: ${UpdateDate}\n新的版本: ${VerConfSample}\n当前版本: ${VerConf}\n" | tee ${ContentVersion}
      echo -e "版本号中，第2位数字有变化代表增加了新的参数，有需要者可更新。\n" >> ${ContentVersion}
      echo -e "版本号中，第3位数字有变化代表仅仅是更新了配置文件注释。\n" >> ${ContentVersion}
      echo -e "本消息只在配置文件更新当天发送一次。" >> ${ContentVersion}
      cd ${ShellDir}
      node update.js
      if [ $? -eq 0 ]; then
        echo "1" > ${SendCount}
        [ -f ${ContentVersion} ] && rm -f ${ContentVersion}
      fi
    fi
  else
    [ -f ${ContentVersion} ] && rm -f ${ContentVersion}
    [ -f ${SendCount} ] && rm -f ${SendCount}
  fi
}

## npm install 子程序，判断是否为安卓
function NpmInstallSub {
  if [ -n "${isTermux}" ]
  then
    npm install --no-bin-links || npm install --no-bin-links --registry=https://registry.npm.taobao.org
  elif ! type yarn
  then
    npm install || npm install --registry=https://registry.npm.taobao.org
  else
    echo -e '使用 yarn 替代 npm'
    yarn install || yarn install --registry=https://registry.npm.taobao.org
  fi
}

## 增加定时任务，Docker和物理机不同
function Add_Cron {
  if [ -z "${isDocker}" ]; then
    grep -E "\/${Cron}\." "${ScriptsDir}/docker/crontab_list.sh" | perl -pe "s|(^.+)node */scripts/(j[dr]_\w+)\.js.+|\1bash ${ShellDir}/jd.sh \2|"  >> ${ListCron}
  else
    grep -E "\/${Cron}\." "${ScriptsDir}/docker/crontab_list.sh" | perl -pe "s|(^.+)node */scripts/(j[dr]_\w+)\.js.+|\1bash jd \2|"  >> ${ListCron}
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
  [ -f ${ScriptsDir}/package.json ] && PackageListOld=$(cat ${ScriptsDir}/package.json)
  if [ -d ${ScriptsDir} ]; then
    Git_PullScripts
  else
    Git_CloneScripts
  fi
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
  JsDrop=$(cat ${ListJsDrop})
  for Cron in ${JsDrop}
  do
    perl -i -ne "{print unless / ${Cron}( |$)/}" ${ListCron}
  done
  crontab ${ListCron}
  echo -e "成功删除失效的脚本与定时任务，当前的定时任务清单如下：\n\n--------------------------------------------------------------\n"
  crontab -l
  echo -e "\n--------------------------------------------------------------\n"
  if [ -d ${ScriptsDir}/node_modules ]; then
    echo -e "jd-base脚本成功删除失效的定时任务：\n\n${JsDrop}" > ${ContentDropTask}
    Notify_DropTask
  fi
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
    Add_Cron
  done
  if [ $? -eq 0 ]
  then
    crontab ${ListCron}
    echo -e "成功添加新的定时任务，当前的定时任务清单如下：\n\n--------------------------------------------------------------\n"
    crontab -l
    echo -e "\n--------------------------------------------------------------\n"
    if [ -d ${ScriptsDir}/node_modules ]; then
      echo -e "jd-base脚本成功添加新的定时任务：\n\n${JsAdd}" > ${ContentNewTask}
      Notify_NewTask
    fi
  else
    echo -e "添加新的定时任务出错，请手动添加...\n"
    if [ -d ${ScriptsDir}/node_modules ]; then
      echo -e "jd-base脚本尝试自动添加以下新的定时任务出错，请手动添加：\n\n${JsAdd}" > ${ContentNewTask}
      Notify_NewTask
    fi
  fi
fi

## npm install
if [ ${ExitStatusScripts} -eq 0 ]; then
  cd ${ScriptsDir}
  if [[ "${PackageListOld}" != "$(cat package.json)" ]]; then
    echo -e "运行 npm install...\n"
    NpmInstallSub
    if [ $? -ne 0 ]; then
      echo -e "\nnpm install 运行不成功，自动删除 ${ScriptsDir}/node_modules 后再次尝试一遍..."
      rm -rf ${ScriptsDir}/node_modules
    fi
    echo
  fi
  if [ ! -d ${ScriptsDir}/node_modules ]; then
    echo -e "运行 npm install...\n"
    NpmInstallSub
    if [ $? -ne 0 ]; then
      echo -e "\nnpm install 运行不成功，自动删除 ${ScriptsDir}/node_modules...\n\n请进入 ${ScriptsDir} 目录后按照wiki教程手动运行 npm install...\n"
      rm -rf ${ScriptsDir}/node_modules
      exit 1
    fi
  fi
fi

## 更新shell脚本、检测配置文件版本并将sample/config.sh.sample复制到config目录下
if [ $? -eq 0 ]; then
  cd ${ShellDir}
  echo -e "--------------------------------------------------------------\n"
  Git_PullShell
  if [ ${ExitStatusShell} -eq 0 ]
  then
    echo -e "\nshell脚本更新完成...\n"
    [ -d ${ScriptsDir}/node_modules ] && Notify_Version
  else
    echo -e "\nshell脚本更新失败，请检查原因后再次运行git_pull.sh，或等待定时任务自动再次运行git_pull.sh...\n"
  fi
  if [ -n "${isDocker}" ] && [ -d ${ShellDir}/config ]; then
    cp -f ${FileConfSample} ${ShellDir}/config/config.sh.sample
  fi
fi

## 调用用户自定义的diy.sh
if [ ${ExitStatusShell} -eq 0 ] && [ "${EnableExtraShell}" = "true" ]; then
  if [ -f ${FileDiy} ]
  then
    . ${FileDiy}
  else
    echo -e "${FileDiy} 文件不存在，跳过执行DIY脚本...\n"
  fi
fi
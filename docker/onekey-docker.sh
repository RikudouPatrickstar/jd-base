#!/bin/sh
#
# Copyright (C) 2021 Patrick⭐
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#
clear

echo "
     ██╗██████╗     ██████╗  ██████╗  ██████╗██╗  ██╗███████╗██████╗ 
     ██║██╔══██╗    ██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗
     ██║██║  ██║    ██║  ██║██║   ██║██║     █████╔╝ █████╗  ██████╔╝
██   ██║██║  ██║    ██║  ██║██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
╚█████╔╝██████╔╝    ██████╔╝╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║
 ╚════╝ ╚═════╝     ╚═════╝  ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
                                                                     
            ==== Create by 老竭力 | Mod by Patrick⭐ ====
"
DockerImage="patrick/jd-base:v3"
ShellName=$0
ShellDir=$(cd "$(dirname "$0")";pwd)
ContainerName=""
PanelPort=""
WorkDir="${ShellDir}/onekey-jd-docker-workdir"
JdDir=""
ConfigDir=""
LogDir=""
ScriptsDir=""

HasImage=false
NewImage=true
DelContainer=false

log() {
    echo -e "\e[32m$1 \e[0m"
}

inp() {
    echo -e "\e[33m$1 \e[0m"
}

warn() {
    echo -e "\e[31m$1 \e[0m"
}


# 检查 Docker 环境
Install_Docker() {
    if [ -x "$(command -v docker)" ]; then
       log "Docker 已安装!"
    else
        if [ -r /etc/os-release ]; then
            lsb_dist="$(. /etc/os-release && echo "$ID")"
        fi
        if [ $lsb_dist == "openwrt" ]; then
            warn "OpenWrt 环境请自行安装 Docker"
            exit 1
        else
            log "安装 Docker 环境..."
            curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
            log "Docker 环境安装完成!"
            systemctl enable docker
            systemctl start docker
        fi
    fi
}
Install_Docker

warn "\n注意如果你什么都不清楚，建议所有选项都直接回车，使用默认选择！！！\n"

#
# 收集配置信息
#

# 配置文件目录
echo -e "\e[33m请输入配置文件保存的绝对路径,直接回车为当前目录:\e[0m"
read jd_dir
if [ -z "$jd_dir" ]; then
    JdDir=$ShellDir/jd-docker
else
    JdDir=$jd_dir
fi
ConfigDir=$JdDir/config
LogDir=$JdDir/log
ScriptsDir=$JdDir/scripts

# 检测镜像是否存在
if [ ! -z "$(docker images -q $DockerImage 2> /dev/null)" ]; then
    HasImage=true
    inp "检测到先前已经存在的镜像，是否创建新的镜像：\n1) 是[默认]\n2) 不需要"
    echo -n -e "\e[33m输入您的选择->\e[0m"
    read update
    if [ "$update" = "2" ]; then
        NewImage=false
    fi
fi

# 检测容器是否存在
Check_ContainerName() {
    if [ ! -z "$(docker ps --format "{{.Names}}" | grep -w $ContainerName 2> /dev/null)" ]; then
        inp "检测到先前已经存在的容器，是否删除先前的容器：\n1) 是[默认]\n2) 不要"
        echo -n -e "\e[33m输入您的选择->\e[0m"
        read update
        if [ "$update" = "2" ]; then
            log "选择了不删除先前的容器，需要重新输入容器名称"
            Input_ContainerName
        else
            DelContainer=true
        fi
    fi
}

# 输入容器名称
Input_ContainerName() {
    echo -n -e "\n\e[33m请输入要创建的Docker容器名称[默认为：jd]->\e[0m"
    read container_name
    if [ -z "$container_name" ]; then
        ContainerName="jd"
    else
        ContainerName=$container_name
    fi
    Check_ContainerName 
}
Input_ContainerName

# 检测端口是否存在
Check_PanelPort() {
    if [ ! -z "$(docker ps -a --format "{{.Ports}}" | grep :$PanelPort- 2> /dev/null)" ]; then
        warn "检测到端口号冲突"
        Input_PanelPort
    else
        inp "端口号未与其他 Docker 容器冲突，如仍发现端口冲突，请自行检查宿主机端口占用情况！"
    fi
}

# 输入端口号
Input_PanelPort() {
    echo -n -e "\n\e[33m请输入控制面板端口号[默认为：5678]->\e[0m"
    read panel_port
    if [ -z "$panel_port" ]; then
        PanelPort="5678"
    else
        PanelPort=$panel_port
    fi
    Check_PanelPort
}
Input_PanelPort

#
# 配置信息收集完成，开始安装
#

log "\n1.创建文件目录"
mkdir -p $ConfigDir
mkdir -p $LogDir
mkdir -p $ScriptsDir

if [ $NewImage = true ]; then
    log "\n2.1.正在创建新镜像..."
    rm -fr $WorkDir
    mkdir -p $WorkDir
    if [ $HasImage = true ]; then
        docker image rm -f $DockerImage
    fi
    wget -q https://github.com/RikudouPatrickstar/jd-base/raw/v3/docker/Dockerfile -O $WorkDir/Dockerfile
    docker build -t $DockerImage $WorkDir > $LogDir/NewImage.log
    rm -fr $WorkDir
fi

if [ $DelContainer = true ]; then
    log "\n2.2.删除先前的容器"
    docker stop $ContainerName > /dev/null
    docker rm $ContainerName > /dev/null
fi

log "\n3.创建容器并运行"
docker run -dit \
    -v $ConfigDir:/jd/config \
    -v $LogDir:/jd/log \
    -v $ScriptsDir:/jd/scripts \
    -p $PanelPort:5678 \
    --name $ContainerName \
    --hostname jd \
    --restart always \
    $DockerImage

log "\n4.下面列出所有容器"
docker ps

log "\n5.安装已经完成。\n请访问 http://<ip>:5678 进行配置\n初始用户名：admin，初始密码：adminadmin"
rm -f $ShellDir/$ShellName

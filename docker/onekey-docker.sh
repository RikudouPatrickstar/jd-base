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
DOCKER_IMAGE="patrick/jdbase:v3"
SCRIPT_NAME=$0
SCRIPT_FOLDER=$(pwd)
CONTAINER_NAME=""
PANEL_PORT=""
JD_PATH=""
CONFIG_PATH=""
LOG_PATH=""

HAS_IMAGE=false
NEW_IMAGE=true
DEL_CONTAINER=false

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
docker_install() {
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
docker_install

warn "\n注意如果你什么都不清楚，建议所有选项都直接回车，使用默认选择！！！\n"

#
# 收集配置信息
#

# 配置文件目录
echo -e "\e[33m请输入配置文件保存的绝对路径,直接回车为当前目录:\e[0m"
read jd_path
JD_PATH=$jd_path
if [ -z "$jd_path" ]; then
    JD_PATH=$SCRIPT_FOLDER
fi
CONFIG_PATH=$JD_PATH/jd-base-docker/config
LOG_PATH=$JD_PATH/jd-base-docker/log

# 检测镜像是否存在
if [ ! -z "$(docker images -q $DOCKER_IMAGE 2> /dev/null)" ]; then
    HAS_IMAGE=true
    inp "检测到先前已经存在的镜像，是否拉取最新的镜像：\n1) 是[默认]\n2) 不需要"
    echo -n -e "\e[33m输入您的选择->\e[0m"
    read update
    if [ "$update" = "2" ]; then
        NEW_IMAGE=false
    fi
fi

# 检测容器是否存在
check_container_name() {
    if [ ! -z "$(docker ps --format "{{.Names}}" | grep -w $CONTAINER_NAME 2> /dev/null)" ]; then
        inp "检测到先前已经存在的容器，是否删除先前的容器：\n1) 是[默认]\n2) 不要"
        echo -n -e "\e[33m输入您的选择->\e[0m"
        read update
        if [ "$update" = "2" ]; then
            log "选择了不删除先前的容器，需要重新输入容器名称"
            input_container_name
        else
            DEL_CONTAINER=true
        fi
    fi
}

# 输入容器名称
input_container_name() {
    echo -n -e "\n\e[33m请输入要创建的Docker容器名称[默认为：jd]->\e[0m"
    read container_name
    if [ -z "$container_name" ]; then
        CONTAINER_NAME="jd"
    else
        CONTAINER_NAME=$container_name
    fi
    check_container_name 
}
input_container_name

# 检测端口是否存在
check_panel_port() {
    if [ ! -z "$(docker ps -a --format "{{.Ports}}" | grep :$PANEL_PORT- 2> /dev/null)" ]; then
        warn "检测到端口号冲突"
        input_panel_port
    else
        inp "端口号未与其他 Docker 容器冲突，如仍发现端口冲突，请自行检查宿主机端口占用情况！"
    fi
}

# 输入端口号
input_panel_port() {
    echo -n -e "\n\e[33m请输入控制面板端口号[默认为：5678]->\e[0m"
    read panel_port
    if [ -z "$panel_port" ]; then
        PANEL_PORT="5678"
    else
        PANEL_PORT=$panel_port
    fi
    check_panel_port
}
input_panel_port

#
# 配置信息收集完成，开始安装
#

log "\n1.创建配置文件目录"
mkdir -p $CONFIG_PATH
mkdir -p $LOG_PATH


if [ $NEW_IMAGE = true ]; then
    log "\n2.1.正在创建新镜像..."
    rm -fr $JD_PATH/Dockerfile
    rm -fr $JD_PATH/docker-entrypoint.sh
    if [ $HAS_IMAGE = true ]; then
        docker image rm -f $DOCKER_IMAGE
    fi
    wget -q https://github.com/RikudouPatrickstar/jd-base/raw/v3/docker/Dockerfile -O $JD_PATH/Dockerfile
    wget -q https://github.com/RikudouPatrickstar/jd-base/raw/v3/docker/docker-entrypoint.sh -O $JD_PATH/docker-entrypoint.sh
    docker build -t $DOCKER_IMAGE $JD_PATH > $LOG_PATH/new_image.log
    rm -fr $JD_PATH/Dockerfile
    rm -fr $JD_PATH/docker-entrypoint.sh
fi

if [ $DEL_CONTAINER = true ]; then
    log "\n2.2.删除先前的容器"
    docker stop $CONTAINER_NAME > /dev/null
    docker rm $CONTAINER_NAME > /dev/null
fi

log "\n3.创建容器并运行"
docker run -dit \
    -v $CONFIG_PATH:/jd/config \
    -v $LOG_PATH:/jd/log \
    -p $PANEL_PORT:5678 \
    --name $CONTAINER_NAME \
    --hostname jd \
    --restart always \
    $DOCKER_IMAGE

log "\n4.下面列出所有容器"
docker ps

log "\n5.安装已经完成。\n现在你可以使用如下信息访问设备来进行配置：\n地址：http://<ip>:$PANEL_PORT\n用户名：admin\n密码：adminadmin"

rm -f $SCRIPT_FOLDER/$SCRIPT_NAME
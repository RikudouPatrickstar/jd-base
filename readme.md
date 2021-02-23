# 一、申明

- 本脚本的原作者为 EvineDeng。

- 本脚本只是给 lxk0301/jd_scripts 套层壳，用来运行其中的 js 脚本，解放双手，自动玩耍京东的各种游戏，获取各种小羊毛。

- 关于文中的 {WORK_PATH}，在物理机中指项目安装目录下的 jd 目录，在 Docker 中指容器里的 /jd 目录。

# 二、如有帮助你薅到羊毛，请不吝赏杯茶水

![thanks](thanks.png)

# 三、快速开始

## 1. Linux

### 脚本一键部署：

运行此脚本前必须手动安装好依赖：`git wget curl perl moreutils node.js npm`  
```shell
wget -q https://github.com/RikudouPatrickstar/jd-base/raw/v3/onekey-install.sh -O onekey-jd-base.sh && chmod +x onekey-jd-base.sh && ./onekey-jd-base.sh
```

## 2. Docker

### 单个 Docker 容器

脚本一键部署：  
```shell
wget -q https://github.com/RikudouPatrickstar/jd-base/raw/v3/docker/onekey-docker.sh -O onekey-jd-docker.sh && chmod +x onekey-jd-docker.sh && ./onekey-jd-docker.sh
```

### 如何自动更新Docker容器（可选）

安装 [containrrr/watchtower](https://containrrr.dev/watchtower/) 可以自动更新容器，它监视你安装的所有容器的原始镜像的更新情况，如有更新，它将使用你原来的配置自动重新部署容器。更详细的部署说明，包括如何避开某些容器不让它自动更新，如何发更新容器后发送通知，设置检测时间等等，请自行了解。

[Docker 相关文件](https://github.com/RikudouPatrickstar/jd-base/tree/v3/docker) 已提供，Docker 如何操作请自行了解，其他玩法自行研究，小白勿触！

# 四、Web 面板使用说明

下面内容是针对非 Docker 用户的，Docker 中这些流程都做好了，直接使用即可。

## 使用流程

1. 面板目录为 {项目安装目录}/panel

2. 手动启动，根据需要二选一。

    ```shell
    # 1. 如需要编辑保存好就结束掉在线页面(保存好后按 Ctrl + C 结束)
    node server.js

    # 2. 如需一直后台运行，以方便随时在线编辑
    npm install -g pm2    # npm和yarn二选一
    yarn global add pm2   # npm和yarn二选一
    pm2 start server.js
    
    # 2.1 如果需要开机自启
    pm2 save && pm2 startup
    ```

4. 访问 `http://<ip>:5678` 登陆、编辑并保存即可（初始用户名：`admin`，初始密码：`password`）。如无法访问，请从防火墙、端口转发、网络方面着手解决。

5. 如需要重置面板密码，cd 到本仓库的目录下输入 `bash jd.sh resetpwd`。

# 五、脚本相关说明

## 脚本简单介绍

### [git_pull.sh](git_pull.sh)

1. 自动更新 jd_scripts 的京东薅羊毛脚本；

2. 自动更新 jd-base 套壳工具脚本；

3. 自动删除失效的定时任务、添加新的定时任务，并发送通知；

4. 检测配置文件模板 `config.sh.sample` 是否升版，如有升版，发出通知；

5. 其他还有若干功能，查看 [git_pull.sh](git_pull.sh) 注释即可看到。

### [export_sharecodes.sh](export_sharecodes.sh)

- 从已经产生的日志中导出互助码，注意：是已经产生的日志。

### [rm_log.sh](rm_log.sh)

- 自动按设定天数（config.sh 中设置的）删除旧日志。

### [jd.sh](jd.sh)

1. 自动按 crontab.list 设定的时间和 config.sh 设定的参数去跑各个薅羊毛脚本。

2. 直接执行该脚本可以看到使用方法。

## 如何更新配置文件

`config.sh` 和 `crontab.list` 两个文件都一样，在任何时候改完保存好就行，其他啥也不用干，改完以后，新的任务就以新配置运行了。其中 `config.sh` 改完立即生效，`crontab.list` 会在下一次任何定时薅羊毛任务启动时更新。

如需要在线比对编辑，可以使用 Web-控制面板

## 如何添加其他脚本

本环境基于 node，所以也只能跑 js 脚本。你可以把你的后缀为 `.js` 的脚本放在 `{WORK_PATH}/scripts` 下。比如你放了个 `test.js`，可以在你的 `crontab.list` 中添加如下的定时任务：

```shell
15 10 * * * bash {WORK_PATH}/jd.sh test     # 如果不需要准时运行或 RandemDelay 未设置
15 10 * * * bash {WORK_PATH}/jd.sh test now # 如果设置了 RandemDelay 但又需要它准时运行
```

然后运行一下 `crontab {WORK_PATH}/config/crontab.list` 更新定时任务即可。

**注意：在 crontab.list 中，你额外添加的任务不能以 “jd_”、“jr_”、“jx_” 开头，以 “jd_”、“jr_”、“jx_” 开头的任务如果不在 [jd_scripts](https://github.com/RikudouPatrickstar/jd_scripts) 这个仓库中，那么这个任务会被删除。**

如果你额外加的脚本要用到环境变量，直接在你的 `config.sh` 文件最下方按以下形式添加好变量即可：

```shell
export 变量名1="变量值1"
export 变量名2="变量值2"
export 变量名3="变量值3"
```

## 如何手动运行脚本

1. 手动 git pull 更新脚本

    ```shell
    cd {WORK_PATH}
    bash git_pull.sh
    ```

2. 手动删除指定时间以前的旧日志

    ```shell
    cd {WORK_PATH}
    bash rm_log.sh
    ```

3. 手动导出所有互助码

    ```shell
    cd {WORK_PATH}
    bash export_sharecodes.sh
    ```

4. 手动启动挂机程序

    `cd` 到脚本目录后输入 `bash jd.sh hangup` 即可，然后挂机脚本就会一直运行。目前仅一个 `jd_crazy_joy_coin.js` 为挂机脚本。

5. 手动执行薅羊毛脚本，用法如下(其中 `xxx` 为 jd_scripts 中的脚本名称)，不支持直接以 `node xxx.js` 命令运行：

    ```shell
    cd {WORK_PATH}
    bash jd.sh xxx      # 如果设置了随机延迟并且当时时间不在0-2、30-31、59分内，将随机延迟一定秒数
    bash jd.sh xxx now  # 无论是否设置了随机延迟，均立即运行
    ```


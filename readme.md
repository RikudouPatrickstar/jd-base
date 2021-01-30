## 脚本可以干什么

### git_pull.sh

1. 自动更新lxk0301的京东薅羊毛脚本；

2. 自动更新我的shell脚本；

3. 自动删除失效的定时任务，并发送通知；

4. 自动添加新的定时任务，并发送通知；

5. 检测配置文件模板`config.sh.sample`是否升版，如有升版，发出通知；

6. 其他还有若干功能，查看 [本文件](https://github.com/EvineDeng/jd-base/blob/v3/git_pull.sh) 注释即可看到。

### export_sharecodes.sh

从已经产生的日志中导出互助码，注意：是已经产生的日志。

### rm_log.sh

自动按设定天数（config.sh中设置的）删除旧日志。

### jd.sh

自动按crontab.list设定的时间去跑各个薅羊毛脚本，需要后本脚本后面提供js脚本名称。

## 操作流程

1. 安装好docker([中文教程](https://mirrors.bfsu.edu.cn/help/docker-ce/))，然后创建容器：

    注1：如果是旁路由，建议用`--network host \`代替`-p 5678:5678 \`这一行。

    注2：如果想要看到lxk0301大佬的js脚本，并且重新部署也不影响自己添加的额外脚本，可以增加一行`-v /你想存放的路径/jd/scripts:/jd/scripts \`，不过这会增加占用约50M空间，并且会在创建时自动克隆lxk0301的js脚本。

    注3：容器本身默认会在启动时自动启动挂机程序（就一个jd_crazy_joy_coin），如不想自动启动，请增加一行`-e ENABLE_HANGUP=false \`。

    注4：容器本身默认会在启动时自动启动控制面板，如不想自动启动，请增加一行`-e ENABLE_WEB_PANEL=false \`。

    注5：群晖和威联通用户，以及其他非root用户的，请在ssh登陆后，切换为root用户再运行：`sudo -i`。

    ```shell
    docker run -dit \
    -v /你想存放的路径/jd/config:/jd/config `# 配置保存目录，冒号左边请修改为你想存放的路径` \
    -v /你想存放的路径/jd/log:/jd/log `# 日志保存目录，冒号左边请修改为你想存放的路径` \
    -p 5678:5678 \
    --name jd \
    --hostname jd \
    --restart always \
    evinedeng/jd:gitee
    ```

2. 请在创建后使用`docker logs -f jd`查看创建日志，直到出现`容器启动成功...`字样才代表启动成功（不是以此结束的请更新镜像），按`Ctrl+C`退出查看日志。

3. 访问`http://<ip>:5678`（ip是指你Docker宿主机的局域网ip），初始用户名：`admin`，初始密码：`adminadmin`，请登陆后务必修改密码，并在线编辑`config.sh`和`crontab.list`，其中`config.sh`可以对比修改，**如何修改请仔细阅读各文件注释**。如未启用控制面板自动启动功能，请运行`docker exec -it jd node /jd/panel/server.js`来启动，使用完控制面板后`Ctrl+C`即可结束进程。如无法访问，请从防火墙、端口转发、网络方面着手解决。实在无法访问，就使用winscp工具sftp连接进行修改。

4. 只有Cookie是必填项，其他根据你自己需要填。编辑好后，如果需要启动挂机程序（目前只有一个jd_crazy_joy_coin.js需要挂机），请重启容器：`docker restart jd`。**在创建容器前config.sh中就有有效Cookie的，无需重启容器。**

5. 如何自动更新Docker容器

    安装`containrrr/watchtower`可以自动更新容器，它也是一个容器，但这个容器可以监视你安装的所有容器的原始镜像的更新情况，如有更新，它将使用你原来的配置自动重新部署容器。部署`containrrr/watchtower`最简单的方式如下：

    ```shell
    docker run -d \
        --name watchtower \
        -v /var/run/docker.sock:/var/run/docker.sock \
        containrrr/watchtower
    ```

    你也可以访问 https://containrrr.dev/watchtower/ 获取更详细的部署说明，包括如何避开某些容器不让它自动更新，如何发更新容器后发送通知，设置检测时间等等。

## 如果多容器并发

多个容器并发，建议使用docker-compose安装，但如果你平台无法正常安装docker-compose，或者你不想用docker-compose，按上述操作流程中方式部署**不同名称不同映射路径**的容器也是可以的，看你个人需要。

如需使用docker-compose，请前往 [这里](https://github.com/docker/compose/releases/) 下载最新版本的文件，放在本机 `/usr/local/bin`下，并重命名为`docker-compose`。

然后参考本仓库的 [docker-compose.yml](https://github.com/EvineDeng/jd-base/blob/v3/docker/docker-compose.yml) 准备好你自己的`docker-compose.yml`，然后部署：

```shell
## cd 到docker-compose.yml的存放路径下
docker-compose up -d
```

## 如何更新配置文件

访问`http://<ip>:5678`并编辑保存好即可，其他啥也不用干，容器也不用重启。其中`config.sh`改完立即生效，`crontab.list`会在下一次任何定时薅羊毛任务启动时更新。`config.sh`可以通过控制面板的对比工具对比修改。

如未启用控制面板自动启动功能，请运行`docker exec -it jd node /jd/panel/server.js`来启动，使用完控制面板后`Ctrl+C`即可结束进程。如无法访问，请从防火墙、端口转发、网络方面着手解决。

也可以不通过控制面板，而是通过sftp连接修改，你自己的配置文件`config.sh`可对照仓库中`sample/config.sh.sample`修改。

## 如何重置控制面板用户名和密码

```shell
docker exec -it jd bash jd resetpwd
```

## 如何添加其他脚本

本环境基于node，所以也只能跑js脚本。你可以把你的后缀为`.js`的脚本放在你映射的`config`或映射的`scripts`下即可。比如你放了个`test.js`，可以在你的`crontab.list`中添加如下的定时任务：

```shell
15 10 * * * bash jd test     # 如果不需要准时运行或RandemDelay未设置
15 10 * * * bash jd test now # 如果设置了RandemDelay但又需要它准时运行
```

识别顺序：`1. /jd/scripts、2. /jd/scripts/backUp、3. /jd/config`，如果一个脚本在多个目录下均存在，以先找到的为准。

如果急你就运行一下`docker exec -it jd crontab /jd/config/crontab.list`更新定时任务即可，如果不急就等着程序自己添加进定时任务。

**注意：在crontab.list中，你额外添加的任务不能以“jd_”、“jr_”、“jx_”开头，以“jd_”、“jr_”、“jx_”开头的任务如果不在[https://github.com/LXK9301/jd_scripts](https://github.com/LXK9301/jd_scripts) 和 [https://github.com/shylocks/Loon](https://github.com/shylocks/Loon) 这两个仓库中，那么这个任务会被删除。**

**其他说明：**

1. 如果你额外加的脚本要用到环境变量，直接在你的`config.sh`文件最下方按以下形式添加好变量即可（单引号或双引号均可）：

    ```shell
    export 变量名1="变量值1"
    export 变量名2="变量值2"
    export 变量名3="变量值3"
    ```

2. 如果你额外添加的脚本要用到lxk0301大佬仓库中的`sendNotify.js`来发送通知，或者要用到`jdCookie.js`来处理Cookie，建议你直接放在容器内的`/jd/scripts`文件夹下，按以下命令复制进容器（如果没有映射`/jd/scripts`出来的话，重新部署容器后要再次运行）：

    ```shell
    docker cp /宿主机上脚本存放路径/test.js jd:/jd/scripts
    ```

## 如何手动运行脚本

1. 手动 git pull 更新脚本

    ```shell
    docker exec -it jd bash git_pull
    ```

2. 手动删除指定时间以前的旧日志

    ```shell
    docker exec -it jd bash rm_log
    ```

3. 手动导出所有互助码

    ```shell
    docker exec -it jd bash export_sharecodes
    ```
4. 手动启动挂机程序（**容器会在启动时立即启动挂机程序，所以你想重启挂机程序，你也可以重启容器，而不采用下面的方法。**）

    ```shell
    docker exec -it jd bash jd hangup
    ```

    然后挂机脚本就会一直运行。如需查看挂机脚本日志，请输入`docker exec -it jd pm2 monit`或`docker exec -it jd pm2 logs`查看。因挂机程序日志过多，不再记录在log文件中。

5. 手动执行薅羊毛脚本，用法如下(其中`-it`后面的`jd`为容器名，`bash`后面的`jd`为命令名，`xxx`为lxk0301大佬的脚本名称)，不支持直接以`node xxx.js`命令运行：

    ```
    docker exec -it jd bash jd xxx      # 如果设置了随机延迟并且当时时间不在0-2、30-31、59分内，将随机延迟一定秒数
    docker exec -it jd bash jd xxx now  # 无论是否设置了随机延迟，均立即运行
    ```

## 如有帮助你薅到羊毛，请不吝赏作者一杯茶水费

https://ftp.bmp.ovh/imgs/2021/01/7303b376a3ea4cc3.png

![Thanks](https://ftp.bmp.ovh/imgs/2021/01/7303b376a3ea4cc3.png)

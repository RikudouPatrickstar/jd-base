## 请仔细阅读[WIKI](https://github.com/EvineDeng/jd-base/wiki)和各文件注释，90%的问题都能找到答案

## 如有帮助到你，请点亮Star

## 如有二次使用，请注明来源

本脚本是[https://github.com/lxk0301/jd_scripts](https://github.com/lxk0301/jd_scripts)的shell套壳工具，适用于以下系统：

- ArmBian/Debian/Ubuntu/OpenMediaVault/CentOS/Fedora/RHEL等Linux系统

- OpenWRT

- Android

- MacOS

- Docker

## 说明

1. 宠汪汪赛跑助力先让用户提供的各个账号之间相互助力，助力完成你提供的所有账号以后，再给我和lxk0301大佬助力，每个账号助力后可得30g狗粮。

2. 将部分临时活动修改为了我的邀请码，已取得lxk0301大佬的同意。

## 更新日志

> 只记录大的更新，小修小改不记录。

2021-01-06，Docker用户增加在线编辑`config.sh`和`crontab.list`功能，详见最新WIKI。

2021-01-04，Docker启动时即自动启动挂机程序。

2020-12-30，增加`config.sh`和`config.sh.sample`文件差异智能比对的脚本，使用方法详见WIKI。

2020-12-30，增加自动挂机功能，如需使用，在运行过一次`bash git_pull.sh`以后，输入`bash jd.sh hangup`即可（docker要进入容器后输入），然后挂机脚本就会一直运行。如果你希望每天终止旧的挂机进程，然后启动新的挂机进程，请参考sample文件夹下各个平台 的list中的挂机定时任务，添加到自己的`crontab.list`中。目前仅一个`jd_crazy_joy_coin.js`为挂机脚本。

## Star趋势

[![Stargazers over time](https://starchart.cc/EvineDeng/jd-base.svg)](https://starchart.cc/EvineDeng/jd-base)

2020-12-23，晚20点多更新错误造成bug，有可能造成后面无法再自动更新脚本，如果发现存在此问题（现象是git_pull.log中没有新的日志内容了），解决办法附下：

- 如果是docker，在docker宿主机运行一下：docker exec -it jd git pull， 即可解决此问题。不过也因此建议docker用户一定要安装watchtower来自动更新，这样我会在出错后重新更新容器才让大家直接自动完成容器更新。

- 如果是物理机或手机termux，cd到脚本存放目录后运行一次：git pull， 即可解决此问题。

- 下次我一定先测试好没问题再发布，以避免类似问题发生。

## 所有教程已转移至[WIKI](https://github.com/EvineDeng/jd-base/wiki)，如有帮助到你，请点亮Star

## 如有二次使用，希望注明来源

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

2020-12-30，增加`config.sh`和`config.sh.sample`文件差异智能比对的脚本，使用方法详见WIKI。

2020-12-30，增加自动挂机功能，如需使用，在运行过一次`bash git_pull.sh`以后，输入`bash jd.sh hangup`即可（docker要进入容器后输入），然后挂机脚本就会一直运行。如果你希望每天终止旧的挂机进程，然后启动新的挂机进程，请参考sample文件夹下各个平台 的list中的挂机定时任务，添加到自己的`crontab.list`中。目前仅一个`jd_crazy_joy_coin.js`为挂机脚本。

2020-12-24，增加导出互助码的一键脚本`export_sharecodes.sh`，老用户需要参考仓库的sample文件添加自己的cron方可使用。

## Star趋势

[![Stargazers over time](https://starchart.cc/EvineDeng/jd-base.svg)](https://starchart.cc/EvineDeng/jd-base)

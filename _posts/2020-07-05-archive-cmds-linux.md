---
layout: post
title: 归档 - linux 常用命令
date: 2020-07-05 00:15:08 +0000
category:
  - 归档
tags:
  - linux
  - cmd
comment: false
reward: false
excerpt: linux 常用命令(阿里云ecs存在到期的风险, 所以把2017年左右的文字挪进git) 
---

| 命令 | 说明 |
|--|--|
| `rpm -qa | grep mysql` | 查看服务是否安装 |
| `cat /etc/redhat-release` | 查看阿里云ecs服务器linux版本 |
| `find /home/ -name elm.cc` | 在某目录下查找名为"elm.cc"的文件 |
| `find /home/ -name '*elm.cc*'` | 在某目录下查找名包含"elm.cc"的文件 |
| `source /etc/profile` | 刷新环境变量 |
| `df -hl` | 磁盘使用量 |
| `top` | 内存使用等 |
| `crontab -l -u -r` | 计划任务 -u 查看用户的 -r 删除 |
| `ln -s /dir1/* /a/upload/image` | 创建软连接, dir1目录中所有文件，在目录/a/upload/image中建立软链接 |
| `du -sh *` | 查询当前目录和文件的大小 |
| `find . -type f -size +20000k` | 查找文件的大小>20000k |

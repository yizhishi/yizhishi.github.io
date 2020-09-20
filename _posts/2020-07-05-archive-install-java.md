---
layout: post
title: 归档 - java 安装
date: 2020-07-05 00:15:08 +0000
category:
  - 归档
tags:
  - java
  - install
comment: false
reward: false
excerpt: java 安装(阿里云ecs存在到期的风险, 所以把2017年左右的文字挪进git) 
---



## 一 下载mysql社区版

[下载地址](https://dev.mysql.com/downloads/)

确认/usr/local/java  文件夹存在

``` sh

tar -zxvf *.tgz

cp -R /root/downloads/jdk1.8.0_144/ /usr/local/java/jdk1.8.0_144/

```

## 二 设置环境变量

``` sh
# 修改/etc/profile
vi /etc/profile

# 在文件末尾加上
export JAVA_HOME=/usr/local/java/jdk1.8.0_144
export PATH=$JAVA_HOME/bin:$PATH

# 刷新环境变量
source /etc/profile

```

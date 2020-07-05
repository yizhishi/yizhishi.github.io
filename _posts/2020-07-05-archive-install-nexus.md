---
layout: post
title: 归档 - nexus安装
date: 2020-07-05 00:15:08 +0000
category:
  - 归档
tags:
  - maven
comment: false
reward: false
excerpt: maven私服nexus的安装(阿里云ecs存在到期的风险, 所以把2017年左右的文字挪进git) 
---

参照自己印象笔记安装

## 一 安装

确认 jdk 和 [maven](http://maven.apache.org/install.html)都已安装.

下载[nexus](http://www.sonatype.org/downloads/nexus-latest-bundle.zip)

``` sh
unzip nexus-latest-bundle.zip

mv nexus-2.11.1-01/ /usr/local/nexus-2.11.1-01/

cd /usr/local/nexus-2.11.1-01/bin/

export RUN_AS_USER=root

./nexus start

```

## 二 更新

nexus 启动后, 访问并登录[http://ip:8081/nexus/](http://ip:8081/nexus), 登录账号/密码默认为: `admin/admin123`.

登录后, 选择左侧菜单树 Repositories, 点击右侧 Central , 选择 Configuration 的 "Download Remote Indexes" 的值从默认值 false 改为 true , 然后点击 save . 最后右键点击 Central 选择 Update Index.

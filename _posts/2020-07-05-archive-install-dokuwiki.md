---
layout: post
title: 归档 - dokuwiki 安装
date: 2020-07-05 00:15:08 +0000
category:
  - 归档
tags:
  - maven
comment: false
reward: false
excerpt: dokuwiki 的安装, 阿里云ecs到期后, 不想再整个wiki了(阿里云ecs存在到期的风险, 所以把2017年左右的文字挪进git) 
---

参照 [www.yd631.com](http://www.yd631.com/dokuwiki-install/) 进行安装.

1. 下载安装包, [下载地址](https://www.xwiki.org/xwiki/bin/view/Download/)

2. 把下载的 dukuwiki 安装包, 解压复制到 apache 下.

    ``` sh

    tar -zxvf dokuwiki-3203a8fa2af3c3d5304bfdecb210ec5d.tgz

    cp -R /root/downloads/dokuwiki/* /var/www/html/dokuwiki/

    chmod -R 777 /var/www/html/dokuwiki/data/ /var/www/html/dokuwiki/conf/

    ```

3. 配置 dokuwiki

访问 [install.php](http://ip:port/install.php) 进行步骤安装, 然后根据提示配置(完成后删掉install.php).

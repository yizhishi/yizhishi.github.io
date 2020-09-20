---
layout: post
title: 归档 - xwiki 部署
date: 2020-07-05 00:15:08 +0000
category:
  - 归档
tags:
  - maven
  - install
comment: false
reward: false
excerpt: xwiki 的部署(阿里云ecs存在到期的风险, 所以把2017年左右的文字挪进git) 
---

## 一 背景

接任务部署一个wiki, 要求: java语言开发, 开源, 内网部署; 需要支持: 大文件上传(300m左右), 所见即所得(wycwyg), 导出, LDAP, 评论与权限.

通过一个好用的 [wiki compare](https://www.wikimatrix.org/) 网站对比后, 可用的只剩 [XWIKI](https://www.xwiki.org/xwiki/bin/view/Main/WebHome) 与 [JSPWIKI](https://jspwiki.apache.org/) 了, 最终选定 XWIIKI.

## 二 准备工作

我使用的是java (version 1.8.0_111), tomcat(version 8.5), mysql(version 5.7.25) .

1. 使用 war 包部署, 选定[当前的稳定版本下载](https://www.xwiki.org/xwiki/bin/view/Download/), 下载 WAR Package for Servlet Container 和 XIP Addon Package for Offline Installs (有网无需下载, 在  Distribution Wizard 的 step 2 可以在线安装).

2. 下载 org.xwiki.contrib.ldap_ldap-ui-x.x.x.xar (<https://extensions.xwiki.org/xwiki/bin/view/Extension/LDAP/Application/>), 对 LDAP 进行可视化配置.

3. 从xwiki的 [maven私服](https://nexus.xwiki.org/nexus) 下载LDAP所需的jar包

    ``` sh
    <dependency>
    　　<groupId>org.xwiki.contrib.ldap</groupId>
    　　<artifactId>ldap-api</artifactId>
    　　<version>x.x.x</version>
    </dependency>
    <dependency>
    　　<groupId>org.xwiki.contrib.ldap</groupId>
    　　<artifactId>ldap-authenticator</artifactId>
    　　<version>x.x.x</version>
    </dependency>
    <dependency>
    　　<groupId>com.novell.ldap</groupId>
    　　<artifactId>jldap</artifactId>
    　　<version>2009-10-07</version>
    </dependency>
    ```

4. 准备MySQL JDBC Driver Jar mysql-connector-java-x.x.x. jar 包

## 三 部署

### 3.1 数据库

#### 3.1.1 建库

  ``` sh
  create database xwiki default character set utf8;
  ```

#### 3.1.2 授权

  ``` sh
  grant all privileges on xwiki.* to xwiki@'%' identified by 'xwiki'
  ```

### 3.2 把下载好的 war 包(war包改名为xwiki.war), 放入 tomcat 容器内, war包解压

把 mysql-connector-java-x.x.x.jar, ldap-api-x.x.x.jar, org.xwiki.contrib.ldap_ldap-authenticator-x.x.x.jar, jldap-2009-10-07.jar, 放入 `${tomcat}\webapps\xwiki\WEB-INF\lib\` 下.

*ps: tomcat 启动过程中如果日志出现: because there was insufficient free space ... consider increasing the maximum size of the cache.*

修改 `${tomcat}\conf\context.xml`, 添加 `<Resources cachingAllowed="true" cacheMaxSize="100000" />`;

如果不起作用, 修改 `${tomcat}\webapps\xwiki\META-INF\context.xml`, 添加`<Resources cachingAllowed="true" cacheMaxSize="100000" />`

### 3.3 修改 XWIKI 的配置, 在 ${tomcat}webapps\xwiki\WEB-INF\ 下

#### 3.3.1 hibernate.cfg.xml

更换 database 相关配置, 注释掉 Configuration for the default database . 打开 MySQL configuration , 修改 Mysql 的 connection.url, connection.username, connection.password.

#### 3.3.2 xwiki.cfg

启用 superadmin, 打开 # xwiki.superadminpassword=system.

打开并修改LDAP的设置, xwiki.authentication.authclass=org.xwiki.contrib.ldap.XWikiLDAPAuthServiceImpl

设置附件存储方式:

  ``` sh
  xwiki.store.attachment.hint=file
  xwiki.store.attachment.versioning.hint=file
  xwiki.store.attachment.recyclebin.hint=file
  ```

#### 3.3.3 xwiki.properties

设置附件存储目录, 打开 #environment.permanentDirectory=/var/local/xwiki/

### 3.4 把 xwiki-platform-distribution-flavor-xip-x.x.x.xip (可改为zip进行解压, 其实就是一个zip包), 解压放入 xwiki.properties中配置的${environment.permanentDirectory}\extension\repository\下. 重启tomcat

*ps: tomcat启动后, 会提示从 <https://nexus.xwiki.org> 获取 findbugs 等jar包失败等报错信息(因为我是无外网安装, 有网情况下不会出现), 无视就好了.*
　　
### 3.5 浏览器中输入 ip:port , 会进行 xwiki 初始化, 初始化完成后, 进入 Distribution Wizard 的 页面, 在 step2(其余step很简单) 等待加载出离线的flavor, 下边是官方给的 [Installation Guide](https://www.xwiki.org/xwiki/bin/view/Documentation/AdminGuide/Installation/)

>Installing without internet connection
XIP package
Since 9.5 a XIP package is provided for the Standard flavor.
>This is actually a zip file containing the required XWiki extensions for both the main wiki and subwikis, in the same format than the local extensions repository.
>download it (use the exact same version of the XIP package as the version of XWiki you have)
Unzip it (rename it to .zip if your zip tool does not recognize it) in the folder <permanentdirectory>/extension/repository
(if you get complains about already existing files don't overwrite them)
Restart XWiki if it was running
Resume standard installation, this time it will find the flavor locally

step2 如图所示(我已经安装好了, 图是我在网上找的, 版本请忽略), 安装flavor.

### 3.6 配置LDAP. 官网指示(<https://extensions.xwiki.org/xwiki/bin/view/Extension/LDAP/Application/>) 不靠谱

#### 3.6.1, superadmin登录后, 进入 <http://ip:port/bin/admin/XWiki/XWikiPreferences>, 依次点击 content -> import->upload 下载好的org.xwiki.contrib.ldap_ldap-ui-x.x.x.xar, 最后点击 右下的 import 按钮

#### 3.6.2 import 成功后, 可以在 <http://ip:port/bin/admin/XWiki/XWikiPreferences> 的 Other -> LDAP 中 进行可视化配置, 我在配置了 红框中的属性后, LDAP可以正常使用了

``` sh

# 修改tomcat

CATALINA_OPTS="-server -Xms800m -Xmx1600m -Dfile.encoding=utf-8 -Djava.awt.headless=true -XX:+UseParallelGC -XX:MaxGCPauseMillis=100"

```

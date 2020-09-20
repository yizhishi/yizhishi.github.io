---
layout: post
title: 归档 - mysql 安装
date: 2020-07-05 00:15:08 +0000
category:
  - 归档
tags:
  - mysql
  - install
comment: false
reward: false
excerpt: mysql 安装(阿里云ecs存在到期的风险, 所以把2017年左右的文字挪进git) 
---

* [[mysql常用命令|]]

* [[docker部署mysql|docker部署mysql]]

======== 安装包 部署 ======

* **一 下载mysql社区版**
  * [[https://dev.mysql.com/downloads/]]

查看linux版本: CentOS Linux release 7.3.1611 (Core).
<code>
cat /etc/redhat-release
</code>

确认是否已安装的mysql , rpm -e (普通删除)  rpm -e --nodeps(强制删除)
<code>
rpm -qa | grep mysql
rpm -e  mysql-libs
rpm -e --nodeps mysql-libs
</code>

确认是否已安装的mariadb, 删除mariadb
<code>
rpm -qa | grep mariadb
rpm -e --nodeps mariadb-libs-5.5.52-1.el7.x86_64
</code>

确认是否已安装libaio, 后续安装时候依赖
<code>
wget <http://mirror.centos.org/centos/6/os/x86_64/Packages/libaio-0.3.107-10.el6.x86_64.rpm>
rpm -ivh libaio-0.3.107-10.el6.x86_64.rpm
</code>

**最后下载了mysql的5.7版本: mysql-5.7.19-1.el7.x86_64.rpm-bundle.tar**

--------------------

* **二 设置环境变量**
解压安装包, 按依赖关系安装
<code>
tar -xvf file.tar
rpm -ivh mysql-community-common-5.7.19-1.el7.x86_64.rpm
rpm -ivh mysql-community-libs-5.7.19-1.el7.x86_64.rpm
rpm -ivh mysql-community-client-5.7.19-1.el7.x86_64.rpm
rpm -ivh mysql-community-server-5.7.19-1.el7.x86_64.rpm
</code>

查看是否安装成功
<code>
rpm -qi mysql-community-server
</code>

------------------------

* **三 初始化mysql**
启动 service mysqld start

重启 service mysqld restart

查看mysql服务是不是开机自动启动
<code>
chkconfig --list | grep mysqld //查看是否开机自启动
chkconfig mysqld on //设置开机自启动
</code>

修改 /etc/my.cnf , 在[mysqld]下边追加 skip-grant-tables, 保存退出; 重启mysql服务.

使用mysql -u root -p mysql, 直接登录数据库, 无需输入密码; 修改root的密码

<code sql>
use mysql;
update user set password=password("123456") where user="root";
flush privileges;
update user set authentication_string=password('123456') where user='root' ;
flush privileges;
</code>

如果密码已经修改过, password这个字段在user表中会被authentication_string 替换,  此时使用

update mysql.user set authentication_string=password('xxxx@2016') where user='root' ;

---------------------------

* **四 其他**

<code sql>
select @@validate_password_length; -- 查看密码策略
set global validate_password_policy=0; -- 修改密码策略, 共0,1,2  三个等级, 0级安全级别最低
select @@validate_password_length; -- 查看密码长度
set global validate_password_length=7; -- 密码长度, 默认8

-- 问题: You must reset your password using ALTER USER statement before executing this statement.
SET PASSWORD = PASSWORD('your new password');
ALTER USER 'root'@'localhost' PASSWORD EXPIRE NEVER;
flush privileges;

show databases; -- 查看数据库

CREATE USER 'kwan'@'%' IDENTIFIED BY 'password'; --创建账户

-- 授权, 否则无法外部访问
GRANT ALL PRIVILEGES ON *.* TO gxl@'%';

grant all on * to 'kwan'@'%' identified by 'password' with grant option;

</code>
------------------------

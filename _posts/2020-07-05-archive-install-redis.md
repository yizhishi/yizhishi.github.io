---
layout: post
title: 归档 - redis 部署
date: 2020-07-05 00:15:08 +0000
category:
  - 归档
tags:
  - redis
  - install
comment: false
reward: false
excerpt: redis 部署(阿里云ecs存在到期的风险, 所以把2017年左右的文字挪进git) 
---

参照[http://www.cnblogs.com/zhuhongbao/archive/2013/06/04/3117997.html](http://www.cnblogs.com/zhuhongbao/archive/2013/06/04/3117997.html)和自己印象笔记安装

## 一 安装

``` sh

wget <http://download.redis.io/releases/redis-4.0.1.tar.gz>

tar redis-4.0.1.tar.gz

cd redis-4.0.1

make

make install

cp redis.conf /etc/

```

`make install`命令执行完成后, 会在`/usr/local/bin`目录下生成几个可执行文件, 分别是 redis-server , redis-cli , redis-benchmark ,redis-check-aof , redis-check-dump , 它们的作用如下:

- redis-server: Redis服务器的daemon启动程序
- redis-cli: Redis命令行操作工具, 也可以用telnet根据其纯文本协议来操作
- redis-benchmark: Redis性能测试工具, 测试Redis在当前系统下的读写性能
- redis-check-aof: 数据修复
- redis-check-dump: 检查导出工具

## 二 修改配置

修改`daemonize yes`---目的使进程在后台运行

参数介绍：

daemonize：是否以后台daemon方式运行

pidfile：pid文件位置

port：监听的端口号

timeout：请求超时时间

loglevel：log信息级别

logfile：log文件位置

databases：开启数据库的数量

save **：保存快照的频率，第一个*表示多长时间，第二个*表示执行多少次写操作。在一定时间内执行一定数量的写操作时，自动保存快照。可设置多个条件。

rdbcompression：是否使用压缩

dbfilename：数据快照文件名（只是文件名，不包括目录）

dir：数据快照的保存目录（这个是目录）

appendonly：是否开启appendonlylog，开启的话每次写操作会记一条log，这会提高数据抗风险能力，但影响效率。

appendfsync：appendonlylog如何同步到磁盘（三个选项，分别是每次写都强制调用fsync、每秒启用一次fsync、不调用fsync等待系统自己同步）

requirepass foobared 密码设置

bind 127.0.0.1 只能本机访问

## 三 启动

启动 和 停止

``` sh

cd /usr/local/bin

./redis-server /etc/redis.conf

./redis-cli -p 6379 -a password
```

连接redis

``` sh
redis-cli -p 6379 -a password
redis 127.0.0.1:6379>
redis 127.0.0.1:6379> config get requirepass

1) "requirepass"
2) password
```

## 四 设置redis开机启动

准备 redisd 文件

``` sh

# !/bin/sh
case $1 in
    start)
        echo "Starting redis ..."
        ./usr/local/bin/redis-server /etc/redis.conf
        echo "redis started ..."
    ;;
    stop)
        echo "Stoping redis ..."
        ./usr/local/bin/./redis-cli -a password shutdown
        echo "redis stopped ..."
    ;;
esac

```

把 redisd 文件放进`/etc/init.d`文件夹下, 使用`chkconfig redisd on`   添加开机启动

``` sh
chkconfig redisd on
```

## docker 环境部署 redis

``` sh
docker run -d -p 8379:6379 -v /usr/local/docker/redis/redis.conf:/usr/local/etc/redis/redis.conf --network=my-net --name redis4.0 redis:4.0.14 redis-server /usr/local/etc/redis/redis.conf
```

将 redis.conf 中的 daemonize yes 注释掉即可运行!

>When you demonize the Redis process, the final Docker exec process (the one that started Redis) has nothing left to do, so that process exits, and the container ends itself.
If you want to keep the container up, you can either not demonize it, or you can, but you must do something else like call wait, or more preferably, tail -f the redis logs

Redis 进程被幽灵化(后台化)后, 启动Redis的那个进程, 也就是Docker执行进程无事可做, 因此Docker执行进程退出, 容器🔚. 后面几句话说的用tail -f 去输出redis的日志. 避免Docker执行进程退出.

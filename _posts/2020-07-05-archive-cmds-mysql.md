---
layout: post
title: 归档 - mysql 常用命令
date: 2020-07-05 00:15:08 +0000
category:
  - 归档
tags:
  - linux
comment: false
reward: false
excerpt: mysql 常用命令(阿里云ecs存在到期的风险, 所以把2017年左右的文字挪进git) 
---

## 查看事务隔离级别

``` sql
SELECT @@tx_isolation;
```

- `read uncommitted` 读取尚未提交的数据: 哪个问题都不能解决
- `read committed` 读取已经提交的数据: 可以解决脏读(oracle默认的事务隔离级别)
- `repeatable read` 重读读取: 可以解决脏读和不可重复读(mysql默认的事务隔离级别)
- `serializable` 串行化: 可以解决脏读, 不可重复读和虚读, 相当于锁表

## 修改事务隔离级别

``` sql
set session transaction isolation level read committed;
```

## 查看大小写区分

``` sql
show variables like "%case%";
```

- lower_case_table_names = 0 不区分大小写(即对表名大小写敏感), 配置文件中添加 `lower_case_table_names=1` . 重启mysql服务
- lower_case_table_names = 1 区分大小写(即对表名大小写敏感)

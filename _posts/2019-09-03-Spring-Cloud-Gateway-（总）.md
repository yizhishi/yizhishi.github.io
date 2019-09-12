---
layout: post
title: Spring Cloud Gateway （总）
date: 2019-09-03 13:55:08 +0000
category:
  - java
tags:
  - Spring Cloud Gateway
comment: false
reward: false
excerpt: 记录自己Spring Cloud Gateway的学习
---

# 简介
[github地址](https://github.com/spring-cloud/spring-cloud-gateway)  
[官方文档](https://cloud.spring.io/spring-cloud-gateway/reference/html/)  
Spring Cloud在Finchley版本后推荐使用自家的API网关组件Spring Cloud Gateway。Gateway是Spring Cloud的一个全新项目，基于Spring Framework5, Project Reactor和Spring Boot2等技术开发，使用的是异步非阻塞的IO模式，目的是为了替换掉Zuul1。

# Spring Cloud Gateway的特性
官方介绍的特性如下：
- 基于Spring Framework5，Project Reactor和Spring Boot2.0
- 可以基于任意请求的属性匹配路由
- 对路由定制断言和过滤器
- 集成Hystrix断路器
- 集成Spring Cloud DiscoveryClient
- 易于开发的断言和过滤器
- 请求限流
- 路径重写

# 产品对比
Spring Cloud以前的API网关产品是Netflix在2013年开源的Zuul1，是Netflix的大规模生产级微服务的成功应用。Zuul1使用的是同步阻塞的IO模式，引入了线程池的处理接入的请求，对BIO进行了优化，是伪异步的IO。

与Zuul1不同，Gateway使用的是异步非阻塞的IO模式，引入了断言（Predicate）以匹配来自HTTP请求的任何内容，还新增了基于redis的限流过滤器等等。

下边以表格形式对Zuul1和gateway作对比：

|						| Zuul1.x								| Gateway									|
|-----------------------|---------------------------------------|-------------------------------------------|
| 实现					| 基于Servlet2.x构建，使用阻塞的API。	| 基于Spring Framework5, Project Reactor和Spring Boot2，使用非阻塞式的API。|
| 长连接				| 不支持								| 支持										|
| 不适用场景			| 后端服务响应慢或者高并发场景下，因为线程数量是固定（有限）的，线程容易被耗尽，导致新请求被拒绝。	|  中小流量的项目，使用Zuul1.x更合适。	|
| 限流					| 无									| 有										|
| 上手难度				| 同步编程，上手简单					| 门槛较高，上手难度中等					|
| 与Spring Cloud集成	| 是									| 是										|
| 与Sentinel集成		| 是									| 是										|
| 技术栈沉淀			| Zuul1开源近七年，经受考验，稳定成熟。	| 未见实际落地案例（肯定是我孤陋寡闻）。	|
| Github used by		| 1007 repositories						| 102 repositories							|
| Github issues			| 88 Open / 2736 Closed					| 135 Open / 850 Closed						|

*注：Github used by和Github issues统计时间截止2019/8/26*

[How It Works](施工中)  
[Route Predicate Factories](施工中)  
[GatewayFilter Factories](施工中)  
[Global Filters](施工中)  
[How It Works](施工中)  
[Actuator API](施工中)  
[Developer Guide](施工中)  









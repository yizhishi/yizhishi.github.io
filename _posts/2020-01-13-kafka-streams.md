---
layout: post
title: untitle
date: 2020-01-13 00:15:08 +0000
category:
  - java
tags:
  - kafka-streams
comment: false
reward: false
excerpt: kafka streams学习
---

一个 Kafka Streams 的 WordCount 应用启动后是怎么处理消息的呢？

## 1 准备工作

### 1.1 Kafka Streams 是什么

> The easiest way to write mission-critical real-time applications and microservices

Kafka Streams 提供了一个最**简单**的，开发实时**流处理**应用的方式。因为：

- 它是一个jar包而非流处理框架。单独构建 Kafka Streams 应用只需要一个jar包；与其他项目集成也只需引用这个jar包。
- Kafka Streams 只依赖 Kafka ，输入数据和输出数据都存放在 Kafka 中。

### 1.2 Kafka 集群

假设我们已经有了 Zookeeper 和 Kafka 环境，现在需要创建两个 topic ：

- source topic，命名为xxx，分区数为2，WordCount应用消费的topic。
- target topic，命名为xxx，分区数为2，WordCount应用处理过的数据会发往这个topic。

创建topic的命令为：

``` sh
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 2 --topic topic-name
```

创建两个topic后，查看topic列表

``` sh
bin/kafka-topics.sh --zookeeper localhost:2181 --list
```

## 2 创建Kafka Streams应用

### 官网的demo

``` java

```

启动 WordCount 应用，控制台可以看到应用的**拓扑**（），如下

``` java
Topologies:
   Sub-topology: 0
    Source: KSTREAM-SOURCE-0000000000 (topics: [TextLinesTopic])
      --> KSTREAM-FLATMAPVALUES-0000000001
    Processor: KSTREAM-FLATMAPVALUES-0000000001 (stores: [])
      --> KSTREAM-KEY-SELECT-0000000002
      <-- KSTREAM-SOURCE-0000000000
    Processor: KSTREAM-KEY-SELECT-0000000002 (stores: [])
      --> KSTREAM-FILTER-0000000005
      <-- KSTREAM-FLATMAPVALUES-0000000001
    Processor: KSTREAM-FILTER-0000000005 (stores: [])
      --> KSTREAM-SINK-0000000004
      <-- KSTREAM-KEY-SELECT-0000000002
    Sink: KSTREAM-SINK-0000000004 (topic: counts-store-repartition)
      <-- KSTREAM-FILTER-0000000005

  Sub-topology: 1
    Source: KSTREAM-SOURCE-0000000006 (topics: [counts-store-repartition])
      --> KSTREAM-AGGREGATE-0000000003
    Processor: KSTREAM-AGGREGATE-0000000003 (stores: [counts-store])
      --> KTABLE-TOSTREAM-0000000007
      <-- KSTREAM-SOURCE-0000000006
    Processor: KTABLE-TOSTREAM-0000000007 (stores: [])
      --> KSTREAM-SINK-0000000008
      <-- KSTREAM-AGGREGATE-0000000003
    Sink: KSTREAM-SINK-0000000008 (topic: WordsWithCountsTopic)
      <-- KTABLE-TOSTREAM-0000000007
```

### 消费


## 


### 拓扑

Kafka Streams 通过拓扑定义应用的逻辑，拓扑包括点和边。

- 点，分为3类：Source、Sink和Processor，Source和Sink分别是拓扑的起止，Source从Kafka的Source topic中取消息处理，Sink把处理完的结果发往Kafka的Target topic

###
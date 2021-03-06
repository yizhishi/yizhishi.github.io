---
layout: post
title: 复旦大学软件工程研究生专业课961真题回忆
date: 2020-01-10 00:15:08 +0000
category:
  - study
tags:
  - mse
comment: false
reward: false
excerpt: 961真题考生回忆版本
---

## 2017 真题回忆

### 2017 数据结构

1. 向量相对于数组有什么优缺点？
2. 二叉树计算叶子节点算法，时间复杂度。（可使用任一程序设计语言或伪代码，建议先用自然语言描述算法）
3. 几乎逆序的数组排序用什么排序算法？写出算法，时间复杂度。
4. 二叉排序树的2种优化方法，并且介绍这两种方法是怎样优化二叉排序树的。

### 2017 软件工程

1. 瀑布过程的特点
2. 开闭原则
3. 敏捷宣言是什么
4. 一个场景（学生毕业申请系统），画出UML图、画出流程图0、画出流程图1
5. 结合传感器说明简述软件测试的作用。
‌6. 是不是用例越多越好？为什么说明原因。
‌7. 白盒测试和黑盒测试在用例设计上的区别。

### 2017 计算机原理

1. Amdahl 硬件优化趋势
2. 流水线是怎样提高性能的，会遇到什么问题，解决方法是什么。
3. 软件优化至关重要，软件优化一般有哪些方法？
4. 高速缓存
5. 性能分析定律
6. 存储结构是怎样提高性能的，它和局部性的关系是什么。
7. 虚拟内存的作用，通过什么方式提高虚拟内存的性能。

## 2018 真题回忆

### 2018 数据结构

1. 栈用单链表和数组哪个更好，说理由。
2. 给了个LNode的类，里面是链表的定义，来实现栈的pop函数功能
3. 希尔排序，说明为什么会不稳定？
4. 哈希冲突的2种解决方法，一种在表内，一种在表外
5. 哈夫曼树，哈夫曼编码的算法，压缩率

### 2018 软件工程

1. 超市系统的用例图
2. 选课系统的数据流程图
3. 图书馆的类图，关于读者，老师，学生，临时读者，图书信息，图书拷贝，借书还书记录。
4. 面向对象设计选择，依赖倒置原则，接口隔离原则。

### 2018 计算机原理

1. amahle优化原理，关于优化程序性能，常用优化方法
2. memery + disk和memery+cache两种存储系统的设计差异
3. 流水线设计的优点，为什么能提高性能，可能会影响的因素，怎么解决处理这些影响因素
4. 缺失率

## 2019 真题回忆

### 2019 数据结构

1. 为何单向链表只能在尾部入，头部出？如果要使得尾部和头部都能以O(1)进行插入和删除操作，需要做什么改造？
2. Dijkstra算法填空
3. 写一个高效的构建二叉堆的算法，分析其复杂度，并给出结果
4. 写一个算法，统计二叉树中有2个非空子树的节点，并分析复杂度
5. 写一个算法，从输入的数字序列中，提取最小的k个元素，并达到O(N)的复杂度，如果达不到O(N)的复杂度，会酌情给分

### 2019 软件工程

1. 概念题。分4小问，4×4分=16分

   - 简述CMMI
   - 简述需求获取的途径
   - 简述抽象和逐步求精的关系
   - 怎样判断用例的好坏？

2. 给定一个需求，画出状态机图：台灯有灭-弱光-强光状态，有接通电源和使用内置充电电池两种能量来源，只有一个按钮，按按钮会使得在 灭-弱光-强光 三个状态中切换，如果没有接通电源也没有足够的电量，按按钮没反应；如果是亮的状态，却没有接通电源，当内置电池电量用完的时候会灭掉
3. 给定一个考试管理系统，给出顶层和0层图，0层分解为考试报名系统和成绩管理系统
4. 给定一个CBubbleSorter类中的Sort方法，问
   - 什么是内聚性？这个方法符合内聚性吗？为什么？怎样提高这个方法的内聚性？
   - 如果这个类是继承自CSorter类，画一个类图来表示这两个的关系
   - 根据上面的类图，怎样设计才能方便地切换为其他的排序算法？你的改动体现了什么设计规则？
5. 2×3=6分
   - 白盒测试的覆盖标准，至少列出三个
   - 有人说：“测试就是检查程序的正确性”，对吗？解释下

### 2019 计算机原理

三问，3×10=30分

1. 流水线的分段划分方法非常影响流水线的性能，简述一下怎么个影响法；阐述下基于分段的流水线处理器中，什么是加速比；简述下怎么分段才能使加速比趋向于理想中的加速比？
2. 流水线的停顿非常影响性能，一般有什么原因会出现停顿？一般用什么策略解决停顿问题？
3. 现代CPU中，分层存储结构如何影响流水线的性能？存储层级结构是基于什么原理设计的？为降低存储对CPU的影响，应该采取什么措施进行优化？

## 考生自己尝试整理的部分答案

[腾讯在线文档（这是考生自己尝试整理的部分答案](https://docs.qq.com/doc/DS3BrakdqVGNZYnd1?opendocxfrom=admin)

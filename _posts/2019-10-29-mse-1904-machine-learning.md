---
layout: post
title: "1904 机器学习"
date: 2019-10-29 22:47:08 +0000
category:
  - study
tags:
  - mse
comment: false
reward: false
excerpt: 2019年04学期，机器学习。
---

## 一、神经网络

神经元  
代价函数  
反向传播  

网络训练过程：

- 准备数据，
  - 标准化，最大最小归一化，[0, 1]，x'=(x-min)/(xmax-xmin)
  - Z-score
  - He
  - Xavier
  - [-1,1]   x' = (x-xmin)/(xmax-xmin) (2) + (-1)
- 网络设计，多少个隐层，每层多少个神经元，输出多少编码，学习步长
  - λ动态，
    - λt+1 = λ0 e^({)-\β\t)

$$
f(x) = \int_{-\infty}^\infty \hat f(\xi)\,e^{2 \pi \xi x} \,d\xi
$$

    - Adam

- 训练
  - 样本拆分

n层网络，输出层使用softmax而不是sigmoid？  
作业一：运行BP代码

## 二、卷积

卷积 -> 特征

梯度消失、梯度爆炸

什么是卷积？

LeNet
作业二：识别手写照片

## 三、CNN

## 四、CNN

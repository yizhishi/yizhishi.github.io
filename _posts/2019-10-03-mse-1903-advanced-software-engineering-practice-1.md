---
layout: post
title: "1903 高级软件工程-作业1"
date: 2019-10-03 14:20:00 +0000
category:
  - study
tags:
  - mse
comment: false
reward: false
excerpt: 2019年03学期，高级软件工程作业1，假设一个软件系统，给出尽量完整的UML。
---

## 软件学院MSE网上选课系统

&emsp;&emsp;现有的软件学院非全日制研究生的选课系统（[软件学院MSE网上选课系统](http://www.fdmse.fudan.edu.cn/fdmse-1516/Default.aspx)）主要处理非全日制研究生的选课事务。系统的需求描述如下：

- 查看每学期可选课程信息，无需登录。
- 学生（即我们）在登录后，可以进行以下操作：
  - 修改个人信息（身份证、手机、备用电话、Email、家庭地址、邮编），修改登录密码。
  - 选课，并可以对已选课程进行退课操作。
  - 查看已选课程。
  - 查看自己的成绩。
- 管理员（如廖老师）在登录后，可以进行以下操作：
  - 维护学生信息，如新增学生信息、修改学生信息、查看学生已选课程等。
  - 维护学生成绩，如新增学生成绩、修改学生成绩等。
  - 维护课程信息，如录入每学期可选课程的信息（课程名、主要教师、课程性质等等）。

## 一、用例图

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);"  src="https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/1903-a-s-e-p1/use-case.png" />
    <br />
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">“MSE网上选课系统”用例图</div>
</center>

### 1.1 用例描述

我在下边给出几个重要用例的用例描述

#### 1.1.1 “登录”用例描述

用例名称：“登录”  
用例简述：该用例允许学生和管理员登录系统，以便进行后操作。  
参与者：学生、管理员  
前置条件：开始这个用例前，需要打开系统主页。当参与者需要进入系统时，该用例开始执行。  
后置条件：如果用例成功结束，则什么信息也不会被修改。  
主事件流如下：

1. 参与者输入账号和密码。
2. 系统判断账号和密码是否正确。
3. 如果账号和密码有一个不正确，提示“登录失败”。

#### 1.1.2 “查看课程信息”用例描述



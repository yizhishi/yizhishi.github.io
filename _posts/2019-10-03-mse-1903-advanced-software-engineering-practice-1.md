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
- [软件学院MSE网上选课系统介绍](#%e8%bd%af%e4%bb%b6%e5%ad%a6%e9%99%a2mse%e7%bd%91%e4%b8%8a%e9%80%89%e8%af%be%e7%b3%bb%e7%bb%9f%e4%bb%8b%e7%bb%8d)
- [一、MSE网上选课系统的用例图](#%e4%b8%80mse%e7%bd%91%e4%b8%8a%e9%80%89%e8%af%be%e7%b3%bb%e7%bb%9f%e7%9a%84%e7%94%a8%e4%be%8b%e5%9b%be)
- [二、MSE网上选课系统的部分活动图](#%e4%ba%8cmse%e7%bd%91%e4%b8%8a%e9%80%89%e8%af%be%e7%b3%bb%e7%bb%9f%e7%9a%84%e9%83%a8%e5%88%86%e6%b4%bb%e5%8a%a8%e5%9b%be)
- [三、MSE网上选课系统的部分顺序图](#%e4%b8%89mse%e7%bd%91%e4%b8%8a%e9%80%89%e8%af%be%e7%b3%bb%e7%bb%9f%e7%9a%84%e9%83%a8%e5%88%86%e9%a1%ba%e5%ba%8f%e5%9b%be)
- [四、MSE网上选课系统的部分协作图](#%e5%9b%9bmse%e7%bd%91%e4%b8%8a%e9%80%89%e8%af%be%e7%b3%bb%e7%bb%9f%e7%9a%84%e9%83%a8%e5%88%86%e5%8d%8f%e4%bd%9c%e5%9b%be)
- [五、MSE网上选课系统的类图](#%e4%ba%94mse%e7%bd%91%e4%b8%8a%e9%80%89%e8%af%be%e7%b3%bb%e7%bb%9f%e7%9a%84%e7%b1%bb%e5%9b%be)
- [六、MSE网上选课系统的部分状态图](#%e5%85%admse%e7%bd%91%e4%b8%8a%e9%80%89%e8%af%be%e7%b3%bb%e7%bb%9f%e7%9a%84%e9%83%a8%e5%88%86%e7%8a%b6%e6%80%81%e5%9b%be)
- [七、MSE网上选课系统的组件图](#%e4%b8%83mse%e7%bd%91%e4%b8%8a%e9%80%89%e8%af%be%e7%b3%bb%e7%bb%9f%e7%9a%84%e7%bb%84%e4%bb%b6%e5%9b%be)
- [八、MSE网上选课系统的部署图](#%e5%85%abmse%e7%bd%91%e4%b8%8a%e9%80%89%e8%af%be%e7%b3%bb%e7%bb%9f%e7%9a%84%e9%83%a8%e7%bd%b2%e5%9b%be)

## 软件学院MSE网上选课系统介绍

软件学院现有的非全日制研究生的选课系统（[软件学院MSE网上选课系统](http://www.fdmse.fudan.edu.cn/fdmse-1516/Default.aspx)）主要处理非全日制研究生的选课事务。  
软件学院MSE网上选课系统的部分网站截图如下：

1. 登录页面
![登录页面](https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/1903-a-s-e-p1/login.jpg)
2. 查看成绩页面
![登录页面](https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/1903-a-s-e-p1/score.jpg)
3. 查看课程页面
![登录页面](https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/1903-a-s-e-p1/course.jpg)
4. 学生信息页面
![登录页面](https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/1903-a-s-e-p1/student.jpg)

通过我的系统的使用和分析，我设想的MSE网上选课系统的需求描述如下：

- 查看每个小学期可选课程信息，无需登录。
- 学生（即我们）在登录后，可以进行以下操作：
  - 修改个人信息（身份证、手机、备用电话、Email、家庭地址、邮编），修改登录密码。
  - 选/退课。
  - 查看已选课程。
  - 查看成绩。
- 管理员（如廖老师）在登录后，可以进行以下操作：
  - 维护学生信息，如新增学生信息、修改学生信息、查看学生已选课程等。
  - 维护学生成绩，如新增学生成绩、修改学生成绩等。
  - 维护课程信息，如录入每学期可选课程的信息（课程名、主要教师、课程性质等）。

下边给出MSE网上选课系统的几种UML图。

## 一、MSE网上选课系统的用例图

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);"  src="https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/1903-a-s-e-p1/use-case.png" />
    <br />
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">图1.1 MSE网上选课系统 用例图</div>
</center>

图1.1是MSE网上选课系统的用例图。其中：  
用户泛化为学生和管理员，用户可以进行登录操作。  
学生可以修改个人信息、查看已选课程、查看成绩、选课、查看课程信息。

- 修改个人信息、查看已选课程、查看成绩、选课的前置条件是学生已登录。
- 修改个人信息有一个扩展用例：修改密码。
- 选课有一个扩展用例：退课。
- 查看课程信息有两个扩展用例：查看课程介绍和查看主要教师介绍。

管理员可以管理课程、管理学生信息、管理学生成绩。

- 管理课程有四个扩展用例：新增课程信息、修改课程信息、删除课程信息和查看课程信息。
- 管理学生信息有四个扩展用例：新增学生信息、修改学生信息、查看学生信息、删除学生信息，其中查看学生信息又有一个扩展用例：查看学生选课信息。
- 管理学生成绩有四个扩展用例：新增学生成绩、修改学生成绩、查看学生成绩和删除学生成绩。

下边给出**登录**用例的用例描述。  
用例名称：“登录”  
用例简述：该用例允许学生和管理员登录系统，以便进行后操作。  
参与者：学生、管理员 。
前置条件：开始这个用例前，需要打开系统主页。当参与者需要进入系统时，该用例开始执行。  
后置条件：如果用例成功结束，则什么信息也不会被修改。  
主事件流如下：

1. 参与者输入账号和密码。
2. 系统判断账号和密码是否正确。
3. 如果账号和密码有一个不正确，提示“登录失败”。

## 二、MSE网上选课系统的部分活动图

下边通过活动图对学生行为的工作流程进行描述，活动图如下：

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);"  src="https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/1903-a-s-e-p1/activity.png" />
    <br />
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">图2.1 MSE网上选课系统 学生行为的活动图</div>
</center>

学生行为的活动图描述如下：

- 1 学生操作选课系统，从**初始活动**进入活动**登录网上选课系统**，该活动可以根据学生不同的操作意向产生3个不同的分支活动。
- 2 从活动**登录网上选课系统**出来：
  - 2.1 进入到活动**查看个人信息**，该活动根据条件“是否修改个人信息”，产生2个分支活动。
    - 2.1.1 如果不修改个人信息，进入到**结束活动**。
    - 2.1.2 如果修改个人信息，进入到活动**修改个人信息**，修改后，进入到**结束活动**。
  - 2.2 进入到活动**查看成绩**，查看后，进入到**结束活动**。
  - 2.3 进入到活动**查看课程**，改活动根据条件“是否进行选退课”，产生2个分支。
    - 2.3.1 如果不选/退课，进入到**结束活动**。
    - 2.3.2 如果选/退课，进入到活动**选/退课**，该活动结束后，进入到**结束活动**。

## 三、MSE网上选课系统的部分顺序图

下图是管理员进行新增成绩操作的顺序图：

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);"  src="https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/1903-a-s-e-p1/sequence.png" />
    <br />
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">图3.1 MSE网上选课系统 管理员新增成绩的活动图</div>
</center>

“管理员新增成绩的顺序图”操作过程如下：  
`管理员`试图登录`login(name, pwd)`到`Web界面`，`Web界面`发送`管理员`输入的账户和密码到`数据库接口`进行校验`check(name, pwd)`，由`数据库接口`完成对账户和密码的校验。登录和校验都是同步消息，因此在`check(name, pwd)`返回前之前的活动会是中断的。将以上操作记录进`系统日志` `addLog()`是异步消息，之前的活动不需要中断。  
`管理员`登录后，在`Web界面`进行成绩管理`manageScore()`，`Web界面`发送信息将新增的成绩`addScore(score)`到`数据库接口`。将以上操作记录进`系统日志` `addLog()`是异步消息，之前的活动不需要中断。

## 四、MSE网上选课系统的部分协作图

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);"  src="https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/1903-a-s-e-p1/communication.png" />
    <br />
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">图4.1 MSE网上选课系统 管理员新增成绩的协作图</div>
</center>

顺序图与协作图都用于描述系统中对象之间的动态关系，两者可以相互转换，图4.1所示的协作图是“图3.1 MSE网上选课系统 管理员新增成绩的活动图”对应的协作图。

## 五、MSE网上选课系统的类图

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);"  src="https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/1903-a-s-e-p1/class.png" />
    <br />
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">图5.1 MSE网上选课系统 类图</div>
</center>

MSE网上选课系统共5个类，分别是Student学生类、Admin管理员类、Score成绩类、Record选课记录类、Course课程类。

- 学生类与成绩类是关联关系，一个学生对应1个或多个成绩（未考试或不同学期不同课程的考试成绩），一个成绩对应一个学生。
- 学生类与选课记录类是关联关系，一个学生对应1个或多条选课记录（未选课或每个学期的上下午课程），一条选课记录对应一个学生。
- 选课记录和课程是聚合关系，每一条选课记录包含一个课程。

## 六、MSE网上选课系统的部分状态图

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);"  src="https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/1903-a-s-e-p1/statechart.png" />
    <br />
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">图6.1 MSE网上选课系统 学生选课的状态图</div>
</center>

图6.1是学生选课的状态图，具体分析如下：

1. `校验通过`状态，学生输入账户和密码登录系统。
2. `选课`状态，学生查看课程后进行选课。
3. `课选满`状态，指的是该学生在该学期已经选满所需课程。若还想选课需要进行退课操作后再次选课；或不再次选课，状态图终止。
4. `成功`状态，选课操作成功，状态图终止。
5. `未开放`状态，系统未开放，状态图终止。
6. `人数满`状态，指的时该门课程选课人数已满，需要继续查看课程进行选课。

## 七、MSE网上选课系统的组件图

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);"  src="https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/1903-a-s-e-p1/component.png" />
    <br />
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">图7.1 MSE网上选课系统 组件图</div>
</center>

图7.1是选课系统的组件图，其中`Default.aspx`是系统的入口，`Course`、`Student`、`Score`和`Login`是系统的四个子程序，分别是课程、学生、成绩和登录。  

- `Course`课程子程序又有3个动态Web页面：`CourseSelectView.aspx`、`CourseSelect.aspx`和`CourseManage.aspx`，分别是课程展示页面、选/退课页面和课程管理页面。这3个动态Web页面都依赖`DB`。
- `Student`学生子程序又有3个动态Web页面：`StudentChangePassword.aspx`、`StudentChangeInfo.aspx`和`StudentManage.aspx`，分别是修改密码页面、修改信息页面和学生管理页面。这3个动态Web页面都依赖`DB`。
- `Score`成绩子程序又有2个动态Web页面：ScoreViewByStudent.aspx和ScoreManage.aspx，分别是成绩展示页面和成绩管理页面。这2个动态Web页面都依赖`DB`。
- `Login`登录子程序又有2个动态Web页面：`UserLogin.aspx`和`UserLogout.aspx`，分别是登录页面和注销管理页面。这2个动态Web页面都依赖`DB`。

## 八、MSE网上选课系统的部署图

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);"  src="https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/1903-a-s-e-p1/deploy.png" />
    <br />
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">图8.1 MSE网上选课系统 组件图</div>
</center>

MSE网上选课系统使用的是B/S架构，用户通过浏览器（如chrome、IE等）使用http协议访问Web服务器。Web服务器与数据库服务器之间有数据交互，通过TCP/IP协议。其中Web服务器使用Tomcat作用web容器，版本是8.5；数据库使用的是Mysql，版本是5.6。

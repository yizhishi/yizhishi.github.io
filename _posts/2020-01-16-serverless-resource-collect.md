---
layout: post
title: serverless资料收集
date: 2020-01-13 00:15:08 +0000
category:
  - cloud-native
tags:
  - serverless
comment: false
reward: false
excerpt: serverless文章整理
---

## 网上文章

看了文章就忘，在这儿把文章收集起来。

### [Serverless 落地挑战与蚂蚁金服实践](https://juejin.im/post/5d4bfcf0e51d4561ee1bdf37)

**CNCF每年都会进行调查**
CNCF 在2018年底基于 2400人的一份统计报告，已有 38% 的组织正在使用Serverless 技术，相比 2017 同期增长了 22%。(数据来源：CNCF Survey)

目前市场上，云厂商提供了多种 Serverless 产品和解决方案，大致可划分为：

1. 函数计算服务：如 AWS Lambda，特点是以代码片段为单位运行，并对代码风格有一定要求。
2. 面向应用的 Serverless 服务：如 **Knative，特点是基于容器服务，并提供了从代码包到镜像的构建能力。**
3. 容器托管服务：如 AWS Fargate，特点是以容器镜像为单元运行，但用户仍需感知容器。

落地挑战

- ~~平台迁移问题~~。我们暂时不涉及，但如果出现类似容器初期选型Mesos而后切换至k8s这种情况，我们也将面临
- serverless技术生产环境应用的要求：**0-1的冷启动速度**、**M-N扩容速度**以及稳定性（需要进行验证）
- 调试与监控：用户对**底层资源无感知**，只能借助平台能力对应用进行调试和监控，用户需要平台提供强大的日志功能进行排错，和多维度的监控功能时刻了解应用状态。（借助Prometheus、Grafana、es、Kibana、Jaeger等）
- 事件源集成采用 Serverless 架构后，应用往往进行更细粒度的拆分，并通过事件串联。因此用户希望平台能集成大多数通用的事件源，并支持自定义事件，使得触发机制更加灵活。
- 工作流支持完成某个业务，往往涉及多个 Serverless 应用之间的配合，当数目较多时，用户希望可以用工作流工具来进行统一编排和状态查看，提高效率。

### [初识 Knative：跨平台的 Serverless 编排框架](https://www.infoq.cn/article/rDL06CdUNEPXtPLzT-3O)

Google 牵头联合 Pivotal、IBM、Red Hat 等发起了 Knative 项目，目标提供一个通用的 PAAS 平台给用户使用。

Knative体系下的各种角色关系？**需要从官网找新的图及解释**

Knative优势

Knative 一方面基于 Kubernetes 实现 Serverless 编排，另外一方面 Knative 还基于 Istio 实现服务的接入、服务路由的管理以及灰度发布等功能。Knative 是在已有的云原生基础之上构建的，有很好的社区基础。Knative 一经开源就受到了大家的追捧，其中的主要缘由有：

- Knative 的定位不是 PAAS 而是一个通用的 Serverless 框架，大家可以基于此框架构建自己的 Serverless PAAS
- Knative 对于 Serverless 架构的设计是标准先行。比如之前的 FAAS 解决方案每一个都有一套自己的事件标准，相互之间无法通用。而 Knative 首先提出了 CloudEvent 这一标准，然后基于此标准进行设计
- 完备的社区生态：Kubernetes、ServiceMesh 等社区都是 Knative 的支持者
- 跨平台：因为 Knative 是构建在 Kubernetes 之上的，而 Kubernetes 在不同的云厂商之间几乎可以提供通用的标准。所以 Knative 也就实现了跨平台的能力，没有供应商绑定的风险
- 完备的 Serverless 模型设计：和之前的 Serverless 解决方案相比 Knative 各方面的设计更加完备。比如：
  - 事件模型非常完备，有注册、订阅、以及外部事件系统的接入等等一整套的设计
  - 比如从源码到镜像的构建
  - 比如 Serving 可以做到按比例的灰度发布。

### [酷家乐的 Istio 与 Knative 实践](https://mp.weixin.qq.com/s/LN4_lkHzGGYa3GrFa7osuQ)

#### istio

链路追踪使用jeager（开箱即用）

服务网格的灰度发布，通过label让某分类的流量只能发到特殊label的实例上，找不到特殊实例则走默认实例。

酷家乐 Istio 一年多以来的实践，可以总结的经验如下：

- 已经可以稳定用在生产环境，蚂蚁金服已进入大规模生产落地阶段；
- 工程架构收益 >> 性能资源损耗，敖小剑在Qcon上的第3次分享也这么说；
- 根据组织和业务情况推广或改造，新旧体系可并存；
- 超大规模应用，架构问题有待社区或业界解决；

#### Knative

谨慎落地，聚合层API的实现，支持了Node.js的运行时。

在万全的情况下（镜像预热，镜像文件极小，使用启动速度最快的运行时），从调用触发到新的 pod 拉起来并服务这个调用请求，也仍然需要 3.6 秒（达不到生产要求）。故在使用中，目前建议采用 pod 预热，pod 共用或者驻留一个 pod 的形式来规避。另外，Knative 社区也在积极处理这个问题，他们单独设立了一个 project 来追踪冷启动时间问题，这个项目的目标是将冷启动时间减少到一秒以内。

我们认为，Knative大规模落地，还存在以下几个问题：

- 尚未发布 1.0 版本，不能说 Production-ready；
- Queue-proxy 这一 Sidecar 资源占用有点多（**额外占用30~60mb内存**），需要瘦身；
- 冷启动时间需要缩短；**他这儿只提了0-1的问题，还需要确定m-n的扩缩容速度**。

酷家乐 Knative 总结的经验如下：

- 它是一个非常有发展前景的开源组件，胜过其他的 Serverless 框架；
- 深入掌握后可谨慎使用；
- 目前社区规模尚小，开发者和使用者都需要扩容；

### [进击的serverless](https://zhuanlan.zhihu.com/p/89480241)

为什么会有serverless？

- 开发人员可以更专注，对服务器无感知。
- 服务器资源利用优化。无请求时，缩容为0；请求到来时扩容0-m（带来了coldstart的问题)
- 另，serverless最原始的需求和驱动力是？是Kubernetes不够好用还是Service Mesh不够友好？（我感觉与service mesh关系不太大)
- 
---
layout: post
title: "限流"
date: 2019-10-29 15:36:00 +0000
category:
  - java
tags:
  - 限流
comment: false
reward: false
excerpt: 常见限流算法，sentinel与hystrix分析。
---

## 一、限流算法

常见的限流算法有：计数器、漏桶、令牌桶。

### 1.1 计数器

![counter](https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/rate-limit/counter.jpg)

计数器限流，指固定的时间窗口内可以通过的一定数量的请求，超过这个数量后，接下来的请求会被拒绝。比如1s内可以通过60个请求，超过60个后，新来的请求会被拒绝。

计数器算法可以“简单粗暴”的实现限流，但是存在“突刺现象”，如上图中最后1秒所示，60个请求集中在1s的前一小部分，导致剩余的大部分时间的请求都被拒绝。

### 1.2 漏桶

![leaky-bucket](https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/rate-limit/leaky-bucket.jpg)

如上图，水进入漏桶里，然后按固定速率流出。因为水流出的速率是固定的，所以当请求过多，装满漏桶后，会出现溢出。

这个算法的核心是：缓存请求、匀速处理、多余的请求丢弃。

### 1.3 令牌桶

![token-bucket](https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/rate-limit/token-bucket.jpg)

令牌桶算法按速率往桶里放token，如果桶里token已满，就不再增加；放token操作和取token操作互不影响。

请求到来时尝试从桶中取token，如果取到token，请求放行；如果没有取到token，请求在队列中被缓存。

<!--令牌桶有3个变量：

- 桶的容量，关系到可以存放的token数量。
- 放token的速率，与取token。
- token消耗，由请求决定。

对令牌桶算法而言，如果突发流量的时间比较短，token没有被取光，整体上系统不会有影响；如果突发流量比较大，时间比较长，token被取光，多余的请求就会被限制。

令牌桶算法的令牌以固定速率产生，并缓存到令牌桶中；令牌桶放满时，多余的令牌被丢弃；请求要消耗等比例的令牌才能被处理；令牌不够时，请求被缓存。

相比漏桶算法，令牌桶算法不同之处在于它不但有一只“桶”，还有一个队列，这个桶是用来存放令牌的，队列才是用来存放请求的。

从作用上来说，漏桶和令牌桶算法最明显的区别就是是否允许突发流量的处理，漏桶算法能够强行限制数据的实时处理速率，对突发流量不做额外处理；而令牌桶算法能够在限制数据的平均传输速率的同时允许某种程度的突发处理。
-->

与漏桶算法相比，令牌桶算法在突发流量到来时，可以同时取走多个token，有token就可以处理请求。如果突发流量的时间比较短，token没有被取光，整体上系统不会有影响，在处理突发流量方面要比漏桶好一些。

## 二、Sentinel

### 2.1 Sentinel的插槽时序

![sentinel](https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/rate-limit/sentinel.png)

sentinel的插槽工作时序如上图（以sentinel与zuul集成为例），通过`CommonFilter`，按插槽的构建顺序调用每个插槽的`entry`和`exit`方法：

- 1 `NodeSelectorSlot`收集资源的路径，并将这些资源的调用路径以树状结构存储起来，用于根据调用路径进行流量控制；`ClusterBuilderSlot`构建资源的 `ClusterNode`；`LogSlot`记录异常，以便定位问题。
- 2 `SystemSlot`根据配置的系统规则和系统当前的整体情况，对系统进行保护。
- 3 `AuthoritySlot`根据配置的授权规则，对请求进行黑/白名单校验。
- 4 `FlowSlot`根据配置的流控规则，对请求进行流控处理。
- 5 `DegradeSlot`根据配置的流控规则，对请求进行降级处理。
- 6 `StatisticSlot#entry`，`StatisticSlot`是Sentinel的核心功能插槽之一，用于统计实时的调用数据。
  - 6.1. 新的请求到来，对`DefaultNode`的`thread count`和`pass count`进行add操作。
  - 6.2. 插槽链上，位置在`StatisticSlot`之后的插槽的`entry`方法出现异常（如流控、降级校验不通过会扔出`BlockException`），如果异常类型是`BlockException`对`DefaultNode`的`block count`进行add操作；如果不是，对`exception count`进行add操作。
- 7 `StatisticSlot#exit`
  - 7.1 计算rt，`rt = 当前时间 - 请求进入插槽的时间`，单位是毫秒，此处设置rt不大于4900（可以通过jvm启动参数：`-Dcsp.sentinel.statistic.max.rt=xxx`来修改）。
  - 7.2 对`DefaultNode`的`response time`和`success count`进行了add操作，对`thread count`进行了decrease操作。

### 2.2 Sentinel的流控

Sentinel的流控在`FlowSlot#entry`中处理，流控规则分为QPS和线程数，是当QPS或者线程数超过某个阈值，采取措施进行流量控制。

#### 2.2.1 QPS限流

流控规则是QPS时，监控指标是node的`pass count`，即一秒内到来到的请求，当`pass count`超过规则阈值时，对流量进行控制。

#### 2.2.2 线程数限流

流控规则是线程数时，监控指标是node的`thread num`，即当前处理该资源的线程数，如果`thread num`超过规则阈值时，对流量进行控制。
<!--
如果流控规则是QPS，node的`passQps + 1 > 流控规则设置的值`时，请求被限流；如果流控规则是线程数，node的`thread num + 1 > 流控规则设置的值`时，请求被限流。
-->

### 2.3 Sentinel的降级

Sentinel的降级在`DegradeSlot#entry`中处理，降级规则分为rt（response time）和异常两种类型，异常又细化为异常比例和异常数。

#### 2.3.1 rt（response time）降级

计算node的平均响应时间（avgRt），`avgRt = rt  / success count`，当1s内持续进入5个请求，对应时刻的avgRt均超过阈值，那么在接下的时间窗口之内，对这个方法的调用都会自动地熔断。

#### 2.3.2 异常降级

异常降级分为异常数和异常比例两种，异常数降级是node的`exception > 设置的值`时，请求被降级；异常比例降级是node的`exception / success > 设置的值`且`每秒请求量≥5`时，请求被降级。

*异常降级针对业务异常，不包括`BlockException`。*

## 三、Hystrix

<!--
Hystrix：

- 使用命令模式将所有对外部服务（或依赖关系）的调用包装在`HystrixCommand`或`HystrixObservableCommand`对象中，并将该对象放在单独的线程中执行。
- 每个依赖都维护着一个线程池（或信号量），线程池被耗尽则拒绝请求（而不是让请求排队）。
- 记录请求成功，失败（客户端扔异常），超时和线程拒绝。
- 服务错误百分比超过了阈值，熔断器开关自动打开，一段时间内停止对该服务的所有请求。
- 请求失败，被拒绝，超时或熔断时执行降级逻辑。

与zuul网关配置使用时，默认的隔离策略是信号量，信号量允许的值时100
-->

Hystrix为我们提供了信号量隔离、线程池隔离、熔断和降级，来构建稳定、可靠的分布式系统。

### 3.1 信号量隔离

信号量的实现是一个简单的计数器，是`TryableSemaphore`接口的具体实现`TryableSemaphoreActual`，当请求进入熔断器时，执行`TryableSemaphore#tryAcquire`，计数器加1，结果大于阈值的话，就返回false，发生信号量拒绝事件，执行降级逻辑。当请求离开熔断器时，执行`TryableSemaphore#release`，计数器减1。

### 3.2 线程池隔离

最终，在调用下游微服务时，是由另外的线程`hystrix-RibbonCommand-x`来完成的（`AbstractCommand#executeCommandWithSpecifiedIsolation`），由此来实现线程分离，从而达到资源隔离的作用。当线程池来不及处理并且请求队列塞满时，新进来的请求将快速失败，可以避免依赖问题扩散。

线程池和信号量都支持熔断和限流。相比线程池，信号量不需要线程切换，因此避免了不必要的开销。但是信号量不支持异步，也不支持超时，也就是说当所请求的服务不可用时，信号量会控制超过限制的请求立即返回，但是已经持有信号量的线程只能等待服务响应或从超时中返回，即可能出现长时间等待。线程池模式下，当超过指定时间未响应的服务，Hystrix会通过响应中断的方式通知线程立即结束并返回。

### 3.3 熔断

![hystrix-circuit-breaker](https://raw.githubusercontent.com/wiki/Netflix/Hystrix/images/circuit-breaker-1280.png)

`HystrixCircuitBreaker`接口有3个方法`allowRequest`
、`isOpen`和`markSuccess`，分别用来判断请求是否可以通行、断路器是否打开和闭合断路器。
`HystrixCircuitBreakerImpl`是熔断器的实现，定义了`allowSingleTest`方法用来检测服务是否恢复。

熔断器的几个方法如下：

- `HystrixCircuitBreakerImpl#allowRequest`，判断请求是否被允许。
  - 如果熔断器配置是强制打开（配置项`circuitBreaker.forceOpen`为true），拒绝请求。
  - 如果熔断器配置是强制关闭（配置项`circuitBreaker.forceClosed`为true），运行放行。调用`HystrixCircuitBreakerImpl#isOpen`执行断路器的计算逻辑，用来模拟断路器打开/关闭的行为。
  - 其他情况下，通过`HystrixCircuitBreaker#isOpen`和`HystrixCircuitBreakerImpl#allowSingleTest`来判断是否允许请求。
- `HystrixCircuitBreakerImpl#isOpen`，判断熔断器开关是否打开。
  - 如果断路器打开标识`circuitOpen`是true，返回`circuitOpen`。
  - 如果总请求数或错误比率在设置的阈值比例内，返回false，断路器处于未打开状态。
  - 如果上一步的条件都不满足，将断路器打开。
- `HystrixCircuitBreakerImpl#allowSingleTest`判断是否允许单个请求通行，检查依赖服务是否恢复。

  - 如果熔断器打开，且距离熔断器打开的时间或上一次试探请求放行的时间超过`circuitBreaker.sleepWindowInMilliseconds`的值时，熔断器器进入半开状态，允许放行一个试探请求；否则，不允许放行。

总结，请求到来时：

- 如果断路器不允许通过，短路；
- 如果断路器允许通过，但是信号量tryAcquire失败，请求被拒绝；信号量tryAcquire成功，放行。

### 3.4 降级

Hystrix在以下几种情况下会走降级逻辑，保护当前服务不受依赖服务的影响：

- `HystrixCommand#construct`或`HystrixCommand#run`抛出异常
- 熔断器打开
- 命令的线程池和队列或信号量的容量超额，命令被拒绝
- 命令执行超时

参考：  
[Nginx限速模块初探](https://zhuanlan.zhihu.com/p/32391675)  
[Sentinel介绍](https://github.com/alibaba/Sentinel/wiki/%E4%BB%8B%E7%BB%8D)  

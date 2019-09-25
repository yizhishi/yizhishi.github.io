---
layout: post
title: Zuul1与Spring Cloud Gateway对比
date: 2019-09-25 00:15:08 +0000
category:
  - java
tags: 
  - Spring-Cloud-Gateway
comment: false
reward: false
excerpt: Zuul1与Spring Cloud Gateway对比
---

## 一、API网关

微服务架下，服务之间容易形成网状的调用关系，这种网状的调用关系不便管理和维护，这种场景下API网关应运而生。作为后端服务的入口，API网关在微服务架构中尤其重要，在对外部系统提供API入口的要求下，API网关应具备路由转发、负载均衡、限流熔断、权限控制、轨迹追踪和实时监控等功能。  
目前，很多微服务都基于的Spring Cloud生态构建。Spring Cloud生态为我们提供了两种API网关产品，分别是Netflix开源的Zuul1和Spring自己开发的Spring Cloud Gateway（下边简称为Gateway）。Spring Cloud以Finchley版本为分界线，Finchley版本发布之前使用Zuul1作为API网关，之后更推荐使用Gateway。  
*虽然Netflix已经在2018年5月开源了Zuul2，但是Spring Cloud已经推出了Gateway，并且在github上表示没有集成Zuul2的计划。所以从Spring Cloud发展的趋势来看，Gateway代替Zuul是必然的*

### 1.1 Zuul1简介

Zuul1是Netflix在2013年开源的网关组件，大规模的应用在Netflix的生产环境中，经受了实践考验。它可以与Eureka、Ribbon、Hystrix等组件配合使用，实现路由转发、负载均衡、熔断等功能。Zuul1的核心是一系列过滤器，过滤器简单易于扩展，已经有一些三方库如`spring-cloud-zuul-ratelimit`等提供了过滤器支持。  
Zuul1基于Servlet构建，使用的是阻塞的IO，引入了线程池来处理请求。每个请求都需要独立的线程来处理，从线程池中取出一个工作线程执行，下游微服务返回响应之前这个工作线程一直是阻塞的。
![多线程系统架构](https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/zuul1-multithreaded-system-architecture.png)

### 1.2 Spring Cloud Gateway

Spring Cloud Gateway 是Spring Cloud的一个全新的API网关项目，目的是为了替换掉Zuul1。Gateway可以与Spring Cloud Discovery Client（如Eureka）、Ribbon、Hystrix等组件配合使用，实现路由转发、负载均衡、熔断等功能，并且Gateway还内置了限流过滤器，实现了限流的功能。  
Gateway基于Spring 5、Spring boot 2和Reactor构建，使用Netty作为运行时环境，比较完美的支持异步非阻塞编程。Netty使用非阻塞的IO，线程处理模型建立在主从Reactors多线程模型上。其中Boss Group轮询到新连接后与Client建立连接，生成NioSocketChannel，将channel绑定到Worker；Worker Group轮询并处理Read、Write事件。
![主从reactors模型](https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/netty-simple-thread-model.png)

## 二、对比

### 2.0 产品对比

下边以表格形式对Zuul1和Gateway作简单对比：

| 对比项            |Zuul1.x                             | Gateway               |
|-------------------|-----------------------------------|------------------------|
| 实现             |基于Servlet2.x构建，使用阻塞的API。   | 基于Spring 5、Project Reactor、Spring Boot 2，使用非阻塞式的API。|
| 长连接           |不支持                               | 支持                  |
| 不适用场景       | 后端服务响应慢或者高并发场景下，因为线程数量是固定（有限）的，线程容易被耗尽，导致新请求被拒绝。 | 中小流量的项目，使用Zuul1.x更合适。 |
| 限流             | 无                                 | 内置限流过滤器          |
| 上手难度          | 同步编程，上手简单                  | 门槛较高，上手难度中等  |
| Spring Cloud集成  | 是                                | 是                     |
| Sentinel集成      | 是                                | 是                    |
| 技术栈沉淀        | Zuul1开源近七年，经受考验，稳定成熟。 | ~~未见实际落地案例~~   |
| Github used by    | 1007 repositories                 | 102 repositories      |
| Github issues     | 88 Open / 2736 Closed             | 135 Open / 850 Closed |

*注：Github used by和Github issues统计时间截止2019/8/26。*

### 2.1 性能对比

#### 2.1.1 低并发场景

不同的tps，同样的请求时间（50s），对两种网关产品进行压力测试，结果如下：

| tps   | 测试样本Zuul1/Gateway，单位个 | 平均响应时间Zuul1/Gateway, 单位毫秒 | 99%响应时间小于Zuul1/Gateway，单位毫秒 | 错误比例Zuul1/Gateway |
|-------|---------------|---------|---------|---------|
| 20tps | 20977 / 20580 | 11 / 14 | 16 / 40 | 0% / 0% |
| 50tps | 42685 / 50586 | 18 / 12 | 66 / 22 | 0% / 0% |

并发较低的场景下，两种网关的表现差不多

#### 2.1.2 高并发场景

配置同样的线程数（2000），同样的请求时间（5分钟），后端服务在不同的响应时间（休眠时间），对两种网关产品进行压力测试，结果如下：

| 休眠时间   | 测试样本Zuul1/Gateway，单位个 | 平均响应时间Zuul1/Gateway, 单位毫秒 | 99%响应时间小于Zuul1/Gateway，单位毫秒 | 错误次数Zuul1/Gateway，单位个 | 错误比例Zuul1/Gateway |
|------------|------------------|---------------|---------------|-----------|-------------|
| 休眠100ms  | 294134 / 1059321 | 2026 / 546    | 6136 / 1774   | 104 / 0   | 0.04% / 0%  |
| 休眠300ms  | 101194 / 399909  | 5595 / 1489   | 15056 / 1690  | 1114 / 0  | 1.10% / 0%  |
| 休眠600ms  | 51732 / 201262   | 11768 / 2975  | 27217 / 3203  | 2476 / 0  | 4.79% / 0%  |
| 休眠1000ms | 31896 / 120956   | 19359 / 4914  | 46259 / 5115  | 3598 / 0  | 11.28% / 0% |

*Zuul网关的tomcat最大线程数为400，hystrix超时时间为100000。*  
Gateway在高并发和后端服务响应慢的场景下比Zuul1的表现要好。

#### 2.1.3 官方性能对比

Spring Cloud Gateway的开发者提供了[benchmark项目](https://github.com/spencergibb/spring-cloud-gateway-bench)用来对比Gateway和Zuul1的性能，官方提供的性能对比结果如下：

| 网关                  | Avg Req/sec/Thread  | Avg Latency |
|-----------------------|--------------------|--------------|
| Spring Cloud Gateway  | 3.24k              | 6.61ms       |
| Zuul1                 | 2.09k              | 12.56ms      |
| none                  | 11.77k             | 2.09ms       |

*测试工具为wrk，测试时间30秒，线程数为10，连接数为200。*  
从官方的对比结果来看，Gateway的RPS是Zuul1的1.55倍，平均延迟是Zuul1的一半。

### 2.2 工作对比

### 2.2.1 Zuul1

![zuul-works](https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/zuul-how-it-works.png)

Zuul1过滤器通过`RequestContext`在过滤器之间共享数据，`ZuulServlet#service`按类型调用过滤器，`ZuulFilter#runFilter`按优先级调用过滤器，`ZuulFilter`最后判断是否执行过滤器。以下Zuul的代码是1.3.1版本，并省略了非关键部分代码。

#### RequestContext

过滤器之间通过`RequestContext`共享数据，`RequestContext`是一个`ConcurrentHashMap`，通过`ThreadLocal`保存，通过`RequestContext#getCurrentContext`获取。

``` java
public class RequestContext extends ConcurrentHashMap<String, Object> {

    protected static final ThreadLocal<? extends RequestContext> threadLocal = new ThreadLocal<RequestContext>() {
        @Override
        protected RequestContext initialValue() {
            try {
                return contextClass.newInstance();
            } catch (Throwable e) {
                throw new RuntimeException(e);
            }
        }
    };

    // 通过getCurrentContext()方法获取
    public static RequestContext getCurrentContext() {
        if (testContext != null) return testContext;

        RequestContext context = threadLocal.get();
        return context;
    }
}
```

#### FilterLoader

Zuul核心类之一，提供按类型获取ZuulFilters的方法`FilterLoader#getFiltersByType`

``` java
/**
 * This class is one of the core classes in Zuul. It compiles, loads from a File, and checks if source code changed.
 * It also holds ZuulFilters by filterType.
 */
public class FilterLoader {

    private final ConcurrentHashMap<String, List<ZuulFilter>> hashFiltersByType = new ConcurrentHashMap<String, List<ZuulFilter>>();
    private FilterRegistry filterRegistry = FilterRegistry.instance();

    /**
     * Returns a list of filters by the filterType specified
     */
    public List<ZuulFilter> getFiltersByType(String filterType) {

        // 第一次获取返回null
        List<ZuulFilter> list = hashFiltersByType.get(filterType);
        if (list != null) return list;

        // list is null.
        list = new ArrayList<ZuulFilter>();

        // 从FilterRegistry#getAllFilters取所有的ZuulFilters。
        // 在ZuulFilterInitializer的PostConstruct方法里，会把ZuulFilters放进FilterRegistry
        // 的一个ConcurrentHashMap里。
        Collection<ZuulFilter> filters = filterRegistry.getAllFilters();
        for (Iterator<ZuulFilter> iterator = filters.iterator(); iterator.hasNext(); ) {
            ZuulFilter filter = iterator.next();
            if (filter.filterType().equals(filterType)) {
                // 所需类型的ZuulFilter
                list.add(filter);
            }
        }
        // 排序
        Collections.sort(list); // sort by priority

        // 把对应类型的ZuulFilters放进hashFiltersByType（一个ConcurrentHashMap），
        // 这样第二次调用这个方法可以直接返回所需的ZuulFilters
        hashFiltersByType.putIfAbsent(filterType, list);
        return list;
    }
}
```

#### ZuulServlet

请求都会被ZuulServlet接收并处理。在`ZuulServlet#service`把request和response放进`RequestContext`，并按类型顺序调用了过滤器。

``` java
public class ZuulServlet extends HttpServlet {
    @Override
    public void service(javax.servlet.ServletRequest servletRequest, javax.servlet.ServletResponse servletResponse) throws ServletException, IOException {
        // 调用了ZuulRunner#init初始化RequestContext，并把ServletRequest、ServletResponse放进RequestContext。
        init((HttpServletRequest) servletRequest, (HttpServletResponse) servletResponse);
        // 这里可以看出ZuulFilter的处理顺序：
        // pre->route->post；
        // 如果pre和route阶段出现异常，调用error->post；
        // 如果post阶段出现异常，调用error。
        try {
            preRoute(); // 调用了ZuulRunner#preRoute
        } catch (ZuulException e) {
            error(e); // 把异常放进RequestContext后调用了ZuulRunner#error
            postRoute(); // 调用了ZuulRunner#postRoute
            return;
        }
        try {
            route(); // 调用了ZuulRunner#route
        } catch (ZuulException e) {
            error(e);
            postRoute();
            return;
        }
        try {
            postRoute();
        } catch (ZuulException e) {
            error(e);
            return;
        }
    }
```

#### ZuulRunner

`ZuulRunner`比较简单，提供了`init`方法将request和response放进`RequestContext`，对ZuulFilters的处理直接调用`FilterProcessor`的同名方法。

``` java
public class ZuulRunner {

    public void init(HttpServletRequest servletRequest, HttpServletResponse servletResponse) {
        // 被ZuulServlet#service调用
        RequestContext ctx = RequestContext.getCurrentContext();
        if (bufferRequests) {
            ctx.setRequest(new HttpServletRequestWrapper(servletRequest));
        } else { // ZuulServlet#init创建了一个bufferRequests为false的ZuulRunner，所以没有warp request。
            ctx.setRequest(servletRequest);
        }
        // 把request和response放进RequestContext
        ctx.setResponse(new HttpServletResponseWrapper(servletResponse));
    }

    public void postRoute() throws ZuulException {
        // 调用FilterProcessor#postRoute，其他route、preRoute和error也是调用的FilterProcessor里的同名方法。
        FilterProcessor.getInstance().postRoute();
    }
    ...
}
```

#### FilterProcessor

`FilterProcessor`的javadoc注释直接注明`This the the core class to execute filters.`，按类型和优先级`ZuulFilter#runFilter`执行过滤器。

``` java
public class FilterProcessor {
    public void postRoute() throws ZuulException {
        // route方法和preRoute方法和postRoute方法一样，区别是调用runFilters时参数分别是route和pre
        // 出现异常往上抛出，try catch 代码略去
        runFilters("post");
    }
    public void error() {
        try {
            runFilters("error");
        } catch (Throwable e) {
            // 异常被捕获而不抛出，但是在ZuulServlet中异常已经被放进RequestContext。
        }
    }
    /**
     * runs all filters of the filterType sType/ Use this method within filters to run custom filters by type
     */
    public Object runFilters(String sType) throws Throwable {
        // 从FilterLoader中获取对应类型的ZuulFilter，是排过序的
        List<ZuulFilter> list = FilterLoader.getInstance().getFiltersByType(sType);
        for (int i = 0; i < list.size(); i++) {
            ZuulFilter zuulFilter = list.get(i);
            // 获取ZuulFilter，并调用processZuulFilter方法
            Object result = processZuulFilter(zuulFilter);
            if (result != null && result instanceof Boolean) {
                // |= 操作，与 += 一样但比较少见，此外还有 &= 、^=
                bResult |= ((Boolean) result);
            }
        }
        return bResult;
    }

    /**
     * Processes an individual ZuulFilter. This method adds Debug information.
     * Any uncaught Thowables are caught by this method and converted to a ZuulException with a 500 status code.
     */
    public Object processZuulFilter(ZuulFilter filter) throws ZuulException {
        // get RequestContext
        RequestContext ctx = RequestContext.getCurrentContext();
        try {
            // 调用ZuulFilter#runFilter。根据过滤器里的shouldFilter判断是否执行过滤器的run()方法。
            // 如果执行过滤器的run()方法，返回执行成功（SUCCESS）或失败（FAILED），不执行则返回跳过（SKIPPED）
            ZuulFilterResult result = filter.runFilter();
            // ZuulFilter#runFilter执行状态
            ExecutionStatus s = result.getStatus();
            switch (s) {
                case FAILED:
                    // 过滤器的run()执行异常
                    t = result.getException();
                    break;
                case SUCCESS:
                    // 过滤器的的run()执行结束
                    o = result.getResult();
                    break;
                default:
                    // 过滤器的shouldFilter是false
                    break;
            }
            // 如果过滤器的run()异常，抛异常
            if (t != null) throw t;
            return o;
        } catch (Throwable e) {
            // 异常往上抛出，在ZuulServlet#service方法里被捕获，然后通过error类型的过滤器处理异常。
        }
    }
}
```

#### ZuulFilter

ZuulFilters的父类，注释好清晰的，简单易懂。提供了：

- filterType抽象方法用于在子类中指定过滤器类型pre、route、post、error。
- filterOrder抽象方法用于在子类中指过滤器优先级。
- isFilterDisabled，过滤器是否被禁用，在配置文件中通过配置如`zuul.RibbonRoutingFilter.route.disable = true`禁用type为route的类名是RibbonRoutingFilter的过滤器。
- runFilter，check过滤器是否被禁用和是否应该执行，然后调用子类的run()方法。

``` java
public abstract class ZuulFilter implements IZuulFilter, Comparable<ZuulFilter> {
    // 过滤器类型
    abstract public String filterType();
    // 过滤器优先级
    abstract public int filterOrder();
    // 过滤器是否被禁用。
    // 在runFilter()方法里，通过判断isFilterDisabled与过滤器的shouldFilter方法，来确定是否执行过滤器的run方法
    public boolean isFilterDisabled() {
        ...
    }
    /**
     * runFilter checks !isFilterDisabled() and shouldFilter(). The run() method is invoked if both are true.
     */
    public ZuulFilterResult runFilter() {
        ZuulFilterResult zr = new ZuulFilterResult();
        // 是否被禁用
        if (!isFilterDisabled()) {
            // 是否应该执行
            if (shouldFilter()) {
                try {
                    Object res = run(); // 执行过滤器的run()
                    zr = new ZuulFilterResult(res, ExecutionStatus.SUCCESS);
                } catch (Throwable e) {
                    zr = new ZuulFilterResult(ExecutionStatus.FAILED);
                    zr.setException(e);
                } finally {
                }
            } else {
                zr = new ZuulFilterResult(ExecutionStatus.SKIPPED);
            }
        }
        return zr;
    }
}
```

### 2.2.2 Gateway

Gateway的工作机制可参考下图（图片来自官方）

![gateway-works](https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/gateway-how-it-works.jpg)

#### ReactorHttpHandlerAdapter

https://xujin.org/sc/gw/gw02/
http://www.iocoder.cn/Spring-Cloud-Gateway/ouwenxue/intro/?vip
Gateway的请求入口是ReactorHttpHandlerAdapter

``` java
public class ReactorHttpHandlerAdapter implements BiFunction<HttpServerRequest, HttpServerResponse, Mono<Void>> {
  @Override
  public Mono<Void> apply(HttpServerRequest reactorRequest, HttpServerResponse reactorResponse) {
    NettyDataBufferFactory bufferFactory = new NettyDataBufferFactory(reactorResponse.alloc());
    try {
      ReactorServerHttpRequest request = new ReactorServerHttpRequest(reactorRequest, bufferFactory);
      ServerHttpResponse response = new ReactorServerHttpResponse(reactorResponse, bufferFactory);

      if (request.getMethod() == HttpMethod.HEAD) {
        response = new HttpHeadResponseDecorator(response);
      }

      return this.httpHandler.handle(request, response)
          .doOnError(ex -> logger.trace(request.getLogPrefix() + "Failed to complete: " + ex.getMessage()))
          .doOnSuccess(aVoid -> logger.trace(request.getLogPrefix() + "Handling completed"));
    }
    catch (URISyntaxException ex) {
      if (logger.isDebugEnabled()) {
        logger.debug("Failed to get request URI: " + ex.getMessage());
      }
      reactorResponse.status(HttpResponseStatus.BAD_REQUEST);
      return Mono.empty();
    }
  }
}
```

## 总结

Zuul1的开源时间很早，Netflix、Riot、携程、拍拍贷等公司都已经在生产环境中使用，自身经受了实践考验，是生产级的API网关产品。  
Gateway在2019年离开Spring Cloud孵化器，应用于生产的案例少，稳定性有待考证。  
从性能方面比较，两种产品在流量小的场景下性能表现差不多；并发高的场景下Gateway性能要好很多。从开发方面比较，Zuul1编程模型简单，易于扩展；Gateway编程模型稍难，代码阅读难度要比Zuul高不少，扩展也稍复杂一些。

附：[一文理解Netty模型架构](https://juejin.im/post/5bea1d2e51882523d3163657#heading-12)

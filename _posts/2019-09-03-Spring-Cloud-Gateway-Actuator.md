---
layout: post
title: Spring Cloud Gateway Actuator
date: 2019-09-03 15:41:08 +0000
category:
  - java
tags: [Spring Cloud Gateway]
comment: false
reward: false
excerpt: Spring Cloud Gateway Actuator。
---



## actuator 端点

官方介绍：

> The /gateway actuator endpoint allows to monitor and interact with a Spring Cloud Gateway application. To be remotely accessible, the endpoint has to be enabled and exposed via HTTP or JMX in the application properties.

使用过spring-boot-starter-actuator的同学应该对actuator不陌生，通过actuator端点可以对Spring Boot应用进行监控和交互（查看beans啥的很方便）。Gateway也有几个端点在`org.springframework.cloud.gateway.actuate.GatewayControllerEndpoint`控制器中定义。

## 端点暴露

在`application.properties`新增属性，和`spring-boot-starter-actuator`使用方法一样，需要暴露端点。

``` java
management.endpoint.gateway.enabled = true          # 这个值默认就是true，所以不是必须的
management.endpoints.web.exposure.include = gateway # 暴露/gateway/*端点
```

暴露后默认通过`ip:port/actuator/gateway/xxxx`进行访问

## 端点简介（2.1.2.RELEASE版本）

| Endpoint                      | Request Method   | 描述  |
|-------------------------------|------------------|-------|
| /refresh                      | Post             | 清除routes的cache                                                 |
| /globalfilters                | Get              | 查询`GlobalFilter`的子类名称和顺序                                 |
| /routefilters                 | Get              | 查询`GatewayFilterFactory`的子类                                  |
| /routes                       | Get              | 查询包括定义的路由信息，详见下文                                    |
| /routes/{id}                  | Post             | 新增route，通过`InMemoryRouteDefinitionRepository`的save方法保存   |
| /routes/{id}                  | Delete           | 删除route，通过`InMemoryRouteDefinitionRepository`的delete方法删除 |
| /routes/{id}                  | Get              | 查询单个路由                                                      |
| /routes/{id}/combinedfilters  | Get              | 查询单个路由                                                      |

### refresh端点

org.springframework.cloud.gateway.actuate.GatewayControllerEndpoint

``` java
    // publisher 是 ApplicationContext 的实现类 ReactiveWebServerApplicationContext
    private ApplicationEventPublisher publisher;

    ...

    @PostMapping("/refresh")
    public Mono<Void> refresh() {
        // publishEvent方法，具体调用的是 ReactiveWebServerApplicationContext 的父类 org.springframework.context.support.AbstractApplicationContext 里的 publishEvent
        // publishEvent方法的入参 RefreshRoutesEvent 继承了 ApplicationEvent
        this.publisher.publishEvent(new RefreshRoutesEvent(this));

        return Mono.empty();
    }
```

org.springframework.context.support.AbstractApplicationContext

``` java
    /**
     * Publish the given event to all listeners.
     * <p>Note: Listeners get initialized after the MessageSource, to be able
     * to access it within listener implementations. Thus, MessageSource
     * implementations cannot publish events.
     * @param event the event to publish (may be application-specific or a
     * standard framework event)
     */
    @Override
    public void publishEvent(ApplicationEvent event) {
        publishEvent(event, null);
    }

    /**
     * Publish the given event to all listeners.
     * @param event the event to publish (may be an {@link ApplicationEvent}
     * or a payload object to be turned into a {@link PayloadApplicationEvent})
     * @param eventType the resolved event type, if known
     * @since 4.2
     */
    protected void publishEvent(Object event, @Nullable ResolvableType eventType) {
        Assert.notNull(event, "Event must not be null");

        // Decorate event as an ApplicationEvent if necessary
        // 1 把入参的 object 转化为 ApplicationEvent
        ApplicationEvent applicationEvent;
        if (event instanceof ApplicationEvent) {
            applicationEvent = (ApplicationEvent) event;
        }
        else {
            applicationEvent = new PayloadApplicationEvent<>(this, event);
            if (eventType == null) {
                eventType = ((PayloadApplicationEvent<?>) applicationEvent).getResolvableType();
            }
        }

        // Multicast right now if possible - or lazily once the multicaster is initialized
        if (this.earlyApplicationEvents != null) {
            this.earlyApplicationEvents.add(applicationEvent);
        }
        else {
            // 2 监听器处理 RefreshRoutesEvent
            // 2.1 DelegatingApplicationListener#onApplicationEvent，什么都没做
            // 2.2 WeightCalculatorWebFilter#onApplicationEvent，强制初始化？？
            // 2.3 RouteRefreshListener#onApplicationEvent，什么都没做
            // 2.4 CachingRouteLocator#onApplicationEvent，清理了 CachingRouteLocator 里的 cache map；能起到什么作用？？
            getApplicationEventMulticaster().multicastEvent(applicationEvent, eventType);
        }

        // Publish event via parent context as well...
        if (this.parent != null) {
            // parent 是 AnnotationConfigApplicationContext 继承了 AbstractApplicationContext
            if (this.parent instanceof AbstractApplicationContext) {
                ((AbstractApplicationContext) this.parent).publishEvent(event, eventType);
            }
            else {
                this.parent.publishEvent(event);
            }
        }
    }
```

org.springframework.cloud.gateway.filter.WeightCalculatorWebFilter

``` java

    private final ObjectProvider<RouteLocator> routeLocator;

    ...

    @Override
    public void onApplicationEvent(ApplicationEvent event) {
        if (event instanceof PredicateArgsEvent) {
            handle((PredicateArgsEvent) event);
        }
        else if (event instanceof WeightDefinedEvent) {
            addWeightConfig(((WeightDefinedEvent) event).getWeightConfig());
        }
        else if (event instanceof RefreshRoutesEvent && routeLocator != null) {
            // 调用了 CachingRouteLocator#getRoutes，然后 Flux#subscribe
            routeLocator.ifAvailable(locator -> locator.getRoutes().subscribe()); // forces initialization
        }

    }
```

### routes端点，get

在eureka注册了gateway和service-a后，返回结果如下：

``` json
[
    {
        "route_id": "e25f164c-65f7-4ebb-bbbf-a6e8d077a751",
        "route_object": {
            "predicate": "org.springframework.cloud.gateway.support.ServerWebExchangeUtils$$Lambda$295/1802415698@64728c4c"
        },
        "order": 0
    },
    {
        "route_id": "CompositeDiscoveryClient_GATEWAY",
        "route_definition": {
            "id": "CompositeDiscoveryClient_GATEWAY",
            "predicates": [
                {
                    "name": "Path",
                    "args": {
                        "pattern": "/gateway/**"
                    }
                }
            ],
            "filters": [
                {
                    "name": "RewritePath",
                    "args": {
                        "regexp": "/gateway/(?<remaining>.*)",
                        "replacement": "/${remaining}"
                    }
                }
            ],
            "uri": "lb://GATEWAY",
            "order": 0
        },
        "order": 0
    },
    {
        "route_id": "CompositeDiscoveryClient_SERVICE-A",
        "route_definition": {
            "id": "CompositeDiscoveryClient_SERVICE-A",
            "predicates": [
                {
                    "name": "Path",
                    "args": {
                        "pattern": "/service-a/**"
                    }
                }
            ],
            "filters": [
                {
                    "name": "RewritePath",
                    "args": {
                        "regexp": "/service-a/(?<remaining>.*)",
                        "replacement": "/${remaining}"
                    }
                }
            ],
            "uri": "lb://SERVICE-A",
            "order": 0
        },
        "order": 0
    }
]
```

### /routes/{id}/combinedfilters端点

id：CompositeDiscoveryClient_GATEWAY，返回如下:

``` json
{
    "Route{id='CompositeDiscoveryClient_GATEWAY', uri=lb://GATEWAY, order=0, predicate=org.springframework.cloud.gateway.support.ServerWebExchangeUtils$$Lambda$295/2058424956@e71a481, gatewayFilters=[OrderedGatewayFilter{delegate=org.springframework.cloud.gateway.filter.factory.RewritePathGatewayFilterFactory$$Lambda$727/1267821762@5af54f45, order=1}]}": 0
}
```

### /routes/{id}端点

id：CompositeDiscoveryClient_GATEWAY，返回如下:

``` json
{
    "id": "CompositeDiscoveryClient_GATEWAY",
    "predicates": [
        {
            "name": "Path",
            "args": {
                "pattern": "/gateway/**"
            }
        }
    ],
    "filters": [
        {
            "name": "RewritePath",
            "args": {
                "regexp": "/gateway/(?<remaining>.*)",
                "replacement": "/${remaining}"
            }
        }
    ],
    "uri": "lb://GATEWAY",
    "order": 0
}
```

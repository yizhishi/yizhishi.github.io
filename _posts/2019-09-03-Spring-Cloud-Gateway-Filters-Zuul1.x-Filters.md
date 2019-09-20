---
layout: post
title: Spring Cloud Gateway 过滤器
date: 2019-09-03 13:55:08 +0000
category:
  - java
tags: 
  - Spring Cloud Gateway
comment: false
reward: false
excerpt: Spring Cloud Gateway过滤器与Zuul1.x过滤器。
---

Gateway的Filter与Zuul1.x的Filter的区别

## Zuul1.x的过滤器如何工作

过滤器是Zuul1.x功能的核心部分，比如收到请求后在`PreDecorationFilter`里判断是通过ribbon路由`RibbonRoutingFilter`，还是直接跳转`SendForwardFilter`，还是简单路由`SimpleHostRoutingFilter`等操作都是通过过滤器实现，且Zuul1.x的过滤器简单易与扩展。
比较重要的类有`RequestContext`、`ZuulServlet`、`ZuulRunner`、`FilterProcessor`、`FilterLoader`。

### RequestContext

通过`RequestContext`共享数据，`RequestContext`是一个`ConcurrentHashMap`，通过`ThreadLocal`保存，通过`RequestContext#getCurrentContext`获取。

``` java
/**
 * The Request Context holds request, response,  state information and data for ZuulFilters to access and share.
 * The RequestContext lives for the duration of the request and is ThreadLocal.
 * extensions of RequestContext can be substituted by setting the contextClass.
 * Most methods here are convenience wrapper methods; the RequestContext is an extension of a ConcurrentHashMap
 * ...
 */
public class RequestContext extends ConcurrentHashMap<String, Object> {
    ...
    private static RequestContext testContext = null;

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
    ...
    /**
     * Get the current RequestContext
     *
     * @return the current RequestContext
     */
    public static RequestContext getCurrentContext() {
        // 通过getCurrentContext()方法获取
        if (testContext != null) return testContext;

        RequestContext context = threadLocal.get();
        return context;
    }

    /**
     * unsets the threadLocal context. Done at the end of the request.
     */
    public void unset() {
        // 在ZuulServlet#service的finally代码块中被调用
        threadLocal.remove();
    }
    ...
    // 下边是一堆get、set方法，包括getRequest()，setRequest()等等

}
```

### ZuulServlet

Zuul1.x是基于Servlet2.5构建的，通过`ZuulServlet#service`转发请求。

``` java
/**
 * Core Zuul servlet which intializes and orchestrates zuulFilter execution
 * ...
 */
public class ZuulServlet extends HttpServlet {
    ...
    @Override
    public void service(javax.servlet.ServletRequest servletRequest, javax.servlet.ServletResponse servletResponse) throws ServletException, IOException {
        try {
            // 调用了ZuulRunner#init初始化RequestContext，并把ServletRequest、ServletResponse放进RequestContext。
            init((HttpServletRequest) servletRequest, (HttpServletResponse) servletResponse);

            // Marks this request as having passed through the "Zuul engine", as opposed to servlets
            // explicitly bound in web.xml, for which requests will not have the same data attached
            RequestContext context = RequestContext.getCurrentContext();
            context.setZuulEngineRan();

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

        } catch (Throwable e) {
            error(new ZuulException(e, 500, "UNHANDLED_EXCEPTION_" + e.getClass().getName()));
        } finally {
            // 调用ThreadLocal#remove，清空RequestContext
            RequestContext.getCurrentContext().unset();
        }
    }
```

### ZuulRunner

`ZuulRunner`比较简单，提供了`init`方法将request和response放进`RequestContext`，对ZuulFilters的处理直接调用`FilterProcessor`的同名方法。

``` java
/**
 * This class initializes servlet requests and responses into the RequestContext and wraps the FilterProcessor calls
 * to preRoute(), route(),  postRoute(), and error() methods
 * ...
 */
public class ZuulRunner {
    ...
    /**
     * sets HttpServlet request and HttpResponse
     *
     * @param servletRequest
     * @param servletResponse
     */
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

    /**
     * executes "post" filterType  ZuulFilters
     *
     * @throws ZuulException
     */
    public void postRoute() throws ZuulException {
        // 调用FilterProcessor#postRoute，其他route、preRoute和error也是调用的FilterProcessor里的同名方法。
        FilterProcessor.getInstance().postRoute();
    }
    ...
}
```

### FilterProcessor

`FilterProcessor`的javadoc注释`This the the core class to execute filters.`，在`FilterProcessor#processZuulFilter`调用了`ZuulFilter#runFilter`对ZuulFilters进行处理。

``` java
/**
 * This the the core class to execute filters.
 * ...
 */
public class FilterProcessor {
    ...
    /**
     * runs "post" filters which are called after "route" filters. ZuulExceptions from ZuulFilters are thrown.
     * Any other Throwables are caught and a ZuulException is thrown out with a 500 status code
     *
     * @throws ZuulException
     */
    public void postRoute() throws ZuulException {
        try {
            // route和preRoute和这个方法一样，区别是调用runFilters时参数分别是route和pre
            runFilters("post");
        } catch (ZuulException e) {
            throw e;
        } catch (Throwable e) {
            throw new ZuulException(e, 500, "UNCAUGHT_EXCEPTION_IN_POST_FILTER_" + e.getClass().getName());
        }
    }

    /**
     * runs all "error" filters. These are called only if an exception occurs.
     * Exceptions from this are swallowed and logged so as not to bubble up.
     */
    public void error() {
        try {
            runFilters("error");
        } catch (Throwable e) {
            // 异常被捕获而不抛出，但是在ZuulServlet中异常已经被放进RequestContext。
            logger.error(e.getMessage(), e);
        }
    }

    /**
     * runs all filters of the filterType sType/ Use this method within filters to run custom filters by type
     *
     * @param sType the filterType.
     * @return
     * @throws Throwable throws up an arbitrary exception
     */
    public Object runFilters(String sType) throws Throwable {
        if (RequestContext.getCurrentContext().debugRouting()) {
            Debug.addRoutingDebug("Invoking {" + sType + "} type filters");
        }
        boolean bResult = false;
        // 从FilterLoader中获取对应类型的ZuulFilter，是排过序的
        List<ZuulFilter> list = FilterLoader.getInstance().getFiltersByType(sType);
        if (list != null) {
            for (int i = 0; i < list.size(); i++) {
                ZuulFilter zuulFilter = list.get(i);
                Object result = processZuulFilter(zuulFilter); // 获取ZuulFilter，并调用processZuulFilter方法
                if (result != null && result instanceof Boolean) {
                    bResult |= ((Boolean) result); // |= 操作，与 += 一样但比较少见，此外还有 &= 、^=
                }
            }
        }
        return bResult;
    }

    /**
     * Processes an individual ZuulFilter. This method adds Debug information.
     * Any uncaught Thowables are caught by this method and converted to a ZuulException with a 500 status code.
     *
     * @param filter
     * @return the return value for that filter
     * @throws ZuulException
     */
    public Object processZuulFilter(ZuulFilter filter) throws ZuulException {

        RequestContext ctx = RequestContext.getCurrentContext(); // get RequestContext
        boolean bDebug = ctx.debugRouting();
        final String metricPrefix = "zuul.filter-"; // 没有被用到~
        long execTime = 0;
        String filterName = "";
        try {
            long ltime = System.currentTimeMillis();
            filterName = filter.getClass().getSimpleName();

            RequestContext copy = null;
            Object o = null;
            Throwable t = null;

            if (bDebug) {
                Debug.addRoutingDebug("Filter " + filter.filterType() + " " + filter.filterOrder() + " " + filterName);
                copy = ctx.copy();
            }

            // 调用ZuulFilter#runFilter。根据过滤器里的shouldFilter判断是否执行过滤器的run()方法。
            // 如果执行过滤器的run()方法，返回执行成功（SUCCESS）或失败（FAILED），不执行则返回跳过（SKIPPED）
            ZuulFilterResult result = filter.runFilter();
            // ZuulFilter#runFilter执行状态
            ExecutionStatus s = result.getStatus();
            // ZuulFilter#runFilter执行时间
            execTime = System.currentTimeMillis() - ltime;

            switch (s) {
                case FAILED: // 过滤器的run()执行异常
                    t = result.getException();
                    ctx.addFilterExecutionSummary(filterName, ExecutionStatus.FAILED.name(), execTime);
                    break;
                case SUCCESS: // 过滤器的的run()执行结束
                    o = result.getResult();
                    ctx.addFilterExecutionSummary(filterName, ExecutionStatus.SUCCESS.name(), execTime);
                    if (bDebug) {
                        Debug.addRoutingDebug("Filter {" + filterName + " TYPE:" + filter.filterType() + " ORDER:" + filter.filterOrder() + "} Execution time = " + execTime + "ms");
                        Debug.compareContextState(filterName, copy);
                    }
                    break;
                default:
                    // 过滤器的shouldFilter是false
                    break;
            }

            if (t != null) throw t; // 如果过滤器的run()异常，抛异常

            // 如果过滤器的run()执行结束或跳过，调用BasicFilterUsageNotifier#notify。
            usageNotifier.notify(filter, s);
            return o;

        } catch (Throwable e) {
            // 异常往上抛出，在ZuulServlet#service方法里被捕获，然后通过error类型的过滤器处理异常。
            if (bDebug) {
                Debug.addRoutingDebug("Running Filter failed " + filterName + " type:" + filter.filterType() + " order:" + filter.filterOrder() + " " + e.getMessage());
            }
            // 调用BasicFilterUsageNotifier#notify，创建一个name是zuul.filter-${filter的类名}的计时器，并count + 1
            usageNotifier.notify(filter, ExecutionStatus.FAILED);
            if (e instanceof ZuulException) {
                throw (ZuulException) e;
            } else {
                ZuulException ex = new ZuulException(e, "Filter threw Exception", 500, filter.filterType() + ":" + filterName);
                ctx.addFilterExecutionSummary(filterName, ExecutionStatus.FAILED.name(), execTime);
                throw ex;
            }
        }
    }
    ...
    // BasicFilterUsageNotifier#notify和一些test
}
```

### FilterLoader

Zuul核心类，提供按类型获取ZuulFilters的方法`FilterLoader#getFiltersByType`

``` java
/**
 * This class is one of the core classes in Zuul. It compiles, loads from a File, and checks if source code changed.
 * It also holds ZuulFilters by filterType.
 * ...
 */
public class FilterLoader {
    ...
    private final ConcurrentHashMap<String, List<ZuulFilter>> hashFiltersByType = new ConcurrentHashMap<String, List<ZuulFilter>>();

    private FilterRegistry filterRegistry = FilterRegistry.instance();
    ...
    /**
     * Returns a list of filters by the filterType specified
     *
     * @param filterType
     * @return a List<ZuulFilter>
     */
    public List<ZuulFilter> getFiltersByType(String filterType) {

        List<ZuulFilter> list = hashFiltersByType.get(filterType); // 第一次获取返回null
        if (list != null) return list;

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
    ...
}
```

### ZuulFilter

ZuulFilters的父类，注释好清晰的，很好懂。提供了：

- filterType抽象方法用于在子类中指定过滤器类型pre、route、post、error。
- filterOrder抽象方法用于在子类中指过滤器优先级。
- isFilterDisabled，过滤器是否被禁用，在配置文件中通过配置如“zuul.RibbonRoutingFilter.route.disable=true”禁用type为route的类名是RibbonRoutingFilter的过滤器。
- runFilter，check过滤器是否被禁用和是否应该执行，然后调用子类的run()方法。
- ...

``` java
...
public abstract class ZuulFilter implements IZuulFilter, Comparable<ZuulFilter> {
    ...
    // 过滤器类型
    abstract public String filterType();
    ...
    // 过滤器优先级
    abstract public int filterOrder();
    ...
    // return zuul.[classname].[filtertype].disable
    public String disablePropertyName() {
        return "zuul." + this.getClass().getSimpleName() + "." + filterType() + ".disable";
    }
    // 过滤器是否被禁用。
    // 在runFilter()方法里，通过判断isFilterDisabled与过滤器的shouldFilter方法，来确定是否执行过滤器的run方法
    public boolean isFilterDisabled() {
        filterDisabledRef.compareAndSet(null, DynamicPropertyFactory.getInstance().getBooleanProperty(disablePropertyName(), false));
        return filterDisabledRef.get().get();
    }

    /**
     * runFilter checks !isFilterDisabled() and shouldFilter(). The run() method is invoked if both are true.
     *
     * @return the return from ZuulFilterResult
     */
    public ZuulFilterResult runFilter() {
        ZuulFilterResult zr = new ZuulFilterResult();
        if (!isFilterDisabled()) { // 是否被禁用
            if (shouldFilter()) { // 是否应该执行
                Tracer t = TracerFactory.instance().startMicroTracer("ZUUL::" + this.getClass().getSimpleName());
                try {
                    Object res = run(); // 执行过滤器的run()
                    zr = new ZuulFilterResult(res, ExecutionStatus.SUCCESS);
                } catch (Throwable e) {
                    t.setName("ZUUL::" + this.getClass().getSimpleName() + " failed");
                    zr = new ZuulFilterResult(ExecutionStatus.FAILED);
                    zr.setException(e);
                } finally {
                    t.stopAndLog();
                }
            } else {
                zr = new ZuulFilterResult(ExecutionStatus.SKIPPED);
            }
        }
        return zr;
    }

    ... // compare与test
}
```

### 总结

通过`RequestContext`在过滤器之间共享数据，`ZuulServlet#service`按类型调用过滤器，`ZuulFilter#runFilter`按优先级调用过滤器，`ZuulFilter`最后判断是否执行过滤器。

## Gateway的过滤器如何工作

施工中

Gateway的过滤器分两类，分别是GlobalFilter和GatewayFilter，俩者有相同的方法定义。

DisPatcherHandler ->

### FilteringWebHandler

``` java

```

### 总结

通过``
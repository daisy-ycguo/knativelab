# 创建定时事件以及订阅该事件

在这个练习中，我们将使用定时事件`Cronjob`。我们会创建一个可访问的对象（Accessable）来接收事件消息，并把它打印到日志中。

![](https://github.com/daisy-ycguo/knativelab/raw/master/images/knative-simplemode.png)

***注意*** 下面的操作要求在目录`knativelab/src/cronjob`中进行，可以在CloudShell窗口执行下面命令进入该目录：
```
cd ~/knativelab/src/cronjob/
```

## 步骤一：创建接收事件消息的服务

由于Knative Service自带一个域名可以访问，所以我们创建一个Knative Service作为可访问的对象，来接受事件消息。输入下面的命令，创建`event-display`服务：

```text
kn service create --image docker.io/daisyycguo/event_display-bb44423e21d22fe93666b961f6cfb013 event-display 
```

期待输出：
```
Service 'event-display' successfully created in namespace 'default'.
```

通过下面命令检查该服务已经创建完成，`READY`那栏显示 `True`。如果还没有，请等待一段时间:

```text
kn service list
```

期待输出：
```
NAME            DOMAIN                                                                   GENERATION   AGE   CONDITIONS   READY   REASON
event-display   event-display-default.knative1-guoyc.au-syd.containers.appdomain.cloud   1            32s   3 OK / 3     True
```

## 步骤二：创建Cronjob事件源

Knative预先安装了定时事件源类型CronJobSource，可以用这个事件源来定时发送事件消息。

1. 创建Cronjob事件源

    我们先来看一下`cronjob.yaml`的内容，这里描述了定时事件源的配置信息：
    ```text
    cat cronjob.yaml
    ```

    期待输出：
    ```
    apiVersion: sources.eventing.knative.dev/v1alpha1
    kind: CronJobSource
    metadata:
    name: cronjobs
    spec:
      schedule: "*/1 * * * *"
      data: "{\"message\": \"Hello world!\"}"
      sink:
        apiVersion: serving.knative.dev/v1alpha1
        kind: Service
        name: event-display
    ```

    可以看到，它的`spec`主要包含三部分内容：
    - schedule: 定时任务的周期，这里`"*/1 * * * *"`表示为定时1分钟。
    - data: 定义了事件消息中数据部分的内容。CloudEvent标准消息将包括这个数据，将从事件源发送出去。
    - sink: 定义了事件数据传送的目的地，这里可以看到是Knative服务 `event-display`，也就是我们刚才创建的服务。

    通过下面命令创建事件源`cronjobs`:

    ```text
    kubectl apply -f cronjob.yaml
    ```

    期待输出：
    ```
    cronjobsource.sources.eventing.knative.dev/cronjobs created
    ```
    
2. 检查该事件源已经被创建:

    ```text
    kubectl get cronjobsource
    ```

    期待输出：
    ```
    NAME       AGE
    cronjobs   44s
    ```

## 步骤三：检查event-display的日志

事件源`cronjobs`每隔1分钟，就会发送一条事件给`event-display`，`event-display`将把它打印到日志中。在这个逻辑的背后，是两个Kubernetes Pod在运行。

1. 查看运行Pod

    下面命令将列出所有运行的Pod：
    ```
    kubectl get pods
    ```

    期待输出：
    ```
    NAME                                              READY   STATUS    RESTARTS   AGE
    cronjob-cronjobs-tlzm9-7d4f79bbc8-krb8q           1/1     Running   0          98s
    event-display-46hhp-deployment-597487d855-7ctj5   2/2     Running   0          37s
    ```

    其中，`cronjob-cronjobs-`为前缀的Pod，就是定时事件源，而`event-display-`为前缀的Pod，则是事件消息的展示应用。

2. 查看`event-display`的日志

    下面我们查看`event-display`的日志：
    ```
    kubectl logs -f $(kubectl get pods --selector=serving.knative.dev/configuration=event-display --output=jsonpath="{.items..metadata.name}") user-container
    ```

    能看到日志显示的CloudEvent标准消息如下面所示：
    ```
    _  CloudEvent: valid _
    Context Attributes,
    SpecVersion: 0.2
    Type: dev.knative.cronjob.event
    Source: /apis/v1/namespaces/default/cronjobsources/cronjobs
    ID: 1e269ba0-114f-41d6-a889-dcdebaa0a73d
    Time: 2019-06-20T14:23:00.000371555Z
    ContentType: application/json
    Transport Context,
    URI: /
    Host: event-display.default.svc.cluster.local
    Method: POST
    Data,
    {
        "message": "Hello world!"
    }
    ```
    这说明了`cronjobs`创建后，定时产生CloudEvent标准格式的事件消息，这个消息被`event-display`接收并打印在日志中。

    观察完毕，使用`ctrl + c`结束进程。

## 步骤四：删除事件源

现在我们先删除`cronjobs`，因为接下来的实验我们将采用其他方法管理事件和订阅：

```
kubectl delete -f cronjob.yaml
```

期待输出：
```
cronjobsource.sources.eventing.knative.dev "cronjobs" deleted
```

`event-display`并没有删除，我们还将在下面的实验中用到它。但因为它是Serverless的服务，一段时间不被调用将会被平台自动收回。

```
kubectl get pods
```

可能的输出：
```
NAME                                              READY   STATUS    RESTARTS   AGE
event-display-rpxcz-deployment-58676c965b-2j6jl   2/2     Running   0          3m46s
```
或者
```
NAME                                              READY   STATUS        RESTARTS   AGE
event-display-rpxcz-deployment-58676c965b-2j6jl   2/2     Terminating   0          4m14s
```
或者
```
No resources found.
```

继续 [exercise 2](./exercise-2.md).